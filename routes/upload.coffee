module.exports = (app, db) ->

  fmt = require("fmt")
  uuid = require("node-uuid")
  fs = require("fs")
  util = require("util")
  awssum = require("awssum")
  im = require("imagemagick")
  amazon = awssum.load("amazon/amazon")
  S3 = awssum.load("amazon/s3").S3
  s3 = new S3(
    accessKeyId: process.env.AWS_ACCESS_KEY_ID
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    region: amazon.US_EAST_1
  )



  uploadFile = (req, targetdir, callback) ->
    moveToDestination = (sourcefile, targetfile, filesize, filetype) ->
      processFile sourcefile, targetfile, filesize, filetype, (err, data) ->
        unless err
          callback
            success: true
            data: data

        else
          callback
            success: false
            error: err



    
    # moveFile(sourcefile, targetfile, function(err) {
    #     if(!err)
    #         callback({success: true});
    #     else
    #         callback({success: false, error: err});
    # });

    if req.xhr
      fname = req.header("x-file-name")
      size = req.header("x-file-size")
      type = req.header("x-file-type")
      console.log fname + " " + size + " " + type
      
      # Be sure you can write to '/tmp/'
      fileId = uuid.v1()
      tmpfile = "/tmp/" + fileId
      
      # Open a temporary writestream
      ws = fs.createWriteStream(tmpfile)
      ws.on "error", (err) ->
        console.log "uploadFile() - req.xhr - could not open writestream."
        callback
          success: false
          error: "Sorry, could not open writestream."


      ws.on "close", (err) ->
        moveToDestination tmpfile, fileId + "_" + fname, size, type

      
      # Writing filedata into writestream
      req.on "data", (data) ->
        ws.write data

      req.on "end", ->
        ws.end()

    
    # Old form-based upload
    else
      moveToDestination req.files.qqfile.path, targetdir + req.files.qqfile.name

  smallImage = 256
  mediumImage = 512
  imageSizes =
    small: 256
    medium: 512

  processFile = (source, filename, filesize, filetype, callback) ->
    
    #TODO only for images
    im.identify source, (err, features) ->
      console.log features  unless err
      
      #     var features = { format: 'JPEG', width: 20, height: 20, depth: 8 };
      #     console.log(features.width)
      ((filename, filesize, filetype, features) ->
        uploadToAmazon filename, source, filetype, (err) ->
          unless err
            addToMediaLibrary decodeURIComponent(filename), filetype, features.width, features.height, null, (err, data) ->
              console.log err  if err
              callback err, data


      ) filename, filesize, filetype, features

    
    #TODO: add mongoose media library
    #     if(err)
    #         console.log(err)
    #     else{
    #     }
    # })
    # { format: 'JPEG', width: 3904, height: 2622, depth: 8 }
    return
    error = null
    for key of imageSizes
      
      # console.log(imageSizes[key])
      destPath = source + "-" + key
      parts = /(.+)\.([^.]+)/.exec(filename)
      newName = parts[1] + "-" + key + "." + parts[2]
      
      #console.log(newName)
      ((newName, destPath, filetype) ->
        im.resize
          srcData: fs.readFileSync(source, "binary")
          width: imageSizes[key]
        
        # srcPath: source,
        # dstPath: destPath,
        , (err, stdout, stderr) ->
          unless err
            
            # console.log(newName)
            fs.writeFileSync destPath, stdout, "binary"
            uploadToAmazon newName, destPath, filetype

      ) newName, destPath, filetype
    callback error

  addToMediaLibrary = (filename, filetype, width, height, kind, callback) ->
    url = "https://s3.amazonaws.com/" + process.env.S3_BUCKET_NAME + "/" + filename
    console.log url
    newMediaObj =
      url: url
      name: filename
      type: filetype
      width: width
      height: height

    unless kind
      newMedia = new db.mediaModel(newMediaObj)
      newMedia.save (err) ->
        if err
          console.log err
        else
          callback null, newMedia


  uploadToAmazon = (fileName, filePath, fileType, callback) ->
    fs.stat filePath, (err, stats) ->
      if err
        return
        console.log err
        callback err
      fileSize = stats.size
      bodyStream = fs.createReadStream(filePath)
      options =
        BucketName: process.env.S3_BUCKET_NAME
        ObjectName: decodeURIComponent(fileName)
        ContentType: fileType
        ContentLength: fileSize
        Body: bodyStream

      s3.PutObject options, (err, data) ->
        if err
          
          #fmt.field('UploadFailed', newName);
          console.log err
          callback err
          
          # put this item back on the queue if retries is less than the cut-off
          # if ( item.retries > 2 ) {
          #     fmt.field('UploadCancelled', item.filename);
          # }
          # else {
          #     // try again
          #     item.retries = item.retries ? item.retries+1 : 1;
          #     uploadItemQueue.push(item);
          # }
          
          # error = err;
          return
        else
          callback null



  
  #console.log(data)
  #addToMediaLibrary(fileName, fileType, width, height, kind, callback){
  
  #console.log(out)
  
  # Moves a file asynchronously over partition borders
  moveFile = (source, dest, callback) ->
    is_ = fs.createReadStream(source)
    is_.on "error", (err) ->
      console.log "moveFile() - Could not open readstream."
      callback "Sorry, could not open readstream."

    is_.on "open", ->
      os = fs.createWriteStream(dest)
      os.on "error", (err) ->
        console.log "moveFile() - Could not open writestream."
        callback "Sorry, could not open writestream."

      os.on "open", ->
        util.pump is_, os, ->
          fs.unlinkSync source

        callback()

  saveSite: (req, res) ->
    console.log('saving')
    filename = req.body.name + ".html"
    html = req.body.content
    path = "/tmp/"+filename
    fs.writeFile "/tmp/"+filename, html, (err) ->
      if err
        console.log err
        res.send JSON.stringify(err),
          "Content-Type": "text/plain"
        , 404
      else
        console.log "The file was saved!"
        uploadToAmazon filename, path, "text/html", (data) ->
          console.log(data)
          res.send JSON.stringify(data),
            "Content-Type": "text/plain"
          , 200



  fileUpload: (req, res) ->
    uploadFile req, "./tmp", (data) ->
      if data.success
        res.send JSON.stringify(data),
          "Content-Type": "text/plain"
        , 200
      else
        res.send JSON.stringify(data),
          "Content-Type": "text/plain"
        , 404

