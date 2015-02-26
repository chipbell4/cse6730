Backbone = require 'backbone'

class AnimationView extends Backbone.View
    colors:
        red: '#FF4136'
        yellow: '#FFDC00'
        green: '#2ECC40'

    initialize: ->
        @currentColor = 'red'
        @render()

    removeOldElements: ->
        svg = @$('svg').get(0)
        svg.removeChild(svg.firstChild) while svg.firstChild

    drawCircle: (color) ->
        # create a new one with the correct color, and add to the svg
        circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
        circle.setAttribute('stroke', 'black')
        circle.setAttribute('fill', @colors[color])
        circle.setAttribute('r', '25')
        circle.setAttribute('cx', '0')
        circle.setAttribute('cy', '0')

        @$('svg').get(0).appendChild(circle)

    onLightChanged: (event) ->
        @currentColor = event.get('data')
        @render()

    render: ->
        @removeOldElements()
        @drawCircle(@currentColor)

module.exports = AnimationView
