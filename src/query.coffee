_ = require "lodash"

class Query
  BASE_URL: "https://en.wikipedia.org/w/api.php"

  BASE_OPTIONS: ->
    format: "json"
    action: "help"

  url: -> @BASE_URL + @url_encode(@full_options())

  # "private"
  options: -> {} #override me in child classes?
  full_options: -> _.extend @BASE_OPTIONS(), @options()
  url_encode: (options) ->
    _.chain(options).pairs()
      .map((pair) -> pair.join("="))
      .reduce(((memo, pair) ->
        if memo == "?" then memo + pair else memo + "&" + pair),
        "?").value()

module.exports = Query
