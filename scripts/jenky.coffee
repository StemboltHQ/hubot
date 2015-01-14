# Description:
#   Lovely Jenkins integration for Hubot.
#
# Commands:
#   hubot jenky status <option> - show build pipeline status

Moment = require('moment')

URL = process.env.HUBOT_JENKINS_URL
BUILDS = ["master", "package", "staging", "production"]

authString = ->
  if process.env.HUBOT_JENKINS_AUTH
    new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')

class Jenky
  constructor: (@prefix, @name = null) ->
    @name ?= @prefix
    @response = "*#{@name} Pipeline Status*" + "\n"
    @build_responses = {}
    @build_count = 0

  status: (msg) ->
    @msg = msg
    for build in BUILDS
      @fetchBuild(build)

  displayBuilds: ->
    for build in BUILDS
      continue if !@build_responses[build]
      @response += @build_responses[build]
    @msg.send(@response)

  fetchBuild: (build) =>
    path = "#{URL}/job/#{@prefix}-#{build}/lastBuild/api/json"
    req = @msg.http(path)
    if auth = authString()
      req.headers Authorization: "Basic #{auth}"

    req.get() (err, res, body) =>
      try
        content = JSON.parse(body)

        sha = @buildSha(content.actions)
        status = if content.building then "building" else content.result.toLowerCase()
        date = Moment(content.timestamp).format('MMMM Do YYYY [at] h:mma')

        @build_responses[build] = "> :#{status}: `#{sha}` *#{build}* on #{date}\n"
      catch error
        @build_responses[build] = null
      finally
        @build_count += 1
        @displayBuilds() if @build_count == BUILDS.length

  # Find SHA1 in API because it is terrible.
  buildSha: (actions) ->
    last_build = (a.lastBuiltRevision for a in actions when a.lastBuiltRevision?)[0]
    last_build["SHA1"][0..6]

module.exports = (robot) ->
  unless process.env.HUBOT_JENKINS_URL?
    robot.logger.warning 'The HUBOT_JENKINS_URL environment variable is not set'
    return

  robot.respond /jenky status$/i, (msg) ->
    jenky = new Jenky "printbear-sm", "Sticker Mule"
    jenky.status(msg)

  robot.respond /jenky status (.*)$/i, (msg) ->
    jenky = new Jenky msg.match[1].trim().toLowerCase()
    jenky.status(msg)
