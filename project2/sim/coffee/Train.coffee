Backbone = require 'backbone'

class Train extends Backbone.Model
    interpolatePosition: (station1, station2, percent) ->
        latitude1 = station1.get('latitude')
        longitude1 = station1.get('longitude')
        latitude2 = station2.get('latitude')
        longitude2 = station2.get('longitude')
        @set(
            latitude: latitude1 + (latitude2 - latitude1) * percent
            longitude: longitude1 + (longitude2 - longitude1) * percent
        )

    figureOutPosition: (currentTimestamp) ->
        if not @has('connection') or not @has('previousStation') or not @has('nextStation')
            @set(
                latitude: 0
                longitude: 0
            )
            return

        # otherwise, we'll intepolate
        percent = @fractionalDistanceFromPreviousStation(currentTimestamp)
        @interpolatePosition(@get('previousStation'), @get('nextStation'), percent)

    fractionalDistanceFromPreviousStation: (currentTimestamp) ->
        if not @has('connection') or not @has('previousStation')
            return 0
        timeElapsed = currentTimestamp - @get('enterTime')
        return timeElapsed / @get('connection').get('timeBetweenStations')

module.exports = Train
