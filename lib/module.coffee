Object = require "./object"

uuid = require 'node-uuid'

class Module extends Object
	constructor: (config, func) ->
		self = this
		
		if typeof config is 'function'
			self.processData = config
		else
			self.processData = func if func?
			super config
	
	process: (data, jobId, previous) ->
		@jobId = jobId
		self = this
		self.processData(data)

	start: () ->

	stop: () ->	

	done: (data) ->
		self = this
		if not @jobId?
			jobId = uuid.v4()
		else
			jobId = @jobId
		self.trigger 'complete', data, jobId, self

	fail: (reason, data) ->
		self = this
		self.trigger 'error', reason, data, @jobId, self

	doNext: (context) ->
		self = this
		self.on 'complete', context.process, context
		return context

module.exports = Module	