# Description:
#   Gets the current meat & bread menu
#
# Commands:
#   hubot meatandbread - Get today's meat & bread menu

Cheerio = require("cheerio")

url = "http://meatandbread.ca/yates-street/todays-menus/"

module.exports = (robot) ->
  robot.respond /meatandbread/i, (msg) ->
    msg.http(url).get() (err, res, body) ->
      response = "*Meat & Bread*\n"

      $ = Cheerio.load(body)
      $('span.menu-item').each ->
        item = $(this).text()
        if /Special|Soup|Salad/.test(item)
          response += "#{item}\n"

      msg.send(response)
