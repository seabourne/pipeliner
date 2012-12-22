mongoose = require('mongoose')
Schema = mongoose.Schema

SettingSchema = new mongoose.Schema
	name: String
	value: Schema.Types.Mixed

Setting = mongoose.model 'Setting', SettingSchema

module.exports = Setting