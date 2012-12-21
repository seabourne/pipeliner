uuid = require 'node-uuid'

class Object
	constructor: (@config) ->
		self = this
		self.config = {} if not self.config
		self.config.id = self.config.id if self.config._id?
		self.config.id = uuid.v4() if not self.config.id?
		self._events = {}

	get: (name) ->
		self = this
		return self.config[name] if self.config[name]?
		return null

	set: (name, value) ->
		self = this
		return self.config[name] = value

	on: (event, callback, context) ->
		self = this
		context ?= self
		self._events[event] ?= [] 
		self._events[event].push {callback: callback, context: context}

	trigger: (event, args...) ->
		self = this
		return if not self._events[event]? or self._events[event].length == 0
		for e in self._events[event]
			do (e) ->
				e.callback.apply(e.context, args)

	off: (e, callback, context) ->
		self = this
		events = self._events[e]
		newEvents = []
		for event in events
			if event.callback != callback and event.context != context
				newEvents.push event				
		self._events[e] = newEvents	

module.exports = Object		