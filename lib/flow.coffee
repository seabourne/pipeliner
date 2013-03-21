Object = require './object'

class Flow extends Object
	constructor: (@config) ->
		super(@config)
		@_modules = {}

	runJobQuery: (callback) ->
		Job = require('./models/job')(Flow::connection)
		callback Job	

	start: () ->
		for id, module of @_modules
			module.start()

	stop: () ->
		@running = false
		for id, module of @_modules
			module.stop()

	run: () ->
		@running = true
		for id, module of @_modules
			module.run() if module.type() is 'input'

	addModules: (modules) ->
		for module in modules
			@addModule module		

	addModule: (module) ->
		throw new Error("Module must have an id") if not module.get? or not module.get('id')?
		@_modules[module.get('id')] = module
		module.on 'complete', @handleComplete, @
		module.on 'error', @handleError, @
		module.flow = @

	getModuleById: (id) ->
		return @_modules[id] if @_modules[id]?
		return null

	handleComplete: (data, runId, order, module) ->
		job = 
			flowId: @get('id')
			moduleId: module.get('id')
			data: data
			complete: true
			runId: runId
			order: order	
		@createJob(job) #if @testing

	handleError: (error, data, runId, order, module) ->
		job = 
			flowId: @get('id')
			moduleId: module.get('id')
			data: data
			error: error.toString()
			complete: false
			runId: runId
			order: order
		@createJob(job)
		@trigger 'error', error, data, runId, order, module
		
	createJob: (job) ->
		throw new Error "Must include a flow id" if not job.flowId?
		throw new Error "Must include a module id" if not job.moduleId?
		#Job.update({}, job, {upsert: true}).exec()
		@runJobQuery (Job) ->
			Job.create job, (err) ->
				throw new Error err if err

	getLastRun: (callback) ->
		@runJobQuery (Job) ->
			Job.findOne({flowId: @get('id')}).sort("-createdOn").exec (err, res) ->
				return callback [] if not res
				Job.find({runId: res.runId}).sort('order').exec (err, jobs) ->
					callback jobs

	getRun: (id, callback) ->	
		@runJobQuery (Job) ->
			Job.find({runId: id}).sort("order").exec (err, jobs) ->
				callback jobs

	getLastRuns: (runs, callback) ->
		if typeof runs is 'function'
			callback = runs
			runs = 5	
		@runJobQuery (Job) ->
			Job.find({flowId: @get('id')}).sort("runId").exec (err, res) =>
				if not res or res.length is 0
					console.log 'No job results returned'
					return callback []
				runIds = []
				for run in res
					runIds.push run.runId if runIds.indexOf(run.runId) == -1 
					break if runIds.length == 5

				Job.find({runId: {$in: runIds}}).sort('runId order').exec (err, jobs) ->
					callback jobs

	getError: (errorId, callback) ->
		@runJobQuery (Job) ->
			Job.findById(errorId).exec (err, job) ->
				callback job			

	getErrors: (callback) ->
		@runJobQuery (Job) ->
			Job.find({flowId: @get('id'), complete: false}).sort("-createdOn").exec (err, jobs) ->
				callback jobs			

	getLastError: (callback) ->
		@runJobQuery (Job) ->
			Job.findOne({flowId: @get('id'), complete: false}).sort("-createdOn").exec (err, res) ->
				Job.find({runId: res.runId}).sort('order').exec (err, jobs) ->
					callback jobs


module.exports = Flow