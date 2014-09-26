# this is a browserify manifest.
require "./require_source.js"
window.$  = window.jQuery = require "jquery"
window._  = require "lodash"
window.d3 = require_source "d3.js"
app = window.WS = {}
app.Query = require_source "query/query.js"
app.RevisionQuery = require_source "query/revision_query.js"
app.RevisionList = require_source "model/revision_list.js"
