Object = require './object'

class Flow extends Object
	constructor: (@config) ->
		self = this
		super(@config)
		self._modules = {}

	start: () ->
		self = this
		for id, module of self._modules
			module.start()

	stop: () ->
		self = this
		for id, module of self._modules
			module.stop()

	addModules: (modules) ->
		self = this
		for module in modules
			self.addModule module

	addModule: (module) ->
		self = this
		throw new Error("Module must have an id") if not module.get? or not module.get('id')?
		self._modules[module.get('id')] = module
		module.on 'complete', self.handleComplete, self
		module.on 'error', self.handleError, self

	getModuleById: (id) ->
		self = this
		return self._modules[id] if self._modules[id]?
		return null

	handleComplete: (data, runId, module) ->
		self = this
		job = 
			flowId: self.get('id')
			moduleId: module.get('id')
			data: data
			complete: true
			runId: runId
		self.createJob(job)

	handleError: (error, data, runId, module) ->
		self = this
		job = 
			flowId: self.get('id')
			moduleId: module.get('id')
			data: data
			error: error.toString()
			complete: false
		self.createJob(job)
		
	createJob: (job) ->
		self = this
		throw new Error "Must include a flow id" if not job.flowId?
		throw new Error "Must include a module id" if not job.moduleId?
		#Job.update({}, job, {upsert: true}).exec()
		Job = require('./models/job')(Flow::connection)
		Job.create job, () ->

	getLastRun: (callback) ->
		self = this
		Job = require('./models/job')(Flow::connection)
		Job.aggregate(
			{ $group: { _id: null, val: { $max: '$runId' }}}, 
    		{ $project: { _id: 0, val: 1 }},
    		(err, res) ->
    			Job.find runId: res[0].val, (err, jobs) ->
    				callback jobs	
    	)

	getLastError: (callback) ->
		self = this
		Job = require('./models/job')(Flow::connection)
		Job.findOne(complete: false)
		.sort('-createdOn')
		.exec (err, rslt) ->
			callback rslt


module.exports = Flow