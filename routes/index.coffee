pg = require('pg')
db_conn = process.env.DATABASE_URL || 'postgres://austinogilvie:@localhost:5432/twitter'
port    = process.env.PORT || 3000
db_client  = new pg.Client(db_conn)
db_client.connect();

tweets = []
exports.index = (req, res) ->
  query='SELECT * FROM users INNER JOIN tweets ON tweets.user_id = users.id LIMIT 10;'

  db_client.query query, null, (err, result) ->
    if err
      console.log "AN ERROR OCCURED: " + err
    else
      res.render 'index',
        title: 'Chirpie',
        header: 'Welcome to Chirpie',
        tweets: result.rows

exports.newTweet = (req, res) ->
  console.log req.body.tweet.username
  if req.body and req.body.tweet
    query = "SELECT * from users WHERE username = '" + req.body.tweet.username+"';"
    console.log query
    db_client.query query, null, (err, result) ->
      if err
        console.log "NO user found"
      else
        console.log result
        user_id = result.rows[0].id
        query = db_client.query('INSERT INTO tweets(user_id, content) VALUES($1, $2)', [user_id,req.body.tweet.content])
    if accepts_html(req.headers['accept']) is true
      res.redirect('/')
    else
      res.send({status:"OK", message: "tweet received"})
  else
    res.send({status:"NOT_OK", message: "no tweet received"})

accepts_html = (header) ->
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included

in_array = (list, id) ->
  included = id in list
  return included

