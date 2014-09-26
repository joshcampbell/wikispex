class ArticleGrowth
  # TODO: references to 'scales' should refer to this object instead
  constructor:({@data, @height, @width, @xField, @yField})->
    @scales = {
      width: @width
      height: @height
      x: d3.time.scale()
          .range([0, @width])
          .domain(d3.extent(@data, (d) -> d[@xField]))
      y: d3.time.scale()
          .range([@height, 0])
          .domain([0, d3.max(@data, (d) -> d[@yField])])
    }
    @el = document.createElement("svg")
    @svg = d3.select(@el)
    @axes = new ArticleGrowth.Axes(@scales)
    @scatterPlot = new ArticleGrowth.ScatterPlot(@scales, @data)
    @areaPlot = new ArticleGrowth.AreaPlot(@scales, @data)

  render: ->
    @areaPlot.render(@svg)
    @axes.render(@svg)
    @scatterPlot.render(@svg)
    @

class ArticleGrowth.Axes
  # TODO: This should probably be two classes.
  constructor: (@scales) ->
  x: => d3.svg.axis().scale(@scales.x).orient("bottom")
  y: => d3.svg.axis().scale(@scales.y).orient("left")
  render: (@target) =>
    @_renderX()
    @_renderY()
    @

  _renderX: =>
    @target.append("g")
      .attr("class", "axis x")
      .attr("transform", "translate(0, #{@scales.height})")
      .call(@x())

  _renderY: =>
    @target.append("g")
      .attr("class", "axis y")
      .call(@y())
    @target.append("text")
      .attr("transform", "rotate(-90)")
      .style("text-anchor", "end")
      .text("Size (characters)")
    

class ArticleGrowth.ScatterPlot
  xField: "timestamp"
  yField: "size"

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

  pathgen: =>
    @__pathgen ?= d3.svg.symbol()

  _offset: (d) =>
    "translate(#{@scales.x(d[@xField])}, #{@scales.y(d[@yField])})"

  _shape: (d) =>
    "square"

class ArticleGrowth.AreaPlot
  xField: "timestamp"
  yField: "size"

  constructor: (@scales, @data) ->

  render: (@target) =>
    @target.append("path")
      .datum(@data)
      .attr("d", @pathgen())
      .attr("class", "area")
    @

  pathgen: =>
    @__pathgen ?= d3.svg.area()
      .x((d) => @scales.x(d[@xField]))
      .y((d) => @scales.y(d[@yField]))
      .y0(@scales.height)
      .interpolate("monotone")

module.exports = ArticleGrowth
