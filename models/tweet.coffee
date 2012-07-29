db_client = require('../db')

exports.find_all = (callback) ->
  q='SELECT * FROM users INNER JOIN tweets ON tweets.user_id = users.id LIMIT 10;'
  db_client.query q, callback

exports.find_user = (username, callback) ->
  q = "SELECT * FROM users WHERE username = '"+username+"';"
  console.log q
  db_client.query q, callback

exports.save_tweet = (user_id, content, callback) ->
	db_client.query 'INSERT INTO tweets(user_id, content) VALUES($1, $2)', [user_id,content], callback