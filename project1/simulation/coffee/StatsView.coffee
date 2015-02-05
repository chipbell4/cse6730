Backbone = require 'backbone'

class StatsView extends Backbone.View
    initialize: ->
        @listenTo(@collection, 'change', @render)

    render: ->
        @$('#car-throughput').html(@collection.exitedCars().length)
        @$('#average-throughput').html(@collection.averageDuration())

module.exports = StatsView
