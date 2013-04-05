should = require 'should'
_ = require 'underscore'

Pipeliner = require '../lib/pipeliner'
Queue = require '../lib/queue'
RedisQueue = require '../lib/queue'
Module = require '../lib/redis_queue'

class Input extends Module
	process: (doc) =>
		@next subdoc for subdoc in doc.docs
		@complete()

class Sum extends Module
	process: (doc) =>
		add = (x,y) ->
			x + y
		doc.sum = _.reduce(doc.numbers, add, 0)
		@next doc
		@complete()

_finalDocs = []

class Output extends Module
	process: (doc) =>
		_finalDocs.push doc
		@complete()

describe "A full example", ->
	before (done) ->
		@o = new Output()
		@flow = [
			{name: 'input', module: new Input()}
			{name: 'sum', module: new Sum()}
			{name: 'output', module: @o}
		]
		@data = docs: [{numbers: [1,2,3]}, {numbers: [4,5,6]}]
		done()

	it "should run the numbers (basic queue)", (done) ->
		p = new Pipeliner(Queue)
		p.createFlow('summer', @flow)
		p.trigger 'summer', @data

		@o.on 'complete', (flow, module, doc) ->
			_.pluck(_finalDocs, 'sum').should.eql [6, 15]
			done()

		p.run()

	it "should run the numbers (redis queue)", (done) ->
		p = new Pipeliner(RedisQueue)
		p.createFlow('summer', @flow)
		p.trigger 'summer', @data

		@o.on 'complete', (flow, module, doc) ->
			_.pluck(_finalDocs, 'sum').should.eql [6, 15]
			done()

		p.run()
