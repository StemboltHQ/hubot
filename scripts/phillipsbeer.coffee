# Description:
#   Gets today's growlers
#
# Commands:
#   hubot growlers - Get today's growlers

Cheerio = require("cheerio")

url = "https://phillipsbeer.com/growlers/"

module.exports = (robot) ->
  robot.respond /growlers/i, (msg) ->
    msg.http(url).get() (err, res, body) ->
      $ = Cheerio.load(body)
      response = $('.beer-name').map(->$(@).text()).get().join("\n")
      msg.send(response)
