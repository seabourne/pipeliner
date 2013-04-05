should = require 'should'
Queue = require '../lib/queue'

describe 'Queue', ->
	describe 'constructor', ->
		before (done) ->
			@instance = new Queue('test')
			done()
		it "should instantiate the object", ->
			@instance.should.be.ok
			@instance.should.be.instanceOf Queue
			@instance.should.have.property('name')

	describe "push", (done) ->
		before (done) ->
			@instance = new Queue('test')
			done()
		it "should push the object into the queue", (done) ->
			object = {some: "object"}
			@instance.push object
			@instance.pop (ret) ->
				ret.should.equal object
				done()

	describe "pop", (done) ->
		it.skip "should process one", (done) ->

	describe "process", (done) ->
		it.skip "should process all", (done) ->
