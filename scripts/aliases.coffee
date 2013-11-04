hubot = require 'hubot'

module.exports = (robot) ->
  robot.respond /build (.*)$/, (msg) ->
    build = new hubot.TextMessage(
      msg.message.user,
      "!jenkins build #{msg.match[1]}"
    )
    robot.receive build
