Backbone = require 'backbone'
Time = require './Time'

class TrainView extends Backbone.View
    initialize: (options) ->
        @map = options.map
        @model.figureOutPosition(0)
        @marker = L.marker([ @model.get('latitude'), @model.get('longitude') ],
            riseOnHover: true
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
