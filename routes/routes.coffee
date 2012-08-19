TweetSchema = require('../models/models').TweetSchema
UserSchema  = require('../models/models').UserSchema
passport    = require('passport')
Users       = new UserSchema
Tweets      = new TweetSchema

###
  USERS
###


exports.login = (req, res) ->
  res.render "./sessions/login"
    user: req.user,
    message: req.flash('error'),
    current_user: req.session.passport.user

exports.newUser = (req, res) ->
  res.render './users/new'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    user: req.user,
    message: req.flash('error'),
    current_user: req.session.passport.user

exports.usersIndex = (req, res) ->
  Users.all (err, result) ->
    if err
      users = []
      res.render './users/index'
        title: 'Chirpie Users',
        header: 'header....',
        user: req.user,
        users: users,
        message: req.flash('error'),
        current_user: req.session.passport.user

    else
      users = result.rows
      res.render './users/index'
        title: 'Chirpie Users',
        header: 'header....',
        user: req.user,
        users: users,
        message: req.flash('error'),
        current_user: req.session.passport.user


exports.showUser = (req, res, next) ->
  console.log 'req.loaded_user inside showUser\n',req.loaded_user
  res.render './users/show'
    title: 'Show user page',
    header: 'show user header',
    user: req.loaded_user,
    current_user: req.session.passport.user


exports.createUser = (req, res, next) ->
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

exports.home = (req, res) ->
  res.render 'home'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    user: req.user,
    tweets: req.user.feed,
    message: req.flash('success'),
    current_user: req.session.passport.user

exports.newTweet = (req, res, next) ->
  if(req.body and req.body.tweet)
    Users.find_by_username req.body.tweet.username, (err, result) ->
      if(err)
        console.log('ERROR...could not find user...\n', err)
      
      else
        user = result.rows[0]
        Tweets.save user.id, req.body.tweet.content, (err, tweet) ->
        if err
          switch err.reason
            when 'content_length_is_zero' then message = 'Tweets must have content!'
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

exports.logout = (req, res) ->
  req.logout()
  res.redirect "/"

exports.about = (req, res) ->
  res.render "about"
    title: 'About Chirpie',
    header: 'About Us',
    user: req.user,
    current_user: req.session.passport.user

accepts_html = (header) ->
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included