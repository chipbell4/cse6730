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
        @listenTo(@model.get('westwardTrack'), 'add remove', @rebindPopup)
        @listenTo(@model.get('eastwardTrack'), 'add remove', @rebindPopup)

    rebindPopup: () ->
        @line.unbindPopup()
        message = @model.toString() + ' has ' + @model.get('tracksDisabled') + ' track(s) disabled, '
        message += (@model.get('westwardTrack').length + @model.get('eastwardTrack').length + @model.get('waitingTrack').length) + ' total trains waiting'
        @line.bindPopup(message)

    render: () ->
        color = 'green'
        if @model.get('tracksDisabled') is 1
            color = 'red'

        @line.setStyle(
            color: color
        )

module.exports = StationConnectionView
