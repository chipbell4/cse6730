Backbone = require 'backbone'

class HistogramView extends Backbone.View
    initialize: (options) ->
        @collection = @collection or new Backbone.Collection()
        @listenTo(@collection, 'change add reset', @rebuildHistogram.bind(@))

        # Set a bin count and histogram size
        @binCount = 25
        if options? and options.binCount?
            @binCount = options.binCount
        @histogramSize =
            min: 0
            max: 100
        if options? and options.histogramSize?
            @histogramSize = options.histogramSize

        @rebuildHistogram()

    binNumber: (value) ->
        # Calculate the bin and then clamp it
        rawBin = Math.floor( (value - @histogramSize.min) / (@histogramSize.max - @histogramSize.min) * @binCount )
        Math.min(Math.max(0, rawBin), @binCount - 1)


    pointPosition: (binValue, binIndex, maxBinValue, binCount) ->
        width = @$('svg').width()
        height = @$('svg').height()

        # use a 10% margin on all sides. Also, remember y has to be mirrored
        point = 
            x: "#{ (0.1 + 0.8 * binIndex / binCount) * width }"
            y: "#{ (0.9 - 0.8 * binValue / maxBinValue) * height }"

    buildSvgPathString: (points) ->
        if points.length is 0
            return ""

        # Build the path string
        pathString = "M#{ points[0].x } #{ points[0].y } "
        pathString += "L#{ point.x } #{ point.y } " for point in points[1..]

    rebuildHistogram: ->
        values = @collection.pluck('value')

        # Build frequency distribution, looping over each value and pushing it into the correct bin
        bins = (0 for k in [0..@binCount])
        bins[ @binNumber(value) ] += 1 for value in values

        maxBinValue = Math.max.apply(Math, bins)
        if bins.length == 0 or maxBinValue < 1
            maxBinValue = 1

        # convert bins into positions for points
        pointPosition = @pointPosition.bind(@)
        @points = bins.map((binValue, index) ->
            pointPosition(binValue, index, maxBinValue, bins.length)
        )

        @render()

    buildLabel: (text, percentageWidth, percentageHeight) ->
        $svg = @$('svg')
        label = document.createElementNS('http://www.w3.org/2000/svg', 'text')
        label.textContent = text
        label.setAttribute('x', $svg.width() * percentageWidth)
        label.setAttribute('y', $svg.height() * (1 - percentageHeight))
        return label

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

        # add labels at the edges and middle
        oneQuarter = (@histogramSize.min * 3 + @histogramSize.max) / 4
        oneHalf = (@histogramSize.min + @histogramSize.max) / 2
        threeQuarter = (@histogramSize.min + @histogramSize.max * 3) / 4
        svg.appendChild @buildLabel(@histogramSize.min, 0.1, 0)
        svg.appendChild @buildLabel( (oneQuarter), 0.3, 0)
        svg.appendChild @buildLabel( (oneHalf), 0.5, 0)
        svg.appendChild @buildLabel( (threeQuarter), 0.7, 0)
        svg.appendChild @buildLabel(@histogramSize.max, 0.9, 0)

module.exports = HistogramView
