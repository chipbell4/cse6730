Backbone = require 'backbone'

###
# A view for representing a station connection on the map
###
class StationConnectionView extends Backbone.View
    ###
    # The constructor for the view. Builds a polyline for the connection, then binds a popup for when the user clicks
    # on the connection
    ###
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

        # Whenever the model changes appropriately, we want to change the popup text
        @listenTo(@model, 'change:tracksDisabled', @rebindPopup)
        @listenTo(@model.get('westwardTrack'), 'add remove', @rebindPopup)
        @listenTo(@model.get('eastwardTrack'), 'add remove', @rebindPopup)

    ###
    # Wires up the popup for the current state of the connection represented by this view
    ###
    rebindPopup: () ->
        @line.unbindPopup()
        message = @model.toString() + ' has ' + @model.get('tracksDisabled') + ' track(s) disabled, '
        message += (@model.get('westwardTrack').length + @model.get('eastwardTrack').length + @model.get('waitingTrack').length) + ' total trains waiting'
        @line.bindPopup(message)

    ###
    # Changes the color of the line based upon how many tracks are clicked
    ###
    render: () ->
        color = 'green'
        if @model.get('tracksDisabled') is 1
            color = 'red'

        @line.setStyle(
            color: color
        )

module.exports = StationConnectionView
