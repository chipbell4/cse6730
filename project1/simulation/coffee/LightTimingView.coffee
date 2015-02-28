Backbone = require 'backbone'

###
# A view for manipulating the light timings
###
class LightTimingView extends Backbone.View
    ###
    # Essentially listen for the sliders to change and then update the global light timing
    ###
    events:
        'change input[type=range]' : 'onTimingChanged'
        'input input[type=range]' : 'onTimingChanged'

    ###
    # Sets up default timings and renders
    ###
    initialize: ->
        @colors = ['red', 'yellow', 'green']
        if not @model?
            @model = new Backbone.Model(
                red: 45
                yellow: 45
                green: 45
            )

        @listenTo(@model, 'change', @render.bind(@))
        @render()

    ###
    # Gets the input value for a particular color
    ###
    input: (color) ->
        return @$('#' + color).val()

    ###
    # Sets the displayed color to match the current input value
    ###
    updateDisplay: (color) ->
        # update the html of a particular span with the current color
        @$('#' + color + '-value').html(@model.get(color) + ' seconds')

    ###
    # For all colors, update the view's span tags to represent the model's state
    ###
    render: ->
        @updateDisplay(color) for color in @colors

    ###
    # A slider was moved, so set the new light timing
    ###
    onTimingChanged: ->
        # for each color, set the model's attribute correctly
        @model.set(color, @input(color)) for color in @colors

module.exports = LightTimingView
