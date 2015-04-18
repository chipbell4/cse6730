Backbone = require 'backbone'
Colors = require './colors'
Time = require './Time'

class TrainView extends Backbone.View
    initialize: (options) ->
        @map = options.map
        @model.figureOutPosition(0)
        @marker = L.circle([ @model.get('latitude'), @model.get('longitude') ], 40,
            color: Colors[@model.get('line')]
            fillColor: Colors[@model.get('line')]
        )
        @marker.addTo(@map)

        # listen for time changes to re calculate things for the model, and re-render
        @listenTo(Time, 'time:step', (currentTime) ->
            @model.figureOutPosition(currentTime)
            @render()
        )

    render: () ->
        @marker.setLatLng([ @model.get('latitude'), @model.get('longitude') ])

module.exports = TrainView
