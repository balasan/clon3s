
module.exports = function(app, db){

    var fmt = require('fmt');
    var uuid = require('node-uuid'),
        fs = require('fs'),
        util = require('util'),
        awssum = require('awssum'),
        im = require('imagemagick')


    var amazon = awssum.load('amazon/amazon');
    var S3 = awssum.load('amazon/s3').S3;

    var s3 = new S3({
        accessKeyId: process.env.AWS_ACCESS_KEY_ID
      , secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
      ,region          : amazon.US_EAST_1
    });

    // var knox = require('knox')
    // var client = knox.createClient({
    //     key: process.env.AWS_ACCESS_KEY_ID
    //   , secret: process.env.AWS_SECRET_ACCESS_KEY
    //   , bucket: process.env.S3_BUCKET_NAME
    // });

    var uploadFile = function(req, targetdir, callback) {

        var moveToDestination = function(sourcefile, targetfile, filesize, filetype) {

        	processFile(sourcefile, targetfile, filesize, filetype, function(err, data) {
                if(!err)
                    callback({success: true, data: data});
                else
                    callback({success: false, error: err});
            });

            // moveFile(sourcefile, targetfile, function(err) {
            //     if(!err)
            //         callback({success: true});
            //     else
            //         callback({success: false, error: err});
            // });
        };

        if(req.xhr) {
            var fname = req.header('x-file-name');
            var size = req.header('x-file-size');
            var type = req.header('x-file-type');

            console.log(fname + ' ' + size + " " + type)

            // Be sure you can write to '/tmp/'
            var fileId = uuid.v1()
            var tmpfile = '/tmp/'+fileId;


            // Open a temporary writestream
            var ws = fs.createWriteStream(tmpfile);
            ws.on('error', function(err) {
                console.log("uploadFile() - req.xhr - could not open writestream.");
                callback({success: false, error: "Sorry, could not open writestream."});
            });
            ws.on('close', function(err) {
                moveToDestination(tmpfile, fileId+'_'+fname, size, type);
            });

            // Writing filedata into writestream
            req.on('data', function(data) {
                ws.write(data);
            });
            req.on('end', function() {
                ws.end();
            });
        }

        // Old form-based upload
        else {
            moveToDestination(req.files.qqfile.path, targetdir+req.files.qqfile.name);
        }
    };


    var smallImage = 256;
    var mediumImage = 512;

    var imageSizes={small:256,medium:512}



    var processFile = function(source, filename, filesize, filetype, callback){

        //TODO only for images
        im.identify(source, function(err, features){
            if (err) throw err
            else{
                console.log(features)
            }
        //     var features = { format: 'JPEG', width: 20, height: 20, depth: 8 };
        //     console.log(features.width)

             (function(filename, filesize, filetype, features){

                uploadToAmazon(filename, source, filetype, function(err){
                    if(err)
                        callback(err)
                    else{
                        addToMediaLibrary(decodeURIComponent(filename), filetype, features.width, features.height, null, function(err,data){

                            if(err)
                                console.log(err)

                            callback(err, data)
                        })



                    } 



                })
            
            })(filename, filesize, filetype,features)


            //TODO: add mongoose media library
            //     if(err)
            //         console.log(err)
            //     else{
            //     }
            // })
          // { format: 'JPEG', width: 3904, height: 2622, depth: 8 }
        })

        return;

    	var error=null;
    	for(var key in imageSizes){

    		// console.log(imageSizes[key])
    		var destPath = source+'-'+key;

    		var parts = /(.+)\.([^.]+)/.exec(filename);
    		var newName = parts[1]+'-'+key+'.'+parts[2];

    		//console.log(newName)

    		(function(newName, destPath,filetype){ 
                im.resize({

        		  	srcData: fs.readFileSync(source, 'binary'),
        		    width:   imageSizes[key],
        			 // srcPath: source,
          	         // dstPath: destPath,

        			}, function(err, stdout, stderr){


        		  		if (err) throw err
        		  		else{

        			  		// console.log(newName)

        					fs.writeFileSync(destPath, stdout, 'binary');
                            uploadToAmazon(newName, destPath, filetype)

        		 		}

    	 	})})(newName,destPath,filetype)

    	}
    	
    	callback(error)

    }

    var addToMediaLibrary = function(filename, filetype, width, height, kind, callback){

        var url = 'https://s3.amazonaws.com/' + process.env.S3_BUCKET_NAME +'/' + filename

        console.log(url)

        var newMediaObj = {url:url, name: filename, type:filetype, width: width, height:height}

        if(kind){

        }
        else{
            var newMedia = new db.mediaModel(newMediaObj)

            newMedia.save(function(err){
                if(err)
                    console.log(err)
                else(callback(null, newMedia))
            })           
        }


    }



    var uploadToAmazon = function(fileName, filePath, fileType, callback){

    	fs.stat(filePath, function (err, stats) {
    		if(err){
    			return;
                console.log(err)
    			callback(err)
    		}
    	    var fileSize=stats.size;
    		var bodyStream = fs.createReadStream(filePath);

    	    var options = {
    	        BucketName: process.env.S3_BUCKET_NAME,
    	        ObjectName: decodeURIComponent(fileName),
                ContentType: fileType,
    	        ContentLength: fileSize,
    	        Body:  bodyStream
    	    };

    		s3.PutObject(options, function(err, data) {
    	        if (err) {
    	            //fmt.field('UploadFailed', newName);
    	            console.log(err);

                    callback(err)


    	            // put this item back on the queue if retries is less than the cut-off
    	            // if ( item.retries > 2 ) {
    	            //     fmt.field('UploadCancelled', item.filename);
    	            // }
    	            // else {
    	            //     // try again
    	            //     item.retries = item.retries ? item.retries+1 : 1;
    	            //     uploadItemQueue.push(item);
    	            // }

    	            // error = err;
    	            return;
    	        }
    	        else{
                    callback(null)
                    //console.log(data)
                    //addToMediaLibrary(fileName, fileType, width, height, kind, callback){


    			}
    	  	//console.log(out)

    			})
    		})	
    }



    // Moves a file asynchronously over partition borders
    var moveFile = function(source, dest, callback) {
        var is = fs.createReadStream(source)

        is.on('error', function(err) {
            console.log('moveFile() - Could not open readstream.');
            callback('Sorry, could not open readstream.')
        });

        is.on('open', function() {
            var os = fs.createWriteStream(dest);

            os.on('error', function(err) {
                console.log('moveFile() - Could not open writestream.');
                callback('Sorry, could not open writestream.');
            });

            os.on('open', function() {

                util.pump(is, os, function() {
                    fs.unlinkSync(source);
                });

                callback();
            });
        });
    };




    return {

        fileUpload : function(req, res) {
            uploadFile(req, './tmp', function(data) {
                if(data.success)
                    res.send(JSON.stringify(data), {'Content-Type': 'text/plain'}, 200);
                else
                    res.send(JSON.stringify(data), {'Content-Type': 'text/plain'}, 404);
            });
        }
    }

}