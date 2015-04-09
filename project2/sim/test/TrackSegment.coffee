expect = require('chai').expect
TrackSegment = require '../coffee/TrackSegment'
Train = require '../coffee/Train'

describe 'TrackSegment', ->
    describe 'model', ->
        it 'should use a train as a model', ->
            trackSegment = new TrackSegment
            trackSegment.add(
                id: 1
            )

            expect(trackSegment.at(0)).to.be.instanceof(Train)

    describe 'releaseNextTrain', ->
        it 'should pop the first in the list', ->
            trackSegment = new TrackSegment
            trackSegment.push(id: 234)
            trackSegment.push(id: 123)

            expect(trackSegment.releaseNextTrain().id).to.equal(234)
            expect(trackSegment.length).to.equal(1)

