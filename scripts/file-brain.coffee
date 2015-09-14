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
  brainPathTmp = "#{brainPath}.tmp"

  try
    data = fs.readFileSync brainPath, 'utf-8'
    if data
      robot.brain.mergeData JSON.parse(data)
  catch error
      console.log('Unable to read file', error)

  robot.brain.on 'save', (data) ->
    json = JSON.stringify(data)
    fs.writeFileSync brainPathTmp, json, 'utf-8'
    fs.renameSync(brainPathTmp, brainPath)
