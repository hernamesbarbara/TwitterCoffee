Tweet = require('../models/models').Tweet
User  = require('../models/models').User
passport = require('passport')
LocalStrategy = require("passport-local").Strategy

user = new User
tweet = new Tweet

###
  USERS
###
exports.signup = (req, res) ->
  res.render 'signup'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',

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
  if req.isAuthenticated()
    console.log 'req is isAuthenticated'
  else
    console.log 'req is not isAuthenticated'


  tweet.find_all (err, result) ->
    if err
      console.log 'An error occurred: ' + err
    else
      res.render 'index'
        title: 'Chirpie',
        header: 'Welcome to Chirpie',
        tweets: result.rows

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

exports.login = (req, res) ->
  res.render "login"
    user: if req.user isnt undefined then req.user else 'unknown'
    message: req.flash('error')

accepts_html = (header) ->
  #returns true if content type
  #requested is html
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included