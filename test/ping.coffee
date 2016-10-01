Helper = require('hubot-test-helper')
pingHelper = new Helper('../scripts/ping.coffee')

co     = require('co')
expect = require('chai').expect

describe 'ping', ->

  beforeEach ->
    @room = pingHelper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user says ping to hubot', ->
    beforeEach ->
      co =>
        yield @room.user.say 'alice', 'hubot ping'
        yield @room.user.say 'bob',   'hubot ping'

    it 'should reply to user', ->
      expect(@room.messages).to.eql [
        ['alice', 'hubot ping']
        ['hubot', 'PONG']
        ['bob',   'hubot ping']
        ['hubot', 'PONG']
      ]
