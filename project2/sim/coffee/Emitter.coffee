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
    constructor: (@eventQueue, @emitType,  @histogram) ->
        sum = (array) ->
            array.reduce( ((a,b) -> a + b), 0 )
        indices = [0..@histogram.pdf.length]
        # a little cryptic, but essentially does running sums to calculate the CDF
        pdf = @histogram.pdf
        @histogramCdf = indices.map((index) -> sum(pdf[..index]))

    ###
    # Returns a number, sampled from the histogram. First, samples from the bins based off of the weights of those
    # bins. However, once a bin is chosen, it samples uniformly within the interval captured by the bin
    ###
    sampleHistogram: ->
        # Figure out which bucket to sample from
        uniformRandom = Math.random()
        index = 0
        while uniformRandom > @histogramCdf[index]
            index += 1

        # now, uniformly sample from that bucket
        binLeft = @histogramBinWidth * index
        binRight = binLeft + @histogramBinWidth

        return Math.random() * (binRight - binLeft) + binLeft

    ###
    # Triggers the next item given the current timestamp
    ###
    emitNext: () ->
        timestamp = Time.current() + @sampleHistogram()
        
        item = new @emitType(
            arrivalTime: timestamp
        )

        @eventQueue.add(
            data: item
            name: 'item:arrived'
            timestamp: timestamp
        )

        return timestamp

module.exports = Emitter
