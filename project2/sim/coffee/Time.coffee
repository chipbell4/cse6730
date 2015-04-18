underscore = require 'underscore'
Backbone = require 'backbone'

currentTime = 0

###
# Wrapper around the current time in the simulation. Allows a nice, safe interface for interacting with the current
# time in the simulation
###
Time = 
    ###
    # Steps forward a second
    ###
    step: (stepSize = 1) ->
        currentTime += stepSize
        @trigger('time:step', currentTime)
        currentTime

    ###
    # Resets the time back to 0
    ###
    reset: ->
        currentTime = 0
        @trigger('time:reset', currentTime)
        currentTime

    ###
    # Jumps to a particular instance in time
    ###
    jumpTo: (newTime) ->
        currentTime = newTime
        @trigger('time:jump', newTime)
        currentTime

    ###
    # Gets the current time
    ###
    current: ->
        currentTime

# mix in eventing into the Time object, so listeners can catch events about things happening to the current simulation
# time
underscore.extend(Time, Backbone.Events)

module.exports = Time
