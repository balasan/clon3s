module.exports = (app, db, passport) ->


  util = require('util')
  FacebookStrategy = require('passport-facebook').Strategy


  passport.serializeUser (user, done) ->
    done null, user

  passport.deserializeUser (obj, done) ->
    done null, obj

  passport.use new FacebookStrategy(
    clientID: process.env.FACEBOOK_APP_ID
    clientSecret: process.env.FACEBOOK_APP_SECRET
    redirect_uri: "http://cms.com:5000"
    callbackURL: "http://cms.com:5000/auth/facebook/callback"
  , (accessToken, refreshToken, profile, done) ->
    
    # asynchronous verification, for effect...
    process.nextTick ->
      
      # To keep the example simple, the user's Facebook profile is returned to
      # represent the logged-in user.  In a typical application, you would want
      # to associate the Facebook account with a user record in your database,
      # and return that user instead.
      done null, profile
  )

  ensureAuthenticated = (req, res, next) ->
    return next()  if req.isAuthenticated()
    res.redirect "/login"
  
  authenticate = (name, pass, fn) ->
    db.userModel.find {}, (err, result) ->
      if result.length is 0
        user = {}
        user.salt = randomString()
        user.username = "admin"
        user.password = hash("password", user.salt)
        newUser = new db.userModel(user)
        newUser.save (err) ->
          if err
            console.log "couln't init user"
            console.log err
          else
            console.log "user init - name:admin password:password"
            fn null, user

      else
        db.userModel.findOne
          username: name
        , (err, user) ->
          if err or not user
            console.log "cannot find user"
            return fn(new Error("cannot find user"))
          return fn(null, user)  if user.password is hash(pass, user.salt)
          console.log "invalid password"
          fn new Error("invalid password")


  hash = (msg, key) ->
    crypto.createHmac("sha256", key).update(msg).digest "hex"
  randomString = ->
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz"
    string_length = 13
    randomstring = ""
    i = 0

    while i < string_length
      rnum = Math.floor(Math.random() * chars.length)
      randomstring += chars.substring(rnum, rnum + 1)
      i++
    randomstring
  format = require("util").format
  crypto = require("crypto")
  


  login: (req, res) ->
    if req.body.logout
      req.session.destroy ->
        res.redirect "home"

    if req.body.login
      authenticate req.body.username, req.body.password, (err, user) ->
        if user
          
          # Regenerate session when signing in
          # to prevent fixation 
          req.session.regenerate ->
            
            # Store the user's primary key 
            # in the session store to be retrieved,
            # or in this case the entire user object
            req.session.user = user.username
            res.redirect "/"

        else
          req.session.error = "Authentication failed, please check your " + " username and password." + " (use \"tj\" and \"foobar\")"
          console.log "req.session.error"
          res.redirect "back"

