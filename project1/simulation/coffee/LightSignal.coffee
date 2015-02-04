Backbone = require 'backbone'
_ = require 'underscore'

class LightSignal
    constructor: (@eventQueue, redTime, yellowTime, greenTime) ->
        # mix in eventing
        _.extend @, Backbone.Events 
        @currentColor = 'red'
        @durations =
            red: redTime
            yellow: yellowTime
            green: greenTime

        # Let the light listen for its own signal changes so it can push new changes on
        @listenTo(@eventQueue, 'light:changed', @onLightChange)

    getNextColor: ->
        return switch @currentColor
            when 'red' then 'green'
            when 'yellow' then 'red'
            when 'green' then 'yellow'

    # Triggers the next light change
    triggerLightChange: (currentTimestamp) ->
        nextColor = @getNextColor()

        @eventQueue.add(
            data: nextColor
            name: 'light:changed'
            timestamp: currentTimestamp + @durations[@currentColor]
        )

    onLightChange: (event) ->
        # change my color
        @currentColor = event.get('data')

        # Schedule the next change
        @triggerLightChange(event.get('timestamp'))

module.exports = LightSignal
