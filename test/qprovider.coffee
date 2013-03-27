should = require 'should'
QProvider = require '../lib/qprovider'

describe 'QProvider', ->
	describe '#constructor', ->
		it "should instantiate the object", ->
			instance = new QProvider()
			instance.should.be.ok
			instance.should.be.instanceOf QProvider

	describe "#push", (done) ->
		it "should push the object into the queue", (done) ->
			instance = new QProvider
			object = {some: "object"}
			instance.push object
			instance.pop (ret) ->
				ret.should.equal object
				done()