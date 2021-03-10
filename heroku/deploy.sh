#!/bin/bash
if [[ -n "$HEROKU_EMAIL" && -n "$HEROKU_API_KEY" ]]; then
	sed -Ei "s/login/login "$HEROKU_EMAIL"/g" .netrc
	sed -Ei "s/password/password "$HEROKU_API_KEY"/g" .netrc
	mv .netrc ~/.netrc
else
	echo "Heroku Credentials Not Found, Add them in secrets"
	exit 2
fi

if [[ -n "$REGION" && -n "$HEROKU_APP" ]]; then
	heroku container:login
	echo "Creating App"
	heroku apps:create "$HEROKU_APP" --stack=container --region=eu
	if [[ $? -eq 0 ]]; then
		echo "Successfully created app"
		heroku container:push web -a "$HEROKU_APP"
		if [[ $? -eq 0 ]]; then
			echo "Deploying"
			heroku container:release web -a "$HEROKU_APP"
			if [[ $? -eq 0 ]]; then
				export APP_SUC=true
				echo "Deployment Success"
			else
				echo "Failed to Release, Try again"
				exit 2
			fi
		else
			echo "Failed to deploy, Try again"
			exit 2
		fi
	else
		echo "Could not create app, Trying to push to Registry"
		echo "Building and pushing the app to Heroku Registry"
		heroku container:push web -a "$HEROKU_APP"
		if [[ $? -eq 0 ]]; then
			echo "Deploying"
			heroku container:release web -a "$HEROKU_APP"
			if [[ $? -eq 0 ]]; then
				export APP_SUC=true
				echo "Deployment Success"
			else
				echo "Container Release Failed"
				exit 2
			fi
		else
			echo "App Name is not available, Please select another"
			exit 2
		fi
	fi
elif [[ -n "$HEROKU_APP" ]]; then
	heroku container:login
	echo "Creating App"
	heroku apps:create "$HEROKU_APP" --stack=container
	if [[ $? -eq 0 ]]; then
		echo "Successfully created app"
		heroku container:push web -a "$HEROKU_APP"
		if [[ $? -eq 0 ]]; then
			echo "Deploying"
			heroku container:release web -a "$HEROKU_APP"
			if [[ $? -eq 0 ]]; then
				export APP_SUC=true
				echo "Deployment Success"
			else
				echo "Failed to Release, Try again"
				exit 2
			fi
		else
			echo "Failed to deploy, Try again"
			exit 2
		fi
	else
		echo "Could not create app, Trying to push to Registry"
		echo "Building and pushing the app to Heroku Registry"
		heroku container:push web -a "$HEROKU_APP"
		echo "Deploying"
		if [[ $? -eq 0 ]]; then
			heroku container:release web -a "$HEROKU_APP"
			if [[ $? -eq 0 ]]; then
				export APP_SUC=true
				echo "Deployment Success"
			else
				echo "Container Release Failed"
				exit 2
			fi
		else
			echo "App Name is not available, Please select another"
			exit 2
		fi
	fi
else 
	echo "Heroku App name Not Provided"
fi


echo "Setting Config Vars"
if [[ -n "$APP_SUC" ]]; then
    # Service Accounts
	if [[ -n "$SA_ZIP" ]]; then
		heroku config:set -a "$HEROKU_APP" SA_ZIP="$SA_ZIP"
	elif [[ -n "$GH_REPO" && -n "$GH_USER" && -n "$GH_AUTH_TOKEN" ]]; then
		heroku config:set -a "$HEROKU_APP"  GH_REPO="$GH_REPO" GH_USER="$GH_USER" GH_AUTH_TOKEN="$GH_AUTH_TOKEN"	
	else
		echo "Provide Some way to get Service Accounts,for Reference check README"
		exit 2
	fi

	#Basic Auth
	if [[ -n "$HTTP_USER" && -n "$HTTP_PASS" ]]; then
		heroku config:set -a "$HEROKU_APP" HTTP_USER="$HTTP_USER" HTTP_PASS="$HTTP_PASS"
	else
		echo "No AUTH Variables provided, HTTP Basic Auth Disabled"
	fi
	
	#Config File
	if [[ -n "$BOT_TOKEN" && -n "$AUTH_CHATS" ]]; then
		heroku config:set -a "$HEROKU_APP" BOT_TOKEN="$BOT_TOKEN" AUTH_CHATS="$AUTH_CHATS" APP_NAME="$HEROKU_APP"
		heroku ps:scale web=1 -a "$HEROKU_APP"
	else
		echo "Bot Token, Auth Chats not Provided Exiting , For Info Read Readme"
		exit 2
	fi
	echo "Deployment Completed"
else
	echo "App Deployment Failed"
	exit 1
fi