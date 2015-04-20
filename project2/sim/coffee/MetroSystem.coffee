Backbone = require 'backbone'
Directions = require './Directions'
Station = require './Station'
StationConnection = require './StationConnection'
EventQueueSingleton = require './EventQueueSingleton'

###
# A class to represent the collection of stations, connected by pieces of track
###
class MetroSystem
    ###
    # The main constructor. Takes an array of station data (see the station data file for an example) and builds a
    # list of stations, along with station connections to join them. Also handles events that require a train to pass
    # from one connection to the next
    ###
    constructor: (@stationData) ->
        # Map to an array of station objects
        @stationData = (new Station(station) for station in @stationData)

        # Build a list of connections from the station object list
        @connections = ( @stationConnectionFactory(index) for index in [1..@stationData.length-1])

        # Wire up events
        EventQueueSingleton.on('train:exit', @onConnectionExit.bind(@))

    ###
    # Helper function for building a station connection from the list of stations stored within the metro system. Takes
    # the right index at which to build
    ###
    stationConnectionFactory: (index) ->
        eastwardTime = @stationData[index - 1].get('timeFromNextEasternStation')
        westwardTime = @stationData[index].get('timeFromNextWesternStation')

        timeBetweenStations = 0
        if eastwardTime? and westwardTime?
            timeBetweenStations = (eastwardTime + westwardTime) / 2
        else if eastwardTime?
            timeBetweenStations = eastwardTime
        else
            timeBetweenStations = westwardTime

        new StationConnection(
            eastStation: @stationData[index - 1]
            westStation: @stationData[index]
            timeBetweenStations: timeBetweenStations
        )

    ###
    # Event handler for when a train exits a connection, meaning that it needs to arrive at the next connection in the
    # list of connections, if there is one
    ###
    onConnectionExit: (event) ->
        eventData = event.get('data')
        nextConnection = @nextConnectionForTrain(eventData.train, eventData.connection)

        if not nextConnection?
            return

        arrivingStation = nextConnection.get('eastStation')
        if eventData.train.get('direction') is Directions.WEST
            arrivingStation = nextConnection.get('westStation')

        EventQueueSingleton.add(
            name: 'train:arrive'
            timestamp: event.get('timestamp')
            data:
                train: eventData.train
                connection: nextConnection
                station: arrivingStation
        )

    ###
    # Figures out the next connection for train, given the current one it just left
    ###
    nextConnectionForTrain: (train, currentConnection) ->
        index = @connections.indexOf(currentConnection)
        if index is -1
            return null
        if index is (@connections.length - 1) and train.get('direction') is Directions.WEST
            return null
        if index is 0 and train.get('direction') is Directions.EAST
            return null

        return @connections[index + train.get('direction')]

module.exports = MetroSystem
