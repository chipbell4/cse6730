Backbone = require 'backbone'
Time = require './Time.coffee'

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
        Time.on('time:step time:reset', @render.bind(@))

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

    drawCar: (car, index) ->
        # create a rectangle, and add values to it
        rectangle = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
        rectangle.setAttribute('fill', @colors.orange)
        rectangle.setAttribute('stroke', @colors.black)

        width = 40;
        height = 30;
        x = 100 + (index * (width + 10)) 
        y = 25
        rectangle.setAttribute('x', x)
        rectangle.setAttribute('y', y)
        rectangle.setAttribute('width', width)
        rectangle.setAttribute('height', height)
        rectangle.setAttribute('rx', 4)
        rectangle.setAttribute('ry', 4)
        @$('svg').get(0).appendChild(rectangle)

        label = document.createElementNS('http://www.w3.org/2000/svg', 'text')
        label.textContent = Number(Time.current() - car.get('arrivalTime')).toPrecision(2)
        label.setAttribute('x', x + width / 5)
        label.setAttribute('y', y + height / 2)
        @$('svg').get(0).appendChild(label)

    onLightChanged: (event) ->
        @currentColor = event.get('data')
        @render()

    render: ->
        @removeOldElements()
        @drawLight(@currentColor)

        carsToDraw = Math.min(@collection.length, 5)
        if carsToDraw is 0
            return

        @drawCar(@collection.at(index), index) for index in [0..carsToDraw - 1]

module.exports = AnimationView
