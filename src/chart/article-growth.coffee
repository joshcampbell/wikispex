class ArticleGrowth
  constructor: () ->

class ArticleGrowth.ScatterPlot
  constructor: (@scales, @data) ->

  render: (@target) =>
    # TODO: I think it may be more idiomatic to use enter() instead of a
    #       for loop here. This works, though.
    for d in @data
      @target.append("path")
             .attr("class", "scatter #{@_shape(d)}")
             .attr("d", @pathgen().type(@_shape(d)))
             .attr("transform", @_offset(d))
    @

  pathgen: () =>
    @__pathgen ?= d3.svg.symbol()

  _offset: (d) =>
    "translate(#{@scales.x(d.timestamp)}, #{@scales.y(d.size)})"

  _shape: (d) =>
    "square"

class ArticleGrowth.AreaPlot
  constructor: (@scales, @data) ->

module.exports = ArticleGrowth
