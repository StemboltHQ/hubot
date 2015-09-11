FROM node:4.0.0

ADD . /hubot
WORKDIR /hubot
RUN npm install -g coffee
RUN npm install
CMD bash start.sh
