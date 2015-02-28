Backbone = require 'backbone'

###
# Collection class that captures ALL events emitted on the event queue. However, it does ignore Backbone built-in
# events like "add" "reset", etc.
###
class EventLog extends Backbone.Collection

    ###
    # Keeps everything sorted by timestep
    ###
    comparator: 'timestamp'

    ###
    # Helper method for setting up event listening
    ###
    watchEventQueue: (eventQueue) ->
        # Whenever ANY event is thrown, store it for later
        @listenTo(eventQueue, 'all', @onEventTriggered)

     ###
     # Called whenever an event is triggered on the event queue. Essentially a wrapper around push that ignores
     # Backbone native events
     ###
     onEventTriggered: (eventName, event) ->
         # ignore non-domain events
         if eventName.indexOf(':') < 0
             return

         @push(event)

module.exports = EventLog
