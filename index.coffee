mongoose = require('mongoose')

Setting = require './lib/models/setting'

global.pipelinerConfig = {db: 'mongodb://localhost/pipeliner'} unless global.pipelinerConfig?

class Pipeliner
	constructor: (config) ->
		@config = global.pipelinerConfig
		@config = config if config 
		@setup()

	setConfig: (config) ->
		@config = config
		@setup()

	setDefaultConfig: (config) ->
		global.pipelinerConfig = config	
		unless config?
			global.pipelinerConfig = {db: 'mongodb://localhost/pipeliner'} 
		
		@setConfig global.pipelinerConfig
		@setup()

	setup: () ->
		@connection = mongoose.createConnection @config.db
		@connection.on 'error', (error) =>
			console.log 'error occured'
			console.log error

		@Flow = require './lib/flow'
		@Module = require './lib/module'

		@Flow::connection = @connection
		@Module::connection = @connection
		@Job = require('./lib/models/job')(@connection)

module.exports = new Pipeliner
