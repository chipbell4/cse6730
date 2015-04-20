Backbone = require 'backbone'
Colors = require './colors'
Time = require './Time'

###
# A view for drawing a train
###
class TrainView extends Backbone.View
    ###
    # The main constructor function. Uses the main map to add a circle marker with the correct color to the map.
    # Whenever the time changes, it automatically updates the trains position.
    ###
    initialize: (options) ->
        @map = options.map
        @model.figureOutPosition(0)
        @marker = L.circle([ @model.get('latitude'), @model.get('longitude') ], 40,
            color: Colors[@model.get('line')]
            fillColor: Colors[@model.get('line')]
            opacity: 1
        )
        @marker.addTo(@map)

        # listen for time changes to re calculate things for the model, and re-render
        @listenTo(Time, 'time:step', (currentTime) ->
            @model.figureOutPosition(currentTime)
            @render()
        )

    ###
    # The main render method. Simply sets the position of the train's map marker based on the trains current position
    ###
    render: () ->
        @marker.setLatLng([ @model.get('latitude'), @model.get('longitude') ])

module.exports = TrainView
