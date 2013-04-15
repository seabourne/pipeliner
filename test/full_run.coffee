should = require 'should'
_ = require 'underscore'

Pipeliner = require '../lib/pipeliner'
Queue = require '../lib/queue'
RedisQueue = require '../lib/redis_queue'
Module = require '../lib/module'

class Input extends Module
	process: (doc, done) =>
		@next subdoc for subdoc in doc.docs
		super doc, done

class Sum extends Module
	process: (doc, done) =>
		add = (x,y) ->
			x + y
		doc.sum = _.reduce(doc.numbers, add, 0)
		@next doc
		super doc, done

_finalDocs = []

class Output extends Module
	process: (doc, done) =>
		_finalDocs.push doc
		super doc, done

describe "A full example", ->
	describe "using in-memory q", ->
		before (done) ->
			@o = new Output()
			@flow = [
				{name: 'input', module: new Input()}
				{name: 'sum', module: new Sum()}
				{name: 'output', module: @o}
			]
			@data = docs: [{numbers: [1,2,3]}, {numbers: [4,5,6]}]
			done()

		it "should run the numbers", (done) ->
			p = new Pipeliner(Queue)
			p.createFlow('summer', @flow)
			p.purge 'summer'
			p.trigger 'summer', @data
			@o.on 'complete', (flow, module, doc) ->
				if _finalDocs.length == 2
					_.pluck(_finalDocs, 'sum').should.eql [6, 15]
					_finalDocs = []
					done()

			p.run()

	describe "using redis q", ->
		before (done) ->
			@o = new Output()
			@flow = [
				{name: 'input', module: new Input()}
				{name: 'sum', module: new Sum()}
				{name: 'output', module: @o}
			]
			@data = docs: [{numbers: [1,2,3]}, {numbers: [4,5,6]}]
			done()

		it "should run the numbers", (done) ->
			p = new Pipeliner(RedisQueue)
			p.createFlow('summer', @flow)
			p.purge 'summer'
			p.trigger 'summer', @data

			@o.on 'complete', (flow, module, doc) ->
				if _finalDocs.length == 2
					_.pluck(_finalDocs, 'sum').should.eql [6, 15]
					_finalDocs = []
					done()

			p.run()
