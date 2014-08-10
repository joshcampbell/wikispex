RevisionList = require "../src/revision_list.coffee"

describe "RevisionList", ->
  beforeEach ->
    @model = RevisionList.create(page_title: "Charizard")

  it "exists", -> assert(@model.page_title = "Charizard")

  describe "#build_query", ->

    beforeEach ->
      @spy = sinon.spy()
      @model.bind "querying", @spy
      @model.ready_query()

    it "publishes to 'querying'", ->
      assert(@spy.called)

    it "publishes its revision query", ->
      assert.equal(@spy.firstCall.args[1], @model.query)

  describe "when its query completes", ->

    beforeEach ->
      @spy = sinon.spy()
      @model.bind "ready", @spy

    it "publishes itself to 'ready'", ->
      @model.query_success([1,2,3])
      # equality doesn't behave quite as expected on these models
      # but the thing being thrown is definitely equal to @model.
      assert.strictEqual(@spy.firstCall.args[0].revisions, @model.revisions)


