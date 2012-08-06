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
    console.log '**NEW TWEET**\nUSER ID: '+user_id+'\nCONTENT '+content
    db_client.query 'INSERT INTO tweets(user_id, content) VALUES($1, $2)', [user_id,content], callback

exports.Tweet = Tweet

class User
  find_all: (callback) ->
    q='SELECT * FROM users;'
    db_client.query q, callback

  find_by_username: (username, callback) ->
    q = "SELECT * FROM users WHERE username = '"+username+"';"
    db_client.query q, callback

  find_by_id: (id, callback) ->
    q = "SELECT * FROM users WHERE id = '"+id+"';"
    console.log q
    db_client.query q, callback

  save: (username, password, callback) ->
    console.log 'inside save method'
    this.unique_email username, (status) ->
      if not status.valid
        console.log 'user isnt valid'
        callback({error: {code: "unable to save this user"}})
      else
        db_client.query 'INSERT INTO users(username, password) VALUES($1, $2)', [username, password], callback    

  unique_email: (username, callback) ->
    this.find_by_username username, (err,result) ->
      if err
        console.log err
        callback valid: false
      else if result.rows.length isnt 0
        callback valid: false
      else
        console.log 'unique user'
        callback valid: true

  valid_password: (password, callback) ->
    console.log 'valid_password called in models'
    true

exports.User = User