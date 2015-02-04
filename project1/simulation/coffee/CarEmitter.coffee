Car = require './Car.coffee'

class CarEmitter
    constructor: (@eventQueue, @distributionParams) ->

    triggerCar: (currentTime) ->
        car = new Car()

        # TODO: Make this smarter
        @eventQueue.add(
            data: car
            name: 'car:arrived'
            timestamp: currentTime + Math.random() * 10
        )

        return car
