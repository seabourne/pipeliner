mongoose = require('mongoose')

Setting = require './lib/models/setting'

class Pipeliner
	constructor: (config)->
		self = this
		self.config = if config then config else {db: 'mongodb://localhost/pipeliner'}

		self.setup()

	setConfig: (config) ->
		self = this
		self.config = config
		self.setup()

	setup: () ->
		self = this
		self.connection = mongoose.createConnection self.config.db
		self.connection.on 'error', (error) ->
			console.log 'error occured'
			console.log error

		self.Flow = require './lib/flow'
		self.Module = require './lib/module'
		self.Job = 

		self.Flow::connection = self.connection
		self.Module::connection = self.connection
		self.Job = require('./lib/models/job')(self.connection)

module.exports = new Pipeliner
