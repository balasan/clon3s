

module.exports = function(app, db){

	var format = require('util').format
	 	, crypto = require('crypto');

	function authenticate(name, pass, fn) {
	  
	  	db.userModel.find({},function(err,result){

	  		if(result.length==0){
	  			var user={}
	  			user.salt = randomString();
	  			user.username = 'admin'
				user.password = hash('password', user.salt);
				var newUser = new db.userModel(user);    		
				newUser.save(function (err) {	    
		    		if(err){ 
		    			console.log("couln't init user");
		    			console.log(err)
		    		}
		    		else {
		    			console.log('user init - name:admin password:password')
		    			return fn(null, user);
		    		}
	  			})
	  		}
	  		else{
			  	db.userModel.findOne({username:name},function(err,user){
				  if (err || !user){
				  	console.log('cannot find user')
				  	 return fn(new Error('cannot find user'));
					}
				  if (user.password == hash(pass, user.salt)){ 
				  	return fn(null, user);
				  }
				  console.log('invalid password')
				  	fn(new Error('invalid password'));  
			  });
	  		}
	  	})

	}

	function hash(msg, key) {
  		return crypto.createHmac('sha256', key).update(msg).digest('hex');
	}

	function randomString() {
		var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
		var string_length = 13;
		var randomstring = '';
		for (var i=0; i<string_length; i++) {
			var rnum = Math.floor(Math.random() * chars.length);
			randomstring += chars.substring(rnum,rnum+1);
		}
		return randomstring;
	}

	return{

		login : function(req, res){
			if(req.body.logout){
			  req.session.destroy(function(){
			    res.redirect('home');
			  });	
			}
			if(req.body.login){
			  authenticate(req.body.username, req.body.password, function(err, user){
			    if (user) {
			      	// Regenerate session when signing in
			      	// to prevent fixation 
			      	req.session.regenerate(function(){
			        // Store the user's primary key 
			        // in the session store to be retrieved,
			        // or in this case the entire user object
			        req.session.user = user.username;
			        res.redirect('/');
			      });
			    } else {
			      req.session.error = 'Authentication failed, please check your '
			        + ' username and password.'
			        + ' (use "tj" and "foobar")';
			      console.log('req.session.error')
			      res.redirect('back');
			   	}
			  });
			}
		}
	}
}