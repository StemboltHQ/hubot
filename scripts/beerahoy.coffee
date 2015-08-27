# Description:
#   Beers requests via slack
#
# Dependencies:
#   None
#
# Configuration:
#   Beerahoy orders url:
#   BASE_URL= "https://beerahoy.herokuapp.com/orders"
#
# Commands:
#   hubot beer me (some) <beer>      create a request for <beer>
#   hubot beer orders                return a list of currently requested beers
#   hubot beer clear( orders)        delete all beer requests
#
# Author:
#   DariaSova

BASE_URL = "https://beerahoy.herokuapp.com/orders"

module.exports = (robot) ->

  robot.respond /beer(\s?me)( some)? (\S.*)$/i, (msg) ->
    request_data = JSON.stringify({
      beer_id: "#{msg.match[3]}"
      employee: "#{msg.message.user.name}",
      format: "json"
    })

    msg.http("#{BASE_URL}")
      .header('Content-Type', 'application/json')
      .post(request_data) (err, res, body) ->
        if res.statusCode isnt 201
          msg.send body
          return
        msg.reply "got your order!"

  robot.respond /beer\s?orders/i, (msg) ->
    robot.http("#{BASE_URL}.json").get() (err, res, body) ->
       if res.statusCode isnt 200
         msg.send body
         return
       data = JSON.parse(body)

       requests = data.map (beer) ->
         return beer

       msg.send "Beers that have been requested: #{requests.join(', ')} #{BASE_URL}"

  robot.respond /beer clear( orders)?/i, (msg) ->
    robot.http("#{BASE_URL}/delete_all").delete() (err, res, body) ->
       if res.statusCode isnt 302
         msg.send body
         return
       msg.reply "Beer requests have been cleared!"
