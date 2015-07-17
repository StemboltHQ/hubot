# Description:
#     Beers requests via slack
#
# Configuration:
#
# Commands:
#   hubot beer me some <beer>        create a request for <beer>
#   hubot what's( on) the beermenu   return a list of currently requested beers
#   hubot clear( all) beer orders    delete all beer requests
#
# URLS:

BASE_URL = "https://beerahoy.herokuapp.com/orders"

module.exports = (robot) ->

  robot.respond /beer(?: me)( some)? (\S.*)$/i, (msg) ->
    request_data = JSON.stringify({
      beer_id: "#{msg.match[2]}"
      employee: "#{msg.message.user.name}",
      format: 'json'
    })

    msg.http("#{BASE_URL}")
      .header('Content-Type', 'application/json')
      .post(request_data) (err, res, body) ->
        if res.statusCode isnt 201
          msg.send body
          return
        msg.reply "got your order!"

  robot.respond /what('s|s|)( on)? the( friday)?( beer\s?menu)/i, (msg) ->
    robot.http("#{BASE_URL}.json").get() (err, res, body) ->
       if res.statusCode isnt 200
         msg.send body
         return
       data = JSON.parse(body)

       requests = data.map (beer) ->
         return beer

       msg.send "Beers that have been requested: #{requests.join(', ')} #{BASE_URL}"

  robot.respond /clear( all)? beer\s?orders/i, (msg) ->
    robot.http("#{BASE_URL}/delete_all").delete() (err, res, body) ->
       if res.statusCode isnt 302
         msg.send body
         return
       msg.reply "Beer requests have been cleared!"
