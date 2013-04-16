events = require 'events'
_ = require 'underscore'

class Pipeliner extends events.EventEmitter
	constructor: (queue) ->
		@queue = queue
		@flows = []
		@_mw = []

	createFlow: (name, tasks) ->
		flow = @flows[name] = []
		prev = null
		for task in tasks
			queue = new @queue name + ':' + task.name
			task = _.extend({queue: queue}, task)
			flow.push task
			if prev
				prev.next = task
			prev = task

	getFlows: () ->
		@flows

	use: (middleware) ->
		@_mw.push middleware

	trigger: (flowName, document) ->
		if not @flows[flowName]
			throw new ReferenceError "Flow " + flowName + " is not defined."
		@flows[flowName][0].queue.push(document)

	purge: (flowName) ->
		x.queue.purge() for x in @flows[flowName]

	# TODO: allow override flow modules here
	run: (flowNames) ->
		if not flowNames
			flowNames = _.keys(@flows)
		for flowName in flowNames
			@runFlow @flows[flowName]

	runFlow: (flow) ->
		for mod in flow
			if mod.next
				@_connectFlow mod, mod.next
			mod.queue.process @setupCallback mod

	setupCallback: (mod) ->
		_stack = []
		for mw in @_mw
			_stack.push mw

		_stack.push (doc, next, complete) ->
			c = () ->
				mod.module.emit "complete"
				complete()

			n = (d) ->
				mod.module.emit "next", d
				next(d)

			mod.module.process doc, n, c	

		return (doc) ->
			i = 0
			complete = () -> 
			next = (doc, ne, co) ->
				return if i > _stack.length - 1

				ne = next unless ne?
				co = complete unless co?
				
				m = _stack[i++]
				
				if m and m.process?
					return m.process doc, ne, co 
				if m and m.call?
					return m doc, ne, co 

			next doc, next, complete
				


	_connectFlow: (mod, next) ->
		mod.module.on 'next', (doc) ->
			next.queue.push doc

module.exports = Pipeliner
