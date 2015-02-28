Backbone = require 'backbone'
SingleCarStat = require './SingleCarStat.coffee'

###
# A collection of car stats
###
class StatCollection extends Backbone.Collection

    ###
    # Lets the collection know that everything in the collection is a Stat
    ###
    model: SingleCarStat

    ###
    # Essentially listens for cars to leave and exit the system
    ###
    watchEventQueue: (eventQueue) ->
        @listenTo(eventQueue, 'car:arrived', @onCarArrived.bind(@))
        @listenTo(eventQueue, 'car:exited', @onCarExited.bind(@))

    ###
    # Filters the collection to only get exited cars
    ###
    exitedCars: ->
        @filter( (model) -> model.hasExited() )

    ###
    # Filters the collection to only get waiting cars
    ###
    waitingCars: ->
        @filter( (model) -> not model.hasExited() )

    ###
    # Gets the average waiting time for cars
    ###
    averageDuration: ->
        sum = (accumulator, model) -> accumulator + model.getDuration()
        @exitedCars().reduce(sum, 0) / @exitedCars().length

    ###
    # A car arrived, push it in the queue and wait for it to exit.
    ###
    onCarArrived: (event) ->
        # add the arrival to our list
        @push(
            carId: event.get('data').cid
            arrivalTime: event.get('timestamp')
        )

    ###
    # A car left, find it and mark it's exit time.
    ###
    onCarExited: (event) ->
        carStat = @findWhere(
            carId: event.get('data').cid
        )

        # if we can't find one, that means that we've reset statistics. We'll just ignore it
        if not carStat?
            return

        carStat.set('exitTime', event.get('timestamp'))
        
module.exports = StatCollection
