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
				
		_stack.push mod.module.process

		return (doc) =>
			i = 0

			complete = (err, d) -> 
				return mod.module.emit "error", err, d, @ if err
				mod.module.emit "complete", d

			start = (doc, nn, cc) ->
				next = () ->
					return nn.apply mod.module, arguments if nn
					start.apply mod.module, arguments
				co = () ->
					return cc.apply mod.module, arguments if cc
					complete.apply mod.module, arguments
				m = _stack[i]
				unless m	
					mod.module.emit "next", doc 
					co.call mod.module, null, doc
					return
				i += 1
				switch m.length
					when 0
						m.call mod.module
						next doc, next, co
					when 1
						m.call mod.module, doc
						next doc, next, co
					when 2
						m.call mod.module, doc, (doc, n, c) ->
							if n and c
								next doc, n, c 
							else if n
								next doc, n, co
							else
								next doc, next, co
					when 3
						m.call mod.module, doc, next, co
			
			start.call mod.module, doc, start, complete
				


	_connectFlow: (mod, next) ->
		mod.module.on 'next', (doc) ->
			next.queue.push doc

module.exports = Pipeliner
