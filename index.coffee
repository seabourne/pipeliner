mongoose = require('mongoose')

config = {}

exports.Flow = Flow = require './lib/flow'
exports.Module = Module = require './lib/module'
exports.Job = Job = require './lib/models/job'

setConfig = (config) ->
	return false if not config.db?
	mongoose.connection.on 'error', console.error.bind console, 'connection error:'
	mongoose.connect config.db

exports.createFlow = (config, callback) ->
	flow = new Flow(config)
	return callback(flow)

exports.getFlow = (id, callback) ->
	Flow.findById id, (err, flw) ->
		flow = new Flow(flw) if flw
		callback(err, flow)

exports.setConfig = setConfig

