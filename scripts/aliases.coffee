# Description:
#   Convenient aliases
#
# Commands:
#   hubot build <build> - Triggers the jenkins build named <build>
#   hubot deploy <build> - Triggers the jenkins build named <build>-production

Hubot = require('hubot')

module.exports = (robot) ->
  trigger = (msg, build) ->
    message = new Hubot.TextMessage(
      msg.message.user,
      "#{robot.name} jenky trigger #{build}"
    )
    robot.receive message
  robot.respond /build (.*)$/, (msg) ->
    trigger msg, msg.match[1]
  robot.respond /deploy (.*)$/, (msg) ->
    trigger msg, "#{msg.match[1]}-production"
