redisq = require 'redisq'

Queue = require './queue'

class RedisQueue extends Queue
	# TODO: factory to set options like host, concurrency
	constructor: (name) ->
		@name = name
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

	length: (cb) ->
		@rq.len (err, len) =>
			console.log err if err
			console.log 'redis q '+@name+' length: '+len
			cb len

module.exports = RedisQueue
