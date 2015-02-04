Backbone = require 'backbone'

# Represent the queue of events
class EventQueue extends Backbone.Collection

    # sort by the timestamp
    comparator: 'timestamp'

    # Emits the next event in the queue
    emitNext: ->
        nextEvent = this.shift()

        # emit the event
        this.trigger(nextEvent.get('name'), nextEvent.get('data'))

        # return it, just in case someone wants is
        return nextEvent

    # Events the next event in the queue if its due to run
    emitNextAt: (timestamp) ->
        this.emitNext() if this.first().get('timestamp') <= timestamp
