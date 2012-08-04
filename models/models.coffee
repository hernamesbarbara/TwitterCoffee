db_client = require('../db')

class Tweet
  find_all: (callback) ->
    q='SELECT * FROM users INNER JOIN tweets ON tweets.user_id = users.id LIMIT 10;'
    db_client.query q, callback
  
  find_user: (username, callback) ->
    q = "SELECT * FROM users WHERE username = '"+username+"';"
    console.log q
    db_client.query q, callback  	
  
  save: (user_id, content, callback) ->
    console.log user_id, content
    db_client.query 'INSERT INTO tweets(user_id, content) VALUES($1, $2)', [user_id,content], callback

exports.Tweet = Tweet

class User
  find_all: (callback) ->
    q='SELECT * FROM users;'
    db_client.query q, callback

  find_by_username: (username, callback) ->
    q = "SELECT * FROM users WHERE username = '"+username+"';"
    console.log q
    db_client.query q, callback

  save: (username, callback) ->
    console.log 'saving new user '+username
    db_client.query 'INSERT INTO users(username) VALUES($1)', [username], callback

  valid_password: (password, callback) ->
    console.log 'valid_password called in models'
    true


exports.User = User