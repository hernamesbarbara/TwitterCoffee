pg = require('pg')
db_conn = process.env.DATABASE_URL || 'postgres://austinogilvie:@localhost:5432/twitter'
port    = process.env.PORT || 8000
client  = new pg.Client(db_conn)
client.connect()
module.exports = client