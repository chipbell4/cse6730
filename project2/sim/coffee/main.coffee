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
StationConnectionCollectionDisableView = require './StationConnectionCollectionDisableView'
HistogramView = require './HistogramView'
Emitter = require './Emitter'
ArrivalData = require './arrival_data'

###
# Given a direction, generates a list of random timestamps based on the empirical distribution in that direction
###
generateTimestampList = (direction) ->
   emitter = new Emitter(
       eventQueue: EventQueueSingleton
       histogram: ArrivalData[direction]
   )

   timestamps = []
   latestTimestamp = 0
   # for 10 hours
   while latestTimestamp < 10 * 60 * 10
       latestTimestamp = emitter.emitNext(latestTimestamp)
       timestamps.push(latestTimestamp)

   return timestamps

###
# Stubs an arrival event for a train at a given time and direction
###
stubEvent = (timestamp, metroSystem, direction) ->
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
            )
            station: station
            connection: connection
            track: track
    )

###
# Pushes a bunch of arrival events for the metro system in both directions, based on an empirical distribution of
# arrivals
###
pushTrains = (metroSystem) ->
    westwardTimestamps = generateTimestampList(Directions.WEST)
    eastwardTimestamps = generateTimestampList(Directions.EAST)

    EventQueueSingleton.push stubEvent(timestamp, metroSystem, Directions.WEST) for timestamp in westwardTimestamps
    EventQueueSingleton.push stubEvent(timestamp, metroSystem, Directions.EAST) for timestamp in eastwardTimestamps

    return EventQueueSingleton.toArray()

$ ->
    # Render a map
    map = new MapView(
        el: $('#map')
    )

    # Build the metro system from the station data we have stored, and then render to a map
    metroSystem = new MetroSystem(stationData)
    metroSystemView = new MetroSystemView(
        model: metroSystem
        map: map.map
    )

    # Queue up events for the simulation, but save the results, since we'll use it to render every train as it moves
    # through the system
    events = pushTrains(metroSystem)
    new TrainView(model: event.get('data').train, map: map.map) for event in events

    # Start time back at 0
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

    # Listen for westward trains to finish their journey, and render stats accordingly
    westwardDistribution = new HistogramView(
        el: $('#westward-distribution')
        histogramSize:
            min: 15
            max: 165
    )
    westwardTrainStarts = { }
    EventQueueSingleton.on('train:arrive', (event) ->
        return if event.get('data').station.get('code') isnt 'D08'
        return if event.get('data').train.get('direction') isnt Directions.WEST
        westwardTrainStarts[event.get('data').train.cid] = event.get('timestamp')
    )
    EventQueueSingleton.on('train:arrive', (event) ->
        return if event.get('data').station.get('code') isnt 'C05'
        return if event.get('data').train.get('direction') isnt Directions.WEST
        firstAppearance = westwardTrainStarts[event.get('data').train.cid]
        durationInSystem = (event.get('timestamp') - firstAppearance) / 60
        westwardDistribution.collection.add(value: durationInSystem)
    )

    # Listen for eastward trains to finish their journey, and render stats accordingly
    eastwardDistribution = new HistogramView(
        el: $('#eastward-distribution')
        histogramSize:
            min: 15
            max: 165
    )
    eastwardTrainStarts = { }
    EventQueueSingleton.on('train:arrive', (event) ->
        return if event.get('data').station.get('code') isnt 'C05'
        return if event.get('data').train.get('direction') isnt Directions.EAST
        eastwardTrainStarts[event.get('data').train.cid] = event.get('timestamp')
    )
    EventQueueSingleton.on('train:arrive', (event) ->
        return if event.get('data').station.get('code') isnt 'D08'
        return if event.get('data').train.get('direction') isnt Directions.EAST
        firstAppearance = eastwardTrainStarts[event.get('data').train.cid]
        durationInSystem = (event.get('timestamp') - firstAppearance) / 60
        eastwardDistribution.collection.add(value: durationInSystem)
    )

    # A poor man's infinite loop that does not block the UI
    doAStep = ->
        events = EventQueueSingleton.emitNextAt(Time.current())
        Time.step(2)
        setTimeout(doAStep, 1000 / simulationSpeed.currentSpeed)

    doAStep()
