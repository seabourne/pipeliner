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
			@instance._pop (ret) ->
				ret.should.equal object
				done()

	describe "process", (done) ->
		it "should process all", (done) ->
			@instance.push {x: 1}
			@instance.push {x: 2}
			count = 0
			@instance.process (doc) ->
				count += 1
				if count is 3
					done()
			@instance.push {x: 3}

	describe "purge", ->
		it "should empty queue", ->
			@instance.push {x: 1}
			@instance.purge()
			@instance.on 'purge', ->
				@instance._pop (ret) ->
					should.eql ret, null
