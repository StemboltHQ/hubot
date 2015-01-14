# Description:
#   Convenient aliases
#
# Commands:
#   hubot build <build> - Triggers the jenkins build named <build>
#   hubot deploy <build> - Triggers the jenkins build named <build>-production

hubot = require 'hubot'

module.exports = (robot) ->
  trigger = (msg, build) ->
    message = new hubot.TextMessage(
      msg.message.user,
      "#{robot.name} jenkins build #{build}"
    )
    robot.receive message
  robot.respond /build (.*)$/, (msg) ->
    trigger msg, msg.match[1]
  robot.respond /package (.*)$/, (msg) ->
    trigger msg, "#{msg.match[1]}-package"
  robot.respond /stage (.*)$/, (msg) ->
    trigger msg, "#{msg.match[1]}-staging"
  robot.respond /deploy (.*)$/, (msg) ->
    trigger msg, "#{msg.match[1]}-production"
