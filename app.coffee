connect        = require('connect')
flash          = require('connect-flash')
express        = require("express")
http = require("http")
passport       = require("passport")
jade           = require('jade')
less           = require('less')
lessMiddleware = require('less-middleware')
util           = require("util")
LocalStrategy  = require("passport-local").Strategy
routes         = require('./routes/routes')
app            = express()
server         = http.createServer(app)
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
  done null, user.id

passport.deserializeUser (id, done) ->
  findById id, (err, user) ->
    done err, user

passport.use new LocalStrategy (username, password, done) ->
  process.nextTick ->
    findByUsername username, (err, user) ->
      return done(err) if err
      unless user
        return done(null, false,
          message: "Unkown user " + username
        )
      unless user.password is password
        return done(null, false,
          message: "Invalid password"
        )
      done null, user

UserSchema = require('./models/models').User
users = new UserSchema

findById = (id, fn) ->
  users.find_by_id id, (err, result) ->
    if err
      fn new Error("User " + id + " does not exist")
    else
      fn null, result.rows[0]

findByUsername = (username, fn) ->
  users.find_by_username username, (err,result) ->
    if err
      fn new Error("ERROR from 'findByUsername' with " + username)
    else
      if result and result.rows.length is 1
        return fn(null, result.rows[0])  if result.rows[0].username is username
      fn null, null

ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/login"

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

app.get('/', routes.index)
app.post('/send', routes.newTweet)
app.get('/signup', routes.signup)
app.post('/signup', routes.newUser)
app.get('/login', routes.login)

app.post "/login", passport.authenticate("local",
  failureRedirect: "/login"
  failureFlash: true
), (req, res) ->
  res.redirect "/"

app.get("/logout", routes.logout)