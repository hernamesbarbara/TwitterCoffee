db_client = require('../db')

validEmail = (email) ->
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

    this.validate username, password, (err) -> 
      if err then callback(err)

      else
        #SAVE THE USER
        db_client.query 'INSERT INTO users(username, password) VALUES($1, $2)', [username, password]
        
        #RETURN THE USER
        db_client.query "SELECT * FROM users WHERE username = '"+username+"';", (err, result) ->
          if err then callback(err)
          else
            user = result.rows[0]
            callback(user)

  validate:(username, password, fn) ->
    if not validEmail(username) 
      fn({error:{reason: "email_format"}})

    else this.is_unique username, (isUnique) ->
      if isUnique
        fn()
      else
        fn({error:{reason: "duplicate_user"}})


  is_unique: (username, callback) ->
    this.find_by_username username, (err, result) ->

      if err
        return callback(false)
      else if result and result.rows and result.rows.length > 0
        return callback(false)
      else
        return callback(true)

exports.User = User