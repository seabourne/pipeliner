events = require 'events'
_ = require 'underscore'
debug = require('debug')('pipeliner')

class Pipeliner extends events.EventEmitter
	constructor: (queue) ->
		debug 'Starting'
		@queue = queue
		@flows = []
		@_mw = []
		@_definedInputs = []
		@_completedInputs = []
		@_indexes = []
		@_completes = []
		@_nexts = []

	createFlow: (name, tasks) ->
		flow = @flows[name] = []
		prev = null
		i = 0
		for task in tasks
			queue = new @queue name + ':' + task.name
			task = _.extend({queue: queue, flowName: name}, task)
			flow.push task
			if prev
				prev.next = task
			prev = task
			i++
		@resetCounts name	

	resetCounts: (name) ->
		@_definedInputs[name] = @_definedInputs[name] || 0
		@_completedInputs[name] = @_completedInputs[name] || 0
		@_completes[name] = []
		@_nexts[name] = []
		@_indexes[name] = []
		
		i = 0
		for task in @flows[name]
			if task.module and (task.module.type == 'input' or (_.isFunction(task.module.type) and task.module.type() == 'input'))
				@_definedInputs[name] += 1
			@_indexes[name][task.name] = i
			@_completes[name][i] = 0
			@_nexts[name][i] = 0
			i++

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

	checkRun: (flowName) =>
		done = @_definedInputs[flowName] == @_completedInputs[flowName]
		for i in [1..Object.keys(@_indexes[flowName]).length]
			break if not done or not @_completes[flowName][i]?
			break if @_nexts[flowName][i-1] == 0
			done = @_completes[flowName][i] >= @_nexts[flowName][i-1]
		if done
			@resetCounts flowName
			@emit 'end' 

	setupCallback: (mod) ->
		checkRun = @checkRun
		_completedInputs = @_completedInputs
		_indexes = @_indexes[mod.flowName]
		_nexts = @_nexts[mod.flowName]
		_completes = @_completes[mod.flowName]
		debug 'Setting up callbacks'
		_completeQueue = []
		_nextQueue = []
		_completeQueue.push (err, doc) ->
			_completes[_indexes[mod.name]] += 1
			if @.type == 'input' or (_.isFunction(@type) and @type() == 'input')
				_completedInputs[mod.flowName] += 1
			checkRun mod.flowName
			return mod.module.emit "error", err, doc, @ if err
			debug 'Complete emitted by %s', mod.module?.config?.title
			mod.module.emit "complete", doc, @

		_nextQueue.push (doc) ->
			_nexts[_indexes[mod.name]] += 1
			debug 'Next emitted by %s', mod.module?.config?.title
			mod.module.emit "next", doc, @
		
		for mw in @_mw
			mw.call mod.module, (cb) ->
				_nextQueue.push cb
			, (cb) ->
				_completeQueue.push cb

		complete = () ->
			c = 0
			cb = (err, d) -> 
				cProc = _completeQueue[c]
				return unless cProc or cContinue is false
				c += 1
				switch cProc.length
					when 2
						ret = cProc.call mod.module, err, d
						cb.call mod.module, err, d
					when 3
						ret = cProc.call mod.module, err, d, cb							
				cContinue = not (ret is false)		
			cb.apply mod.module, arguments

		next = () ->
			n = 0
			cb = (doc) ->
				nProc = _nextQueue[n]
				unless nProc or nConinue is false
					return
				n += 1
				switch nProc.length
					when 0
						ret = nProc.call mod.module
						cb.call mod.module, doc
					when 1
						ret = nProc.call mod.module, doc
						cb.call mod.module, doc
					when 2
						ret = nProc.call mod.module, doc, cb

				nConinue = not (ret is false)
			cb.apply mod.module, arguments	

		return (doc, done) =>			
			if done
				_completeQueue.push (err, doc) ->
					done()
			debug 'Processing %s', mod.module?.config?.title
			switch mod.module.process.length
				when 0
					mod.module.process.call mod.module
					next.call mod.module, doc
					complete.call mod.module
				when 1
					mod.module.process.call mod.module, doc
					next.call mod.module, doc
					complete.call mod.module
				when 2
					mod.module.process.call mod.module, doc, next
					complete.call mod.module
				when 3
					mod.module.process.call mod.module, doc, next, complete			

	_connectFlow: (mod, next) ->
		mod.module.on 'next', (doc) ->
			next.queue.push doc

module.exports = Pipeliner
