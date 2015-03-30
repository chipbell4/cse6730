Backbone = require 'backbone'
HistogramView = require './HistogramView.coffee'
Time = require './Time.coffee'

###
# A view for representing the current statistics of the simulation
###
class StatsView extends Backbone.View
    ###
    # Listens for the collection to re-render, also keeping track of time. Sets up the histograms too
    ###
    initialize: ->
        @listenTo(@collection, 'add change', @onCarExited)
        @listenTo(@collection, 'add', @onCarArrived)
        @listenTo(@collection, 'reset', @render.bind(@))
        @listenTo(Time, 'time:step', @render.bind(@))

        @inputHistogram = new HistogramView(
            el: @$('#input-stats')[0]
            histogramSize:
                min: 0
                max: 60
        )

        @outputHistogram = new HistogramView(
            el: @$('#output-stats')[0]
            histogramSize:
                min: 0
                max: 60
        )

    ###
    # A car arrived, get it's arrival time and push into the input histogram
    ###
    onCarArrived: (event) ->
        # recalculate the interarrival times between cars, so we can display that distribution too
        arrivalTimes = @collection.pluck('arrivalTime')
        
        interarrivalTimes = (arrivalTimes[k] - arrivalTimes[k-1] for k in [1..arrivalTimes.length-1])
        @inputHistogram.collection.reset interarrivalTimes.map((time) ->
            obj =
                value: time
        )

    ###
    # A car exited, re-render since we'll want to show updated averages. Also, update the output histogram
    ###
    onCarExited: (event) ->
        @render()

        @outputHistogram.collection.reset @collection.exitedCars().map((car) ->
            obj = 
                value: car.getDuration()
        )

    ###
    # Render a couple of little useful tidbits of info.
    ###
    render: ->
        @$('#car-throughput').html(@collection.exitedCars().length)
        @$('#average-throughput').html(@collection.averageDuration().toPrecision(4) + 's')
        @$('#cars-waiting').html(@collection.waitingCars().length)

        seconds = '' + Time.current() % 60
        if seconds.length < 2
            seconds = '0' + seconds
        minutes = Math.floor (Time.current() / 60)
        @$('#current-time').html("#{minutes}:#{seconds}")

module.exports = StatsView
