should = require 'should'

pipeliner = require '../index'

pipeliner.setConfig({db: 'mongodb://localhost/pipeliner_test'})

Flow = pipeliner.Flow
Job = pipeliner.Job
Module = pipeliner.Module

inputData =
	title: 'Some Title'

class Input extends Module
	processData: () ->
		this.done(inputData)

	start: () ->
		this.process()

class UpcaseProcessor extends Module
	processData: (data) ->
		data.title = data.title.toUpperCase()
		this.done(data)


flow = input = processor = null

describe "Pipeliner", () ->
	describe "Run a flow", () ->
		before () ->
			Job.remove({}).exec()

		before (done) ->
			flow = new Flow
			input = new Input
			processor = new UpcaseProcessor

			flow.addModule input
			flow.addModule processor

			input.doNext processor

			processor.on 'complete', (data) ->
				done()

			flow.start()

		it "should work", (done) ->
			Job.findOne moduleId: processor.get('id'), (err, job) ->
				should.exist(job)
				job.data.title.should.eql inputData.title.toUpperCase()
				done()
