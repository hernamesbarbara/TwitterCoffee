db_client = require('../db')

validateEmail = (email) ->
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  re.test email

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
    db_client.query q, callback

  save: (username, password, callback) ->
    if validateEmail(username)
      this.unique_email username, (status) ->
        if not status.valid
          callback({validation: "duplicate_user", message:"Usernames must be unique"})
        else
          db_client.query 'INSERT INTO users(username, password) VALUES($1, $2)', [username, password], callback
    else callback({validation: "email_format", message:"Email format invalid"})

  unique_email: (username, callback) ->
    this.find_by_username username, (err,result) ->
      if err
        callback valid: false
      else if result.rows.length isnt 0
        callback valid: false
      else
        callback valid: true

  valid_password: (password, callback) ->
    if password.length < 5
      callback(valid: false)
    else 
    callback(valid: true)

exports.User = User