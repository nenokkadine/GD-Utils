FROM mhart/alpine-node:slim-12

LABEL maintainer="Nenokkadine"

#Dependencies
RUN apk update && \
    apk add --no-cache --update git \
                                curl \
                                wget \
                                tar \
                                unzip \
                                xz \
                                neofetch \
                                htop \
                                bash && \
    mkdir /gdutils
WORKDIR /gdutils
