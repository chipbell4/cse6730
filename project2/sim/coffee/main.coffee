$ = require 'jquery'
Backbone = require 'backbone'
stationData = require './station_data.coffee'
EventQueueSingleton = require './EventQueueSingleton'
Directions = require './Directions'
MapView = require './MapView.coffee'
Train = require './Train'
MetroSystem = require './MetroSystem'
MetroSystemView = require './MetroSystemView'

stubEvent = (timestamp, metroSystem) ->
    timestamp = timestamp + Math.random()
    return new Backbone.Model(
        timestamp: timestamp
        name: 'train:arrived'
        data:
            train: new Train(
                direction: Directions.WEST
            )
            station: metroSystem.stationData[0]
    )

pushTrains = (metroSystem) ->
    EventQueueSingleton.push(stubEvent(timestamp, metroSystem)) for timestamp in [1..100] by 2

$ ->
    map = new MapView(
        el: $('#map')
    )

    metroSystem = new MetroSystem(stationData)
    metroSystemView = new MetroSystemView(
        model: metroSystem
        map: map.map
    ) 

    pushTrains(metroSystem)

    Time.reset()

    doAStep = ->
        evt = EventQueueSingleton.emitNextAt(Time.current())
        console.log evt
        Time.step()
        setTimeout(doAStep, 1000)

    doAStep()
