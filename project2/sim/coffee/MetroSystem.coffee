Backbone = require 'backbone'
Directions = require './Directions'
Station = require './Station'
StationConnection = require './StationConnection'
EventQueueSingleton = require './EventQueueSingleton'

###
# A class to represent the collection of stations, connected by pieces of track
###
class MetroSystem
    constructor: (@stationData) ->
        # Map to an array of station objects
        @stationData = (new Station(station) for station in @stationData)

        # Build a list of connections from the station object list
        @connections = ( @stationConnectionFactory(index) for index in [1..@stationData.length-1])

        # Wire up events
        EventQueueSingleton.on('train:exit', @onConnectionExit.bind(@))

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
