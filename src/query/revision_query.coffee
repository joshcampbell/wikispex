Spine = require "spine"
Query = require_source "query/query"
_ = require "lodash"

class RevisionQuery extends Spine.Module
  @include(Spine.Events)
  # PUBLISHES:
  # - "success" when all subsidiary requests are complete

  REVISION_PROPERTIES = [ "timestamp", "user", "size", "comment", "flags",
			  "tags", "ids", "content" ]

  BASE_OPTIONS =
    action: "query"
    prop: "revisions"
    rvprop: REVISION_PROPERTIES.join("|")
    rvlimit: 500
    rvdiffto: "prev"

  constructor: ({@title, @max_revisions}) ->
    @max_revisions ?= 1000
    @revisions = []

  perform: (continuation=null)=>
    query = if continuation? then @build_query(rvstartid: continuation) else @build_query()
    @listenTo query, "success", @process.bind(@)
    query.perform()

  # "private"

  # TODO: we'll probably want to use parts of this procedure elsewhere
  process: (response) =>
    continuation = @continuation_from(response)
    @revisions = @revisions.concat(@revisions_from(response))
    @trigger "progress", { progress: @revisions.length, total: @max_revisions, new: @revisions_from(response) }
    if continuation? && @revisions.length < @max_revisions
      @perform continuation #NOTE: recursive
    else @trigger "success", @revisions

  options: => _.extend BASE_OPTIONS, titles: @title

  build_query: (args={}) =>
    new Query(_.extend @options(), args)

  perform_initial_query: => @build_query().perform()

  # response accessors - TODO: break out into module
  page_from: (response) => _.values(response.query.pages)[0]
  revisions_from: (response) => @page_from(response).revisions
  continuation_from: (response) =>
    qc = response["query-continue"]
    if qc? then qc.revisions.rvcontinue else null

module.exports = RevisionQuery
