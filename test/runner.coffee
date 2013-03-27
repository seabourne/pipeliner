should = require 'should'
Runner = require '../lib/runner'

QProvider = require '../lib/qprovider'

class TestQProvider
	

describe 'Runner', ->
	describe '#constructor', ->
		it "should save the passed qprovider to the internal var", ->
			qprovider = new TestQProvider
			instance = new Runner qprovider
			instance.qprovider.should.equal qprovider

		it "should create a default qprovider if one is not specified", ->
			instance = new Runner
			instance.qprovider.should.be.instanceOf QProvider