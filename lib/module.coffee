Object = require "./object"

class Module extends Object
	
	process: (data, jobId, previous) ->
		jobId = (new Date()).getTime() if not jobId?
		@jobId = jobId
		self = this
		self.processData(data)

	start: () ->

	stop: () ->	

	done: (data) ->
		self = this
		self.trigger 'complete', data, @jobId, self

	fail: (reason, data) ->
		self = this
		self.trigger 'error', reason, data, @jobId, self

	doNext: (context) ->
		self = this
		self.on 'complete', context.process, context

module.exports = Module	