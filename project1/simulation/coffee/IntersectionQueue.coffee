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

    onCarArrived: (event) ->
        @push event.get('data')

    releaseCar: (currentTimestamp) ->
        if @length == 0
            return

        @eventQueue.add(
            data: @pop()
            timestamp: currentTimestamp + 2 # TODO: Make this variable
            name: 'car:exited'
        )

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
