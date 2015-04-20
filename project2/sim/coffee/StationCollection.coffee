Backbone = require 'backbone'
Station = require './Station.coffee'

###
# Represents a collection of stations
###
class StationCollection extends Backbone.Collection
    model: Station

    ###
    # Finds the next station after a given station. The station can be the actual station, or it can be the code for the station
    ###
    stationAfter: (station, direction) ->
        if typeof station is 'string'
            station = @get(station)

        if not station?
            return
        
        # find the index of the station
        index = @indexOf(station)

        @at(index + direction)

module.exports = StationCollection
