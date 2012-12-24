mongoose = require('mongoose')
Schema = mongoose.Schema

JobSchema = new mongoose.Schema
	flowId: String
	moduleId: String
	runId: String
	complete: {type: Boolean, default: false}
	createdOn: {type: Date, default: Date.now}
	error: Schema.Types.Mixed
	data: Schema.Types.Mixed

module.exports = (connection) ->
	return connection.model 'Job', JobSchema