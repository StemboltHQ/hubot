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
      response = ""
      $ = Cheerio.load(body)
      $('span.menu-item').each ->
        item = $(this).text()
        if /Special|Soup|Salad/.test(item)
          [title, info] = item.split(':')
          response += "*#{title}* - #{info.trim()}\n"

      msg.send(response)
