should = require 'should'
_ = require 'underscore'

Pipeliner = require '../lib/pipeliner'

queues = []

class TestQueue
	constructor: (name) ->
		@name = name
		@tasks = []

		queues[name] = @

	push: (task) ->
		@tasks.push task

	process: (callback) ->

	purge: ->
		@tasks = []

describe 'Pipeliner', ->
	describe "#constructor", ->
		it "takes a provider, returns an object", ->
			p = new Pipeliner(TestQueue)
			p.should.have.property('queue')

	describe "createFlow", ->
		before (done) ->
			@p = new Pipeliner(TestQueue)
			@tasks = [
				{name: 'input1'},
				{name: 'processor1'}
			]
			@p.createFlow 'test', @tasks
			done()

		it "creates queues for each task", ->
			_.keys(queues).should.eql _.map(@tasks, (t) -> 'test:'+t.name)

		it "keeps a reference to the flow", ->
			_.keys(@p.getFlows()).should.eql ['test']

	describe "trigger", ->
		it "should error for non-existent flows", ->
			(=>
				@p.trigger "nope", {}
			).should.throwError(/^Flow.*not defined/)

		it "should push to the input of the named flow", ->
			doc = {x: 'x'}
			@p.trigger "test", doc
			@p.flows['test'][0].queue.tasks.should.eql [doc]

	describe "runner", ->
		it.skip "should run the processors"

	describe "purge", ->
		it "should empty all queues", ->
			@p.trigger 'test', x: 1
			@p.purge 'test'
			@p.flows['test'][0].queue.tasks.should.eql []
			@p.flows['test'][1].queue.tasks.should.eql []
