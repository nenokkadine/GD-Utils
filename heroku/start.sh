#!/bin/bash
wget -q https://github.com/nenokkadine/gdutils/releases/latest/download/gdutils.tar.gz && tar -xzf gdutils.tar.gz && rm -rf gdutils.tar.gz
chmod a+x copy count dedupe md5
mkdir /out
wget -q https://github.com/nenokkadine/GD-Utils/raw/master/src/gdutils -O /usr/bin/gdutils && chmod a+x /usr/bin/gdutils
wget -q https://github.com/nenokkadine/GD-Utils/raw/master/src/SetWebhook -O /usr/bin/SetWebhook && chmod a+x /usr/bin/SetWebhook && SetWebhook
#Caddy
wget -q https://github.com/caddyserver/caddy/releases/download/v2.3.0/caddy_2.3.0_linux_amd64.tar.gz -O cad.tar.gz && tar xzf cad.tar.gz && rm -rf cad.tar.gz && chmod a+x caddy && mv caddy /usr/bin/caddy
#Service Accounts
if [[ -n $GH_USER && -n $GH_AUTH_TOKEN && -n $GH_REPO ]]; then
	echo "Usage of Service Accounts (Git), Clonning git"
	git clone -q https://"$GH_AUTH_TOKEN"@github.com/"$GH_USER"/"$GH_REPO" accounts
    	mv accounts/*.json sa/
	rm -rf accounts
elif [[ -n $SA_ZIP ]]; then
	echo "Usage of Service Accounts (Zip URL), Downloading"
	wget -q $SA_ZIP -O accounts.zip
    	unzip -qq accounts.zip
    	mv accounts/*.json sa/
	rm -rf accounts
else
	echo "Neither Service Accounts Nor Token Provided. Exiting..."
	exit 0
fi

# Config
if [[ -n "$BOT_TOKEN" && -n "$AUTH_CHATS" ]]; then
	wget -qO- https://gist.github.com/nenokkadine/433284483b9df4e73dfcb90d4310bd65/raw/9d743d207020cc88ef5c72caa0cc2a9c5c2a27af/config.js | sed -e "s/\$BOT_TOKEN/$BOT_TOKEN/g" -e "s/\$AUTH_CHATS/$AUTH_CHATS/g" > config.js
else
	echo "Bot Token, Auth Chats not Provided Exiting , For Info Read Readme"
	exit 0
fi
#Start GDutils Server
node server.js &

# HTTPS Auth
if [[ -n "$HTTP_USER" && -n "$HTTP_PASS" ]]; then
	wget -qO- https://gist.github.com/nenokkadine/5db0fff9216fcedc0dd5862d0a5ab864/raw/95cabcaaf776e47ebb1990b2583f443171cf742a/caddyauth | sed -e "s/\$HTTP_USER/$HTTP_USER/g" -e "s/\$HASHPASS/$(caddy hash-password --plaintext $HTTP_PASS)/g" > /Caddyfile
else
	wget -q https://gist.github.com/nenokkadine/5db0fff9216fcedc0dd5862d0a5ab864/raw/95cabcaaf776e47ebb1990b2583f443171cf742a/caddynoauth -O /Caddyfile
fi

#Terminal over Web
wget -q https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64 -O ttyd && chmod a+x ttyd
./ttyd -i /usr/ttyd.sock -a -s 9 -b /bash -P 1 -t disableLeaveAlert=true -t rendererType=webgl -t titleFixed='Web Terminal' bash &
cd ..
# Caddy Run
wget -q https://github.com/nenokkadine/gdutils/raw/master/assets/html.zip -O assets.zip && unzip -qq /assets.zip && rm -rf /assets.zip
caddy run --config /Caddyfile
