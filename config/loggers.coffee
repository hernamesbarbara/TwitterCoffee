util      = require('util')
winston   = require('winston')
winstond  = require('winstond')
MongoDB   = require('winston-mongodb').MongoDB

config =
  levels:
    auth:    0
    verbose: 1
    info:    2
    data:    3
    warn:    4
    debug:   5
    error:   6

  colors:
    auth:    'cyan',
    verbose: 'magenta',
    info:    'green',
    data:    'grey',
    warn:    'yellow',
    debug:   'blue',
    error:   'red'

  file:
    filename: './log/log.json'

###
  WINSTOND SERVER
###  
server = winstond.nssocket.createServer
  services: ["collect", "query", "stream"]
  port: 9003

server.add MongoDB,
  db: "twittercoffee"
  collection: 'logs'
  safe: true
  host: 'localhost'
  port: 27017
  keepAlive: 1000

server.listen()

###
  Loggers
###

to_console = new winston.Logger
  transports: [ new (winston.transports.Console)(colorize: true, level: 'auth') ]
  levels: config.levels
  colors: config.colors

to_db = new winston.Logger
  levels: config.levels
  level: 'auth'

to_db.add require("winston-nssocket").Nssocket,
  host: "127.0.0.1"
  port: 9003
  level: 'auth'

to_db.stream().on "log", (message) ->
  to_console.auth JSON.stringify(message)


to_console.exitOnError = false
to_db.exitOnError = false
loggers =  module.exports = {"to_console": to_console, "to_db": to_db}