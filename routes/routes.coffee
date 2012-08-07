TweetSchema = require('../models/models').Tweet
UserSchema  = require('../models/models').User


users = new UserSchema
tweets = new TweetSchema

###
  USERS
###
exports.signup = (req, res) ->
  res.render 'signup'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    user: req.user,
    message: req.flash('error')

exports.newUser = (req, res) ->
  console.log 'inside newUser'
  if req.body and req.body.user
    console.log  req.body.user.password
    users.save(req.body.user.username, req.body.user.password, (err, result) ->
      if err
        switch err.validation
          when "email_format" then message = "Username must be a valid email address."
          when "duplicate_user" then message = "Username already taken. Try logging in instead."
          else message = "Please enter a valid username and password"
        req.flash('error', message)
        res.redirect('/signup')
      #save the user and redirect to root_path
      else if accepts_html(req.headers['accept'])
        res.redirect('/')
      else
        res.send({status:"OK", message: "User received"})
    )

exports.index = (req, res) ->
  if req.isAuthenticated()
    tweets.find_all (err, result) ->
      if err
        console.log 'An error occurred: ' + err
      else
        res.render 'index'
          title: 'Chirpie',
          header: 'Welcome to Chirpie',
          user: req.user,
          tweets: result.rows
  else
    res.redirect('/login')

exports.newTweet = (req, res) ->
  if req.body and req.body.tweet
    tweets.find_user req.body.tweet.username, (err, result) ->
      #find_user(username, callback)
      if err
        console.log('ERROR...could not find user...', err)
      else
        user_id = result.rows[0].id
      if user_id
        tweets.save user_id, req.body.tweet.content, (err, result) ->
          #save the tweet
          #save(user_id, content, callback)
          if accepts_html(req.headers['accept'])
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
  #returns true if content type
  #requested is html
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included

