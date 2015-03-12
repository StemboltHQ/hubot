# Description:
#   Gets the bigwheel features
#
# Commands:
#   hubot bigwheel - Get today's meat & bread menu

Cheerio = require("cheerio")

url = "http://bigwheelburger.com/"

module.exports = (robot) ->
  robot.respond /bigwheel/i, (msg) ->
    msg.http(url).get() (err, res, body) ->
      $ = Cheerio.load(body)
      response = $('.featuredpage').text().trim()
      msg.send(response)
