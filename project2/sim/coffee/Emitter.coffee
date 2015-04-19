_ = require 'underscore'
Random = require './Random.coffee'
Time = require './Time.coffee'

###
# Main "emitter" for items. Allows you to pass in a histogram of the probability distribution you'd like to emit as, and
# will emit as often as you'd like
###
class Emitter
    ###
    # Creates a new emitter, passing the event queue, the type to emit, and an object describing the histogram, with a
    # pdf, min, and max keys
    ###
    constructor: (options) ->
        { @eventQueue, @histogram } = options

        sum = (array) ->
            array.reduce( ((a,b) -> a + b), 0 )
        indices = [0..@histogram.pdf.length]
        # a little cryptic, but essentially does running sums to calculate the CDF
        pdf = @histogram.pdf
        @histogram.cdf = indices.map((index) -> sum(pdf[..index]))

    ###
    # Chooses a bin randomly, based on the histogram's cdf
    ###
    chooseBinRandomly: () ->
        r = Random.random()
        currentIndex = 0
        while r > @histogram.cdf[currentIndex]
            currentIndex += 1
        return currentIndex

    ###
    # Calculates the width of a histogram bin
    ###
    calculateBinWidth: () ->
        (@histogram.max - @histogram.min) / @histogram.pdf.length

    ###
    # Samples uniformly within a bin
    ###
    uniformSampleWithinBin: (binIndex) ->
        binWidth = @calculateBinWidth()
        leftEdge = binWidth * binIndex + @histogram.min
        rightEdge = leftEdge + binWidth
        return leftEdge + (rightEdge - leftEdge) * Random.random()

    ###
    # Returns a number, sampled from the histogram. First, samples from the bins based off of the weights of those
    # bins. However, once a bin is chosen, it samples uniformly within the interval captured by the bin
    ###
    sampleHistogram: ->
        binIndex = @chooseBinRandomly()
        return @uniformSampleWithinBin(binIndex)

    ###
    # Triggers the next item given the current timestamp
    ###
    emitNext: () ->
        return Time.current() + @sampleHistogram()

module.exports = Emitter
