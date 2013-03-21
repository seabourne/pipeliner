mongoose = require('mongoose')

Setting = require './lib/models/setting'

gconfig = {db: 'mongodb://localhost/pipeliner'}

class Pipeliner
	constructor: (config) -> 
		@setConfig()

	setConfig: (config) ->
		@config = if config then config else gconfig
		@setConnection()

	setConnection: (connection) ->
		if connection
			@setup(connection)
		else
			connection = mongoose.createConnection @config.db
		
			connection.on 'connected', (error) =>
				@setup(connection)
			
			connection.on 'error', (error) =>
				return console.log error
			
	resetConnection: () ->
		@setConnection()	

	setup: (connection) ->
		@connection = connection
		@Flow = require './lib/flow'
		@Module = require './lib/module'

		@Flow::connection = connection
		@Job = @getJobModel(connection)

	getJobModel: (connection) ->
		return require('./lib/models/job')(connection)

module.exports = new Pipeliner
