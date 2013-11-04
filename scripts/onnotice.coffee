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

mirrorImage = (msg, url) ->
  params = QS.stringify
    "key": "65aea9a07b4f6110c90248ffa247d41a"
    "image": url
  msg.http("http://api.imgur.com/2/upload.json")
    .headers
      "Content-type": "application/x-www-form-urlencoded"
    .post(params) (err, res, body) ->
      json = JSON.parse(body)
      url = json.upload.links.original
      msg.send url

generateImage = (msg, values) ->
  params = {}
  for i in [0..7]
    params["line#{i+1}"] = values[i] || "BEARS"
  params = QS.stringify(params)
  url = "http://www.shipbrook.net/onnotice/"
  msg.http(url)
    .headers
      "Content-type": "application/x-www-form-urlencoded"
    .post(params) (err, res, body) ->
      img = body.match(/src="([^"]+)"/)[1]
      mirrorImage msg, "#{url}#{img}"

getOnNoticeImage = (values) ->
  generateImage(values)

module.exports = (robot) ->
  putOnNotice = (msg) ->
    target = msg.match[1]
    msg.send("ok, #{target} is on notice")
    list = robot.brain.data.onNotice || []
    list.push(target)
    list = list.slice(-8)
    robot.brain.data.onNotice = list

  robot.hear /putting (.+) on notice/i, (msg) ->
    putOnNotice(msg)

  robot.respond /who is on notice/i, (msg) ->
    generateImage(msg, robot.brain.data.onNotice)

