class ArticleGrowth
  margin:
    left: 40
    right: 30
    top: 30
    bottom: 30

  constructor: ({data, @height, @width, @xField, @yField})->
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
    @areaPlot = new ArticleGrowth.AreaPlot(@scales, @data)
    @scatterPlot = new ArticleGrowth.ScatterPlot(@scales, @data)

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

  #FIXME: the skip_consolidation flag exists purely for testing purposes and is
  #       indicative of a malformed object graph -- this object needs to know
  #       too much about the article growth chart. I think that it's probably
  #       best to pass around a full ChartData object? Something containing the
  #       data points as well as the scales.
  constructor: (@scales, @data, skip_consolidation=false) ->
    unless skip_consolidation
      # calculate the minimum distance between plotted points in milliseconds
      # and use them to consolidate the data points.
      min_distance_px = 25
      min_distance = @scales.x.invert(min_distance_px) - @scales.x.domain()[0]
      @data = ArticleGrowth.ScatterPlot.ConsolidatedData(@data, min_distance, @xField, @yField, convert_to_date: true)

  render: (@target) =>
    # TODO: I think it may be more idiomatic to use enter() instead of a
    #       for loop here. This works, though.
    for d, index in @data
      previous = @data[index - 1] || {}
      shape = @_shape(d, previous)
      offset = @_offset(d)
      @target.append("path")
             .attr("class", "scatter #{shape}")
             .attr("size", 100)
             .attr("d", @pathgen().type(shape))
             .attr("transform", offset)
      if d.consolidated?
        @target.append("text")
         .attr("transform", offset)
         .text(d.consolidated.length)
    @

  pathgen: =>
    @__pathgen ?= d3.svg.symbol()

  _offset: (d) =>
    "translate(#{@scales.x(d[@xField])}, #{@scales.y(d[@yField])})"

  _shape: (d, previous) =>
    return "circle" if d.consolidated?
    return "square" if(d[@yField] == previous[@yField])
    return "triangle-down" if(d[@yField] < previous[@yField])
    return "triangle-up"

class ArticleGrowth.ScatterPlot.Tooltip


ArticleGrowth.ScatterPlot.ConsolidatedData = (data, min_distance, xField, yField, options={}) ->
  # FIXME: crying out for decomposition
  convert_to_date = options.convert_to_date
  consolidated_data = []
  previous = {}
  # replace points that are too close together with aggregates
  for d, index in data
    d = _.clone(d)
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
  # make another pass to average the positions of the aggregates
  _.each(consolidated_data, (d) ->
    if d.consolidated?
      d[xField] = _.chain(d.consolidated)
                          .pluck(xField)
                          .map((x) -> if convert_to_date then x.getTime() else x)
                          .reduce((sum, x) -> sum + x)
                          .value() / d.consolidated.length
      d[xField] = new Date(d[xField]) if convert_to_date
  )
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
