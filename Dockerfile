FROM node:7-alpine

RUN npm install -g coffee-script bower

WORKDIR /app

ADD package.json .
RUN npm install

ADD . .
RUN coffee -c .
