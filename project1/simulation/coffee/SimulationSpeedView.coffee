Backbone = require 'backbone'

###
# A view for setting the simulation speed
###
class SimulationSpeedView extends Backbone.View
    ###
    # If a slider is moved, update the speed
    ###
    events:
        'change #speed' : 'onSpeedChanged'
        'input #speed' : 'onSpeedChanged'

    ###
    # Set the initial speed and render
    ###
    initialize: ->
        @$('#speed').val(25)
        @onSpeedChanged()

    ###
    # Listener for when the user moves the slider. Get's the new value and renders
    ###
    onSpeedChanged: ->
        @currentSpeed = @$('#speed').val()
        @render()

    ###
    # Renders the view
    ###
    render: ->
        @$('#speed-value').html("#{ @currentSpeed }x")


module.exports = SimulationSpeedView
