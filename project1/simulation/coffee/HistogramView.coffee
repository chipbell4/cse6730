Backbone = require 'backbone'

class HistogramView extends Backbone.View
    initialize: (options) ->
        @collection = @collection or new Backbone.Collection()
        @listenTo(@collection, 'change add reset', @rebuildHistogram.bind(@))

        # Set a bin count
        @binCount = 25
        if options? and options.binCount?
            @binCount = options.binCount

        @rebuildHistogram()

    binNumber: (value, min, max) ->
        Math.floor( (value - min) / (max - min) * @binCount )

    pointPosition: (binValue, binIndex, binCount) ->
        width = @$('svg').width()
        height = @$('svg').height()

        # use a 10% margin on all sides. Also, remember y has to be mirrored
        point = 
            x: "#{ (0.1 + 0.8 * binIndex / binCount) * width }"
            y: "#{ (0.9 - 0.8 * binValue) * height }"

    buildSvgPathString: (points) ->
        if points.length is 0
            return ""

        # Build the path string
        pathString = "M#{ points[0].x } #{ points[0].y } "
        pathString += "L#{ point.x } #{ point.y } " for point in points[1..]

    rebuildHistogram: ->
        values = @collection.pluck('value')
        # handle empty list case here

        minValue = Math.min.apply(Math, values)
        maxValue = Math.max.apply(Math, values)

        # Build frequency distribution, looping over each value and pushing it into the correct bin
        bins = (0 for k in [0..@binCount])
        bins[ @binNumber(value, minValue, maxValue) ] += 1 for value in values
        if @collection.length > 1
            bins = (binValue / @collection.length for binValue in bins)

        # convert bins into positions for points
        pointPosition = @pointPosition.bind(@)
        @points = bins.map((binValue, index) ->
            pointPosition(binValue, index, bins.length)
        )

        @render()

    render: ->
        # build a SVG path from the current point set
        path = document.createElementNS('http://www.w3.org/2000/svg', 'path')
        path.setAttribute('d', @buildSvgPathString(@points))
        path.setAttribute('fill', 'none')
        path.setAttribute('stroke-width', '2')
        path.setAttribute('stroke', 'black')

        # append onto the svg
        svg = @$('svg').get(0)
        svg.removeChild(svg.firstChild) while svg.firstChild
        svg.appendChild(path)

module.exports = HistogramView
