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

		_stack.push (doc, next, complete) =>
			c = (err, doc, m) ->
				complete(err, doc, m)
				return mod.module.emit "error", err, doc, m if err
				mod.module.emit "complete" 
				
			n = (d, ne, co) ->
				next(d, ne, co)
				ne = next unless ne?
				co = complete unless co?
				mod.module.emit "next", d
				
			try
				mod.module.process doc, n, c
			catch e
				complete e, doc, mod.module if e

		return (doc) =>
			i = 0
			complete = (err) -> 
				console.log err if err
			next = (doc, ne, co, mo) =>
				mo = mod.module unless mo?
				return if i > _stack.length - 1

				ne = next unless ne?
				co = complete unless co?
				m = _stack[i++]
				if m and m.process?
					return m.process doc, ne, co, mo
				if m and m.call?
					return m doc, ne, co, mo

			next doc, next, complete, mod.module
				


	_connectFlow: (mod, next) ->
		mod.module.on 'next', (doc) ->
			next.queue.push doc

module.exports = Pipeliner
