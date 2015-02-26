Car = require './Car.coffee'

class CarEmitter
    constructor: (@eventQueue, @distributionParams) ->

    triggerCar: (currentTime) ->
        car = new Car()

        # TODO: Make this smarter
        timestamp = currentTime + Math.random() * 10

        @eventQueue.add(
            data: car
            name: 'car:arrived'
            timestamp: timestamp
        )

        return timestamp

module.exports = CarEmitter
