express = require("express")
http = require("http")
jade    = require('jade')
less = require('less')
lessMiddleware = require('less-middleware')
connect = require('connect')
passport = require("passport")
LocalStrategy = require("passport-local").Strategy
routes  = require('./routes/routes')

app = express()
server = http.createServer(app)
io = require("socket.io").listen(server)

port = process.env.PORT || 8000
console.log("Listening on " + port)
server.listen(port)

app.configure(() ->
  app.set('view engine', 'jade')
  app.set('views', "#{__dirname}/views")

  app.use(connect.bodyParser())
  app.use(lessMiddleware({src: __dirname + "/public", compress: true}))
  app.use(connect.static(__dirname + '/public'))
  app.use(passport.initialize())
  app.use(passport.session())
  app.use(express.cookieParser())
  app.use(express.session({secret : "shhhhhhhhhhhhhh!"}))
  app.use(express.logger())
  app.use(express.methodOverride())
  app.use(app.router)
)

User  = require('./models/models').User
users = new User
#user = new User

##

# find_by_id = (id, fn) ->
#   User.find_by_id
#     id: id, (rsp) ->
#       if rsp isnt `undefined` & rsp.objects isnt `undefined` & rsp.objects.length > 0
#         fn(null, rsp.objects[0])
#       else
#         fn(new Error("User " + id + " does not exist"), null)

findByUsername = (username, fn) ->
  users.find_by_username
    username: username, (rsp) ->
      if rsp isnt `undefined` & rsp.objects isnt `undefined` & rsp.objects.length > 0
        fn(null, rsp.objects[0])
      else
        fn(new Error("User " + username + " does not exist"), null)



##
passport.use new LocalStrategy((username, password, done) ->
  console.log 'passport local strategy called in app.coffee'
  users.find_by_username username, (err, user) ->
    console.log 'calling find_by_username from app.coffee'
    return done(err) if err
    unless user
      return done(null, false, message: "Unknown user" )
    done(null, user)
)

passport.serializeUser (user, done) ->
  console.log 'serialize user called'
  done null, user

passport.deserializeUser (obj, done) ->
  console.log 'de serialize user called'
  done null, obj



app.get('/', routes.index)
app.post('/send', routes.newTweet)
app.get('/signup', routes.signup)
app.post('/signup', routes.newUser)

app.get('/login', routes.login)


app.post "/login", (req, res, next) ->
  console.log 'username'
  passport.authenticate("local", (err, user, info) ->
    console.log 'err',err
    console.log 'user', user
    console.log 'info', info
    return next(err) if err
    console.log 'finding user_id'
    users.find_by_username req.body.user.username, (err, results) ->
      user = results.rows[0].username
      if not user
          return res.redirect("/login")
      else 
        res.redirect "/"

  ) req, res, next

