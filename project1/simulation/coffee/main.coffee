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
Time = require './Time.coffee'

$ = require 'jquery'

pushCars = (eventQueue, carCount) ->

    # This is simply summary data collected from my files in the data_processing folder
    northboundProbabilities = [ 0.582677165, 0.204724409, 0.015748031, 0.007874016, 0.007874016, 0.015748031, 0, 0.007874016,
        0.007874016, 0.007874016, 0.039370079, 0.007874016, 0.015748031, 0, 0.015748031, 0.039370079, 0.007874016, 0,
        0.007874016, 0, 0.007874016 ]
    northboundBinWidth = 47.5 / 20 

    emitter = new CarEmitter(eventQueue, northboundProbabilities, northboundBinWidth)

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

    # create the intersection queue to manage cars through the light
    intersectionQueue = new IntersectionQueue([], eventQueue)

    # add an animation for the light change, and cars passing through
    animation = new AnimationView(
        el: $('#animation')[0]
        collection: intersectionQueue
    )
    animation.listenTo(eventQueue, 'light:changed', animation.onLightChanged.bind(animation))

    simulationSpeed = new SimulationSpeedView(
        el: $('#simulation-speed')[0]
    )

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
    lightSignal = new LightSignal(eventQueue, 45, 45, 45)
    lightSignal.listenTo(lightTiming.model, 'change', lightSignal.updateTimings)

    lightSignal.triggerLightChange(0)

    Time.reset()
    doAStep = ->
        evt = eventQueue.emitNextAt(Time.current())
        Time.step()
        # sleep before stepping again. Base the sleep on the simulation speed
        setTimeout(doAStep, 1000 / simulationSpeed.currentSpeed)

     doAStep()


