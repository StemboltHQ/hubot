FROM node

ADD . /hubot
WORKDIR /hubot
RUN npm install -g coffee
RUN npm install
CMD bash start.sh
