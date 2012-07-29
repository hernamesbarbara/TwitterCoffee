pg = require('pg')
db_conn = process.env.DATABASE_URL || 'postgres://austinogilvie:@localhost:5432/twitter'
port    = process.env.PORT || 3000
db_client  = new pg.Client(db_conn)
db_client.connect()
module.exports = db_client