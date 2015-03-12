# Description:
#   Imperilment notifications via webhook
#
# Configuration:
#   1. Create a new webhook at:
#      http://<IMPERILMENT_URL>.com/web_hooks/new
#
#   2. Add the url: <HUBOT_URL>:<PORT>/hubot/imperilment/<room>
#
# Commands:
#   None
#
# URLS:
#   POST /hubot/imperilment/<room>
#
# Events:
#   - new answer created

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
