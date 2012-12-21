should = require 'should'

pipeliner = require '../index'

pipeliner.setConfig({db: 'mongodb://localhost/pipeliner_test'})

Flow = pipeliner.Flow
Job = pipeliner.Job
Module = pipeliner.Module

inputData = 
	title: 'Some Title'

class Input extends Module
	process: () ->
		this.trigger 'complete', inputData, this


class UpcaseProcessor extends Module
	process: (data) ->
		data.title = data.title.toUpperCase()
		this.trigger 'complete', data, this

flow = input = processor = null

describe "Pipeliner", () ->
	describe "Run a flow", () ->
		before () ->
			Job.remove({}).exec()

		before (done) ->
			flow = new Flow
			input = new Input
			processor = new UpcaseProcessor

			processor.on 'complete', (data) ->
				done()

			flow.addModule(input)
			flow.addModule(processor)	
			
			input.on 'complete', processor.process, processor

			input.process()

		it "should work", (done) ->
			Job.findOne moduleId: processor.get('id'), (err, job) ->
				should.exist(job)
				job.data.title.should.eql inputData.title.toUpperCase()
				done()

