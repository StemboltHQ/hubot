# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   FILE_BRAIN_PATH
#
# Commands:
#   None
#
# Author:
#   dustyburwell

fs   = require 'fs'
path = require 'path'

module.exports = (robot) ->
  brainPath = process.env.FILE_BRAIN_PATH or '/var/hubot'
  brainPath = path.join brainPath, 'brain-dump.json'

  try
    robot.logger.info "loading brain from #{brainPath}"
    data = fs.readFileSync brainPath, 'utf-8'
    if data
      robot.brain.mergeData JSON.parse(data)
  catch error
      console.log('Unable to read file', error) unless error.code is 'ENOENT'

  robot.brain.on 'save', (data) ->
    robot.logger.info "saving brain to #{brainPath}"
    fs.writeFileSync brainPath, JSON.stringify(data), 'utf-8'
    robot.logger.info "save complete"
