require "../src/require_source.coffee"

global.require_fixture = (path) ->
  require "#{__dirname}/fixtures/#{path}"

global.assert = require "assert"
global.sinon = require "sinon"
global.jsdom = require "jsdom"

jsdom.env("<!-- empty body -->",
  (errors, window) ->
    throw errors if errors?
    global.window = window
    global.document = window.document
    window.d3 = require_source "d3.js" #UGLY HACK SORRY
)

beforeEach ->
  @sinon = sinon.sandbox.create()
  global.document.body.innerHTML = ""

afterEach ->
  @sinon.restore()
