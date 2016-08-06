# Description:
#  Quote Board Interface
#
# Dependencies:
#  None
#
# Commands:
#  !quote <name> said <quote> - Adds that quote attributed to that person to the DB
#  !quote_me_as <name> - Adds <name> to be your full name for quotes attributed to you
#
# Notes:
#  None
#
# Author:
#  @murph33

QUOTE_URL = process.env.HUBOT_QUOTEBOARD_QUOTE_URL or "https://quote-board.herokuapp.com/api/v1/quotes"
PERSON_URL = process.env.HUBOT_QUOTEBOARD_PERSON_URL or "https://quote-board.herokuapp.com/api/v1/people"

module.exports = (robot) ->
  robot.respond /quote_me_as (.*)/i, (msg) ->
    data =
      person:
        slack_name: "@#{msg.message.user.name}"
        full_name: msg.match[1]
    data = JSON.stringify(data)
    msg.http(PERSON_URL)
      .header('Content-Type', 'application/json')
      .post(data) (err, res, body) ->
        msg.send('It worked!') if res.statusCode is 201
        msg.send('It did not work') if res.statusCode is 400
  robot.respond /quote (.*?) said (.*)/i, (msg) ->
    data =
      quote:
        quoted_person: msg.match[1]
        body: msg.match[2]
    data = JSON.stringify(data)
    msg.http(QUOTE_URL)
      .header('Content-Type', 'application/json')
      .post(data) (err, res, body) ->
        msg.send("It worked!") if res.statusCode is 201
        msg.send("It didn't work") if res.statusCode is 400
