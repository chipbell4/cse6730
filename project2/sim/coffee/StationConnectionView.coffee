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
            weight: 10
        ).addTo(@map)

        @rebindPopup()
        @listenTo(@model, 'change:tracksDisabled', @rebindPopup)

    rebindPopup: () ->
        @line.unbindPopup()
        @line.bindPopup(@model.toString() + ' has ' + @model.get('tracksDisabled') + ' track(s) disabled')

    render: () ->
        color = 'green'
        if @model.get('tracksDisabled') is 1
            color = 'red'

        @line.setStyle(
            color: color
        )

module.exports = StationConnectionView
