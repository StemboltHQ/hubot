# Description:
#   Imperilment notifications via webhook
#
# Dependencies:
#   'lodash': '^3.6.0'
#
# Configuration:
#   1. Create a new webhook at:
#      http://<IMPERILMENT_URL>.com/web_hooks/new
#
#   2. Add the url: <HUBOT_URL>:<PORT>/hubot/imperilment/<room>
#
# Commands:
#   hubot who's not in                                         return a list of users with unanswered clues
#   hubot imperilment me as <email>                            remember your imperilment email is <email>
#
# URLS:
#   POST /hubot/imperilment/<room>
#
# Events:
#   - new answer created

_ = require('lodash')

leaderboard_url = "http://imperilment.freerunningtech.com/leader_board"
imperilment_color = '#229'
channelSpamDelay = 15 * 60 * 1000
isMonday = ->
  new Date().getDay() == 1

# So we can pass object-like classes to hubot's api
Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}

module.exports = (robot) ->
  isDM = (msg) ->
    msg.message.room == msg.message.user.name

  tooOften = ->
    lastAsked = robot.brain.get('lastAskedWhoIsIn') || new Date(0)
    new Date - lastAsked < channelSpamDelay

  usernameFromEmail = (email) ->
    user = _.find robot.brain.users(), (user) ->
      user.imperilmentEmail == email
    if user then user.name else null

  getPendingUsers = (cb) ->
    robot.http("#{leaderboard_url}.json").get() (err, res, body) ->
      game_results = JSON.parse(body)
      waiting_on = _.chain(game_results)
        .select (game_result) ->
          _.includes(game_result.results, 'unanswered')
        .pluck('user')
        .pluck('email')
        .map(usernameFromEmail)
        .compact()
        .value()
      cb(waiting_on)

  robot.respond /imperilment(?: me)? as (.*)$/i, (msg) ->
    email = msg.match[1]
    msg.message.user.imperilmentEmail = email
    msg.send "Okay, I'll remember your Imperilment email is #{email}"

  robot.respond /forget( me| my)? imperilment$/i, (msg) ->
    delete msg.message.user.imperilmentEmail
    msg.send "Okay, I'll no longer nag you about imperilment"

  robot.respond /who('s|s| is|se)? not in/i, (msg) ->
    if msg.message.user.name is 'senjai'
      return robot.send({room: msg.message.user.name }, "I'm sorry, I can't do that Richard.")
    getPendingUsers (waiting_on) ->
      if _.isEmpty(waiting_on)
        response = """
          Everyone is already in!
          See for yourself #{leaderboard_url}
          """
      else
        response = """
          We're still missing responses from #{waiting_on.join(', ')}
          """
      if isDM(msg)
        return robot.send { room: msg.message.user.name }, response
      if tooOften()
        msg.reply('Easy on the channel spam!')
        return robot.send({room: msg.message.user.name }, response)
      robot.brain.set('lastAskedWhoIsIn', new Date)
      msg.send(response)
