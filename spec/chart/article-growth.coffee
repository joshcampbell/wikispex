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
        @subject = new ArticleGrowth.ScatterPlot(@scales, @data, true)
  
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

      beforeEach ->
        data = [
          { x: 50 }
          { x: 100 }
          { x: 101 }
          { x: 102 }
        ]
        @subject = ArticleGrowth.ScatterPlot.ConsolidatedData(data, 3, "x")
        
      it "merges them", ->
        assert.equal(@subject.length, 2)

      it "provides access to the the original data points", ->
        assert.equal(@subject[1].consolidated.length, 3)

      it "averages the x values of its constituent data points", ->
        assert.equal(@subject[1].x, 101)

    describe "when merge zones abut", ->

      beforeEach ->
        data = [
          { x: 1 }
          { x: 2 }
          { x: 3 }
          { x: 4 }
        ]
        @subject = ArticleGrowth.ScatterPlot.ConsolidatedData(data, 2, "x")

      it "consolidates them into areas of min_distance width", ->
        assert.equal(@subject.length, 2)

      it "provides access to the original data points", ->
        consolidated_length = (d) -> d.consolidated?.length
        assert.deepEqual(_.map(@subject, consolidated_length), [2,2])

    describe "date handling", ->

      beforeEach ->
        data = [
          { time: new Date(), mullahs: 1 }
          { time: new Date(new Date() - 500), mullahs: 2 }
        ]
        @subject = ArticleGrowth.ScatterPlot.ConsolidatedData(data, 2000, "time", "mullahs", convert_to_date: true)

      it "yields aggregates whose x fields are dates", ->
        assert(@subject[0].time instanceof Date)

  describe "Tooltip", ->
    describe "#render", ->
      it "draws a box", ->
      describe "when there is room on the right", ->
        it "appears to the right of the cursor", ->
      describe "when there isn't room on the right", ->
        it "appears to the left of the cursor", ->
  describe "Revision Summary Tooltip", ->
    describe "#content", ->
      it "shows the editor count", ->
      it "shows the date range", ->
      it "shows total diffs", ->

