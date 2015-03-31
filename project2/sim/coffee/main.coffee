$ = require 'jquery'
MapView = require './MapView.coffee'

$ ->
    map = new MapView(
        el: $('#map')
    )
