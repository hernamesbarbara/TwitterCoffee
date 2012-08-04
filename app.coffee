express = require("express")
http = require("http")
jade    = require('jade')
less = require('less')
lessMiddleware = require('less-middleware')
connect = require('connect')
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
  app.use lessMiddleware({src: __dirname + "/public", compress: true})
  app.use(connect.static(__dirname + '/public'))
  app.use(express.cookieParser())
  app.use(express.session({secret : "shhhhhhhhhhhhhh!"}))
  app.use(express.logger())
  app.use(express.methodOverride())
  app.use(app.router)
)

app.get('/', routes.index)
app.post('/send', routes.newTweet)
app.get('/signup', routes.signup)
app.post('/signup', routes.newUser)

