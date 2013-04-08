events = require 'events'

class Module extends events.EventEmitter
	process: (doc) ->
		@complete()

	next: (doc) ->
		@emit "next", doc

	complete: () ->
		@emit "complete"

module.exports = Module
