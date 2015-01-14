# Description:
#   Lovely Jenkins integration for Hubot.
#
# Commands:
#   hubot jenky status <option> - show build pipeline status

Moment = require('moment')

URL = process.env.HUBOT_JENKINS_URL
AUTH = new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')
BUILDS = ["master", "package", "staging", "production"]

class Jenky
  constructor: (@prefix, @name = null) ->
    @name ?= @prefix
    @response = "*#{@name} Pipeline Status*" + "\n"
    @build_responses = {}
    @build_count = 0

  displayBuilds: (msg) ->
    for build in BUILDS
      @response += @build_responses[build]
    msg.send(@response)

  fetchBuild: (msg, build) =>
    path = "#{URL}/job/#{@prefix}-#{build}/lastBuild/api/json"
    req = msg.http(path)
    req.headers Authorization: "Basic #{AUTH}"

    req.get() (err, res, body) =>
      content = JSON.parse(body)

      build = content.fullDisplayName.match(///#{@prefix}-([a-z]*)///)[1]
      sha = content.fullDisplayName.match(/#([0-9a-z]*)/)[1]
      status = if content.building then "BUILDING" else content.result
      date = Moment(content.timestamp).format('MMMM Do YYYY [at] h:mma')

      @build_responses[build] = "> *#{build}* `#{sha}` #{status} on #{date}\n"
      @build_count += 1
      @displayBuilds(msg) if @build_count == BUILDS.length

module.exports = (robot) ->
  robot.respond /jenky status$/i, (msg) ->
    jenky = new Jenky "printbear-sm", "Sticker Mule"
    for build in BUILDS
      jenky.fetchBuild(msg, build)

  robot.respond /jenky status (.*)$/i, (msg) ->
    jenky = new Jenky msg.match[1].trim().toLowerCase()
    for build in BUILDS
      jenky.fetchBuild(msg, build)
