should = require 'should'

Module = require '../../lib/module'

describe "Module", () ->
	describe "Constructor", () ->
		it "should accept the standard configuration object", () ->
			data = 
				key: 'value'
			mod = new Module data
			mod.get('key').should.eql data.key

		it "should accept a function for processData", () ->
			func = () ->
				return 'processData'
			mod = new Module func
			mod.processData.should.eql(func)

		it "should accept both a config and function parameter", () ->
			data = 
				key: 'value'
			func = () ->
				return 'processData'	
			mod = new Module data, func
			mod.get('key').should.eql data.key
			mod.processData.should.eql(func)
