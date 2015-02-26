Car = require './Car.coffee'

class CarEmitter
    constructor: (@eventQueue, @histogramPdf, @histogramBinWidth) ->
        sum = (array) ->
            array.reduce( ((a,b) -> a + b), 0 )
        indices = [0..@histogramPdf.length]
        # a little cryptic, but essentially does running sums to calculate the CDF
        pdf = @histogramPdf
        @histogramCdf = indices.map((index) -> sum(pdf[..index]))

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
