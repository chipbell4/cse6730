Backbone = require 'backbone'

class StationConnectionView extends Backbone.View
    initialize: (options) ->
        @map = options.map

        positions = [
            [@model.get('eastStation').get('latitude'), @model.get('eastStation').get('longitude')],
            [@model.get('westStation').get('latitude'), @model.get('westStation').get('longitude')]
        ]

        @line = L.polyline(positions,
            color: 'green'
        ).addTo(@map)

        @line.on('click', @onLineClicked.bind(@))


    onLineClicked: () ->
        currentTracksDisabled = @model.get('tracksDisabled')
        @model.set('tracksDisabled', (currentTracksDisabled + 1) % 3)
        @render

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
