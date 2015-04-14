_ = require 'underscore'
Backbone = require 'backbone'
Station = require './Station.coffee'
EventQueueSingleton = require './EventQueueSingleton'
Directions = require './Directions.coffee'
TrackSegment = require './TrackSegment.coffee'

class StationConnection
    constructor: (options = {}) ->
        options.eastStation ?= new Station
        options.westStation ?= new Station
        @eastStation = options.eastStation
        @westStation = options.westStation
        @eastwardTrack = new TrackSegment
        @westwardTrack = new TrackSegment
        @waitingTrack = new TrackSegment
        @tracksDisabled = 0
        @cid = _.uniqueId()

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

     releaseNextTrain: (direction) ->
         if @tracksDisabled == 2
             return
         if @tracksDisabled == 1 or direction is Directions.EAST
             return @eastwardTrack.shift()
         if direction is Directions.WEST
             return @westwardTrack.shift()

     onTrainArrived: (train, station) ->
         if train.get('direction') == Directions.EAST and station.get('code') == @westStation.get('code')
             @enqueueTrain(train)
         else if train.get('direction') == Directions.WEST and station.get('code') == @eastStation.get('code')
             @enqueueTrain(train)

     onConnectionEnter: (event) ->
         return

     onConnectionExit: (event) ->
         connection = event.get('data').connection
         station = event.get('data').station
         train = event.get('data').train
         if connection.cid isnt @cid
             return
         if station.cid isnt @eastStation.cid and station.cid isnt @westStation.cid
             return
         if @tracksDisabled is 2
             return

         nextTrain = undefined
         if train.get('direction') is Directions.WEST and @tracksDisabled is 0
             nextTrain = @westwardTrack.shift()
         else
             nextTrain = @eastwardTrack.shift()

         # Push a new event with the next train, but at the same timestamp
         newEvent = event.clone()
         newEvent.set('train', nextTrain)
         EventQueueSingleton.add(newEvent)
             

module.exports = StationConnection
