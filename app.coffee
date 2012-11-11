
###
Module dependencies.
###

db = null
express = require("express")
passport = require('passport')
routes = require("./routes")(app, db)
upload = require("./routes/upload")(app, db)
login = require("./routes/login")(app, db, passport)
http = require("http")
path = require("path")
app = express()

MongoStore = require("connect-mongo")(express)

sessionStore = new MongoStore(
  url: "mongodb://" + process.env.MONGODB_USERNAME + ":" + process.env.MONGODB_PASSWORD + "@ds041347.mongolab.com:41347/cloner")

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use(express.cookieParser('blabla'));
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.session(
    store: sessionStore
    secret: "doin sum clonin"
    cookie:
      path: "/"
      expires: true
      maxAge: 60000 * 60 * 24
  )
  app.use(passport.initialize());
  app.use(passport.session());
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get "/", routes.index
app.post "/grabsite", routes.grabsite
app.post "/saveSite", upload.saveSite



app.get "/auth/facebook", passport.authenticate("facebook", {display:'popup'}), (req, res) ->
app.get "/auth/facebook/callback", passport.authenticate("facebook",
  failureRedirect: "/login"
), (req, res) ->
  res.redirect '/'
app.get "/logout", (req, res) ->
  req.logout()
  res.redirect '/'



http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

