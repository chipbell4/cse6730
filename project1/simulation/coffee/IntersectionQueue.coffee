AccelerationCalculator = require './AccelerationCalculator.coffee'
Backbone = require 'backbone'

# Represents a list of cars at the light
class IntersectionQueue extends Backbone.Collection

    # sort by the timestamp
    comparator: 'position'

    initialize: (items, @eventQueue) ->
        @eventQueue.on('car:arrived', @onCarArrived.bind(@))
        @eventQueue.on('car:exited', @onCarExited.bind(@))
        @eventQueue.on('light:changed', @onLightChanged.bind(@))
        @blockingCars = true
        @accelerator = new AccelerationCalculator
        @queueIndex = 1
        @lastEmitTimestamp = 0

    onCarArrived: (event) ->
        @push event.get('data')

        if not @blockingCars
            @releaseCar event.get('timestamp')

    releaseCar: (currentTimestamp) ->
        # since there are no cars, reset the queue length
        if @length == 0
            @queueIndex = 1
            return

        # Calculate when the next car in the queue will hit the intersection
        @accelerator.options.queue_index = @queueIndex
        @lastEmitTimestamp = currentTimestamp + @accelerator.timeToIntersection()

        @eventQueue.add(
            data: @pop()
            timestamp: @lastEmitTimestamp
            name: 'car:exited'
        )

        # move to the next car in the queue, so that the delay will change
        @queueIndex += 1

    onCarExited: (event) ->
        if @blockingCars
            return

        @releaseCar event.get('timestamp')

    onLightChanged: (event) ->
        color = event.get('data')
        if color == 'red'
            @blockingCars = true
        else
            @blockingCars = false

        if @blockingCars
            return

        # If we're not blocking cars, push a car through
        @releaseCar event.get('timestamp')

module.exports = IntersectionQueue
