Backbone = require 'backbone'

class AnimationView extends Backbone.View
    colors:
        red: '#FF4136'
        yellow: '#FFDC00'
        green: '#2ECC40'
        black: '#111111'
        gray: '#AAAAAA'
        orange: '#FF851B'

    initialize: ->
        @currentColor = 'red'
        @render()

        @collection.on('add remove reset change', @render.bind(@))

    removeOldElements: ->
        svg = @$('svg').get(0)
        svg.removeChild(svg.firstChild) while svg.firstChild

    drawLight: (color) ->
        # create a new one with the correct color, and add to the svg
        circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
        circle.setAttribute('stroke', 'black')
        circle.setAttribute('fill', @colors[color])
        circle.setAttribute('r', '25')
        circle.setAttribute('cx', '10%')
        circle.setAttribute('cy', '50%')

        @$('svg').get(0).appendChild(circle)

    drawCar: (car, x, y) ->
        # create a rectangle, and add values to it
        rectangle = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
        rectangle.setAttribute('fill', @colors.orange)
        rectangle.setAttribute('stroke', @colors.black)
        rectangle.setAttribute('x', x)
        rectangle.setAttribute('y', y)
        rectangle.setAttribute('width', 40)
        rectangle.setAttribute('height', 30)
        @$('svg').get(0).appendChild(rectangle)

        label = document.createElementNS('http://www.w3.org/2000/svg', 'text')
        label.textContent = '20'
        label.setAttribute('x', x + 40 / 5)
        label.setAttribute('y', y + 30 / 2)
        @$('svg').get(0).appendChild(label)

    onLightChanged: (event) ->
        @currentColor = event.get('data')
        @render()

    render: ->
        @removeOldElements()
        @drawCar(null, 200, 30)
        #@drawLight(@currentColor)

module.exports = AnimationView
