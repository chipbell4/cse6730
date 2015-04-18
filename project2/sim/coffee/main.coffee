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
Time = require './Time'

stubEvent = (timestamp, metroSystem) ->
    timestamp = timestamp + Math.random()
    return new Backbone.Model(
        timestamp: timestamp
        name: 'train:arrive'
        data:
            train: new Train(
                direction: Directions.WEST
            )
            station: metroSystem.stationData[0]
            connection: metroSystem.connections[0]
            track: metroSystem.connections[0].get('westwardTrack')
    )

pushTrains = (metroSystem) ->
    events = (stubEvent(timestamp, metroSystem) for timestamp in [1..1])
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

    doAStep = ->
        events = EventQueueSingleton.emitNextAt(Time.current())
        console.log event.toJSON() for event in events
        Time.step()
        setTimeout(doAStep, 1000 / 30)

    doAStep()
