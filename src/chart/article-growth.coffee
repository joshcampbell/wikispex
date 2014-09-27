class ArticleGrowth
  margin:
    left: 40
    right: 30
    top: 30
    bottom: 30

  constructor:({data, @height, @width, @xField, @yField})->
    @setData(data)
    @scales = {
      width: @width
      height: @height
      x: d3.time.scale()
          .range([0, @width])
          .domain(d3.extent(@data, (d) => d[@xField]))
      y: d3.scale.linear()
          .range([@height, 0])
          .domain([0, d3.max(@data, (d) => d[@yField])])

    }
    @el = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    @el.setAttribute("class", "chart article-growth")
    @axes = new ArticleGrowth.Axes(@scales)
    @scatterPlot = new ArticleGrowth.ScatterPlot(@scales, @data)
    @areaPlot = new ArticleGrowth.AreaPlot(@scales, @data)

  render: ->
    @el.innerHTML = ""
    @svg = d3.select(@el)
        .attr("height", @height + @margin.top + @margin.bottom)
        .attr("width", @width + @margin.left + @margin.right)
        .append("g")
        .attr("transform", "translate(#{@margin.left}, #{@margin.top})")
    @areaPlot.render(@svg)
    @axes.render(@svg)
    @scatterPlot.render(@svg)
    @

  setData: (data) -> @data = _.sortBy(data, "timestamp")

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
      .attr("y", 5)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Size (characters)")
    

class ArticleGrowth.ScatterPlot
  xField: "timestamp"
  yField: "size"

  constructor: (@scales, data) ->
    # calculate the minimum distance between plotted points in milliseconds
    # and use them to consolidate the data points.
    min_distance_px = 15
    min_distance = @scales.x.invert(min_distance_px) - @scales.x.domain()[0]
    @data = ArticleGrowth.ScatterPlot.ConsolidatedData(data, min_distance, @xField)

  render: (@target) =>
    # TODO: I think it may be more idiomatic to use enter() instead of a
    #       for loop here. This works, though.
    for d, index in @data
      previous = @data[index - 1] || {}
      shape = @_shape(d, previous)
      @target.append("path")
             .attr("class", "scatter #{shape}")
             .attr("d", @pathgen().type(shape))
             .attr("transform", @_offset(d))
    @

  pathgen: =>
    @__pathgen ?= d3.svg.symbol()

  _offset: (d) =>
    "translate(#{@scales.x(d[@xField])}, #{@scales.y(d[@yField])})"

  _shape: (d, previous) =>
    return "square" if(d[@yField] == previous[@yField])
    return "triangle-down" if(d[@yField] < previous[@yField])
    return "triangle-up"

ArticleGrowth.ScatterPlot.ConsolidatedData = (data, min_distance, xField) ->
  consolidated_data = []
  previous = {}
  for d, index in data
    difference = d[xField] - previous[xField]
    if !isNaN(difference) && difference < min_distance
      if typeof previous.consolidated == "undefined"
        consolidated = []
        consolidated.push(_.clone(previous))
        previous.consolidated = consolidated
      previous.consolidated.push(d)
    else
      consolidated_data.push(d)
      previous = d
  consolidated_data
    

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
