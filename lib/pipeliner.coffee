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
		return (doc) =>
			c = 0
			cContinue = true
			nConinue = true

			_completeQueue = []
			_completeQueue.push (err, doc) ->
				return mod.module.emit "error", err, doc, @ if err
				mod.module.emit "complete", doc, @

			_nextQueue = []
			_nextQueue.push (doc) ->
				mod.module.emit "next", doc, @
			
			for mw in @_mw
				mw.call mod.module, doc, (cb) ->
					_nextQueue.push cb
				, (cb) ->
					_completeQueue.push cb

			complete = (err, d) -> 
				process.nextTick ->
					cProc = _completeQueue[c]
					return unless cProc or cContinue is false
					c += 1
					switch cProc.length
						when 2
							ret = cProc.call mod.module, err, d
							complete err, doc
						when 3
							ret = cProc.call mod.module, err, d, complete							
					cContinue = not (ret is false)
				
			next = () ->
				n = 0
				cb = (doc) ->
					process.nextTick ->
						nProc = _nextQueue[n]
						unless nProc or nConinue is false
							return
						n += 1
						switch nProc.length
							when 0
								ret = nProc.call mod.module
								cb(doc)
							when 1
								ret = nProc.call mod.module, doc
								cb(doc)
							when 2
								ret = nProc.call mod.module, doc, cb

						nConinue = not (ret is false)
				cb.apply mod.module, arguments
				
			switch mod.module.process.length
				when 0
					mod.module.process.call mod.module
					next doc
					complete()
				when 1
					mod.module.process.call mod.module, doc
					next doc
					complete()
				when 2
					mod.module.process.call mod.module, doc, next
					complete()
				when 3
					mod.module.process.call mod.module, doc, next, complete			


	_connectFlow: (mod, next) ->
		mod.module.on 'next', (doc) ->
			next.queue.push doc

module.exports = Pipeliner
