Backbone = require 'backbone'
Backbone.$ = require 'jquery'

###
# A view for drawing the map
###
class MapView extends Backbone.View
    initialize: ->
        @map = L.map(@el.id).setView([51.505, -0.09], 13)
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(@map);

module.exports = MapView 
