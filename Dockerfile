############################################################
# Dockerfile file to build Hubot container images
# AUTHOR: andrew <yu.yang2@hpe.com>
############################################################

FROM ubuntu:latest
MAINTAINER andrew <yu.yang2@hpe.com>
ENV http_proxy=http://proxy.houston.hpecorp.net:8080 https_proxy=http://proxy.houston.hpecorp.net:8080

# set environment
ENV HUBOT_NAME=yubot
ENV HUBOT_ADAPTER=flowdock
ENV HUBOT_DESCRIPTION=$HUBOT_NAME-$HUBOT_ADAPTER
# ENV HUBOT_FLOWDOCK_TOKEN=
RUN apt-get update && apt-get install -y build-essential curl


RUN apt-get install -y supervisor
ADD supervisor/ /etc/supervisor/conf.d/
VOLUME ["/log/supervisor"]
CMD exec supervisord -n
RUN useradd -d /opt/hubot -m -s /bin/bash -U hubot; \
    echo "hubot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN curl --silent --location https://deb.nodesource.com/setup_0.12 | bash - && apt-get install -y nodejs
RUN npm install -g  yo generator-hubot 

VOLUME ["/log/hubot"]
EXPOSE 5555

# Create Hubot
USER hubot
WORKDIR /opt/hubot
RUN npm config set proxy=http://proxy.houston.hpecorp.net:8080 && \
    yo hubot --name $HUBOT_NAME \
             --description $HUBOT_DESCRIPTION \
             --adapter $HUBOT_ADAPTER \
             --defaults \
    && npm install hubot-$HUBOT_ADAPTER --save 

ADD hubot/*.json /opt/hubot/
ADD hubot/hubot.env /opt/hubot/

RUN npm install

USER root
WORKDIR /

