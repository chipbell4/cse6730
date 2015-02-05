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
    
    # The listeners and display for that
    log = new EventLog([])
    log.watchEventQueue eventQueue
    eventLogView = new EventLogView(
        collection: log
        el: $('textarea').get(0)
    )

    # TODO: Use the values in the file here
    lightSignal = new LightSignal(eventQueue, 45, 10, 45)

    lightSignal.triggerLightChange(0)

    currentTime = 0
    doAStep = ->
        evt = eventQueue.emitNext()

    doAStep() for i in [1..10]
