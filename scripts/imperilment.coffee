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

eventActions =
  answer:
    new: (data, callback) ->
      answer = data.answer
      callback """
      New Imperilment clue!
      > *#{answer.category.name}* for *$#{answer.amount}*
      >
      > #{answer.answer}
      #{answer.url}
      """

announceEvent = (eventType, action, data, cb) ->
  if eventActions[eventType]?[action]?
    eventActions[eventType][action](data, cb)
  else
    cb "Received a #{action} #{eventType} from Imperilment."

module.exports = (robot) ->

  usernameFromEmail = (email) ->
    user = _.find robot.brain.users(), (user) ->
      user.imperilmentEmail == email
    if user
      user.name
    else
      email

  robot.router.post '/hubot/imperilment/:room', (req, res) ->
    room = req.params.room
    eventType = req.headers['x-imperilment-event']
    data = req.body
    action = data.action

    try
      announceEvent eventType, action, data, (say) ->
        robot.messageRoom room, say
      res.send({ message: 'success' })
    catch err
      robot.emit 'error', err
      res.status(500).send({ error: err })

  robot.respond /imperilment(?: me)? as (.*)$/i, (msg) ->
    email = msg.match[1]
    msg.message.user.imperilmentEmail = email
    msg.send "Okay, I'll remember your Imperilment email is #{email}"

  robot.respond /who('s|s| is|se)? not in/i, (msg) ->
    msg.http("#{leaderboard_url}.json").get() (err, res, body) ->
      game_results = JSON.parse(body)
      waiting_on = _.chain(game_results).select (game_result) ->
        _.includes(game_result.results, 'unanswered')
      .pluck('user')
      .pluck('email')
      .map(usernameFromEmail)
      .value()
      if _.isEmpty(waiting_on)
        response = """
          Everyone is already in!
          See for yourself #{leaderboard_url}
          """
      else
        response = """
          We're still missing responses from #{waiting_on.join(' ')}
          """
      msg.send(response)
