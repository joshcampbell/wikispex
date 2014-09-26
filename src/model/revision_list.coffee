Spine = require "spine"
_ = require "lodash"
RevisionQuery = require "../query/revision_query"

class RevisionList extends Spine.Model
  @configure "RevisionList", "title", "revisions"

  init: ({@title}) ->

  populate: -> @ready_query().perform()

  # "private"
  ready_query: =>
    @query = new RevisionQuery(title: @title)
    @trigger "querying", @query
    @query.bind "success", @query_success
    @query

  query_success: (revisions) =>
      @revisions = revisions
      @save()
      @trigger "ready"

module.exports = RevisionList
