Directions = require './Directions.coffee'

TrackSegment = require './TrackSegment.coffee'

class StationConnection
    constructor: (@timeBetweenStations) ->
        @eastwardTrack = new TrackSegment
        @westwardTrack = new TrackSegment
        @tracksDisabled = 0

    disableTrack: () ->
        @tracksDisabled += 1
        if @tracksDisabled > 2
            @tracksDisabled = 2

    enableTrack: () ->
        @tracksDisabled -= 1
        if @tracksDisabled < 0
            @tracksDisabled = 0

    enqueueTrain: (train) ->
        if train.direction is Directions.EAST
            @eastwardTrack.push(train)
        else
            @westwardTrack.push(train)

module.exports = StationConnection
