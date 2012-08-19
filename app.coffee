connect        = require('connect')
flash          = require('connect-flash')
express        = require("express")
http           = require("http")
passport       = require("passport")
jade           = require('jade')
less           = require('less')
lessMiddleware = require('less-middleware')
util           = require("util")
LocalStrategy  = require("passport-local").Strategy
routes         = require('./routes/routes')
app            = express()
server = module.exports = http.createServer(app)
#io             = require("socket.io").listen(server)

port = process.env.PORT || 8000
console.log("Express server listening at http://127.0.0.1:#{port}/")
console.log("You're in your #{app.settings.env} environment")
server.listen(port)


# io.sockets.on "connection", (socket) ->
#   socket.emit "news",
#     hello: "world"

#   socket.on "my other event", (data) ->
#     console.log data

passport.serializeUser (user, done) ->
  done(null, user.id)

passport.deserializeUser (id, done) ->
  findById id, (err, user) ->
    done(err, user)

passport.use new LocalStrategy (username, password, done) ->
  process.nextTick ->
    findByUsername username, (err, user) ->
      if err
        return done(err, false)
      
      if not user
        return done(null, false, {message: "Unkown user " + username})
      
      if user.password != password
        return done(null, false, {message: "Invalid password"})
      
      done(null, user)

UserSchema = require('./models/models').UserSchema
Users = new UserSchema

findById = (id, fn) ->
  Users.find id, (err, result) ->
    if err
      fn(new Error("User " + id + " does not exist"))
    else
      fn(null, result.rows[0])

findByUsername = (username, fn) ->
  Users.find_by_username username, (err,result) ->
    if err
      fn(new Error("ERROR from 'findByUsername' with " + username))
    else
      if result and result.rows.length is 1
        return fn(null, result.rows[0]) if result.rows[0].username is username
      fn(null, null)

ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.redirect("/login")

ignoreIfAuthenticated = (req, res, next) ->
  return next() if not req.isAuthenticated()
  res.redirect("/")

loadUser = (req, res, next) ->
  id = req.params.id
  
  Users.find id, (err, result) ->
    if(err)
      res.render "404.jade",
        title: "404 - Page Not Found",
        showFullNav: false,
        status: 404,
        url: req.url

    else if result and result.rows and result.rows.length == 1
      user = result.rows[0]
      user.tweets = user.followers = user.following = []
      
      Users.tweets_for user.id, (err, result) ->
        if(err)
          user.tweets = []
        else
          user.tweets = result.rows

      Users.followers user.id, (err, result) ->
        if(err)
          user.followers = []
        else
          user.followers = result.rows

      Users.following user.id, (err, result) ->
        if(err)
          user.following = []
        else
          user.following = result.rows

      req.loaded_user = user
      next()
    
    else
      res.render "404.jade",
        title: "404 - Page Not Found",
        showFullNav: false,
        status: 404,
        url: req.url

loadCurrentUser = (req, res, next) ->
  id = req.session.passport.user

  Users.find id, (err, result) ->
    if result and result.rows and result.rows.length == 1
      
      user = result.rows[0]
      req.user.tweets = req.user.followers = req.user.following = req.user.feed = []
      
      Users.tweets_for user.id, (err, result) ->
        if(err)
          req.user.tweets = []
        else
          req.user.tweets = result.rows

      Users.followers user.id, (err, result) ->
        if(err)
          req.user.followers = []
        else
          req.user.followers = result.rows

      Users.following user.id, (err, result) ->
        if(err)
          req.user.following = []
        else
          req.user.following = result.rows

      Users.feed user.id, (err, result) ->
        if(err)
          req.user.feed = []
        else
          req.user.feed = result.rows

        next()

    else
      res.render "404.jade",
        title: "404 - Page Not Found",
        showFullNav: false,
        status: 404,
        url: req.url

app.configure ->
  app.set "views", __dirname + "/views"
  app.set('view engine', 'jade')
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.session(secret: "keyboard cat")
  app.use passport.initialize()
  app.use passport.session()
  app.use(connect.static(__dirname + '/public'))
  app.use(lessMiddleware({src: __dirname + "/public", compress: true}))
  app.use flash()
  app.use app.router
  app.use (req, res, next) ->
    res.render "404.jade",
      title: "404 - Page Not Found"
      showFullNav: false
      status: 404
      url: req.url

app.get('/about', routes.about)

app.get('/', ensureAuthenticated, loadCurrentUser, routes.home)
app.get('/home', ensureAuthenticated, routes.home)
app.post('/send', ensureAuthenticated, routes.newTweet)
app.get('/signup', ignoreIfAuthenticated, routes.newUser)
app.post('/signup', ignoreIfAuthenticated, routes.createUser)
app.get('/login', ignoreIfAuthenticated, routes.login)

app.post "/login", passport.authenticate("local",
  failureRedirect: "/login"
  failureFlash: true
), (req, res) ->
  res.redirect "/"

app.get("/logout", routes.logout)

app.get('/users', ensureAuthenticated, routes.usersIndex)
app.get('/users/:id', ensureAuthenticated, loadUser, routes.showUser);