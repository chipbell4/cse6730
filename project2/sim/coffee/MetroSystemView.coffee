Backbone = require 'backbone'
StationConnectionView = require './StationConnectionView'

###
# A class for rendering the full metro system
###
class MetroSystemView extends Backbone.View
    initialize: (options) ->
        @map = options.map

        @stationMarkers = (@markerFactory(station) for station in @model.stationData)

        @connectionViews = (@connectionViewFactory(connection) for connection in @model.connections)

    markerFactory: (station) ->
        circle = L.circle([station.get('latitude'), station.get('longitude')], 40,
            color: 'white',
            fillColor: '#fff',
            fillOpacity: 1
        ).addTo(@map)

        circle.bindPopup(station.get('name'))
        return circle

    connectionViewFactory: (connection) ->
        return new StationConnectionView(
            model: connection
            map: @map
        )

module.exports = MetroSystemView
