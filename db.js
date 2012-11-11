

module.exports = function(){

	var mongoose = require('mongoose');
	mongoose.connect('mongodb://'+ process.env.MONGODB_USERNAME + ':'+ process.env.MONGODB_PASSWORD + '@ds041347.mongolab.com:41347/cloner')


	var Schema = mongoose.Schema;

	var elementSchema = new Schema({
		url:String
		,name:{type: String, index: true}
		,renditions:Array
		,tags:{type: Array, index: true}
		,source:String
		,size:Number
		,width:Number
		,height:Number
		,order:Number
		,parent:String
		,page:String
		,text: String
		,type: String
	})


	var pageSchema = new Schema({
		name:{type : String, index: { unique: true }}
		,modules : [moduleSchema]
		,space:{type: Number, default: 0}
	  //, images      : [imageSchema]
	})

	var userSchema = new Schema({
		  username : {type :String,  index: { unique: true }}
		, salt : {type: String}
		, password : Buffer
	});

	var mediaSchema = new Schema({
		url:String
		,name:{type: String, index: true}
		,renditions:[renditionsSchema]
		,width:Number
		,height:Number
		,parent:String
		,type:String
		,tags:{type: Array, index: true}
	})

	var renditionsSchema = new Schema({
		type:String
		,url:String
		,kind:String
		,height:Number
		,width:Number
	})

	return {
		// elementModel : mongoose.model('textModel', elementSchema),
		pageModel : mongoose.model('pageModel', pageSchema),
		userModel : mongoose.model('userModel', userSchema),
		mediaModel: mongoose.model('mediaModel', mediaSchema),
		renditionsSchema : mongoose.model('renditionsModel',renditionsSchema)
	}

}