expect = require('chai').expect

Directions = require '../coffee/Directions.coffee'
StationCollection = require '../coffee/StationCollection.coffee'

describe 'StationCollection', ->
    stations = null
    stationData = [
        {
            code: 'A',
            name: 'Station A',
        },
        {
            code: 'B',
            name: 'Station B',
        },
    ]

    beforeEach ->
        stations = new StationCollection(stationData)

    describe 'get', ->
        it 'should be able to find by code', ->
            result = stations.get('A')
            expect(result.get('name')).to.equal('Station A')

    describe 'stationAfter', ->
        it 'should work with codes in the west direction', ->
            expect(stations.stationAfter('A', Directions.WEST).id).to.equal('B')

        it 'should work with a model in the west direction', ->
            A = stations.at(0)
            expect(stations.stationAfter(A, Directions.WEST).id).to.equal('B')

        it 'should work in codes the east direction', ->
            expect(stations.stationAfter('B', Directions.EAST).id).to.equal('A')
        
        it 'should work in models the east direction', ->
            B = stations.at(1)
            expect(stations.stationAfter(B, Directions.EAST).id).to.equal('A')

        it 'should return null if cannot find the model', ->
            expect(stations.stationAfter('C', Directions.WEST)).to.not.be.ok
            expect(stations.stationAfter('C', Directions.EAST)).to.not.be.ok

        it 'should return nothing if the next station index is out of bounds', ->
            expect(stations.stationAfter('A', Directions.EAST)).to.not.be.ok
            expect(stations.stationAfter('B', Directions.WEST)).to.not.be.ok
