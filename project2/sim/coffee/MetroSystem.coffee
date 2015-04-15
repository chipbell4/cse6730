Backbone = require 'backbone'
Directions = require './Directions'
StationConnection = require './StationConnection'
EventQueueSingleton = require './EventQueueSingleton'

###
# A class to represent the collection of stations, connected by pieces of track
###
class MetroSystem
    constructor: (@stationData) ->
        @connections = [ @stationConnectionFactory(index) for index in [1..@stationData.length-1]]

    stationConnectionFactory: (index) ->
        # TODO: Set the between station time "timeBetweenStations" from @stationData

        new StationConnection(
            eastStation: @stationData[index - 1]
            westStation: @stationData[index]
        )

    onConnectionExit: (event) ->
        eventData = event.get('data')
        nextConnection = @nextConnectionForTrain(eventData.train, eventData.connection)

        if not nextConnection?
            return

        arrivingStation = nextConnection.eastStation
        if eventData.train.get('direction') is Directions.EAST
            arrivingStation = nextConnection.westStation

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
