events = require 'events'

class Module extends events.EventEmitter
	processData: (doc, done) =>
		next = (doc) =>
			@emit "next", doc

		complete = () =>
			@emit "complete"

		@process doc, next, complete 

	process: (doc, next, complete) ->
		if next
			next null, true
		

module.exports = Module
