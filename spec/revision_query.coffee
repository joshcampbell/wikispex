require "./spec_helper.coffee"
RevisionQuery = require "../src/query/revision_query.coffee"

fixtures = {}
fixtures.first_response = require "./charizard.json"
fixtures.last_response = require "./charizard-sans-continuation.json"

describe "Revision Query", ->
  beforeEach ->
    @query = new RevisionQuery(title: "Charizard")
    @query.perform = sinon.spy() #$.ajax doesn't work in this node setup

  describe "#continuation_from", ->
    it "retrieves the ID of the next revision", ->
      actual = @query.continuation_from(fixtures.first_response)
      assert.equal(actual, 499848673)

  describe "#revisions_from", ->
    it "retrieves the revisions hash from results", ->
      actual = @query.revisions_from(fixtures.first_response)
      assert.equal(actual.length, 250)

  describe "#process", ->

    describe "when given an erroneous response", ->

    describe "when given an incomplete response", ->

      beforeEach ->
        @spy = sinon.spy()
        @query.bind "progress", @spy
        @query.process(fixtures.first_response)

      it "publishes progress", ->
        assert(@spy.called)

      it "publishes the number of revisions retrieved", ->
        assert.equal(@spy.getCall(0).args[0].progress, 250)

      it "publishes the maximum number of revisions", ->
        assert.equal(@spy.getCall(0).args[0].total, @query.max_revisions)

    it "doesn't blow away the revisions array", ->
      @query.revisions = [1]
      @query.process(fixtures.first_response)
      assert.equal(@query.revisions.length, 251)

    describe "when given a complete response", ->

      beforeEach ->
        @spy = sinon.spy()
        @query.bind "success", @spy
        @query.process(fixtures.last_response)

      it "publishes success", ->
        assert(@spy.called)

      it "publishes its revisions", ->
        assert.equal(@spy.getCall(0).args[0].length, @query.revisions.length)
        assert(@query.revisions.length > 0)


  describe "#build_query", ->

    describe "when passed nothing", ->
      # this goes against tdd doctrine by asserting
      # something about the Query class. i doubt the
      # query class is ever going to stop exposing its
      # URL as #url

      it "includes the title in the query", ->
        actual = @query.build_query().url()
        expected = "titles=Charizard"
        assert(actual.indexOf(expected) > -1)

      it "includes the base options in the URL", ->
        actual = @query.build_query().url()
        expected = "prop=revisions"
        assert(actual.indexOf(expected) > -1)

    describe "when passed a revision id", ->
