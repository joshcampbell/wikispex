Spine = require "spine"
$ = jQuery = require "jquery"
_ = require "lodash"

class Query extends Spine.Module
  @include(Spine.Events)

  BASE_URL: "https://en.wikipedia.org/w/api.php"

  BASE_OPTIONS:
    format: "json"
    action: "help"
    callback: "?" # (because mediawiki sites don't use CORS)
    # If they did, we could use a native XHR object instead
    # of shoving in jquery so we don't have to reimplement jsonp
    # support.

  constructor: (@options={}) ->
  url: => @BASE_URL + @url_encode(@full_options())
  perform: => $.ajax({
    dataType: "json"
    url: @url()
    success: @publish("success")
    error: @publish("error")
  })

  # "private"
  options: -> {} #override me in child classes?
  full_options: -> _.extend @BASE_OPTIONS, @options
  url_encode: (options) ->
    _.chain(options).pairs()
      .map((pair) -> pair.join("="))
      .reduce(((memo, pair) ->
        if memo == "?" then memo + pair else memo + "&" + pair),
        "?").value()
  publish: (message) => (args...) =>
    @trigger.apply(@, [message].concat(args))

module.exports = Query
