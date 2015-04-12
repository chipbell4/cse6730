Directions = require './Directions'
StationConnection = require './StationConnection'

###
# A class to represent the collection of stations, connected by pieces of track
###
class MetroSystem
    constructor: (@stationData, @eventQueue) ->
        @connections = [ new StationConnection() for index in [1..@stationData.length-1]]

    connectionProcessedTrain: (train, connection) ->

    nextConnectionForTrain: (train, currentConnection) ->
        index = @connections.indexOf(currentConnection)
        if index == -1
            return null
        if index == (@connections.length - 1) and train.get('direction') is Directions.WEST
            return null
        if index == 0 and train.get('direction') is Directions.EAST
            return null

        return @connections[index + train.get('direction')]


module.exports = MetroSystem
