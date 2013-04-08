should = require 'should'

Module = require '../lib/module'

class TestModule extends Module
	process: (doc, done) =>
		doc.processed = true
		@next doc
		super doc, done

describe "Module", ->
	describe "next", ->
		it "should emit next doc", (done) ->
			d = {x: 'x'}
			m = new Module()
			m.on 'next', (doc) ->
				doc.should.eql d
				done()
			m.next(d)

	describe "complete", ->
		it "should emit event", (done) ->
			m = new Module()
			m.on 'complete', ->
				done()
			m.complete()

	describe "process", ->
		it "should trigger complete", (done) ->
			m = new Module()
			m.on 'complete', ->
				done()
			m.process()

		it "should call done callback if provided", (done) ->
			m = new TestModule()
			m.process x:1, (err, res) ->
				res.should.eql true
				done()

	describe "TestModule.process", ->
		it "should emit next doc, processed", (done) ->
			d = {x: 'x'}
			m = new TestModule()
			m.on 'next', (doc) ->
				doc.should.have.property("processed", true)
				done()
			m.process(d)
