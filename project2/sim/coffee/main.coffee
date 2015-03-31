$ = require 'jquery'
Backbone = require 'backbone'
MapView = require './MapView.coffee'

$ ->
    map = new MapView(
        el: $('#map')
    )

    station = new Backbone.Model(
        name: 'McPherson Square'
        latitude: 38.9013327968
        longitude: -77.0336341721
    )

    map.addStation(station)
