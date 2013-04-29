should = require 'should'

lib = require '../index'

describe 'lib', ->
		it "should get an object back", ->
			lib.should.have.property('Pipeliner')
			lib.should.have.property('Queue')
			lib.should.have.property('RedisQueue')
