# Description:
#  Notice Board Generator
#
# Dependencies:
#  None
#
# Commands:
#  putting <name> on notice - Puts <name> on notice
#  hubot who is on notice - Show the notice board
#
# Notes:
#  None
#
# Author:
#  @jhawthorn

QS = require 'querystring'

generateImage = (msg, values) ->
  params = {'text[]': values}
  params = QS.stringify(params)
  msg.send(params)
  msg.http("http://colbert.herokuapp.com/generate").post(params) (err,res,body) ->
    location = res.headers.location
    msg.send(location)

module.exports = (robot) ->
  putOnNotice = (msg) ->
    target = msg.match[1]
    msg.send("ok, #{target} is on notice")
    list = robot.brain.data.onNotice || []
    list.push(target)
    list = list.slice(-10)
    robot.brain.data.onNotice = list

  robot.hear /putting (.+) on notice/i, (msg) ->
    putOnNotice(msg)

  robot.respond /on notice/i, (msg) ->
    generateImage(msg, robot.brain.data.onNotice)

