redisq = require 'redisq'

Queue = require './queue'

class RedisQueue extends Queue
	# TODO: factory to set options like host, concurrency
	constructor: (name) ->
		@rq = redisq.queue name
		@concurrency = 1

	push: (object) ->
		# TODO this can fail
		@rq.push object, ->

	process: (callback) ->
		@rq.process callback, @concurrency


module.exports = RedisQueue
