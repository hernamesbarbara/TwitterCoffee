connect = require('connect')
express = require('express')
jade = require('jade')
routes = require('./routes')

app = module.exports = express.createServer()


# CONFIGURATION
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

app.configure 'development', () ->
  app.use express.errorHandler({
    dumpExceptions: true
    showStack     : true
  })

app.configure 'production', () ->
  app.use(express.errorHandler())

app.get('/', routes.index)
app.post('/send', routes.newTweet)

# SERVER

app.listen(3000)
console.log("Express server listening on port 3000")