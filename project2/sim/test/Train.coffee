expect = require('chai').expect
Train = require '../coffee/Train'
Station = require '../coffee/Station'

describe 'Train', ->
    describe 'interpolatePosition', ->
        station1 = station2 = train = null

        beforeEach ->
            station1 = new Station(
                latitude: 1
                longitude: 2
            )
            station2 = new Station(
                latitude: 2
                longitude: 0
            )
            train = new Train

        it 'should interpolate correctly', ->
            train.interpolatePosition(station1, station2, 0.5)
            expect(train.get('latitude')).to.be.closeTo(1.5, 0.01)
            expect(train.get('longitude')).to.be.closeTo(1, 0.01)

        it 'should handle the left edge okay', ->
            train.interpolatePosition(station1, station2, 0.0)
            expect(train.get('latitude')).to.be.closeTo(1, 0.01)
            expect(train.get('longitude')).to.be.closeTo(2, 0.01)
        
        it 'should handle the right edge okay', ->
            train.interpolatePosition(station1, station2, 1.0)
            expect(train.get('latitude')).to.be.closeTo(2, 0.01)
            expect(train.get('longitude')).to.be.closeTo(0, 0.01)

        it 'should only throw one change event', ->
            callCount = 0
            train.on('change', () ->
                callCount += 1
            )

            train.interpolatePosition(station1, station2, 1.0)
            expect(callCount).to.equal(1)

