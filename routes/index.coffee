model = require('../models/tweet')

tweets = []
exports.index = (req, res) ->
  model.find_all (err, result) ->
    if err
      console.log 'An error occurred: ' + err
    else
      res.render 'index'
        title: 'Chirpie',
        header: 'Welcome to Chirpie',
        tweets: result.rows

exports.newTweet = (req, res) ->
  if req.body and req.body.tweet

    model.find_user(req.body.tweet.username, (err, result) ->
      #find_user(username, callback)
      if err
        console.log 'ERROR...could not find user...', err
      else
        user_id = result.rows[0].id

        model.save_tweet(user_id, req.body.tweet.content, (err, result) ->
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