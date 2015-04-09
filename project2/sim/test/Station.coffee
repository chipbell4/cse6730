expect = require('chai').expect

Station = require '../coffee/Station.coffee'

describe 'Station', ->
    describe 'idAttribute', ->
        it 'should use the station code as an id', ->
            model = new Station(
                code: 'ABC'
                id: 'NOT IT'
            )

            expect(model.id).to.equal('ABC')
