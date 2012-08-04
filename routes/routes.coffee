Tweet = require('../models/models').Tweet
User  = require('../models/models').User

user = new User
tweet = new Tweet


###
  USERS
###
exports.signup = (req, res) ->
  res.render 'signup'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    host: "http://localhost"

exports.newUser = (req, res) ->
  console.log 'inside new user'
  console.log req.body.user.username
  if req.body and req.body.user
    user.save(req.body.user.username, (err, result) ->
      #save the user and redirect to root_path
      if accepts_html(req.headers['accept'])
        res.redirect('/')
      else
        res.send({status:"OK", message: "User received"})
    )

###
  TWEETS
###

exports.index = (req, res) ->
  tweet.find_all (err, result) ->
    if err
      console.log 'An error occurred: ' + err
    else
      res.render 'index'
        title: 'Chirpie',
        header: 'Welcome to Chirpie',
        tweets: result.rows
        host: "http://localhost"

exports.newTweet = (req, res) ->
  if req.body and req.body.tweet

    tweet.find_user(req.body.tweet.username, (err, result) ->
      #find_user(username, callback)
      if err
        console.log('ERROR...could not find user...', err)
      else
        user_id = result.rows[0].id
      if user_id
        tweet.save(user_id, req.body.tweet.content, (err, result) ->
          #save_tweet(user_id, content, callback)
          if accepts_html(req.headers['accept'])
            res.redirect('/')
          else
            res.send({status:"OK", message: "Tweet received"})
        )
    )

accepts_html = (header) ->
  #returns true if content type
  #requested is html
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included