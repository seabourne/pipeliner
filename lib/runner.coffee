QProvider = require './qprovider'

class Runner
	constructor: (qprovider) ->
		@qprovider = qprovider
		@qprovider ?= new QProvider

module.exports = Runner
