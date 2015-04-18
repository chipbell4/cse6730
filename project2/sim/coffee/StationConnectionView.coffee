Backbone = require 'backbone'

class StationConnectionView extends Backbone.View
    initialize: (options) ->
        @map = options.map

        positions = [
            [@model.eastStation.get('latitude'), @model.eastStation.get('longitude')],
            [@model.westStation.get('latitude'), @model.westStation.get('longitude')]
        ]

        @line = L.polyline(positions,
            color: 'green'
        ).addTo(@map)

    render: () ->
        color = 'green'
        if @model.get('tracksDisabled') is 1
            color = 'yellow'
        else if @model.get('tracksDisabled') is 2
            color = 'red'

        @line.setStyle(
            color: color
        )

module.exports = StationConnectionView
