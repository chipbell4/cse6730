Backbone = require 'backbone'
Station = require './Station.coffee'
EventQueueSingleton = require './EventQueueSingleton'
Directions = require './Directions.coffee'
TrackSegment = require './TrackSegment.coffee'

class StationConnection
    constructor: (@eastStation, @westStation) ->
        @eastwardTrack = new TrackSegment
        @westwardTrack = new TrackSegment
        @waitingTrack = new TrackSegment
        @tracksDisabled = 0

    disableTrack: () ->
        @tracksDisabled += 1
        if @tracksDisabled > 2
            @tracksDisabled = 2
        @realignTrains()

    enableTrack: () ->
        @tracksDisabled -= 1
        if @tracksDisabled < 0
            @tracksDisabled = 0
        @realignTrains()

    enqueueTrain: (train) ->
        @waitingTrack.add train
        @realignTrains()

     realignTrains: () ->
         # First, push all trains to the waiting track. We'll decide whether or not to split from there
         @waitingTrack.add @eastwardTrack.toJSON()
         @waitingTrack.add @westwardTrack.toJSON()
         @eastwardTrack.reset()
         @westwardTrack.reset()

         # If no tracks are available, there's nothing left to do
         if @tracksDisabled is 2
             return

         splitTrains = @waitingTrack.splitByDirection()

         # regardless, since a SINGLE track is at least available, we know that the eastbound trains get to use the
         # eastbound track
         @eastwardTrack.add(splitTrains.east.toJSON())
         
         # if we have a single track, the eastbound track will also take the west bound
         if @tracksDisabled is 1
             @eastwardTrack.add(splitTrains.west.toJSON())
         # otherwise, west can handle itself (since both tracks are available)
         else
             @westwardTrack.add(splitTrains.west.toJSON())
         
         @waitingTrack.reset()

     releaseNextTrains: () ->
         releasedTrains = new Backbone.Collection
         if @eastwardTrack.length > 0
             releasedTrains.push @eastwardTrack.shift()
         if @westwardTrack.length > 0
             releasedTrains.push @westwardTrack.shift()
         return releasedTrains

     onTrainArrived: (train, station) ->
         if train.get('direction') == Directions.EAST and station.get('code') == @westStation.get('code')
             @enqueueTrain(train)
         else if train.get('direction') == Directions.WEST and station.get('code') == @eastStation.get('code')
             @enqueueTrain(train)

     onConnectionExit: (connection, train, station) ->
        

module.exports = StationConnection
