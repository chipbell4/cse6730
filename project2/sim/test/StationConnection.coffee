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
    beforeEach ->
        connection = new StationConnection(eastStation, westStation) 

    describe 'disableTrack', ->
        it 'should by default have 0 tracks disabled', ->
            expect(connection.tracksDisabled).to.equal(0)

        it 'should increment to 1 if a single track is disabled', ->
            connection.disableTrack()
            expect(connection.tracksDisabled).to.equal(1)

        it 'should increment to 2 if two tracks are disabled', ->
            connection.disableTrack()
            connection.disableTrack()
            expect(connection.tracksDisabled).to.equal(2)

        it 'should never go above 2', ->
            connection.disableTrack()
            connection.disableTrack()
            connection.disableTrack()
            expect(connection.tracksDisabled).to.equal(2)

    describe 'enableTrack', ->
        it 'should decrement the number of tracks to 1 if 2 tracks are disabled', ->
            connection.tracksDisabled = 2
            connection.enableTrack()
            expect(connection.tracksDisabled).to.equal(1)

        it 'should never go below 0', ->
            connection.tracksDisabled = 0
            connection.enableTrack()
            expect(connection.tracksDisabled).to.equal(0)

    describe 'enqueueTrain', ->
        it 'should push the train to the eastward track if the train is heading eastward', ->
            connection.enqueueTrain(direction: Directions.EAST)

            expect(connection.eastwardTrack.length).to.equal(1)
            expect(connection.westwardTrack.length).to.equal(0)

        it 'should push the train to the westward track if the train is heading westward', ->
            connection.enqueueTrain(direction: Directions.WEST)

            expect(connection.eastwardTrack.length).to.equal(0)
            expect(connection.westwardTrack.length).to.equal(1)

        it 'should push all trains to the east track if a single track is disabled', ->
            connection.tracksDisabled = 1
            connection.enqueueTrain(direction: Directions.WEST)

            expect(connection.eastwardTrack.length).to.equal(1)
            expect(connection.westwardTrack.length).to.equal(0)

        it 'should push the train to the waiting track if all tracks are disabled, so it will not be processed', ->
            connection.tracksDisabled = 2
            connection.enqueueTrain(direction: Directions.EAST)

            expect(connection.waitingTrack.length).to.equal(1)
            expect(connection.eastwardTrack.length).to.equal(0)
            expect(connection.westwardTrack.length).to.equal(0)

    describe 'realignTrains', ->
       it 'should push all trains from both east and west collections into the waiting track if all tracks are disabled', ->
           connection.eastwardTrack.push(direction: Directions.EAST)
           connection.westwardTrack.push(direction: Directions.WEST)

           connection.tracksDisabled = 2
           connection.realignTrains()

           expect(connection.eastwardTrack.length).to.equal(0)
           expect(connection.westwardTrack.length).to.equal(0)
           expect(connection.waitingTrack.length).to.equal(2)

       it 'should push all trains from westward and waiting to eastward if a single track is available', ->
            connection.westwardTrack.push(direction: Directions.WEST)
            connection.waitingTrack.push(direction: Directions.EAST)

            connection.tracksDisabled = 1
            connection.realignTrains()

            expect(connection.eastwardTrack.length).to.equal(2)
            expect(connection.westwardTrack.length).to.equal(0)
            expect(connection.waitingTrack.length).to.equal(0)

        it 'should push all trains to their correct location if two trains are available', ->
            connection.eastwardTrack.push(direction: Directions.EAST)
            connection.eastwardTrack.push(direction: Directions.WEST)
            connection.waitingTrack.push(direction: Directions.WEST)

            connection.tracksDisabled = 0
            connection.realignTrains()

            expect(connection.eastwardTrack.length).to.equal(1)
            expect(connection.westwardTrack.length).to.equal(2)
            expect(connection.waitingTrack.length).to.equal(0)

    describe 'releaseNextTrain', ->
        it 'should release a train from the east direction if one is available', ->
            connection.eastwardTrack.push({ id: 123 })
            expect(connection.releaseNextTrain(Directions.EAST).get('id')).to.equal(123)
            expect(connection.eastwardTrack.length).to.equal(0)

        it 'should release a train from the west direction if one is available', ->
            connection.westwardTrack.push({ id: 123 })
            expect(connection.releaseNextTrain(Directions.WEST).get('id')).to.equal(123)
            expect(connection.westwardTrack.length).to.equal(0)

        it 'should return null if no tracks are available', ->
            connection.westwardTrack.push({ id: 123 })
            connection.eastwardTrack.push({ id: 234 })
            connection.tracksDisabled = 2
            expect(connection.releaseNextTrain(Directions.EAST)).to.equal(undefined)
            expect(connection.releaseNextTrain(Directions.WEST)).to.equal(undefined)

        it 'should return whatever is in the eastern track if there is one track', ->
            connection.eastwardTrack.push({ id: 123 })
            connection.tracksDisabled = 1
            expect(connection.releaseNextTrain(Directions.WEST).get('id')).to.equal(123)
            expect(connection.eastwardTrack.length).to.equal(0)

    describe 'onTrainArrived', ->
        it 'should push a train if its heading east and the station matches the western station', ->
            train = new Train(direction: Directions.EAST)
            connection.onTrainArrived(train, westStation)
            expect(connection.eastwardTrack.length).to.equal(1)

        it 'should push a train if its heading west and the station matches the eastern station', ->
            train = new Train(direction: Directions.WEST)
            connection.onTrainArrived(train, eastStation)
            expect(connection.westwardTrack.length).to.equal(1)

        it 'should not push a train if the station matches the west but is heading the wrong direction', ->
            train = new Train(direction: Directions.WEST)
            connection.onTrainArrived(train, westStation)
            expect(connection.westwardTrack.length).to.equal(0)
        
        it 'should not push a train if the station matches the east but is heading the wrong direction', ->
            train = new Train(direction: Directions.EAST)
            connection.onTrainArrived(train, eastStation)
            expect(connection.eastwardTrack.length).to.equal(0)

        it 'should not push a train if the station mismatches', ->
            train = new Train(direction: Directions.EAST)
            connection.onTrainArrived(train, new Station)
            expect(connection.eastwardTrack.length).to.equal(0)

    describe 'onConnectionExit', ->
        stubEvent = (connection, train, station) ->
            new Backbone.Model(
                timestamp: 0
                name: 'train:exit'
                data:
                    connection: connection
                    train: train
                    station: station
            )
        beforeEach ->
            EventQueueSingleton.reset()

        it 'should enqueue nothing if the connection mismatches', ->
            anotherConnection = new StationConnection(eastStation, westStation)
            console.log 'About to do it!'
            EventQueueSingleton.reset()
            connection.onConnectionExit(stubEvent(anotherConnection, new Train, eastStation))
            expect(EventQueueSingleton.length).to.equal(0)

        it 'should enqueue nothing if the station mismatches', ->
            connection.onConnectionExit(stubEvent(connection, new Train, new Station))
            expect(EventQueueSingleton.length).to.equal(0)

        it 'should enqueue nothing if both track segments are blocked', ->
            connection.tracksDisabled = 2
            connection.onConnectionExit(stubEvent(connection, new Train, eastStation))
            expect(EventQueueSingleton.length).to.equal(0)

        it 'should dequeue the westward train if a westward train was released and no lines are blocked', ->
            train = new Train(direction: Directions.WEST)
            connection.westwardTrack.push(train)
            connection.onConnectionExit(stubEvent(connection, new Train(direction: Directions.WEST), westStation))
            expect(EventQueueSingleton.length).to.equal(1)
            expect(EventQueueSingleton.first().get('train')).to.equal(train)
            expect(connection.westwardTrack.length).to.equal(0)

        it 'should dequeue the eastward train if an eastward train was released and no lines are blocked', ->
            train = new Train(direction: Directions.EAST)
            connection.eastwardTrack.push(train)
            connection.onConnectionExit(stubEvent(connection, new Train, eastStation))
            expect(EventQueueSingleton.length).to.equal(1)
            expect(EventQueueSingleton.first().get('train')).to.equal(train)
            expect(connection.eastwardTrack.length).to.equal(0)

        it 'should dequeue the first available train if only a single lane is available', ->
            train = new Train(direction: Directions.EAST)
            connection.tracksDisabled = 1
            connection.eastwardTrack.push(train)
            connection.onConnectionExit(stubEvent(connection, new Train, westStation))
            expect(EventQueueSingleton.length).to.equal(1)
            expect(EventQueueSingleton.first().get('train')).to.equal(train)
            expect(connection.eastwardTrack.length).to.equal(0)

