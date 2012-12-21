should = require 'should'

pipeliner = require '../../index'

pipeliner.setConfig({db: 'mongodb://localhost/pipeliner_test'})

Flow = pipeliner.Flow
Job = pipeliner.Job
Module = pipeliner.Module

describe "Flow", () ->
	flw = null
	mod = null
	data = null
	error = null

	beforeEach () ->
		Job.remove({}).exec()
		flw = new Flow()
		
	describe "Constructor", () ->
		it "should initialize the internal _modules hash", () ->
			flw._modules.should.eql({})

	describe "addModule", () ->
		it "should add the passed module to the hash with the id as key", () ->
			mod = new Module()
			flw.addModule mod
			should.exist(flw._modules[mod.get('id')])
			flw._modules[mod.get('id')].should.eql(mod)

		it "should throw a warning if the passed object doesnt have an id", () ->
			mod = {}
			(() -> 
			  flw.addModule(mod)
			).should.throw()

		it "should bind handleComplete to the complete event", (done) ->
			mod = new Module
			
			mod.process = () ->
				this.trigger 'complete', done
			
			flw.handleComplete = (done) ->
				done()

			flw.addModule(mod)
			mod.process()			

		it "should bind handleError to the error event", (done) ->
			mod = new Module
			
			mod.process = () ->
				this.trigger 'error', done
			
			flw.handleError = (done) ->
				done()

			flw.addModule(mod)
			mod.process()		

	describe "getModuleById", () ->
		it "should return the module that was created", () ->
			mod = new Module
			flw.addModule(mod)
			flw.getModuleById(mod.get('id')).should.eql(mod)

		it "should return null if no id is passed", () ->
			should.not.exist(flw.getModuleById())	

	describe "start", () ->
		it "should call start for each module", (done) ->
			mod = new Module
			mod.start = done
			flw.addModule(mod)
			flw.start()


	describe "stop", () ->
		it "should call stop for each module", (done) ->
			mod = new Module
			mod.stop = done
			flw.addModule(mod)
			flw.stop()

	describe "createJob", () ->
		it "should create a new job", (done) ->
			mod = new Module
			job = 
				moduleId: mod.get('id')
				flowId: flw.get('id')
				data: 'some data'
			flw.createJob job
			Job.findOne moduleId: mod.get('id'), (err, res) ->
				should.exist res
				res.should.have.property 'moduleId', mod.get('id')
				done()

		it "should throw an error if the flowId is missing", () ->
			mod = new Module
			job = 
				moduleId: mod.get('id')
				data: 'some data'
			(() -> 
				flw.createJob job
			).should.throw(/flow id/)

		it "should throw an error if the moduleId is missing", () ->
			mod = new Module
			job = 
				flowId: flw.get('id')
				data: 'some data'
			(() -> 
				flw.createJob job
			).should.throw(/module id/)	

	describe "handleComplete", () ->
		it "should save a job with the correct data", (done) ->
			mod = new Module
			data = 'some data'
			mod.process = () ->
				this.trigger 'complete', data, this
			mod.on 'complete', flw.handleComplete, flw
			mod.process()
			Job.findOne moduleId: mod.get('id'), (err, res) ->
				should.exist res
				res.should.have.property 'data', data
				done()

		it "should mark the job as complete", (done) ->
			mod = new Module
			data = 'some data'
			mod.process = () ->
				this.trigger 'complete', data, this
			mod.on 'complete', flw.handleComplete, flw
			mod.process()
			Job.findOne moduleId: mod.get('id'), (err, res) ->
				should.exist res
				res.should.have.property 'complete', true
				done()

	describe "handleFailure", () ->	
		it "should save a job with the current error", (done) ->	
			mod = new Module
			data = 'some bad data'
			error = new Error 'something went wrong'
			mod.process = () ->
				this.trigger 'error', error, data, this
			mod.on 'error', flw.handleError, flw
			mod.process()
			Job.findOne moduleId: mod.get('id'), (err, res) ->
				should.exist res
				res.should.have.property 'error', error.toString()
				done()

		it "should mark the job as not complete", (done) ->
			mod = new Module
			data = 'some bad data'
			error = new Error 'something went wrong'
			mod.process = () ->
				this.trigger 'error', error, data, this
			mod.on 'error', flw.handleError, flw
			mod.process()
			Job.findOne moduleId: mod.get('id'), (err, res) ->
				should.exist res
				res.should.have.property 'complete', false
				done()		