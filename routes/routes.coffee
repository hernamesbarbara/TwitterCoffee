TweetSchema = require('../models/models').TweetSchema
UserSchema  = require('../models/models').UserSchema
passport    = require("passport")

Users = new UserSchema
Tweets = new TweetSchema

###
  USERS
###
exports.login = (req, res) ->
  res.render "login"
    user: req.user
    message: req.flash('error')

exports.signup = (req, res) ->
  res.render 'signup'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    user: req.user,
    message: req.flash('error')

exports.usersIndex = (req, res) ->
  Users.find_all (err, result) ->
    if err
      users = []
      res.render 'users_index'
        title: 'Chirpie Users',
        header: 'header....',
        user: req.user,
        users: users,
        message: req.flash('error')
    else
      users = result.rows
      res.render 'users_index'
        title: 'Chirpie Users',
        header: 'header....',
        user: req.user,
        users: users,
        message: req.flash('error')

exports.userShow = (req, res, next) ->
  unless req.params.id
    res.render "404.jade",
      title: "404 - Page Not Found",
      showFullNav: false,
      status: 404,
      url: req.url
  Users.find_by_id req.params.id, (err, result) ->
    if err
      res.render "404.jade",
        title: "404 - Page Not Found",
        showFullNav: false,
        status: 404,
        url: req.url
    else
      user = result.rows[0]
      Users.tweets_for user.id, (err, result) ->
        if err
          user.tweets = []
          res.render 'user_show'
            title: 'Show user page',
            header: 'show user header',
            user: user
        else
          user.tweets = result.rows
          console.log 'user =>\n',user
          res.render 'user_show'
            title: 'Show user page',
            header: 'show user header',
            user: user

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

accepts_html = (header) ->
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included