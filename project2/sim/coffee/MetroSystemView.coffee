Backbone = require 'backbone'
StationConnectionView = require './StationConnectionView'

###
# A class for rendering the full metro system
###
class MetroSystemView extends Backbone.View
    ###
    # Backbone-style constructor. Essentially renders the stations, along with the station connections for the system
    ###
    initialize: (options) ->
        @map = options.map

        @stationMarkers = (@markerFactory(station) for station in @model.stationData)

        @connectionViews = (@connectionViewFactory(connection) for connection in @model.connections)

    ###
    # Helper method for generating station markers
    ###
    markerFactory: (station) ->
        circle = L.circle([station.get('latitude'), station.get('longitude')], 40,
            color: 'white',
            fillColor: '#fff',
            fillOpacity: 1
        ).addTo(@map)

        circle.bindPopup(station.get('name'))
        return circle

    ###
    # Helper method for generating connection views for each connection
    ###
    connectionViewFactory: (connection) ->
        return new StationConnectionView(
            model: connection
            map: @map
        )

module.exports = MetroSystemView
