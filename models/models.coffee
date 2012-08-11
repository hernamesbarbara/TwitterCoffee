db_client = require('../db')

valid_email = (email) ->
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  re.test email

class Tweet
  find_all: (callback) ->
    q='SELECT * FROM users INNER JOIN tweets ON tweets.user_id = users.id LIMIT 10;'
    db_client.query q, callback
  
  find_user: (username, callback) ->
    q = "SELECT * FROM users WHERE username = '"+username+"';"
    db_client.query q, callback  	
  
  save: (user_id, content, callback) ->
    console.log '\n'+'**NEW TWEET**\nUSER ID: '+user_id+'\nCONTENT '+content+'\n'
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
    if valid_email(username)
      this.unique_email username, (email) ->
        if email.duplicate or email.err
          err = {invalid: true, validation: "duplicate_user"}
          callback(err)
        else
          db_client.query 'INSERT INTO users(username, password) VALUES($1, $2)', [username, password]
          db_client.query "SELECT * FROM users WHERE username = '"+username+"';", (err, result) ->
            if err
              callback(err)
            else
              user = result.rows[0]
              callback(user)
    else 
      err = {invalid: true, validation: "email_format"}
      callback(err)

  unique_email: (username, callback) ->
    this.find_by_username username, (err,result) ->
      if err
        callback({err: true})
      else if result.rows.length isnt 0
        callback({duplicate: true})
      else
        callback({duplicate: false})

  valid_password: (password, callback) ->
    if password.length < 5
      callback()
    else 
    callback()

exports.User = User