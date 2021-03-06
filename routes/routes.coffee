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
      return res.render './users/index'
        title: 'Chirpie Users',
        header: 'header....',
        user: req.current_user,
        users: [],
        message: req.flash('error'),
        loggedIn: req.isAuthenticated()
    else
      users = result.rows
      return res.render './users/index'
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
      if ! err
        if accepts_html(req.headers['accept'])
          req.flash('success', "Welcome to Chirpie!")
          req.login(user, next)
          return res.redirect('/')
        else
          return res.send({status:"OK", message: "User received"})

      if err.type == 'AuthenticationError'
        msg = err.message 

      else
        msg = 'Username must be a unique email address'

      util.inspect(err, true)
      req.flash('error', msg)
      res.redirect('/signup')

exports.home = (req, res) ->
  res.render 'home'
    title: 'Chirpie',
    header: 'Welcome to Chirpie',
    user: req.current_user,
    message: req.flash('error'),
    welcome: req.flash('welcome'),
    success: req.flash('success'),
    loggedIn: req.isAuthenticated()

exports.newTweet = (req, res, next) ->
  Tweets.save req.current_user.id, req.body.tweet.content, (err, tweet) ->
    if ! err 
      if accepts_html(req.headers['accept'])
        req.flash('success', "Saved")
        return res.redirect('/')
    
      else
        return res.send({status:"OK", message: "Tweet received"})
    
    else if err.type == 'ValidationError' 
      msg = err.message
    else
      msg = 'Uh oh! Unknown error occured'
    
    util.inspect(err, true)
    req.flash('error', msg)
    res.redirect('/')

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
