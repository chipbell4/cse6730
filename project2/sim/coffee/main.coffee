$ = require 'jquery'
Backbone = require 'backbone'
stations = require './stations.coffee'
MapView = require './MapView.coffee'

importStations = (map) ->
    stationModels = (new Backbone.Model(station) for station in stations)
    (map.addStation(station) for station in stationModels) 

$ ->
    map = new MapView(
        el: $('#map')
    )

    importStations(map)
