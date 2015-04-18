$ = require 'jquery'
Backbone = require 'backbone'
stationData = require './station_data.coffee'
MapView = require './MapView.coffee'
MetroSystem = require './MetroSystem'
MetroSystemView = require './MetroSystemView'

$ ->
    map = new MapView(
        el: $('#map')
    )

    metroSystem = new MetroSystem(stationData)
    metroSystemView = new MetroSystemView(
        model: metroSystem
        map: map.map
    ) 

