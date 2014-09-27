require "../spec_helper.coffee"

ArticleGrowth = require_source "chart/article-growth"

describe "Article Growth Chart (integration)", ->

  beforeEach ->
    @data = [
      { timestamp: (new Date()), size: 5 }
      { timestamp: (new Date() - 100000), size: 10 }
    ]
    @subject = new ArticleGrowth(
      data: @data
      width: 640
      height: 480
      xField: "timestamp"
      yField: "size"
    )

  it "doesn't explode", ->
    @subject.render()

describe "Article Growth Plots", ->

  beforeEach ->
    @svg = d3.select(document.createElement("svg"))
    @scales =
      x: sinon.stub().returns(50)
      y: sinon.stub().returns(100)
      height: 1000
      width: 500
    @data = [
      { timestamp: (new Date()), size: 5 } 
      { timestamp: (new Date() - 100000), size: 10 }
    ]

  describe "Scatter Plot", ->
   
    describe "#render", ->
  
      beforeEach ->
        @subject = new ArticleGrowth.ScatterPlot(@scales, @data)
  
      it "uses the x scale", ->
        @subject.render(@svg)
        assert.equal(@scales.x.callCount, @data.length)
      
      it "uses the y scale", ->
        @subject.render(@svg)
        assert.equal(@scales.y.callCount, @data.length)
  
      it "adds a path for each data point to the svg", ->
        @subject.render(@svg)
        paths = @svg.selectAll("path")
        assert.equal(paths.size(), @data.length)
  
  describe "Area Plot", ->

    beforeEach ->
      @subject = new ArticleGrowth.AreaPlot(@scales, @data)
  
    describe "#render", ->

      it "appends a path element to the provided svg", ->
        @subject.render(@svg)
        paths = @svg.selectAll("path")
        assert.equal(paths.size(), 1)

  describe "Consolidated Revision Set", ->

    describe "when data points are too close together", ->

      it "merges them", ->

      it "provides access to the the original data points", ->
