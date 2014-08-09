require "./spec_helper.coffee"
Query = require "../src/query.coffee"

describe "Query", ->

  beforeEach ->
    @query = new Query()

  describe "#url", ->
    it "creates a well-formed URL", ->
      actual = @query.url()
      expected = "https://en.wikipedia.org/w/api.php?format=json&action=help"
      assert.equal(actual, expected)

  describe "url_encode", ->
    it "URL encodes the provided hash", ->
      actual = @query.url_encode({ "key": "value", "key2": "value2" })
      expected = "?key=value&key2=value2"
      assert.equal(actual, expected)

