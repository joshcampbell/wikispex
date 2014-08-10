Spine = require "spine"
_ = require "lodash"

class Query extends Spine.Module
  @include(Spine.Events)

  BASE_URL: "https://en.wikipedia.org/w/api.php"

  BASE_OPTIONS:
    format: "json"
    action: "help"

  constructor: (@options={}) ->
  url: -> @BASE_URL + @url_encode(@full_options())
  perform: -> @xhr().send()

  # "private"
  options: -> {} #override me in child classes?
  full_options: -> _.extend @BASE_OPTIONS, @options
  url_encode: (options) ->
    _.chain(options).pairs()
      .map((pair) -> pair.join("="))
      .reduce(((memo, pair) ->
        if memo == "?" then memo + pair else memo + "&" + pair),
        "?").value()
  xhr: =>
    xhr = new XMLHttpRequest()
    xhr.onerror = @publish("error")
    xhr.onload = @publish("complete")
    xhr.onprogress = @publish("progress")
    xhr.open("GET", @url(), true)
    xhr
  publish: (message) => (args...) =>
    @trigger.apply(@, [message].concat(args))

module.exports = Query
