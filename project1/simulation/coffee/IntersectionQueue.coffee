Backbone = require 'backbone'

# Represents a list of cars at the light
class IntersectionQueue extends Backbone.Collection

    # sort by the timestamp
    comparator: 'position'

    constructor: (@eventQueue) ->
        @eventQueue.on('car:arrived', @onCarArrived)

    onCarArrived: ->
        console.log 'Arived'
