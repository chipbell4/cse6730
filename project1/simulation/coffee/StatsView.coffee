Backbone = require 'backbone'
HistogramView = require './HistogramView.coffee'

class StatsView extends Backbone.View
    initialize: ->
        @listenTo(@collection, 'add change', @onCarExited)
        @listenTo(@collection, 'add', @onCarArrived)

        @inputHistogram = new HistogramView(
            el: @$('#input-stats')[0]
            histogramSize:
                min: 0
                max: 50
        )

        @outputHistogram = new HistogramView(
            el: @$('#output-stats')[0]
            histogramSize:
                min: 0
                max: 20
        )

    onCarArrived: (event) ->
        # recalculate the interarrival times between cars, so we can display that distribution too
        arrivalTimes = @collection.pluck('arrivalTime')
        
        interarrivalTimes = (arrivalTimes[k] - arrivalTimes[k-1] for k in [1..arrivalTimes.length-1])
        @inputHistogram.collection.reset interarrivalTimes.map((time) ->
            obj =
                value: time
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
