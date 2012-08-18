TweetSchema = require('../models/models').TweetSchema
UserSchema  = require('../models/models').UserSchema
passport    = require("passport")

Users = new UserSchema
Tweets = new TweetSchema

###
  USERS
###
exports.signup = (req, res) ->
  res.render 'signup'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    user: req.user,
    message: req.flash('error')

exports.newUser = (req, res, next) ->
  if req.body and req.body.user
    Users.save req.body.user.username, req.body.user.password, (err, user) ->
      if err
        switch err.reason
          when "email_format" then message = "Username must be a valid email address."
          when "duplicate_user" then message = "Username already taken. Try logging in instead."
          else message = "Please enter a valid username and password"
        req.flash('error', message)
        res.redirect('/signup')
      else if accepts_html(req.headers['accept'])
        req.flash('success', "Welcome to Chirpie!")
        req.login(user, next)
        res.redirect('/')
      else
        res.send({status:"OK", message: "User received"})

exports.index = (req, res) ->
  Tweets.find_all (err, result) ->
    if err
      console.log 'An error occurred: ' + err
    else
      res.render 'index'
        title: 'Chirpie',
        header: 'Welcome to Chirpie',
        user: req.user,
        tweets: result.rows
        message: req.flash('success')

exports.newTweet = (req, res, next) ->
  if req.body and req.body.tweet
    Users.find_by_username req.body.tweet.username, (err, result) ->
      if err
        console.log('ERROR...could not find user...\n', err)
      else
        user_id = result.rows[0].id
      if user_id
        Tweets.save user_id, req.body.tweet.content, (err, tweet) ->
          if err
            switch err.reason
              when 'length_over_140' then message = "Tweets must be 140 characters of less"
              when 'no_user_id_provided' then message = "Unknown user..."
              else message = "something went wrong..."
            req.flash('success', message)
            res.redirect('/')
          else if accepts_html(req.headers['accept'])
              req.flash('success', "Saved")
              res.redirect('/')
          else
            res.send({status:"OK", message: "Tweet received"})

exports.login = (req, res) ->
  if req.isAuthenticated()
    res.redirect('/')
  else
    res.render "login"
      user: req.user
      message: req.flash('error')

exports.logout = (req, res) ->
  req.logout()
  res.redirect "/"

accepts_html = (header) ->
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included