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

pushTrains = (metroSystem) ->
    westwardTimestamps = generateTimestampList(Directions.WEST)
    eastwardTimestamps = generateTimestampList(Directions.EAST)

    EventQueueSingleton.push stubEvent(timestamp, metroSystem, Directions.WEST) for timestamp in westwardTimestamps
    EventQueueSingleton.push stubEvent(timestamp, metroSystem, Directions.EAST) for timestamp in eastwardTimestamps

    return EventQueueSingleton.toArray()

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

    # Listen for changes in the the output
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

    doAStep = ->
        events = EventQueueSingleton.emitNextAt(Time.current())
        Time.step(2)
        setTimeout(doAStep, 1000 / simulationSpeed.currentSpeed)

    doAStep()
