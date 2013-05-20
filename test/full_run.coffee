should = require 'should'
_ = require 'underscore'

Pipeliner = require '../lib/pipeliner'
Queue = require '../lib/queue'
RedisQueue = require '../lib/redis_queue'
Module = require('events').EventEmitter

class Input extends Module
	process: (doc, next, complete) ->
		console.log 'Input process'
		next subdoc for subdoc in doc.docs
		complete()

	type: 'input'	

class Sum extends Module
	process: (doc) ->
		console.log 'Sum process'
		add = (x,y) ->
			x + y
		doc.sum = _.reduce(doc.numbers, add, 0)

	type: 'processor'	

_finalDocs = []

class ErrorSum extends Module
	process: (doc, next, complete) ->
		add = (x,y) ->
			x + y
		doc.sum = _.reduce(doc.numbers, add, 0)
		#next doc
		complete 'Failure'

	type: 'processor'	

_finalDocs = []

class Output extends Module
	process: (doc) ->
		console.log 'Output process'
		_finalDocs.push doc

	type: 'output'		

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

	describe "middleware", ->
		before (done) ->
			@data = docs: [{numbers: [1,2,3]}, {numbers: [4,5,6]}]
			done()

		it "should apply the middleware", (done) ->
			p = new Pipeliner(Queue)
			o = new Output()
			flow = [
				{name: 'input', module: new Input()}
				{name: 'sum', module: new Sum()}
				{name: 'output', module: o}
			]
			nextRun = false
			nextComplete = false
			p.use (doc, next, complete) ->
				
				console.log 'mw fired'
				next (doc) ->
					console.log 'next mw fired'
					nextRun = true

				complete (err, doc) ->
					console.log 'complete mw fired' 
					nextComplete = true
			
			p.createFlow('summer', flow)
			p.purge 'summer'
			p.trigger 'summer', @data
			
			o.on 'complete', () ->
				if _finalDocs.length == 2
					_.pluck(_finalDocs, 'sum').should.eql [6, 15]
					_finalDocs = []
					nextRun.should.be.true
					nextComplete.should.be.true
					done()
			
			p.run()	

	describe "error", ->
		before (done) ->
			@proc = new ErrorSum()
			@flow = [
				{name: 'input', module: new Input()}
				{name: 'sum', module: @proc}
				{name: 'output', module: new Output()}
			]
			@data = docs: [{numbers: [1,2,3]}]
			done()

		it "should throw an error event", (done) ->
			p = new Pipeliner(Queue)
			p.createFlow('summer', @flow)
			p.purge 'summer'
			p.trigger 'summer', @data
			@proc.on 'error', (error) ->
				should.exist error
				error.should.eql 'Failure'
				done()

			p.run()	
				