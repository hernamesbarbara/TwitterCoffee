TweetSchema = require('../models/models').TweetSchema
UserSchema  = require('../models/models').UserSchema
passport    = require('passport')
util        = require("util")
Users       = new UserSchema
Tweets      = new TweetSchema


exports.login = (req, res) ->
  res.render "./sessions/login"
    user: req.current_user,
    message: req.flash('error'),
    loggedIn: req.isAuthenticated()

exports.newUser = (req, res) ->
  res.render './users/new'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    user: req.current_user,
    message: req.flash('error'),
    loggedIn: req.isAuthenticated()

exports.usersIndex = (req, res) ->
  Users.all (err, result) ->
    if err
      users = []
      res.render './users/index'
        title: 'Chirpie Users',
        header: 'header....',
        user: req.current_user,
        users: users,
        message: req.flash('error'),
        loggedIn: req.isAuthenticated()
    else
      users = result.rows
      res.render './users/index'
        title: 'Chirpie Users',
        header: 'header....',
        user: req.current_user,
        users: users,
        message: req.flash('error'),
        loggedIn: req.isAuthenticated()

exports.showUser = (req, res, next) ->
  res.render './users/show'
    title: 'Show user page',
    header: 'show user header',
    user: req.loaded_user,
    loggedIn: req.isAuthenticated()


exports.createUser = (req, res, next) ->
  if req.body and req.body.user
    Users.save req.body.user.username, req.body.user.password, (err, user) ->
      if err
        console.log err
        console.log util.inspect(err)
        if err.type == 'AuthenticationError'
          msg = err.message 
        else
          util.inspect(err, true)
          msg = 'Username must be a unique email address'
        
        req.flash('error', msg)
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
    user: req.current_user,
    loggedIn: req.isAuthenticated()

exports.newTweet = (req, res, next) ->
  Tweets.save req.current_user.id, req.body.tweet.content, (err, tweet) ->
    if err
      if err.type == 'ValidationError'
        msg = err.message
      else
        util.inspect(err, true)
        msg = 'something went wrong...'
      
      req.flash('success', msg)
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
    user: req.current_user,
    loggedIn: req.isAuthenticated()

accepts_html = (header) ->
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included
