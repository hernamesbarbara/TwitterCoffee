db_client         = require('../db')
AuthError         = require('../shared/ApplicationErrors').AuthenticationError
ValidationError   = require('../shared/ApplicationErrors').ValidationError
ApplicationError  = require('../shared/ApplicationErrors').ApplicationError

validEmail = (email) ->
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  re.test(email)

class Tweet
  all: (callback) ->
    q='SELECT * FROM users INNER JOIN tweets ON tweets.user_id = users.id LIMIT 10;'
    db_client.query q, callback
  
  save: (user_id, content, callback) ->
    this.beforeSave user_id, content, (err, validation) ->
      if err 
        callback(err, null)
      else if validation 
        callback(validation, null)
      else
        #SAVE THE TWEET
        db_client.query 'INSERT INTO tweets(user_id, content) VALUES($1, $2)', [user_id,content]
        
        #RETURN THE NEW TWEET IF SAVED SUCCESSFULLY
        q="SELECT t.* FROM tweets t INNER JOIN users u ON t.user_id = u.id WHERE t.user_id = '"+user_id+"' ORDER BY t.created_at DESC LIMIT 1;"
        db_client.query q, (err, result) ->
          if err
            callback(err, null)
          else
            tweet = result.rows[0]
            callback(null, tweet)

  beforeSave:(user_id, content, fn) ->
    if content.length < 1
      fn(new ValidationError('Tweet must have some content!'))
    else if content.length > 140
      fn(new ValidationError('Tweets must be 140 characters of less'))
    else unless user_id
      fn(new ApplicationError('No user_id was provided'))
    else
      this.ensure_user user_id, (valid) ->
        if valid
          fn() 
        else
          fn(new ApplicationError('The user_id provided was not found'))

  ensure_user: (user_id, callback) ->
    q = "SELECT * FROM users WHERE id = '"+user_id+"';"
    db_client.query q, (err, result) ->
      if err
        return callback(false)
      else unless result and result.rows and result.rows.length is 1
        return callback(false)
      else
        return callback(true)

exports.TweetSchema = Tweet

class User
  all: (callback) ->
    q='SELECT * FROM users;'
    db_client.query q, callback

  find_by_username: (username, callback) ->
    q = "SELECT * FROM users WHERE username = '"+username+"';"
    db_client.query q, callback

  find: (id, callback) ->
    q = "SELECT * FROM users WHERE id = '"+id+"';"
    db_client.query q, callback

  save: (username, password, callback) ->

    this.beforeSave username, password, (err, validation) -> 
      if err then callback(err, null)

      else if validation
        callback(validation, null)
      else
        #SAVE THE USER
        db_client.query 'INSERT INTO users(username, password) VALUES($1, $2)', [username, password]
        
        #RETURN THE USER
        db_client.query "SELECT * FROM users WHERE username = '"+username+"';", (err, result) ->
          if err then callback(err, null)
          else
            user = result.rows[0]
            callback(null, user)
  feed: (user_id, callback) ->
    q = "SELECT following.username, t.* FROM users u INNER JOIN relationships r ON r.follower_id = u.id  INNER JOIN users following ON r.followed_id = following.id INNER JOIN tweets t ON t.user_id = following.id WHERE u.id = '"+user_id+"';"
    db_client.query q, callback

  tweets_for: (user_id, callback) ->
    q = "SELECT t.* FROM tweets t INNER JOIN users u ON u.id = t.user_id WHERE t.user_id = '"+user_id+"';"
    db_client.query q, callback

  followers: (user_id, callback) ->
    q = "SELECT followers.* FROM users u INNER JOIN relationships r ON r.followed_id = u.id INNER JOIN users followers ON r.follower_id = followers.id WHERE u.id = '"+user_id+"';"
    db_client.query q, callback

  following: (user_id, callback) ->
    q = "SELECT following.* FROM users u INNER JOIN relationships r ON r.follower_id = u.id INNER JOIN users following ON r.followed_id = following.id WHERE u.id = '"+user_id+"';"
    console.log 'about to call Users.following() with query:\n', q
    db_client.query q, callback

  beforeSave:(username, password, fn) ->
    #USERNAME MUST BE IN FORMAT <FOO@BAR.COM>
    if not validEmail(username) 
      #fn({reason: "email_format"})
      fn(new AuthError("Invalid email address"))

    #USERNAMES MUST BE UNIQUE
    else this.ensure_unique username, (unique) ->
      if unique
        fn()
      else
        fn(new AuthError("Username must be unique"))


  ensure_unique: (username, callback) ->
    this.find_by_username username, (err, result) ->
      if err
        return callback(false)
      else if result and result.rows and result.rows.length > 0
        return callback(false)
      else
        return callback(true)

exports.UserSchema = User