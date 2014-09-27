# libraries
global.assert = require "assert"
global.sinon = require "sinon"
global.jsdom = require "jsdom"

# helpers to avoid "../../../"
require "../src/require_source.coffee"

global.spec_directory = __dirname
global.require_fixture = (path) ->
  require "#{spec_directory}/fixtures/#{path}"

# set up a mock DOM
jsdom.env("<!-- empty body -->",
  (errors, window) ->
    throw errors if errors?
    global.window = window
    global.document = window.document
    window.d3 = require_source "d3.js" #UGLY HACK SORRY
)

# reset DOM and mocks between tests
beforeEach ->
  @sinon = sinon.sandbox.create()
  global.document.body.innerHTML = ""

afterEach ->
  @sinon.restore()
