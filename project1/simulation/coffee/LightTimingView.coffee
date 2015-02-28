Backbone = require 'backbone'

class LightTimingView extends Backbone.View
    events:
        'change input[type=range]' : 'onTimingChanged'
        'input input[type=range]' : 'onTimingChanged'

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

    input: (color) ->
        return @$('#' + color).val()

    updateDisplay: (color) ->
        # update the html of a particular span with the current color
        @$('#' + color + '-value').html(@model.get(color) + ' seconds')

    render: ->
        # For all colors, update the view's span tags to represent the model's state
        @updateDisplay(color) for color in @colors

    onTimingChanged: ->
        # for each color, set the model's attribute correctly
        @model.set(color, @input(color)) for color in @colors

module.exports = LightTimingView
