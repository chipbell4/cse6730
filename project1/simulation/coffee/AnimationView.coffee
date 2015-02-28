Backbone = require 'backbone'
Time = require './Time.coffee'

###
# View for drawing the svg animation of the light signal and the first couple of cars waiting to go.
###
class AnimationView extends Backbone.View
    ###
    # Just a hash of "nice" colors. Borrowed from https://github.com/mrmrs/colors
    ###
    colors:
        red: '#FF4136'
        yellow: '#FFDC00'
        green: '#2ECC40'
        black: '#111111'
        gray: '#AAAAAA'
        orange: '#FF851B'

    ###
    # Starts up the view, setting the current color to red. This view watches the global intersection queue for changes
    # and re-renders if it has changed. This will cause a redraw if a car leaves or enters. Also, we're listening for
    # Time steps, so we can update the displayed wait times for cars
    ###
    initialize: ->
        @currentColor = 'red'
        @render()

        @collection.on('add remove reset change', @render.bind(@))
        Time.on('time:step time:reset', @render.bind(@))

    ###
    # Removes all child elements from the svg encapsulated by this view
    ###
    removeOldElements: ->
        svg = @$('svg').get(0)
        svg.removeChild(svg.firstChild) while svg.firstChild

    ###
    # Draws the current state of the light as colored circle.
    ###
    drawLight: (color) ->
        # create a new one with the correct color, and add to the svg
        circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
        circle.setAttribute('stroke', 'black')
        circle.setAttribute('fill', @colors[color])
        circle.setAttribute('r', '25')
        circle.setAttribute('cx', '10%')
        circle.setAttribute('cy', '50%')

        @$('svg').get(0).appendChild(circle)

    ###
    # Draws a single car, assuming it's at the index in the intersection queue passed to the function
    ###
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

    ###
    # A light changed. Update the color and re-render
    ###
    onLightChanged: (event) ->
        @currentColor = event.get('data')
        @render()

    ###
    # Draws the animation, including the light state and the first 5 cars (or less if there isn't 5)
    ###
    render: ->
        @removeOldElements()
        @drawLight(@currentColor)

        carsToDraw = Math.min(@collection.length, 5)
        if carsToDraw is 0
            return

        @drawCar(@collection.at(index), index) for index in [0..carsToDraw - 1]

module.exports = AnimationView
