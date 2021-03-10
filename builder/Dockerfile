FROM mhart/alpine-node:12
RUN apk add --no-cache --update \
                            bash \
                            curl                         
RUN apk add --no-cache --virtual .build-deps make gcc g++ python3 && mkdir builder
COPY src builder
RUN cd builder && npm install && apk del .build-deps
