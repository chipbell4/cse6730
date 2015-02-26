Backbone = require 'backbone'
HistogramView = require './HistogramView.coffee'

class StatsView extends Backbone.View
    initialize: ->
        @listenTo(@collection, 'add', @onCarExited)
        @listenTo(@collection, 'change', @onCarExited)

        @outputHistogram = new HistogramView(
            el: @$('#output-stats')[0]
        )

    onCarExited: (event) ->
        @render()

        # reset the collection with the new values of car exits
        @outputHistogram.collection.reset @collection.exitedCars().map((car) ->
            obj = 
                value: car.get('exitTime')
        )

    render: ->
        @$('#car-throughput').html(@collection.exitedCars().length)
        @$('#average-throughput').html(@collection.averageDuration())
        @$('#cars-waiting').html(@collection.waitingCars().length)

module.exports = StatsView
