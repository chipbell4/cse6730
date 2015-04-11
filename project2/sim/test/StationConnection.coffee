expect = require('chai').expect
Backbone = require 'backbone'
StationConnection = require '../coffee/StationConnection'
Directions = require '../coffee/Directions'

describe 'StationConnection', ->
    connection = null
    beforeEach ->
        connection = new StationConnection(2)

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

    describe 'releaseNextTrains', ->
        it 'should release a collection', ->
            expect(connection.releaseNextTrains()).to.be.instanceof(Backbone.Collection)

        it 'should release a train from the east direction if one is available', ->
            connection.eastwardTrack.push({ id: 123 })
            expect(connection.releaseNextTrains().length).to.equal(1)
            expect(connection.eastwardTrack.length).to.equal(0)

        it 'should release a train from the west direction if one is available', ->
            connection.westwardTrack.push({ id: 123 })
            expect(connection.releaseNextTrains().length).to.equal(1)
            expect(connection.westwardTrack.length).to.equal(0)
