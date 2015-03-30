Backbone = require 'backbone'

###
# Represents the queue of domain events moving through the application
###
class EventQueue extends Backbone.Collection

    ###
    # Keep events sorted by the timestamp, so it remains a priority queue
    ###
    comparator: 'timestamp'

    ###
    # Emits the next event in the queue
    ###
    emitNext: ->
        nextEvent = this.shift()

        # emit the event
        this.trigger(nextEvent.get('name'), nextEvent)

        # return it, just in case someone wants is
        return nextEvent

    ###
    # Events all events that are due to run before the passed timestamp. Essentially "re-syncs" the queue with the
    # current time
    ###
    emitNextAt: (timestamp) ->
        this.emitNext() while this.first()? and this.first().get('timestamp') <= timestamp

module.exports = EventQueue
