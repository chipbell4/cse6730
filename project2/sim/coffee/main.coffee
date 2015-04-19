$ = require 'jquery'
Backbone = require 'backbone'
stationData = require './station_data.coffee'
EventQueueSingleton = require './EventQueueSingleton'
Directions = require './Directions'
MapView = require './MapView.coffee'
Train = require './Train'
TrainView = require './TrainView'
MetroSystem = require './MetroSystem'
MetroSystemView = require './MetroSystemView'
SimulationSpeedView = require './SimulationSpeedView'
Time = require './Time'
EventLog = require './EventLog'
EventLogView = require './EventLogView'
StationConnectionCollectionDisableView = require './StationConnectionCollectionDisableView'

stubEvent = (timestamp, metroSystem, direction) ->
    timestamp = timestamp + Math.random()

    station = metroSystem.stationData[0]
    connection = metroSystem.connections[0]
    track = connection.get('westwardTrack')
    if direction is Directions.EAST
        station = metroSystem.stationData[metroSystem.stationData.length - 1]
        connection = metroSystem.connections[metroSystem.connections.length - 1]
        track = connection.get('eastwardTrack')

    return new Backbone.Model(
        timestamp: timestamp
        name: 'train:arrive'
        data:
            train: new Train(
                direction: direction
                line: 'BL'
            )
            station: station
            connection: connection
            track: track
    )

pushTrains = (metroSystem) ->
    events = (stubEvent(timestamp, metroSystem, Directions.WEST) for timestamp in [1..421] by 10)
    Array.prototype.push.apply(events, (stubEvent(timestamp, metroSystem, Directions.EAST) for timestamp in [1..421] by 10))
    EventQueueSingleton.push event for event in events
    return events

$ ->
    map = new MapView(
        el: $('#map')
    )

    metroSystem = new MetroSystem(stationData)
    metroSystemView = new MetroSystemView(
        model: metroSystem
        map: map.map
    )

    events = pushTrains(metroSystem)

    new TrainView(model: event.get('data').train, map: map.map) for event in events

    Time.reset()

    # Allow the user to update simulation speed on the fly
    simulationSpeed = new SimulationSpeedView(
        el: $('#simulation-speed')
    )

    # Allow the user to disable tracks on the fly
    disableView = new StationConnectionCollectionDisableView(
        collection: new Backbone.Collection(metroSystem.connections)
        el: $('#track-disabling-control')
    )
    disableView.render()

    # Log events
    log = new EventLog()
    #log.watchEventQueue(EventQueueSingleton)
    logView = new EventLogView(
        collection: log
        el: $('#event-log')
    )

    doAStep = ->
        events = EventQueueSingleton.emitNextAt(Time.current())
        Time.step(2)
        setTimeout(doAStep, 1000 / simulationSpeed.currentSpeed)

    doAStep()
