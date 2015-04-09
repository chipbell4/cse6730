Backbone = require 'backbone'
Train = require './Train'

###
# Represents a track segment, where trains can queue up to pass through. This is the limited resource in the
# simulation, since no two trains can be on the same track segment at a time
###
class TrackSegment extends Backbone.Collection
    ###
    # Only trains can drive on a track segment
    ###
    model: Train

    ###
    # Alias for unshift, so we have a more domain-friendly notation for pushing a train through the segment
    ###
    releaseNextTrain: ->
        @shift()

module.exports = TrackSegment
