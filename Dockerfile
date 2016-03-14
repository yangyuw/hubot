############################################################
# Dockerfile file to build Hubot container images
# AUTHOR: andrew <yu.yang2@hpe.com>
############################################################

# Pull base image.
FROM node:latest
MAINTAINER andrew <yu.yang2@hpe.com>
ENV http_proxy=http://proxy.houston.hpecorp.net:8080 https_proxy=https://proxy.houston.hpecorp.net:8080

# set environment
ENV HUBOT_NAME=hubot
ENV HUBOT_ADAPTER=flowdock
ENV HUBOT_DESCRIPTION=$HUBOT_NAME-$HUBOT_ADAPTER
# ENV HUBOT_FLOWDOCK_TOKEN=
RUN apt-get update && apt-get install -y build-essential curl

# install redis
RUN apt-get install -y redis-server
ADD redis/redis.conf /etc/redis/
VOLUME ["/log/redis", "/data/redis"]

# install supervisor
RUN apt-get install -y supervisor
ADD supervisor/ /etc/supervisor/conf.d/
VOLUME ["/log/supervisor"]
CMD exec supervisord -n

# Install CoffeeScript, Hubot
RUN npm install -g hubot coffee-script yo generator-hubot \
    && useradd -m -s /bin/bash hubot
VOLUME ["/log/hubot"]
EXPOSE 5555

# Create Hubot
USER hubot
WORKDIR /home/hubot
RUN yo hubot --name $HUBOT_NAME \
             --description $HUBOT_DESCRIPTION \
             --adapter $HUBOT_ADAPTER \
             --defaults \
    && npm install hubot-$HUBOT_ADAPTER --save \
    && sed -i -r 's/^\s+#//' scripts/example.coffee

ADD hubot/*.json /opt/hubot/
ADD hubot/hubot.env /opt/hubot/
ADD hubot/scripts/ /opt/hubot/scripts/

RUN npm install

USER root
WORKDIR /
