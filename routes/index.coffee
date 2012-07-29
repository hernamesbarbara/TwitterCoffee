exports.index = (req, res) ->
  console.log req
  console.log res
  res.render('index', { 
  	title: 'Chirpie'
  	,header: 'Welcome to Chirpie'
  	,tweets: tweets
   })
#tweets = {name:'Hank Mardukas', content: 'This is my first tweet'}
tweets = []
exports.newTweet = (req, res) ->
  if req.body and req.body.tweet
    tweets.push(req.body.tweet)
    if accepts_html(req.headers['accept']) is true
      res.redirect('/')
    else
      res.send({status:"OK", message: "tweet received"})
  else
    res.send({status:"NOT_OK", message: "no tweet received"})

accepts_html = (header) ->
  attrs = header.split(",")
  included = 'text/html' in attrs
  return included