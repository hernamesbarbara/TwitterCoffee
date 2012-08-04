Tweet = require('../models/tweet').Tweet
tweet = new Tweet

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
        tweet.save_tweet(user_id, req.body.tweet.content, (err, result) ->
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