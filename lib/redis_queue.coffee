redisq = require 'redisq'

Queue = require './queue'

class _RedisQueue extends Queue
	# TODO: factory to set options
	constructor: (name) ->
		@rq = redisq.queue name

	push: (object) ->
		@rq.push object

	process: (callback) ->
		@rq.process callback, 1


module.exports = _RedisQueue
