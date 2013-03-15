uuid = require 'node-uuid'
cloneextend = require 'cloneextend'   

class Object
	constructor: (@config) ->
		@config = {} if not @config
		@config.id = @config.id if @config._id?
		@config.id = uuid.v4() if not @config.id?
		@_events = {}

	get: (name) ->
		return @config[name] if @config[name]?
		return null

	set: (name, value) ->
		return @config[name] = value

	on: (event, callback, context) ->
		throw new Error 'Must supply a callback' if not callback
		context ?= @
		@_events[event] ?= [] 
		@_events[event].push {callback: callback, context: context}

	trigger: (event, args...) ->
		return if not @_events[event]? or @_events[event].length == 0
		for e in @_events[event]
			do (e) ->
				e.callback.apply(e.context, args)

	off: (e, callback, context) ->
		events = @_events[e]
		newEvents = []
		for event in events
			if event.callback != callback and event.context != context
				newEvents.push event				
		@_events[e] = newEvents	

	clone: (obj) ->
		return cloneextend.clone(obj)


module.exports = Object		