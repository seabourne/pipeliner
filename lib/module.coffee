events = require 'events'

class Module extends events.EventEmitter
	process: (doc, done) ->
		@complete()
		if done
			done null, true

	next: (doc) ->
		@emit "next", doc

	complete: () ->
		@emit "complete"

module.exports = Module
