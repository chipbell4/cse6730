$ = require 'jquery'
Backbone = require 'backbone'
stationData = require './station_data.coffee'
MapView = require './MapView.coffee'

importStations = (map) ->
    stationModels = (new Backbone.Model(station) for station in stationData)
    (map.addStation(station) for station in stationModels) 

    (map.connectStations(stationModels[i], stationModels[i-1]) for i in [1..(stationModels.length - 1)])

$ ->
    map = new MapView(
        el: $('#map')
    )

    importStations(map)
