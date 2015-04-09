expect = require('chai').expect
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
            train =
                direction: Directions.EAST

            connection.enqueueTrain(train)

            expect(connection.eastwardTrack.length).to.equal(1)
            expect(connection.westwardTrack.length).to.equal(0)

        it 'should push the train to the westward track if the train is heading westward', ->
            train =
                direction: Directions.WEST

            connection.enqueueTrain(train)

            expect(connection.eastwardTrack.length).to.equal(0)
            expect(connection.westwardTrack.length).to.equal(1)
