FROM node

ADD . /hubot
WORKDIR /hubot
RUN npm install
CMD bash start.sh
