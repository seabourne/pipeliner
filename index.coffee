class Pipeliner
	constructor: (config) ->
		@setConfig config

	setConfig: (config) ->
		@_config = config

	getConfig: () ->
		@_config

module.exports = Pipeliner		