events = require 'events'

class BaseQueue extends events.EventEmitter
	constructor: (name) ->
		@name = name
		@_internalQueue = []

	push: (object) ->
		@_internalQueue.push object

	pop: (callback) ->
		callback @_internalQueue.pop()

	process: (callback) ->
		while @_internalQueue.length
			@pop callback

module.exports = BaseQueue
