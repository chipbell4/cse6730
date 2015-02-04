Backbone = require 'backbone'

class LightSignal extends Backbone.Events
    constructor: (@eventQueue, redTime, yellowTime, greenTime) ->
        @currentColor = 'red'
        @durations =
            red: redTime
            yellow: yellowTime
            green: greenTime

        # Let the light listen for its own signal changes so it can push new changes on
        @this.listenTo(@eventQueue, 'light:changed', @onLightChange)

    getNextColor: ->
        'green' if @currentColor == 'red'
        'red' if @currentColor == 'yellow'
        'yellow' if @currentColor == 'green'

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
