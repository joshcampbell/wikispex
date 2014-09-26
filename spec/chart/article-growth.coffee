require "../spec_helper.coffee"

ArticleGrowth = require_source "chart/article-growth"

describe "Article Growth Chart", ->

  it "exists", -> assert ArticleGrowth?

describe "Scatter Plot", ->
 
  describe "#render", ->

    beforeEach ->
      @svg = d3.select(document.createElement("svg"))
      @scales =
        x: sinon.stub().returns(50)
        y: sinon.stub().returns(100)
      @data = [
        { timestamp: (new Date()), size: 5 } 
        { timestamp: (new Date() - 100000), size: 10 }
      ]
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


