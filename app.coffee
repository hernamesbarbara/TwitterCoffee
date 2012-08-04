express = require("express")
http = require("http")
jade    = require('jade')
connect = require('connect')
routes  = require('./routes')

app = express()
server = http.createServer(app)
io = require("socket.io").listen(server)
server.listen(8000)

app.configure(() ->
  app.set('view engine', 'jade')
  app.set('views', "#{__dirname}/views")

  app.use(connect.bodyParser())
  app.use(connect.static(__dirname + '/public'))
  app.use(express.cookieParser())
  app.use(express.session({secret : "shhhhhhhhhhhhhh!"}))
  app.use(express.logger())
  app.use(express.methodOverride())
  app.use(app.router)
)

app.get('/', routes.index)
app.post('/send', routes.newTweet)