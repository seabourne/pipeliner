events = require 'events'
_ = require 'underscore'

class Pipeliner extends events.EventEmitter
	constructor: (queue) ->
		@queue = queue
		@flows = []

	createFlow: (name, tasks) ->
		flow = @flows[name] = []
		for task in tasks
			queue = new @queue task.name
			flow.push _.extend({queue: queue}, task)

	getFlows: () ->
		@flows

	trigger: (flowName, document) ->
		if not @flows[flowName]
			throw new ReferenceError "Flow " + flowName + " is not defined."
		@flows[flowName][0].queue.push(document)

module.exports = Pipeliner
