expect = require('chai').expect
Train = require '../coffee/Train'
Backbone = require 'backbone'
Station = require '../coffee/Station'
StationConnection = require '../coffee/StationConnection'
EventQueueSingleton = require '../coffee/EventQueueSingleton'
Directions = require '../coffee/Directions'

describe 'StationConnection', ->
    connection = null
    eastStation = new Station(code: 'EAST')
    westStation = new Station(code: 'WEST')
    stubEvent = (connection, train, station) ->
        new Backbone.Model(
            timestamp: 0
            name: 'train:exit'
            data:
                connection: connection
                train: train
                station: station
                track: connection.get('eastwardTrack')
        )
    beforeEach ->
        EventQueueSingleton.reset()
        connection = new StationConnection(
            eastStation: eastStation
            westStation: westStation
            timeBetweenStations: 2
        )
        connection.off()

    describe 'disableTrack', ->
        it 'should by default have 0 tracks disabled', ->
            expect(connection.get('tracksDisabled')).to.equal(0)

        it 'should increment to 1 if a single track is disabled', ->
            connection.disableTrack()
            expect(connection.get('tracksDisabled')).to.equal(1)

        it 'should increment to 2 if two tracks are disabled', ->
            connection.disableTrack()
            connection.disableTrack()
            expect(connection.get('tracksDisabled')).to.equal(2)

        it 'should never go above 2', ->
            connection.disableTrack()
            connection.disableTrack()
            connection.disableTrack()
            expect(connection.get('tracksDisabled')).to.equal(2)

    describe 'enableTrack', ->
        it 'should decrement the number of tracks to 1 if 2 tracks are disabled', ->
            connection.set('tracksDisabled', 2)
            connection.enableTrack()
            expect(connection.get('tracksDisabled')).to.equal(1)

        it 'should never go below 0', ->
            connection.set('tracksDisabled', 0)
            connection.enableTrack()
            expect(connection.get('tracksDisabled')).to.equal(0)

    describe 'enqueueTrain', ->
        it 'should push the train to the eastward track if the train is heading eastward', ->
            connection.enqueueTrain(direction: Directions.EAST)

            expect(connection.get('eastwardTrack').length).to.equal(1)
            expect(connection.get('westwardTrack').length).to.equal(0)

        it 'should push the train to the westward track if the train is heading westward', ->
            connection.enqueueTrain(direction: Directions.WEST)

            expect(connection.get('eastwardTrack').length).to.equal(0)
            expect(connection.get('westwardTrack').length).to.equal(1)

        it 'should push all trains to the east track if a single track is disabled', ->
            connection.set('tracksDisabled', 1)
            connection.enqueueTrain(direction: Directions.WEST)

            expect(connection.get('eastwardTrack').length).to.equal(1)
            expect(connection.get('westwardTrack').length).to.equal(0)

        it 'should push the train to the waiting track if all tracks are disabled, so it will not be processed', ->
            connection.set('tracksDisabled', 2)
            connection.enqueueTrain(direction: Directions.EAST)

            expect(connection.get('waitingTrack').length).to.equal(1)
            expect(connection.get('eastwardTrack').length).to.equal(0)
            expect(connection.get('westwardTrack').length).to.equal(0)

    describe 'realignTrains', ->
       it 'should push all trains from both east and west collections into the waiting track if all tracks are disabled', ->
           connection.get('eastwardTrack').push(direction: Directions.EAST)
           connection.get('westwardTrack').push(direction: Directions.WEST)

           connection.set('tracksDisabled', 2)
           connection.realignTrains()

           expect(connection.get('eastwardTrack').length).to.equal(0)
           expect(connection.get('westwardTrack').length).to.equal(0)
           expect(connection.get('waitingTrack').length).to.equal(2)
       
       it 'should push all trains from westward and waiting to eastward if a single track is available', ->
            connection.get('westwardTrack').push(direction: Directions.WEST)
            connection.get('waitingTrack').push(direction: Directions.EAST)

            connection.set('tracksDisabled', 1)
            connection.realignTrains()

            expect(connection.get('eastwardTrack').length).to.equal(2)
            expect(connection.get('westwardTrack').length).to.equal(0)
            expect(connection.get('waitingTrack').length).to.equal(0)

        it 'should push all trains to their correct location if two trains are available', ->
            connection.get('eastwardTrack').push(direction: Directions.EAST)
            connection.get('eastwardTrack').push(direction: Directions.WEST)
            connection.get('waitingTrack').push(direction: Directions.WEST)

            connection.set('tracksDisabled', 0)
            connection.realignTrains()

            expect(connection.get('eastwardTrack').length).to.equal(1)
            expect(connection.get('westwardTrack').length).to.equal(2)
            expect(connection.get('waitingTrack').length).to.equal(0)

    describe 'releaseNextTrain', ->
        it 'should release a train from the east direction if one is available', ->
            connection.get('eastwardTrack').push({ id: 123 })
            expect(connection.releaseNextTrain(Directions.EAST).get('id')).to.equal(123)
            expect(connection.get('eastwardTrack').length).to.equal(0)

        it 'should release a train from the west direction if one is available', ->
            connection.get('westwardTrack').push({ id: 123 })
            expect(connection.releaseNextTrain(Directions.WEST).get('id')).to.equal(123)
            expect(connection.get('westwardTrack').length).to.equal(0)

        it 'should return null if no tracks are available', ->
            connection.get('westwardTrack').push({ id: 123 })
            connection.get('eastwardTrack').push({ id: 234 })
            connection.set('tracksDisabled', 2)
            expect(connection.releaseNextTrain(Directions.EAST)).to.equal(undefined)
            expect(connection.releaseNextTrain(Directions.WEST)).to.equal(undefined)

        it 'should return whatever is in the eastern track if there is one track', ->
            connection.get('eastwardTrack').push({ id: 123 })
            connection.set('tracksDisabled', 1)
            expect(connection.releaseNextTrain(Directions.WEST).get('id')).to.equal(123)
            expect(connection.get('eastwardTrack').length).to.equal(0)

    describe 'onTrainArrived', ->
        beforeEach ->
            connection.preferredTrackForTrain = -> null

        it 'should not push a train if its not the same connection', ->
            event = stubEvent(connection, new Train(direction: Directions.EAST), westStation)

        it 'should push a train if its heading east and the station matches the western station', ->
            event = stubEvent(new StationConnection, new Train(direction: Directions.EAST), westStation)
            connection.onTrainArrived(event)
            expect(connection.get('eastwardTrack').length).to.equal(0)
            expect(connection.get('westwardTrack').length).to.equal(0)
            expect(connection.get('waitingTrack').length).to.equal(0)

        it 'should push a train if its heading west and the station matches the eastern station', ->
            event = stubEvent(connection, new Train(direction: Directions.WEST), eastStation)
            connection.onTrainArrived(event)
            expect(connection.get('westwardTrack').length).to.equal(1)

    describe 'onConnectionEnter', ->
        it 'should emit an event with the same train, but at a later time', ->
            event = stubEvent(connection, new Train, new Station)
            event.set('timestamp', 1)
            event.set('name', 'train:enter')
            connection.onConnectionEnter(event)
            expect(EventQueueSingleton.length).to.equal(1)
            expect(EventQueueSingleton.first().get('data').train).to.equal(event.get('data').train)
            expect(EventQueueSingleton.first().get('timestamp')).to.equal(3)

        it 'should not emit an event if the connection does no match', ->
            event = stubEvent(new StationConnection, new Train, new Station)
            connection.onConnectionEnter(event)
            expect(EventQueueSingleton.length).to.equal(0)

    describe 'onConnectionExit', ->
        it 'should enqueue nothing if the connection mismatches', ->
            anotherConnection = new StationConnection(
                eastStation: eastStation
                westStation: westStation
            )
            EventQueueSingleton.reset()
            connection.onConnectionExit(stubEvent(anotherConnection, new Train, eastStation))
            expect(EventQueueSingleton.length).to.equal(0)

        it 'should enqueue nothing if the station mismatches', ->
            connection.onConnectionExit(stubEvent(connection, new Train, new Station))
            expect(EventQueueSingleton.length).to.equal(0)

        it 'should enqueue nothing if both track segments are blocked', ->
            connection.set('tracksDisabled', 2)
            connection.onConnectionExit(stubEvent(connection, new Train, eastStation))
            expect(EventQueueSingleton.length).to.equal(0)

        it 'should dequeue the westward train if a westward train was released and no lines are blocked', ->
            train = new Train(direction: Directions.WEST)
            connection.get('westwardTrack').push(train)
            connection.onConnectionExit(stubEvent(connection, new Train(direction: Directions.WEST), westStation))
            expect(EventQueueSingleton.length).to.equal(1)
            expect(EventQueueSingleton.first().get('data').train).to.equal(train)
            expect(connection.get('westwardTrack').length).to.equal(0)

        it 'should dequeue the eastward train if an eastward train was released and no lines are blocked', ->
            train = new Train(direction: Directions.EAST)
            connection.get('eastwardTrack').push(train)
            connection.onConnectionExit(stubEvent(connection, new Train, eastStation))
            expect(EventQueueSingleton.length).to.equal(1)
            expect(EventQueueSingleton.first().get('data').train).to.equal(train)
            expect(connection.get('eastwardTrack').length).to.equal(0)

        it 'should dequeue the first available train if only a single lane is available', ->
            train = new Train(direction: Directions.EAST)
            connection.set('tracksDisabled', 1)
            connection.get('eastwardTrack').push(train)
            connection.onConnectionExit(stubEvent(connection, new Train, westStation))
            expect(EventQueueSingleton.length).to.equal(1)
            expect(EventQueueSingleton.first().get('data').train).to.equal(train)
            expect(connection.get('eastwardTrack').length).to.equal(0)

    describe 'preferredTrackForTrain', ->
        setConnectionState = (options) ->
            train = new Train(direction: options.direction)
            connection.get('eastwardTrack').isOccupied = -> options.eastwardTrackStatus
            connection.get('westwardTrack').isOccupied = -> options.westwardTrackStatus
            connection.set('tracksDisabled', options.tracksDisabled)
            return train

        it 'should return a track if the train is eastward and the eastward track is unoccupied', ->
            train = setConnectionState(direction: Directions.EAST, eastwardTrackStatus: false, westwardTrackStatus: true, tracksDisabled: 0)
            expect(connection.preferredTrackForTrain(train)).to.equal(connection.get('eastwardTrack'))

        it 'should return a track if the train is westward and the westward track is unoccupied, with no disabled tracks', ->
            train = setConnectionState(direction: Directions.WEST, eastwardTrackStatus: true, westwardTrackStatus: false, tracksDisabled: 0)
            expect(connection.preferredTrackForTrain(train)).to.equal(connection.get('westwardTrack'))

        it 'should return a track if the train is westward and the eastward track is unoccupied with a single disabled track', ->
            train = setConnectionState(direction: Directions.WEST, eastwardTrackStatus: false, westwardTrackStatus: true, tracksDisabled: 1)
            expect(connection.preferredTrackForTrain(train)).to.equal(connection.get('eastwardTrack'))

        it 'should return nothing if there are no tracks available', ->
            train = setConnectionState(direction: Directions.WEST, eastwardTrackStatus: false, westwardTrackStatus: false, tracksDisabled: 2)
            expect(connection.preferredTrackForTrain(train)).to.equal(null)
            train.set('direction', Directions.EAST)
            expect(connection.preferredTrackForTrain(train)).to.equal(null)
