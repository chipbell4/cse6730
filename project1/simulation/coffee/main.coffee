Backbone = require 'backbone'
Car = require './Car.coffee'
CarEmitter = require './CarEmitter.coffee'
EventQueue = require './EventQueue.coffee'
LightTimingView = require './LightTimingView.coffee'
LightSignal = require './LightSignal.coffee'
IntersectionQueue = require './IntersectionQueue.coffee'
EventLog = require './EventLog.coffee'
EventLogView = require './EventLogView.coffee'
StatCollection = require './StatCollection.coffee'
StatsView = require './StatsView.coffee'

$ = require 'jquery'

pushCars = (eventQueue, carCount) ->
    emitter = new CarEmitter(eventQueue, 0)

    emitter.triggerCar 10*k for k in [1..carCount]

    return emitter

$ ->
    # create a global event queue
    eventQueue = new EventQueue

    # push some cars to be processed
    pushCars(eventQueue, 2000)

    # handle input from the light timing
    lightTiming = new LightTimingView(
        el: $('#light-timings')[0]
    )

    # create the intersection queue to manage cars through the light
    intersectionQueue = new IntersectionQueue([], eventQueue)
    
    # Log Events
    log = new EventLog([])
    log.watchEventQueue eventQueue
    eventLogView = new EventLogView(
        collection: log
        el: $('textarea').get(0)
    )

    # Keep track of stats
    statCollection = new StatCollection
    statCollection.watchEventQueue eventQueue
    statsView = new StatsView(
        collection: statCollection
        el: $('#stats').get(0)
    )

    # TODO: Use the values in the file here
    lightSignal = new LightSignal(eventQueue, 45, 10, 45)

    lightSignal.triggerLightChange(0)

    currentTime = 0
    doAStep = ->
        evt = eventQueue.emitNextAt(currentTime)
        currentTime += 1
        setTimeout(doAStep, 100)

     doAStep()
        

