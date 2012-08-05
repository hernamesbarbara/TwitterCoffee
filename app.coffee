users = [
  id: 1
  username: "bob"
  password: "secret"
  email: "bob@example.com"
,
  id: 2
  username: "joe"
  password: "birthday"
  email: "joe@example.com"
]

findById = (id, fn) ->
  idx = id - 1
  if users[idx]
    fn null, users[idx]
  else
    fn new Error("User " + id + " does not exist")

findByUsername = (username, fn) ->
  i = 0
  len = users.length

  while i < len
    user = users[i]
    return fn(null, user)  if user.username is username
    i++
  fn null, null

ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/login"

connect        = require('connect')
flash          = require('connect-flash')
express        = require("express")
passport       = require("passport")
jade           = require('jade')
less           = require('less')
lessMiddleware = require('less-middleware')
util           = require("util")
LocalStrategy  = require("passport-local").Strategy
routes         = require('./routes/routes')

passport.serializeUser (user, done) ->
  console.log 'serializeUser called'
  done null, user.id

passport.deserializeUser (id, done) ->
  console.log 'deserializeUser called'
  findById id, (err, user) ->
    done err, user


passport.use new LocalStrategy((username, password, done) ->
  console.log 'local strategy called'
  process.nextTick ->
    findByUsername username, (err, user) ->
      return done(err)  if err
      unless user
        return done(null, false,
          message: "Unkown user " + username
        )
      unless user.password is password
        return done(null, false,
          message: "Invalid password"
        )
      done null, user


)

app = express.createServer()
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

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

app.listen 8000