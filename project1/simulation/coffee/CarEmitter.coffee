Car = require './Car.coffee'

###
# Main "emitter" for cars. Allows you to pass in a histogram of the probability distribution you'd like to emit as, and
# will emit as often as you'd like
###
class CarEmitter
    ###
    # Creates a new emitter, passing the event queue, an array of probabilities for the bins of the distribution, and
    # the width of each bin
    ###
    constructor: (@eventQueue, @histogramPdf, @histogramBinWidth) ->
        sum = (array) ->
            array.reduce( ((a,b) -> a + b), 0 )
        indices = [0..@histogramPdf.length]
        # a little cryptic, but essentially does running sums to calculate the CDF
        pdf = @histogramPdf
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
    # Triggers a car given the current timestamp
    ###
    triggerCar: (currentTime) ->
        timestamp = currentTime + @sampleHistogram()
        
        car = new Car(
            arrivalTime: timestamp
        )

        @eventQueue.add(
            data: car
            name: 'car:arrived'
            timestamp: timestamp
        )

        return timestamp

module.exports = CarEmitter
