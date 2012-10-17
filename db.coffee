module.exports = ->
  mongoose = require("mongoose")
  
  #mongoose.connect('mongodb://'+ process.env.MONGODB_USERNAME + ':'+ process.env.MONGODB_PASSWORD + '@ds035137.mongolab.com:35137/cms')
  mongoose.connect "mongodb://" + process.env.MONGODB_USERNAME + ":" + process.env.MONGODB_PASSWORD + "@ds033047.mongolab.com:33047/infwin"

  Schema = mongoose.Schema

  elementSchema = new Schema(
    url: String
    name:
      type: String
      index: true
    renditions: Array
    tags:
      type: Array
      index: true
    source: String
    size: Number
    width: Number
    height: Number
    order: Number
    parent: String
    page: String
    text: String
    type: String
  )

  moduleSchema = new Schema(
    width: Number
    height: Number
    elements: [elementSchema]
    order: Number
    space:
      type: Number
      default: 0
    parent: String
    page: String
  )

  pageSchema = new Schema(
    name:
      type: String
      index:
        unique: true
    modules: [moduleSchema]
    space:
      type: Number
      default: 0
  )
  
  userSchema = new Schema(
    username:
      type: String
      index:
        unique: true

    salt:
      type: String

    password: Buffer
  )

  mediaSchema = new Schema(
    url: String
    name:
      type: String
      index: true
    renditions: [renditionsSchema]
    width: Number
    height: Number
    parent: String
    type: String
    tags:
      type: Array
      index: true
  )
 
  renditionsSchema = new Schema(
    type: String
    url: String
    kind: String
    height: Number
    width: Number
  )

  elementModel: mongoose.model("textModel", elementSchema)
  moduleModel: mongoose.model("moduleModel", moduleSchema)
  pageModel: mongoose.model("pageModel", pageSchema)
  userModel: mongoose.model("userModel", userSchema)
  mediaModel: mongoose.model("mediaModel", mediaSchema)
  renditionsSchema: mongoose.model("renditionsModel", renditionsSchema)
