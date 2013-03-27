class QProvider
	constructor: ->
		@_internalQueue = []

	push: (object) ->
		@_internalQueue.push object

	pop: (callback) ->
		callback @_internalQueue.pop()

module.exports = QProvider