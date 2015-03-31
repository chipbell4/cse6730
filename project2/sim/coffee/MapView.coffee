Backbone = require 'backbone'
Backbone.$ = require 'jquery'

###
# A view for drawing the map
###
class MapView extends Backbone.View
    ###
    # Sets up the map, by setting the image tiles to use for drawing roads and things. For reference, see
    # http://leafletjs.com/examples/quick-start.html
    ###
    initialize: ->
        @map = L.map(@el.id).setView([38.8941386,-77.0236192], 13)
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(@map);

    ###
    # Adds a new station (as a backbone model)
    #
    # @param Backbone.Model station
    ###
    addStation: (station) ->
        circle = L.circle([station.get('latitude'), station.get('longitude')], 100,
            color: 'red',
            fillColor: '#f03',
            fillOpacity: 0.5
        ).addTo(@map)

        circle.bindPopup(station.get('name'))

    ###
    # Connects two stations with a line
    #
    # @param firstStation  A backbone model for the first station
    # @param secondStation A backbone model for the second station
    ###
    connectStations: (firstStation, secondStation) ->
        positions = [
            [firstStation.get('latitude'), firstStation.get('longitude')],
            [secondStation.get('latitude'), secondStation.get('longitude')]
        ]

        line = L.polyline(positions,
            color: 'red'
        ).addTo(@map)

module.exports = MapView 
