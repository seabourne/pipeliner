Object = require "./object"

uuid = require 'node-uuid'

class Module extends Object
	constructor: (config, func) ->
		if typeof config is 'function'
			@processData = config
		else
			@processData = func if func?
			super config
	
	process: (data, jobId, order, previous) ->
		@jobId = jobId
		@order = order
		@processData @clone(data)

	start: () ->

	stop: () ->	

	done: (data) ->
		if not @jobId?
			jobId = uuid.v4()
		else
			jobId = @jobId

		if not @order?
			order = 0
		else
			order = @order+1
		@trigger 'complete', data, jobId, order, @

	fail: (reason, data) ->
		@trigger 'error', reason, data, @jobId, @

	doNext: (context) ->
		@on 'complete', context.process, context
		return context

module.exports = Module	