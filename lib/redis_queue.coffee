redisq = require 'redisq'

Queue = require './queue'

class RedisQueue extends Queue
	# TODO: factory to set options like host, concurrency
	constructor: (name) ->
		@rq = redisq.queue name
		@concurrency = 1

	push: (object) ->
		# TODO this can fail
		@rq.push object, =>
			@emit 'push', object

	process: (callback) ->
		@rq.process callback, @concurrency
		@on 'push', (object) =>
			if not @rq.workersActive
				@rq.process callback, @concurrency

	purge: ->
		@rq.purge (err, res) =>
			@emit 'purged' if res

module.exports = RedisQueue
