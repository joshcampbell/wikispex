require "./spec_helper.coffee"
Query = require_source "query/query.coffee"

describe "Query", ->

  beforeEach ->
    @query = new Query()

  describe "#url", ->
    it "creates a well-formed URL (brittle test)", ->
      actual = @query.url()
      expected = "https://en.wikipedia.org/w/api.php?format=json&action=help"
      assert(actual.indexOf(expected) == 0)

    it "includes options passed to the constructor", ->
      @query = new Query(action: "delete")
      substring = "action=delete"
      assert(@query.url().indexOf(substring) > -1)

  describe "url_encode", ->
    it "URL encodes the provided hash", ->
      actual = @query.url_encode({ "key": "value", "key2": "value2" })
      expected = "?key=value&key2=value2"
      assert.equal(actual, expected)

  describe "publish", -> # FOR INTERNAL USE ONLY
    it "is a higher order function that does some crazy garbage", ->
      # (it passes whatever arguments XMLHttpRequest sees fit to provide
      # to event listeners. it uses currying so that i don't have to
      # define tedious & redundant publish_error, publish_complete, etc.
      # methods)
      spy = sinon.spy()
      callback = @query.publish("message")
      @query.bind("message", spy)
      callback("foo", "bar")
      assert(spy.calledOnce)
      assert(spy.calledWith("foo"))
