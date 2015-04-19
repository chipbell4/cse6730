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
            weight: 8
        ).addTo(@map)

        @line.on('click', @onLineClicked.bind(@))


    onLineClicked: () ->
        if @model.get('tracksDisabled') is 2
            @model.set('tracksDisabled', 1)
        if @model.get('tracksDisabled') is 1
            @model.set('tracksDisabled', 2)
        console.log 'At ' + @model.toString() + ' tracks disabled are ' + @model.get('tracksDisabled')
        @render()

    render: () ->
        color = 'green'
        if @model.get('tracksDisabled') is 1
            color = 'red'

        @line.setStyle(
            color: color
        )

module.exports = StationConnectionView
