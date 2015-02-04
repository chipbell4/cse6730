require './Car.coffee'
require './CarEmitter.coffee'
require './EventQueue.coffee'
require './LightSignal.coffee'
require './IntersectionQueue.coffee'

$ = require 'jquery'

$ ->
    # create a global event queue
    window.eventQueue = new EventQueue
    # TODO: Use the values in the file here
    window.lightSignal = new LightSignal(window.eventQueue, 45, 10, 45)
