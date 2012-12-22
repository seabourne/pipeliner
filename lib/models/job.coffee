mongoose = require('mongoose')
Schema = mongoose.Schema

JobSchema = new mongoose.Schema
	flowId: String
	moduleId: String
	runId: Number
	complete: {type: Boolean, default: false}
	createdOn: {type: Date, default: Date.now}
	error: Schema.Types.Mixed
	data: Schema.Types.Mixed

Job = mongoose.model 'Job', JobSchema

module.exports = Job