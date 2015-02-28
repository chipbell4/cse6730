Backbone = require 'backbone'
_ = require 'underscore'

###
# Class to represent the light signal. Switches periodically between the three light colors.
###
class LightSignal
    ###
    # Sets up the light signal, specifying an initial green, red, and yellow time. Also listens for its own queued
    # light:changed event to emit the next light:change
    ###
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

    ###
    # Figures out the next light color from the current
    ###
    getNextColor: ->
        return switch @currentColor
            when 'red' then 'green'
            when 'yellow' then 'red'
            when 'green' then 'yellow'

    ###
    # Triggers the next light change after currentTimestamp
    ###
    triggerLightChange: (currentTimestamp) ->
        nextColor = @getNextColor()

        @eventQueue.add(
            data: nextColor
            name: 'light:changed'
            timestamp: currentTimestamp + @durations[@currentColor]
        )

    ###
    # Triggered when a light changes. Essentially sets the new color, and schedules the next light change
    ###
    onLightChange: (event) ->
        # change my color
        @currentColor = event.get('data')

        # Schedule the next change
        @triggerLightChange(event.get('timestamp'))

     ###
     # Listener for when anyone chooses to change light timings
     ###
     updateTimings: (newTimings) ->
        colors = ['red', 'yellow', 'green']
        @durations[color] = Number newTimings.get(color) for color in colors

module.exports = LightSignal
