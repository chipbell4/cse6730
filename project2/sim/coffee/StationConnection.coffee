Backbone = require 'backbone'
Station = require './Station.coffee'
EventQueueSingleton = require './EventQueueSingleton'
Directions = require './Directions.coffee'
TrackSegment = require './TrackSegment.coffee'

###
# The most important class in the simulation. Represents the connection between two stations. Each connection has a
# designated eastward and westward track, but these can be disabled forcing eastbound and westbound trains to share
# a track.
###
class StationConnection extends Backbone.Model
    ###
    # The default values for the connection. Initializes empty tracks, and defaults 0 tracks to be disabled
    ###
    defaults: () ->
        {
            eastwardTrack: new TrackSegment
            westwardTrack: new TrackSegment
            waitingTrack: new TrackSegment
            tracksDisabled: 0
        }

    ###
    # The constructor. Wires up the main events we care about: When a train arrives at the edge of the connection. When
    # a train enters a connection, occupying a track, and when a train exits a connection, freeing a track for use by
    # the next train
    ###
    initialize: (options = {}) ->
        @listenTo(EventQueueSingleton, 'train:arrive', @onTrainArrived)
        @listenTo(EventQueueSingleton, 'train:enter', @onConnectionEnter)
        @listenTo(EventQueueSingleton, 'train:exit', @onConnectionExit)

    ###
    # disables a track, forcing trains to share a track (potentially even wait for a track to become free)
    ###
    disableTrack: () ->
        @set('tracksDisabled', @get('tracksDisabled') + 1)
        if @get('tracksDisabled') > 2
            @set('tracksDisabled', 2)
        @realignTrains()

    ###
    # Enables a track
    ###
    enableTrack: () ->
        @set('tracksDisabled', @get('tracksDisabled') - 1)
        if @get('tracksDisabled') < 0
            @set('tracksDisabled', 0)
        @realignTrains()

    ###
    # Enqueues a new train to pass through the connection
    ###
    enqueueTrain: (train) ->
        @get('waitingTrack').add train
        @realignTrains()

    ###
    # Reassigns trains to the correct holding locations. For instance, if no tracks are available, it pushes all trains
    # to a "waiting track". If a single is available, makes all trains use an eastward track. Otherwise, splits them by
    # their direction
    ###
    realignTrains: () ->
        # First, push all trains to the waiting track. We'll decide whether or not to split from there
        @get('waitingTrack').add @get('eastwardTrack').toArray()
        @get('waitingTrack').add @get('westwardTrack').toArray()
        @get('eastwardTrack').reset()
        @get('westwardTrack').reset()

        # If no tracks are available, there's nothing left to do
        return if @get('tracksDisabled') is 2

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

    ###
    # Releases the next train heading a certain direction
    ###
    releaseNextTrain: (direction) ->
        return if @get('tracksDisabled') == 2
        return @get('eastwardTrack').shift() if @get('tracksDisabled') == 1 or direction is Directions.EAST
        return @get('westwardTrack').shift() if direction is Directions.WEST

    ###
    # Handler for when a train arrives. Pushes the train onto the queue to be processed. However, if a track is open,
    # it goes ahead and pushes the train through
    ###
    onTrainArrived: (event) ->
        train = event.get('data').train
        station = event.get('data').station
        return if event.get('data').connection isnt @

        @enqueueTrain(train)

        # Go ahead and push the train through, if it's the only remaining train
        track = @preferredTrackForTrain(train)
        if track? and track.length is 1
            event.get('data').track = track
            track.shift()
            @onConnectionEnter(event)

    ###
    # Handler for when a train enters a connection. Prevents other trains from entering the connection, but also
    # schedules the exit event for the train in the future, so that other trains can move through.
    ###
    onConnectionEnter: (event) ->
        return if event.get('data').connection isnt @

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

    ###
    # Handler for when a train exits the connection. Frees the track that was being used, and queues up the next train
    # (if there is one) to occupy the connection.
    ###
    onConnectionExit: (event) ->
        # pluck data off of the event
        connection = event.get('data').connection
        station = event.get('data').station
        train = event.get('data').train
        track = event.get('data').track

        # now decide if the next train can be pushed along?
        return if connection isnt @

        # free up the track
        track.occupy(null)

        return if @get('tracksDisabled') is 2
        
        nextTrack = @preferredTrackForTrain(train)
        nextTrain = @releaseNextTrain(train.get('direction'))

        # if there is no next train, just wait for the next
        return if not nextTrain?
        return if not nextTrack?

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

    ###
    # Decides which track a train should be placed on, based on it's direction and how many tracks are available.
    ###
    preferredTrackForTrain: (train) ->
        return null if @get('tracksDisabled') is 2
        return @get('eastwardTrack') if train.get('direction') is Directions.EAST and not @get('eastwardTrack').isOccupied()
        if train.get('direction') is Directions.WEST
            return @get('westwardTrack') if @get('tracksDisabled') is 0 and not @get('westwardTrack').isOccupied()
            return @get('eastwardTrack') if @get('tracksDisabled') is 1 and not @get('eastwardTrack').isOccupied()
        return null

    ###
    # If a line is blocked but then reopened, waiting trains may not have an event to trigger them to enter the connection.
    ###
    awakenLines: (timestamp) ->
        track = @preferredTrackForTrain(new Backbone.Model(direction: Directions.EAST))
        if @canAwakenInDirection(Directions.EAST) and track.length > 0
            event = new Backbone.Model(
                name: 'train:enter'
                timestamp: timestamp
                data:
                    train: @get('eastwardTrack').shift()
                    connection: @
                    track: @get('eastwardTrack')
            )
            @onConnectionEnter(event)

        track = @preferredTrackForTrain(new Backbone.Model(direction: Directions.WEST))
        if @canAwakenInDirection(Directions.WEST) and track.length > 0
            event = new Backbone.Model(
                name: 'train:enter'
                timestamp: timestamp
                data:
                    train: track.shift()
                    connection: @
                    track: track
            )
            @onConnectionEnter(event)

    ###
    # Decides if a direction is free to be awakened, i.e. starting trains on that line again
    ###
    canAwakenInDirection: (direction) ->
        track = @preferredTrackForTrain(new Backbone.Model(direction: direction))
        return track?

    ###
    # A nice string representation of the connection. Provides the two stations that are connected
    ###
    toString: () ->
        @get('eastStation').get('name') + ' to ' + @get('westStation').get('name')

module.exports = StationConnection
