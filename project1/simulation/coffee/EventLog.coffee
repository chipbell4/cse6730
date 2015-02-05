Backbone = require 'backbone'

class EventLog extends Backbone.Collection

    comparator: 'timestamp'

    watchEventQueue: (eventQueue) ->
        # Whenever ANY event is thrown, store it for later
        @listenTo(eventQueue, 'all', @onEventTriggered)

     onEventTriggered: (eventName, event) ->
         # ignore non-domain events
         if eventName.indexOf(':') < 0
             return

         @push(event)

module.exports = EventLog
