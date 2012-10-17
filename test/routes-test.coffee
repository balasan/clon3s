routes = require "../routes/index"
require "should"
nodeio = require "node.io"

describe "routes", ->
  describe "index", ->
    it "should display index with posts", ->
      req = null
      res = 
        render: (view, vars) ->
          view.should.equal "index"
          vars.title.should.equal "Express"
      routes.index(req, res)

