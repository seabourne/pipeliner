events = require 'events'

class Queue extends events.EventEmitter
	constructor: (name) ->
		@name = name
		@_internalQueue = []

	push: (object) ->
		process.nextTick =>
			@_internalQueue.push object
			@emit 'push', object

	_pop: (callback) ->
		callback @_internalQueue.pop()

	process: (callback) ->
		@on 'push', (object) ->
			@_pop callback
		while @_internalQueue.length
			@_pop callback

	purge: ->
		@_internalQueue = []
		@emit 'purged'

module.exports = Queue
