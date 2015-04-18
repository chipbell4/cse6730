expect = require('chai').expect
Backbone = require 'backbone'
TrackSegment = require '../coffee/TrackSegment'
Directions = require '../coffee/Directions'
Train = require '../coffee/Train'

describe 'TrackSegment', ->
    trackSegment = null

    beforeEach ->
        trackSegment = new TrackSegment

    describe 'model', ->
        it 'should use a train as a model', ->
            trackSegment.add(
                id: 1
            )

            expect(trackSegment.at(0)).to.be.instanceof(Train)

    describe 'releaseNextTrain', ->
        it 'should pop the first in the list', ->
            trackSegment.push(id: 234)
            trackSegment.push(id: 123)

            expect(trackSegment.releaseNextTrain().id).to.equal(234)
            expect(trackSegment.length).to.equal(1)

    describe 'splitByDirection', ->
        it 'should return the correct types', ->
            result = trackSegment.splitByDirection()

            expect(result.east).to.be.instanceof(TrackSegment)
            expect(result.west).to.be.instanceof(TrackSegment)

        it 'should put eastbound trains in the east list', ->
            trackSegment.add(
                direction: Directions.EAST
            )

            result = trackSegment.splitByDirection()
            expect(result.east.length).to.equal(1)
            expect(result.west.length).to.equal(0)

        it 'should put westbound trains in the west list', ->
            trackSegment.add(
                direction: Directions.WEST
            )

            result = trackSegment.splitByDirection()
            expect(result.east.length).to.equal(0)
            expect(result.west.length).to.equal(1)

    describe 'occupy', ->
        it 'should by default not have an occupying train', ->
            expect(trackSegment.isOccupied()).to.equal(false)
            expect(trackSegment.occupyingTrain).to.equal(undefined)

        it 'should save the train on the track segment', ->
            train = new Train
            trackSegment.occupy(train)
            expect(trackSegment.isOccupied()).to.equal(true)
            expect(trackSegment.occupyingTrain).to.equal(train)

        it 'should remove the train if it is called with nothing', ->
            train = new Train
            trackSegment.occupy(train)
            trackSegment.occupy(null)
            expect(trackSegment.isOccupied()).to.equal(false)
            expect(trackSegment.occupyingTrain).to.equal(undefined)


