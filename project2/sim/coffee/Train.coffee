Backbone = require 'backbone'
Directions = require './Directions'

###
# Model that represents a train
###
class Train extends Backbone.Model

    ###
    # Picks a color based on the train distribution. Colors are BL, OR, then SV in that order
    ###
    sampleFromTrainColorDistribution: (distribution) ->
        r = Math.random()
        totalProbabilitySeen = 0
        index = 0
        while r > totalProbabilitySeen
            totalProbabilitySeen += distribution[index]
            index += 1

        colors = ['BL', 'OR', 'SV']
        return colors[index - 1]

    ###
    # Constructor for the model. Looks at the direction, and chooses the color for the train randomly based on an
    # empirical distribution gathered from real data
    ###
    initialize: () ->
        if @get('direction') is Directions.EAST
            @set('line', @sampleFromTrainColorDistribution([0.237652, 0.350751, 0.411597]))
        else if @get('direction') is Directions.WEST
            @set('line', @sampleFromTrainColorDistribution([0.274308, 0.374703, 0.350988]))

    ###
    # Uses linear interpolation to set the location of the train based it's position between two stations
    ###
    interpolatePosition: (station1, station2, percent) ->
        if percent > 1
            percent = 1

        latitude1 = station1.get('latitude')
        longitude1 = station1.get('longitude')
        latitude2 = station2.get('latitude')
        longitude2 = station2.get('longitude')
        @set(
            latitude: latitude1 + (latitude2 - latitude1) * percent
            longitude: longitude1 + (longitude2 - longitude1) * percent
        )

    ###
    # Uses the current timestamp + the arrival time at a station to figure out the interpolated position of the train
    # at a given time
    ###
    figureOutPosition: (currentTimestamp) ->
        missing = []
        if not @has('connection')
            missing.push 'CONNECTION'
        if not @has('previousStation')
            missing.push 'PREVIOUS STATION'
        if not @has('nextStation')
            missing.push 'NEXT STATION'

        if not @has('connection') or not @has('previousStation') or not @has('nextStation')
            @set(
                latitude: 0
                longitude: 0
            )
            return

        # otherwise, we'll intepolate
        percent = @fractionalDistanceFromPreviousStation(currentTimestamp)
        @interpolatePosition(@get('previousStation'), @get('nextStation'), percent)

    ###
    # Given the train's arrival time and current timestamp, decides the fractional distance (0 to 1) that the train is
    # down it's current connection
    ###
    fractionalDistanceFromPreviousStation: (currentTimestamp) ->
        if not @has('connection') or not @has('previousStation')
            return 0
        timeElapsed = currentTimestamp - @get('enterTime')
        return timeElapsed / @get('connection').get('timeBetweenStations')

module.exports = Train
