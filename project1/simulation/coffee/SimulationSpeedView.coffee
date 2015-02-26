Backbone = require 'backbone'

class SimulationSpeedView extends Backbone.View
    events:
        'change #speed' : 'onSpeedChanged'
        'input #speed' : 'onSpeedChanged'

    initialize: ->
        @$('#speed').val(25)
        @onSpeedChanged()

    onSpeedChanged: ->
        @currentSpeed = @$('#speed').val()
        @render()

    render: ->
        @$('#speed-value').html("#{ @currentSpeed }x")


module.exports = SimulationSpeedView
