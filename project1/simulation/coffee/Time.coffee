underscore = require 'underscore'
Backbone = require 'backbone'

currentTime = 0

Time = 
    step: ->
        currentTime += 1
        @trigger('time:step', currentTime)
        currentTime
    reset: ->
        currentTime = 0
        @trigger('time:reset', currentTime)
        currentTime
    jumpTo: (newTime) ->
        currentTime = newTime
        @trigger('time:jump', newTime)
        currentTime
    current: ->
        currentTime

# mixin eventing into the Time object, so people can listen to events
underscore.extend(Time, Backbone.Events)

module.exports = Time
