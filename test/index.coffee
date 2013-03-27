should = require 'should'

app = require '../index'

describe 'App', ->
	describe "#constructor", ->
		it "should get an object back", ->
			app.should.be.ok