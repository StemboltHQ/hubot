# Description:
#   Lovely Jenkins integration for Hubot.
#
# Commands:
#   hubot jenky status <option> - show build pipeline status
#   hubot jenky trigger <build> - trigger build on Jenkins
#   hubot jenky build - trigger configured master build on Jenkins
#   hubot jenky package - trigger configured package build on Jenkins
#   hubot jenky stage - trigger configured staging build on Jenkins
#   hubot jenky deploy - trigger configured production build on Jenkins
#   hubot jenky config <prefix> <name> - add default prefix and possibly a name for a channel

Moment = require('moment')
Hubot = require 'hubot'

URL = process.env.HUBOT_JENKINS_URL
BUILDS = ["master", "package", "staging", "production"]

authString = ->
  if process.env.HUBOT_JENKINS_AUTH
    new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')

class Jenky
  constructor: (@prefix, @name = null) ->
    @name = if !!@name then @name else @prefix
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
      if res.statusCode is 200
        content = JSON.parse(body)

        sha = @buildSha(content.actions)
        status = if content.building then "building" else content.result.toLowerCase()
        date = Moment(content.timestamp).format('MMMM Do YYYY [at] h:mma')

        @build_responses[build] = "> :#{status}: `#{sha}` *#{build}* on #{date}\n"
      else
        @build_responses[build] = null

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

  getBrain = ->
    robot.brain.get('jenky') || {}

  withJenkyConfig = (msg, callback) ->
    config = getBrain()[msg.message.room]
    if not config
      msg.send("No default Jenky prefix found for channel")
    else
      callback(config)

  triggerBuild = (msg, build) ->
    message = new Hubot.TextMessage(
      msg.message.user,
      "#{robot.name} jenkins build #{build}"
    )
    robot.receive message

  robot.respond /jenky status$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      jenky = new Jenky config.prefix, config.name
      jenky.status(msg)

  robot.respond /jenky status (.*)$/i, (msg) ->
    jenky = new Jenky msg.match[1].trim().toLowerCase()
    jenky.status(msg)

  robot.respond /jenky trigger (.*)$/i, (msg) ->
    triggerBuild msg, msg.match[1]

  robot.respond /jenky build$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      triggerBuild msg, "#{config.prefix}-master"

  robot.respond /jenky package$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      triggerBuild msg, "#{config.prefix}-package"

  robot.respond /jenky stage$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      triggerBuild msg, "#{config.prefix}-staging"

  robot.respond /jenky deploy$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      triggerBuild msg, "#{config.prefix}-production"

  robot.respond /jenky config ([A-z\-]*)\s*(.*)$/i, (msg) ->
    opts = getBrain()

    room = msg.message.room
    prefix = msg.match[1].trim().toLowerCase()
    name = msg.match[2].trim()

    opts[room] = {prefix: prefix, name: name}

    robot.brain.set('jenky', opts)

    response = "Using Jenky prefix: `#{prefix}` "
    response += "and name: \"#{name}\" " if name
    response += "for channel #{room}"

    msg.send(response)
