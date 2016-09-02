# Description:
#   Gets today's growlers
#
# Commands:
#   hubot growlers - Get today's growlers

Cheerio = require("cheerio")

phillips = (msg) ->
  url = "https://phillipsbeer.com/growlers/"
  msg.http(url).get() (err, res, body) ->
    $ = Cheerio.load(body)
    fills = $('.beer-name').map(->$(@).text()).get().join("\n")
    msg.send("*Phillips*:\n#{fills}")

driftwood = (msg) ->
  url = "https://driftwoodbeer.com/contact/"

  msg.http(url).get() (err, res, body) ->
    $ = Cheerio.load(body)
    getName = () -> $(@).children().remove().end().text().trim()
    fills = $(".growler-fill li:not(.note)").map(getName).get().join("\n")
    msg.send("*Driftwood*:\n#{fills}")

module.exports = (robot) ->
  robot.respond /growlers/i, (msg) ->
    phillips(msg)
    driftwood(msg)
