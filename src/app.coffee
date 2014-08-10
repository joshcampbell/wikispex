# this is a browserify manifest.
console.log('changed')
window.$ = window.jQuery = require "jquery"
app = window.WS = {}
app.Query = require "./query.js"
