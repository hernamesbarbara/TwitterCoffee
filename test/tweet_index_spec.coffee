routes = require("../routes/index")
require "should"

describe "routes", ->
  describe "visting the index", ->
    it "should have a title and header", ->
      req = null
      res = 
        render: (view, vars) ->
          view.should.equal "index"
          vars.title.should.equal 'Chirpie'
          vars.header.should.equal 'Welcome to Chirpie'
      routes.index(req, res)