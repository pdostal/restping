FROM node

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --force-yes cron \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g coffee-script bower

ADD crontab /etc/cron.d/custom
RUN chmod +rx /etc/cron.d/custom
RUN touch /var/log/cron.log

WORKDIR /app

ADD package.json .
RUN npm install

ADD . .
RUN coffee -c .
