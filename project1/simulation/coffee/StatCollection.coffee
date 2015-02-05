Backbone = require 'backbone'
SingleCarStat = require './SingleCarStat.coffee'

class StatCollection extends Backbone.Collection

    model: SingleCarStat

    watchEventQueue: (eventQueue) ->
        @listenTo(eventQueue, 'car:arrived', @onCarArrived.bind(@))
        @listenTo(eventQueue, 'car:exited', @onCarExited.bind(@))

    exitedCars: ->
        @filter( (model) -> model.hasExited() )

    waitingCars: ->
        @filter( (model) -> not model.hasExited() )

    averageDuration: ->
        sum = (accumulator, model) -> accumulator + model.getDuration()
        @exitedCars().reduce(sum, 0) / @exitedCars().length

    onCarArrived: (event) ->
        # add the arrival to our list
        @push(
            carId: event.get('data').cid
            arrivalTime: event.get('timestamp')
        )

    onCarExited: (event) ->
        carStat = @findWhere(
            carId: event.get('data').cid
        )

        carStat.set('exitTime', event.get('timestamp'))
        
module.exports = StatCollection
