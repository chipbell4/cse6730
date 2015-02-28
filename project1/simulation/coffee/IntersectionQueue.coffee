AccelerationCalculator = require './AccelerationCalculator.coffee'
Backbone = require 'backbone'

###
# Collection for representing the line of cars waiting at the light
###
class IntersectionQueue extends Backbone.Collection

    ###
    # Keep cars sorted by their position
    ###
    comparator: 'position'

    ###
    # Go ahead and start listening to the event queue for when cars enter and leave the system. Also listens to the
    # light changes to change its blocking/non-blocking status
    ###
    initialize: (items, @eventQueue) ->
        @eventQueue.on('car:arrived', @onCarArrived.bind(@))
        @eventQueue.on('car:exited', @onCarExited.bind(@))
        @eventQueue.on('light:changed', @onLightChanged.bind(@))

        @blockingCars = true
        @accelerator = new AccelerationCalculator
        @queueIndex = 1
        @lastEmitTimestamp = 0

    ###
    # A car has arrived. Also, if we're not blocking, go ahead and release the car as well
    ###
    onCarArrived: (event) ->
        @push event.get('data')

        if not @blockingCars
            @releaseCar event.get('timestamp')

    ###
    # Releases a car from the intersection at a given timestmp. Using the acceleration calculator to figure out WHEN a
    # car would make it out and schedules that to happen.
    ###
    releaseCar: (currentTimestamp) ->
        # since there are no cars, reset the queue length
        if @length == 0
            @queueIndex = 1
            return

        # Calculate when the next car in the queue will hit the intersection
        @accelerator.options.queue_index = @queueIndex
        @lastEmitTimestamp = currentTimestamp + @accelerator.timeToIntersection()

        # Queue up the event to happen. This collection is actually listening for that every event and will pop off the
        # car when it's time.
        @eventQueue.add(
            data: @pop()
            timestamp: @lastEmitTimestamp
            name: 'car:exited'
        )

        # move to the next car in the queue, so that the delay will change
        @queueIndex += 1

    ###
    # A car has exited. Since there's only one intersection queue, and only one car at the front we can safely assume
    # we can just release the first
    ###
    onCarExited: (event) ->
        if @blockingCars
            return

        @releaseCar event.get('timestamp')

    ###
    # Triggered when the light changes. Essentially swaps the blocking/non-blocking state.
    ###
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
