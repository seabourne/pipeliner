Object = require "./object"

uuid = require 'node-uuid'

class Module extends Object
	constructor: (config, func) ->
		@stopped = false
		if typeof config is 'function'
			@processData = config
		else
			@processData = func if func?
			super config
	
	process: (data, jobId, order, previous) ->
		done = (data) =>
			newId = if not jobId then uuid.v4() else jobId
			if not order or order < 1
				order = 0 

			newOrder = order+1
			@trigger 'complete', data, newId, newOrder, @ unless @stopped

		fail = (error, data) =>
			newId = if not jobId then uuid.v4() else jobId

			newOrder = if not order then 0 else (order+1)
			@trigger 'error', error, data, newId, newOrder, @ unless @stopped

		try
			@processData @clone(data), done, fail
		catch e 
			fail "Error processing module: "+e 

	start: () ->
		@stopped = false

	stop: () ->
		@stopped = true

	run: () ->	
		@stopped = false
		@process()

	doNext: (context) ->
		@on 'complete', context.process, context
		return context

module.exports = Module	