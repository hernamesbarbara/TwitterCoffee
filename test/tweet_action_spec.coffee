routes = require "../routes/index"
require "should"

describe "routes", ->
  describe "index", ->
    it "should display index with tweets", ->
      req = null
      res = 
        render: (view, vars) ->
          view.should.equal "index"
          vars.title.should.equal 'Chirpie'
          vars.header.should.equal 'Welcome to Chirpie'
      routes.index(req, res)