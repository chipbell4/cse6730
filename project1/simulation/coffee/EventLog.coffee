Backbone = require 'backbone'

class EventLog extends Backbone.Collection

    comparator: 'timestamp'

    initialize: (options) ->
        @eventQueue = options.eventQueue
        # Whenever ANY event is thrown, store it for later
        @listenTo(@eventQueue, 'all', @push)

module.exports = EventLog
