# Description:
#   Lovely Jenkins integration for Hubot.
#
# Commands:
#   hubot jenky build - trigger configured master build on Jenkins
#   hubot jenky config - print the current channel config
#   hubot jenky config <prefix> <name> - add default prefix and possibly a name for a channel
#   hubot jenky deploy - trigger configured production build on Jenkins
#   hubot jenky package - trigger configured package build on Jenkins
#   hubot jenky stage - trigger configured staging build on Jenkins
#   hubot jenky status - show build pipeline status based on config
#   hubot jenky status <prefix> - show build pipeline status for the provided prefix
#   hubot jenky trigger <build> - trigger build on Jenkins

Moment = require('moment')

class Jenky
  BUILDS = ["master", "package", "staging", "production"]
  URL = process.env.HUBOT_JENKINS_URL

  constructor: (@prefix, @name = null) ->
    @name ||= @prefix

  status: (@msg) ->
    @build_responses = {}
    @build_count = 0
    for build in BUILDS
      fetchBuild.call(@, build)

  trigger: (@msg, build = null) ->
    path = triggerBuildPath.call(@, build)
    req = jenkinsRequest.call(@, path)
    req.post() (err, res, body) =>
      build_message = if build then "*#{build}* " else ""
      if res.statusCode is 201
        @msg.reply "#{build_message}build started for #{@name}"
      else
        @msg.reply "Unable to start #{build_message}build for #{@name}"

  displayBuilds = ->
    response = "*#{@name} Pipeline Status*" + "\n"
    for build in BUILDS
      continue if !@build_responses[build]
      response += @build_responses[build]
    @msg.send(response)

  fetchBuild = (build) ->
    path = buildInfoPath.call(@, build)
    req = jenkinsRequest.call(@, path)
    req.get() (err, res, body) =>
      if res.statusCode is 200
        content = JSON.parse(body)

        sha = buildSha(content.actions)
        status = if content.building then "building" else content.result.toLowerCase()
        date = Moment(content.timestamp).format('MMMM Do YYYY [at] h:mma')

        @build_responses[build] = "> :#{status}: `#{sha}` *#{build}* on #{date}\n"
      else
        @build_responses[build] = null

      @build_count += 1
      displayBuilds.call(@) if @build_count == BUILDS.length

  # Find SHA1 in API because it is terrible.
  buildSha = (actions) ->
    last_build = (a.lastBuiltRevision for a in actions when a.lastBuiltRevision?)[0]
    last_build["SHA1"][0..6]

  buildInfoPath = (build) ->
    "#{URL}/job/#{@prefix}-#{build}/lastBuild/api/json"

  triggerBuildPath = (build = null) ->
    path = "#{URL}/job/#{@prefix}"
    path += "-#{build}" if build
    path += "/build"

  jenkinsRequest = (path) ->
    req = @msg.http(path)
    if auth = authString()
      req.headers Authorization: "Basic #{auth}"
    req.header('Content-Length', 0)
    req

  authString = ->
    if process.env.HUBOT_JENKINS_AUTH
      new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')

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

  robot.respond /jenky status$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      jenky = new Jenky config.prefix, config.name
      jenky.status(msg)

  robot.respond /jenky status (.*)$/i, (msg) ->
    jenky = new Jenky msg.match[1].trim().toLowerCase()
    jenky.status(msg)

  robot.respond /jenky trigger (.*)$/i, (msg) ->
    jenky = new Jenky msg.match[1]
    jenky.trigger(msg)

  robot.respond /jenky build$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      jenky = new Jenky config.prefix, config.name
      jenky.trigger(msg, 'master')

  robot.respond /jenky package$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      jenky = new Jenky config.prefix, config.name
      jenky.trigger(msg, 'package')

  robot.respond /jenky stage$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      jenky = new Jenky config.prefix, config.name
      jenky.trigger(msg, 'staging')

  robot.respond /jenky deploy$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      jenky = new Jenky config.prefix, config.name
      jenky.trigger(msg, 'production')

  robot.respond /jenky config$/i, (msg) ->
    withJenkyConfig msg, (config) ->
      response = "Jenky configured to use prefix: `#{config.prefix}` "
      response += "and name: *#{config.name}*" if config.name
      msg.send(response)

  robot.respond /jenky config ([A-z\-]*)\s*(.*)$/i, (msg) ->
    opts = getBrain()

    room = msg.message.room
    prefix = msg.match[1].trim().toLowerCase()
    name = msg.match[2].trim()

    opts[room] = {prefix: prefix, name: name}

    robot.brain.set('jenky', opts)

    response = "Using Jenky prefix: `#{prefix}` "
    response += "and name: *#{name}* " if name
    response += "for channel ##{room}"

    msg.send(response)
