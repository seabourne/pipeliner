Object = require './object'

class Flow extends Object
	constructor: (@config) ->
		super(@config)
		@_modules = {}

	start: () ->
		for id, module of @_modules
			module.start()

	stop: () ->
		for id, module of @_modules
			module.stop()

	addModules: (modules) ->
		for module in modules
			@addModule module

	addModule: (module) ->
		throw new Error("Module must have an id") if not module.get? or not module.get('id')?
		@_modules[module.get('id')] = module
		module.on 'complete', @handleComplete, @
		module.on 'error', @handleError, @

	getModuleById: (id) ->
		return @_modules[id] if @_modules[id]?
		return null

	handleComplete: (data, runId, module) ->
		job = 
			flowId: @get('id')
			moduleId: module.get('id')
			data: data
			complete: true
			runId: runId
		@createJob(job)

	handleError: (error, data, runId, module) ->
		job = 
			flowId: @get('id')
			moduleId: module.get('id')
			data: data
			error: error.toString()
			complete: false
		@createJob(job)
		
	createJob: (job) ->
		throw new Error "Must include a flow id" if not job.flowId?
		throw new Error "Must include a module id" if not job.moduleId?
		#Job.update({}, job, {upsert: true}).exec()
		Job = require('./models/job')(Flow::connection)
		Job.create job, () ->

	getLastRun: (callback) ->
		Job = require('./models/job')(Flow::connection)
		Job.aggregate(
			{ $group: { _id: null, val: { $max: '$runId' }}}, 
    		{ $project: { _id: 0, val: 1 }},
    		(err, res) ->
    			Job.find runId: res[0].val, (err, jobs) ->
    				callback jobs	
    	)

	getLastError: (callback) ->
		Job = require('./models/job')(Flow::connection)
		Job.findOne(complete: false)
		.sort('-createdOn')
		.exec (err, rslt) ->
			callback rslt


module.exports = Flow