module.exports = (connection) -> 
	return connection.models['Job'] if connection.models['Job']
	Schema = connection.base.Schema

	JobSchema = new Schema
		flowId: String
		moduleId: String
		runId: String
		order: {type: Number, default: 0}
		complete: {type: Boolean, default: false}
		createdOn: {type: Date, default: Date.now}
		error: Schema.Types.Mixed
		data: Schema.Types.Mixed

	return connection.model 'Job', JobSchema