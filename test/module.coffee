should = require 'should'

Module = require '../lib/module'

class TestModule extends Module
	process: (doc, next, complete) =>
		doc.processed = true
		next doc
		complete()

describe "Module", ->
	describe "next", ->
		it "should emit next doc", (done) ->
			d = {x: 'x'}
			m = new Module()
			m.on 'next', (doc) ->
				doc.should.eql d
				done()
			m.emit 'next', d

	describe "complete", ->
		it "should emit event", (done) ->
			m = new Module()
			m.on 'complete', ->
				done()
			m.emit 'complete'

	describe "processData", ->
		it "should trigger process", (done) ->
			m = new Module()
			m.process = (d, next, complete) ->
				done()
			m.processData()

	describe "TestModule.process", ->
		it "should emit next doc, processed", (done) ->
			d = {x: 'x'}
			m = new TestModule()
			m.on 'next', (doc) ->
				doc.should.have.property("processed", true)
				done()
			m.processData(d)
