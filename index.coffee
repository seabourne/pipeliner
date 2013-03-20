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
			@newConnection gconfig.db

	resetConnection: () ->
		@setConnection()	

	newConnection: (db, callback) ->
		return false if not db
		connection = mongoose.createConnection db
		
		connection.on 'connected', (error) =>
			@setup(connection)
			callback connection if callback
		
		connection.on 'error', (error) =>
			return console.log error

	setup: (connection) ->
		@connection = connection
		console.log 'pipeliner setting up'
		#console.log @connection
		@Flow = require './lib/flow'
		@Module = require './lib/module'

		@Flow::connection = connection
		@Module::connection = connection
		@Job = require('./lib/models/job')(connection)

module.exports = new Pipeliner
