should = require 'should'

Pipeliner = require '../index'

config = {key: 'value'}

describe 'App', ->
	describe "#constructor", ->
		it "should accept a passed config object", ->
			app = new Pipeliner config
			app._config.should.equal config

	describe "#setConfig", ->
		it "should set the config var", ->
			app = new Pipeliner
			app.setConfig config
			app._config.should.equal config

	describe "#getConfig", ->
		it "should get the config", ->
			app = new Pipeliner config
			app.getConfig().should.equal config