Backbone = require 'backbone'

class StatsView extends Backbone.View
    initialize: ->
        @listenTo(@collection, 'add', @render)
        @listenTo(@collection, 'change', @render)

    render: ->
        @$('#car-throughput').html(@collection.exitedCars().length)
        @$('#average-throughput').html(@collection.averageDuration())
        @$('#cars-waiting').html(@collection.waitingCars().length)

module.exports = StatsView
