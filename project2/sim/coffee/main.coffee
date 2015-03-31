$ = require 'jquery'
Backbone = require 'backbone'
stations = require './stations.coffee'
MapView = require './MapView.coffee'

importStations = (map) ->
    stationModels = (new Backbone.Model(station) for station in stations)
    (map.addStation(station) for station in stationModels) 

    (map.connectStations(stationModels[i], stationModels[i-1]) for i in [1..(stationModels.length - 1)])

$ ->
    map = new MapView(
        el: $('#map')
    )

    importStations(map)
