# this is a browserify manifest.
window.$  = window.jQuery = require "jquery"
window._  = require "lodash"
window.d3 = require "../src/d3.js"

WS = window.WS = {}
WS.Query = require "./query/query.js"
WS.RevisionQuery = require "./query/revision_query.js"
WS.RevisionList = require "./model/revision_list.js"
WS.ArticleGrowth = require "./chart/article-growth.js"
WS.JSONFixture = require "../spec/charizard-sans-continuation.json"

WS.adHocLiveIntegrationTest = ->
  window.revs = WS.JSONFixture.query.pages[24198906].revisions
  _.each(revs, (r) -> r.timestamp = new Date(r.timestamp))
  window.chart = new WS.ArticleGrowth
    data: revs
    width: 640
    height: 480
    xField: "timestamp"
    yField: "size"
  chart.render()
  document.body.appendChild(chart.el) 
