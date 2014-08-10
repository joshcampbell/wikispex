# this is a browserify manifest.
window.$ = window.jQuery = require "jquery"
window._ = require "lodash"
app = window.WS = {}
app.Query = require "./query.js"
app.RevisionQuery = require "./revision_query.js"
app.RevisionList = require "./revision_list.js"
