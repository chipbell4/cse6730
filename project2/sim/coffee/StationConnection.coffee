Backbone = require 'backbone'
Station = require './Station.coffee'
EventQueueSingleton = require './EventQueueSingleton'
Directions = require './Directions.coffee'
TrackSegment = require './TrackSegment.coffee'

class StationConnection extends Backbone.Model
    defaults: () ->
        {
            eastwardTrack: new TrackSegment
            westwardTrack: new TrackSegment
            waitingTrack: new TrackSegment
            tracksDisabled: 0
        }

    initialize: (options = {}) ->
        # wire up events
        @listenTo(EventQueueSingleton, 'train:arrive', @onTrainArrived)
        @listenTo(EventQueueSingleton, 'train:enter', @onConnectionEnter)
        @listenTo(EventQueueSingleton, 'train:exit', @onConnectionExit)

    disableTrack: () ->
        @set('tracksDisabled', @get('tracksDisabled') + 1)
        if @get('tracksDisabled') > 2
            @set('tracksDisabled', 2)
        @realignTrains()

    enableTrack: () ->
        @set('tracksDisabled', @get('tracksDisabled') - 1)
        if @get('tracksDisabled') < 0
            @set('tracksDisabled', 0)
        @realignTrains()

    enqueueTrain: (train) ->
        @get('waitingTrack').add train
        @realignTrains()

    realignTrains: () ->
        # First, push all trains to the waiting track. We'll decide whether or not to split from there
        @get('waitingTrack').add @get('eastwardTrack').toJSON()
        @get('waitingTrack').add @get('westwardTrack').toJSON()
        @get('eastwardTrack').reset()
        @get('westwardTrack').reset()

        # If no tracks are available, there's nothing left to do
        if @get('tracksDisabled') is 2
            return

        splitTrains = @get('waitingTrack').splitByDirection()

        # regardless, since a SINGLE track is at least available, we know that the eastbound trains get to use the
        # eastbound track
        @get('eastwardTrack').add(splitTrains.east.toJSON())
        
        # if we have a single track, the eastbound track will also take the west bound
        if @get('tracksDisabled') is 1
            @get('eastwardTrack').add(splitTrains.west.toJSON())
        # otherwise, west can handle itself (since both tracks are available)
        else
            @get('westwardTrack').add(splitTrains.west.toJSON())
        
        @get('waitingTrack').reset()

    releaseNextTrain: (direction) ->
        if @get('tracksDisabled') == 2
            return
        if @get('tracksDisabled') == 1 or direction is Directions.EAST
            return @get('eastwardTrack').shift()
        if direction is Directions.WEST
            return @get('westwardTrack').shift()

    onTrainArrived: (train, station) ->
        if train.get('direction') == Directions.EAST and station.get('code') == @get('westStation').get('code')
            @enqueueTrain(train)
        else if train.get('direction') == Directions.WEST and station.get('code') == @get('eastStation').get('code')
            @enqueueTrain(train)

    onConnectionEnter: (event) ->
        if event.get('data').connection isnt @
            return

        # Mark the train's neighboring stations
        if event.get('data').train.get('direction') is Directions.EAST
            event.get('data').train.set('previousStation', @westStation)
            event.get('data').train.set('nextStation', @eastStation)
        else
            event.get('data').train.set('previousStation', @eastStation)
            event.get('data').train.set('nextStation', @westStation)

        exitEvent = event.clone()
        exitEvent.set('name', 'train:exit')
        exitEvent.set('timestamp', event.get('timestamp') + @get('timeBetweenStations'))
        EventQueueSingleton.add(exitEvent)

    onConnectionExit: (event) ->
        connection = event.get('data').connection
        station = event.get('data').station
        train = event.get('data').train
        if connection isnt @
            return
        if station isnt @get('eastStation') and station isnt @get('westStation')
            return
        if @get('tracksDisabled') is 2
            return

        nextTrain = undefined
        if train.get('direction') is Directions.WEST and @get('tracksDisabled') is 0
            nextTrain = @get('westwardTrack').shift()
        else
            nextTrain = @get('eastwardTrack').shift()

        # Push a new event with the next train, but at the same timestamp
        newEvent = event.clone()
        newEvent.set('train', nextTrain)
        EventQueueSingleton.add(newEvent)

module.exports = StationConnection
