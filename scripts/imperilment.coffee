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

class Message
  @getter 'color', -> imperilment_color
  @getter 'fallback', ->
    """
    #{@pretext}
    > *#{@title}*
    > #{@text}
    > #{@title_link}
    """

class NewAnswerMessage extends Message
  constructor: (data) ->
    @answer = data.answer
  @getter 'pretext',    -> 'New Imperilment clue!'
  @getter 'title',      -> "#{@answer.category.name} for $#{@answer.amount}"
  @getter 'title_link', -> "#{@answer.url}"
  @getter 'text',       -> "#{@answer.answer}"

class AllInMessage extends Message
  @getter 'pretext',    -> 'Time to reveal Imperilment!'
  @getter 'title',      -> 'Leaderboard'
  @getter 'title_link', -> "#{leaderboard_url}"
  @getter 'text',       -> 'Everyone who has registered their email is in.'

module.exports = (robot) ->
  isDM = (msg) ->
    msg.message.room == msg.message.user.name

  tooManyOut = (waiting_on) ->
    created_at = robot.brain.get('lastQuestionCreatedAt') || new Date(0)
    hours_since = (new Date - created_at) / 3600
    waiting_on.length > 2 ^ hours_since

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

  eventActions =
    answer:
      new: (room, data) ->
        robot.brain.set('lastQuestionCreatedAt', new Date)
        robot.emit 'slack-attachment',
          channel: room
          content: new NewAnswerMessage(data)

    question:
      new: (room, data) ->
        return if isMonday()
        everyoneIsIn = ->
          robot.brain.set('everyoneIsIn', true)
          robot.emit 'slack-attachment',
            channel: room
            content: new AllInMessage
        getPendingUsers (waiting_on) ->
          if _.isEmpty(waiting_on)
            everyoneIsIn() unless robot.brain.get('everyoneIsIn')
          else
            robot.brain.set('everyoneIsIn', false)

  robot.router.post '/hubot/imperilment/:room', (req, res) ->
    room = req.params.room
    data = req.body
    eventType = data.type
    action = data.action
    try
      eventActions[eventType][action](room, data)
      res.send({ message: 'success' })
    catch err
      robot.messageRoom(room, "Received a #{action} #{eventType} from Imperilment.")
      robot.emit 'error', err
      res.status(500).send({ error: err })

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
      if tooManyOut(waiting_on)
        msg.reply("We're still waiting on #{waiting_on.length} people, let's give them a minute.")
        return robot.send({room: msg.message.user.name }, response)
      if tooOften()
        msg.reply('Easy on the channel spam!')
        return robot.send({room: msg.message.user.name }, response)
      robot.brain.set('lastAskedWhoIsIn', new Date)
      msg.send(response)
