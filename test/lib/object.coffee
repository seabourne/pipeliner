should = require 'should'

Object = require '../../lib/object'

describe "Object", () ->
	describe "Constructor", () ->
		it "should accept a passed config variable", () ->
			config = 
				test: 'config'
			obj = new Object(config)
			obj.config.should.have.property('test', config.test)

		it "should initialize config with an id", () ->
			obj = new Object()
			obj.config.should.have.property("id")

		it "should use the passed id if present", () ->
			config = 
				id: 'someId'
			obj = new Object(config)
			obj.config.should.have.property('id', config.id)

		it "should use _id if present", () ->
			config = 
				_id: 'someId'
			obj = new Object(config)
			obj.config.should.have.property('id', config.id)			

	obj = null
	beforeEach () ->
		config =
			test: 'value'
		obj = new Object(config)

	describe "get", () ->
		it "should return the specified config value", () ->
			obj.get('test').should.eql(obj.config.test)

		it "should return null if the value isn't found", () ->
			should.not.exist(obj.get('someValue'))

	describe "set", () ->
		it "should set the specified config value", () ->
			value = 'value2'
			obj.set('test2', value)
			obj.config.test2.should.eql(value)

		it "should set a value to null if no value is passed", () ->
			obj.set('test2')
			should.not.exist(obj.config.test2)

	describe "on", (done) ->
		callback = () ->
			
		it "should set an event listener for the specified event", () ->
			obj.on 'event', callback, this
			obj._events['event'][0].should.eql({callback: callback, context: this})	

		it "should set a default context if no context is passed", () ->
			obj.on 'event', callback
			obj._events['event'][0].context.should.be.ok

	describe "trigger", (done) ->
		callback = (done) ->
			done()

		it "should fire the specified event callback", (done) ->
			obj.on 'event', callback, this
			obj.trigger 'event', done

		it "should do nothing if the event hasnt been bound yet", (done) ->
			obj.trigger 'event', () ->
				done('shouldnt have fired')
			done()		

	describe "off", (done) ->
		callback = (done) ->
			done(new Error('Shouldnt have fired the callback'))

		it "should remove the specific event", (done) ->
			obj.on 'event', callback, this
			obj.off 'event', callback, this
			obj.trigger 'event', done
			done()
