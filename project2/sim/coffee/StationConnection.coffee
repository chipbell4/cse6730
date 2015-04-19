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
        @get('waitingTrack').add @get('eastwardTrack').toArray()
        @get('waitingTrack').add @get('westwardTrack').toArray()
        @get('eastwardTrack').reset()
        @get('westwardTrack').reset()

        # If no tracks are available, there's nothing left to do
        if @get('tracksDisabled') is 2
            return

        splitTrains = @get('waitingTrack').splitByDirection()

        # regardless, since a SINGLE track is at least available, we know that the eastbound trains get to use the
        # eastbound track
        @get('eastwardTrack').add(splitTrains.east.toArray())
        
        # if we have a single track, the eastbound track will also take the west bound
        if @get('tracksDisabled') is 1
            @get('eastwardTrack').add(splitTrains.west.toArray())
        # otherwise, west can handle itself (since both tracks are available)
        else
            @get('westwardTrack').add(splitTrains.west.toArray())
        
        @get('waitingTrack').reset()

    releaseNextTrain: (direction) ->
        if @get('tracksDisabled') == 2
            return
        if @get('tracksDisabled') == 1 or direction is Directions.EAST
            return @get('eastwardTrack').shift()
        if direction is Directions.WEST
            return @get('westwardTrack').shift()

    onTrainArrived: (event) ->
        train = event.get('data').train
        station = event.get('data').station
        if event.get('data').connection isnt @
            return

        @enqueueTrain(train)

        # Go ahead and push the train through, if it's the only remaining train
        track = @preferredTrackForTrain(train)
        if track? and track.length is 1
            event.get('data').track = track
            track.shift()
            @onConnectionEnter(event)

    onConnectionEnter: (event) ->
        if event.get('data').connection isnt @
            return

        # mark the track as unavailable
        event.get('data').track.occupy(event.get('data').train)

        # Mark the train's neighboring stations, and enter time
        previousStation = null
        nextStation = null
        if event.get('data').train.get('direction') is Directions.EAST
            previousStation = @get('westStation')
            nextStation = @get('eastStation')
        else
            previousStation = @get('eastStation')
            nextStation = @get('westStation')
        event.get('data').train.set(
            previousStation: previousStation
            nextStation: nextStation
            enterTime: event.get('timestamp')
            connection: @
        )

        exitEvent = new Backbone.Model(
            name: 'train:exit'
            timestamp: event.get('timestamp') + @get('timeBetweenStations')
            data:
                station: nextStation
                connection: @
                train: event.get('data').train
                track: event.get('data').track
        )
        EventQueueSingleton.add(exitEvent)

    onConnectionExit: (event) ->
        # pluck data off of the event
        connection = event.get('data').connection
        station = event.get('data').station
        train = event.get('data').train
        track = event.get('data').track

        # now decide if the next train can be pushed along?
        if connection isnt @
            return

        # free up the track
        track.occupy(null)

        if @get('tracksDisabled') is 2
            return
        
        nextTrack = @preferredTrackForTrain(train)
        nextTrain = @releaseNextTrain(train.get('direction'))

         # if there is no next train, just wait for the next
        if not nextTrain?
            return

        # Push a new event with the next train entering the connection, but at the same timestamp
        EventQueueSingleton.add(
            name: 'train:enter'
            timestamp: event.get('timestamp')
            data:
                train: nextTrain
                track: nextTrack
                connection: @
                station: event.get('station')
        )

    preferredTrackForTrain: (train) ->
        if @get('tracksDisabled') is 2
            return null
        else if train.get('direction') is Directions.EAST and not @get('eastwardTrack').isOccupied()
            return @get('eastwardTrack')
        else if train.get('direction') is Directions.WEST
            if @get('tracksDisabled') is 0 and not @get('westwardTrack').isOccupied()
                return @get('westwardTrack')
            else if @get('tracksDisabled') is 1 and not @get('eastwardTrack').isOccupied()
                return @get('eastwardTrack')
        return null

    toString: () ->
        @get('eastStation').get('name') + ' to ' + @get('westStation').get('name')

module.exports = StationConnection
