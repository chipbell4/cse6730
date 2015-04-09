expect = require('chai').expect

StationCollection = require '../coffee/StationCollection.coffee'

describe 'StationCollection', ->
    stations = null
    stationData = [
        {
            code: 'A',
            name: 'Station A',
            latitude: 38,
            longitude: -76,
            eastwardStationTime: 1,
            westwardStationTime: 2
        },
        {
            code: 'B',
            name: 'Station B',
            latitude: 38,
            longitude: -77,
            eastwardStationTime: 3,
            westwardStationTime: 4
        },
    ]

    beforeEach ->
        stations = new StationCollection(stationData)

    describe 'get', ->
        it 'should be able to find by code', ->
            result = stations.get('A')
            expect(result.get('name')).to.equal('Station A')

    describe 'east', ->
        it 'should define an east direction', ->
            expect(StationCollection.EAST).to.be.ok

    describe 'west', ->
        it 'should define a west direction', ->
            expect(StationCollection.WEST).to.be.ok

    describe 'stationAfter', ->
        it 'should work with codes in the west direction', ->
            expect(stations.stationAfter('A', StationCollection.WEST).id).to.equal('B')

        it 'should work with a model in the west direction', ->
            A = stations.at(0)
            expect(stations.stationAfter(A, StationCollection.WEST).id).to.equal('B')

        it 'should work in codes the east direction', ->
            expect(stations.stationAfter('B', StationCollection.EAST).id).to.equal('A')
        
        it 'should work in models the east direction', ->
            B = stations.at(1)
            expect(stations.stationAfter(B, StationCollection.EAST).id).to.equal('A')

        it 'should return null if cannot find the model', ->
            expect(stations.stationAfter('C', StationCollection.WEST)).to.not.be.ok
            expect(stations.stationAfter('C', StationCollection.EAST)).to.not.be.ok

        it 'should return nothing if the next station index is out of bounds', ->
            expect(stations.stationAfter('A', StationCollection.EAST)).to.not.be.ok
            expect(stations.stationAfter('B', StationCollection.WEST)).to.not.be.ok
