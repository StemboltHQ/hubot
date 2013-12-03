# Description:
#  We are a _ company
#
# Dependencies:
#  None
#
# Commands:
#  we are a <type> company - Specify the <type> of company we are
#  hubot what kind of company are we
#
# Notes:
#  None
#
# Author:
#  @jhawthorn

module.exports = (robot) ->
  robot.hear /we (are not|aren't|are no longer) an? (.+) company/i, (msg) ->
    types = robot.brain.data.companyType || []
    types = (x for x in types when x != msg.match[2])
    robot.brain.data.companyType = types

  robot.hear /we are an? (.+) company/i, (msg) ->
    types = robot.brain.data.companyType ?= []
    if msg.match[1] not in types
      types.push(msg.match[1])

  robot.respond /what kind of company are we/i, (msg) ->
    types = robot.brain.data.companyType || []
    msg.send("We are a #{types.join(', ')} company")

