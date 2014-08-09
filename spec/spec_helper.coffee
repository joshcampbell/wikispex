global.assert = require "assert"
global.sinon = require "sinon"
global.jsdom = require "jsdom"

jsdom.env("<!-- empty body -->",
  (errors, window) ->
    throw errors if errors?
    global.window = window
    global.document = window.document
)

beforeEach ->
  @sinon = sinon.sandbox.create()
  global.document.body.innerHTML = ""

afterEach ->
  @sinon.restore()
