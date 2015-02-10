# Description:
#   Gets the current picnic menu
#
# Commands:
#   hubot picnic - Get today's picnic menu

api_key = process.env.HUBOT_TUMBLR_API_KEY
url = "http://api.tumblr.com/v2/blog/picniccoffee.tumblr.com/posts/?api_key=#{api_key}"

Cheerio = require("cheerio")

module.exports = (robot) ->
  robot.respond /picnic/i, (msg) ->
    msg.http(url).get() (err, res, body) ->
      data = JSON.parse(body)
      post = data.response.posts[0]
      response = post.title + "\n"

      $ = Cheerio.load("<root>#{post.body}</root>")

      $('strong').each ->
        $(this).replaceWith("*#{$(this).text()}*")
      $('br').replaceWith("\n")
      $('p').each ->
        $(this).replaceWith("\n\n#{$(this).html()}\n\n")

      console.log($('root').text().trim())

      items = $('root').text().trim().split(/\n\n+/)
      for item in items
        response += item.trim().split(/\n+/).join(" - ") + "\n"

      msg.send(response)

