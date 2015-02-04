Car = require './Car.coffee'
CarEmitter = require './CarEmitter.coffee'
EventQueue = require './EventQueue.coffee'
LightSignal = require './LightSignal.coffee'
IntersectionQueue = require './IntersectionQueue.coffee'
EventLog = require './EventLog.coffee'
EventLogView = require './EventLogView.coffee'

$ = require 'jquery'

$ ->
    # create a global event queue
    eventQueue = new EventQueue
    log = new EventLog
    # TODO: Use the values in the file here
    lightSignal = new LightSignal(eventQueue, 45, 10, 45)

    lightSignal.triggerLightChange(0)

    currentTime = 0
    doAStep = ->
        console.log('t = ' + currentTime)
        console.log('Color ' + lightSignal.currentColor)
        evt = eventQueue.emitNext()
        currentTime = evt.get('timestamp')

    doAStep() for i in [1..10]
