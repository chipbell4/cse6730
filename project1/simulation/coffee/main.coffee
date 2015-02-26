AnimationView = require './AnimationView.coffee'
Backbone = require 'backbone'
Car = require './Car.coffee'
CarEmitter = require './CarEmitter.coffee'
EventQueue = require './EventQueue.coffee'
LightTimingView = require './LightTimingView.coffee'
LightSignal = require './LightSignal.coffee'
IntersectionQueue = require './IntersectionQueue.coffee'
EventLog = require './EventLog.coffee'
EventLogView = require './EventLogView.coffee'
SimulationSpeedView = require './SimulationSpeedView.coffee'
StatCollection = require './StatCollection.coffee'
StatsView = require './StatsView.coffee'

$ = require 'jquery'

pushCars = (eventQueue, carCount) ->
    emitter = new CarEmitter(eventQueue, [0, 0, 0.1, 0.2, 0.7], 10)

    timestamp = 0
    cars = 0
    while cars < carCount
        timestamp = emitter.triggerCar timestamp
        cars += 1

    return emitter

$ ->
    # create a global event queue
    eventQueue = new EventQueue

    # push some cars to be processed
    pushCars(eventQueue, 500)

    # handle input from the light timing
    lightTiming = new LightTimingView(
        el: $('#light-timings')[0]
    )

    # add an animation for the light change, and cars passing through
    animation = new AnimationView(
        el: $('#animation')[0]
    )
    animation.listenTo(eventQueue, 'light:changed', animation.onLightChanged.bind(animation))

    simulationSpeed = new SimulationSpeedView(
        el: $('#simulation-speed')[0]
    )

    # create the intersection queue to manage cars through the light
    intersectionQueue = new IntersectionQueue([], eventQueue)
    
    # Log Events
    log = new EventLog([])
    log.watchEventQueue eventQueue
    eventLogView = new EventLogView(
        collection: log
        el: $('#event-log').get(0)
    )

    # Keep track of stats
    statCollection = new StatCollection
    statCollection.watchEventQueue eventQueue
    statsView = new StatsView(
        collection: statCollection
        el: $('#stats').get(0)
    )

    # Create a light signal. Whenever the timings change from the UI, update the actual simulation on the fly
    lightSignal = new LightSignal(eventQueue, 45, 10, 45)
    lightSignal.listenTo(lightTiming.model, 'change', lightSignal.updateTimings)

    lightSignal.triggerLightChange(0)

    currentTime = 0
    doAStep = ->
        evt = eventQueue.emitNextAt(currentTime)
        currentTime += 1
        # sleep before stepping again. Base the sleep on the simulation speed
        setTimeout(doAStep, 1000 / simulationSpeed.currentSpeed)

     doAStep()
        

