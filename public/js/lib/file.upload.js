/* file.upload.js | version : 0.1.1 | author : John Fischer | license : MIT */
(function(fileUpload) {
    var __onprogress,
        __onsuccess,
        __$progress;
        
    fileUpload.bind = function(options) {
        
        var self = this;
        
        // if (!window.File || !window.FileReader || !window.FileList || !window.Blob) {
        //     throw new Error("The File APIs are not fully supported in this browser.");
        // }

        self.options = {
            button: '#uploadFiles',
            input: '#files',
            progress: '#status',
            url: 'upload',
            onprogress: function(data) {
                throw new Error("You should defined onprogress: function(data) { file, meanSpeed, progress, size, timeRest }");
            },
            onsuccess: function (file) {
                throw new Error("You should defined onsuccess: function(file) { name, type, size, data }");
            }        
        };
        
        for (var key in options) {
            self.options[key] = options[key];
        }
        
        // Starting the job
        $(self.options.input).live("change", function(e){ 

            
            var uri = 'http://'+$(location).attr('host')+'/'//window.location.origin+'/';
            var index = uri.indexOf('#', 0);
            if (index != -1) {
                uri = uri.slice(0, index);   
            }
            self.uri = uri;            
            self.files = e.target.files;
            //uploadFiles(uri + self.options.url, e.target.files);
        });

        //$(self.options.button).live("click", function(){
        
        fileUpload.startUpload = function(id){

            //self.files[0].id = id;
            //console.log(self.files)
            uploadFiles(self.uri + self.options.url, self.files, id);

       };


        __$progress = $(self.options.progress);
        __onprogress = self.options.onprogress;
        __onsuccess = self.options.onsuccess;
    };
        
    function getHumanSize(size) {
        var type = "o";

        if (size > 1024) {
            size = size / 1024;
            type = "KB";
        }

    	if (size > 1024) {
    	    size = size / 1024;
    	    type = "MB";
    	}
        
    	return size.toFixed(1).toString().replace('.0', '') + type;
    }
    
    function updateProgress(e) {
        
        if (e.lengthComputable) {
            
            var file = e.target.file;
            var curTime = new Date();
            var speed = (e.loaded - e.target.loaded) / ((curTime - e.target.time) * 1.024); // speed in Ko / s (1000/1024)
            var meanSpeed = Math.floor((speed + e.target.speed) / 2);
            
            var bytesToLoad = (file.size - e.target.loaded) / 1024;
            var timeRest = ((bytesToLoad / meanSpeed) + 0.7 * e.target.timeRest) / 1.7;
            
            if (meanSpeed < 1024) {
                meanSpeed += 'KB/s';
            }
            else {
                meanSpeed = (meanSpeed / 1024).toFixed(1).toString().replace('.0', '') + 'MB/s';
            }
            
            // e.target.timeRest = timeRest;
            // e.target.time = curTime;
            // e.target.loaded = e.loaded;
            // e.target.speed = speed;
            
            file.type = file.type.replace("/", "_");
            var size = getHumanSize(file.size);
            
            var progress = Math.floor((e.loaded / e.total) * 1000) / 10;
            
            __onprogress({file:file, meanSpeed:meanSpeed, progress:progress, timeRest:timeRest.toFixed(0) + 's', size:size});
        }
    }

    function uploadFiles(root, files, id) {
        
        function ajaxDL(root, files, i, id) {

            if (i == files.length)
                return;

            var file = files[i];
            var formData = new FormData();
            formData.append("file", file);
            formData.append("id", id);


            var xhr = new XMLHttpRequest();
            xhr.upload.file = file;
            xhr.upload.time = new Date();
            xhr.upload.loaded = xhr.upload.speed = xhr.upload.timeRest = 0;
            // sous IE event is different
            
            if (xhr.upload.addEventListener) {
                xhr.upload.addEventListener("progress", updateProgress, false);
            } else if (xhr.upload.attachEvent) {
                xhr.upload.attachEvent("progress", updateProgress);
            }
            
            xhr.open("POST", root);
            xhr.send(formData);
            xhr.onreadystatechange = function() {
                
                if (xhr.readyState == 4 && xhr.status == 200) {
                    
                    __$progress.html('');
                    
                    __onsuccess({
                        name: file.name,
                        resp: JSON.parse(xhr.responseText),
                        type: file.type,
                        size: file.size
                    });
                                 
                    ajaxDL(root, files, i+1);
                }
            };
        }

        ajaxDL(root, files, 0 ,id);
    }
})(window.fileUpload || (window.fileUpload = {}));