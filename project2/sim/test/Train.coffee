expect = require('chai').expect
Directions = require '../coffee/Directions'
Train = require '../coffee/Train'
Station = require '../coffee/Station'
StationConnection = require '../coffee/StationConnection'

describe 'Train', ->
    station1 = station2 = train = connection = null
    beforeEach ->
        station1 = new Station(
            latitude: 1
            longitude: 2
        )
        station2 = new Station(
            latitude: 2
            longitude: 0
        )
        connection = new StationConnection(eastStation: station1, westStation: station2)
        train = new Train(previousStation: station1, nextStation: station2, direction: Directions.WEST, connection: connection, enterTime: 0)

    describe 'interpolatePosition', ->
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

     describe 'figureOutPosition', ->
         it 'should set the lat and long to 0 if there is no connection', ->
             train.unset('connection')
             train.figureOutPosition(0)
             expect(train.get('latitude')).to.equal(0)
             expect(train.get('longitude')).to.equal(0)

         it 'should set the lat and long to 0 if there is no previous station', ->
             train.unset('previousStation')
             train.figureOutPosition(0)
             expect(train.get('latitude')).to.equal(0)
             expect(train.get('longitude')).to.equal(0)

         it 'should set the lat and long to 0 if ther is no next station', ->
             train.unset('nextStation')
             train.figureOutPosition(0)
             expect(train.get('latitude')).to.equal(0)
             expect(train.get('longitude')).to.equal(0)

         it 'should use the fractional distance if everything is set correctly', ->
             train.set('enterTime', 1)
             train.get('connection').set('timeBetweenStations', 2)
             train.figureOutPosition(2)
             expect(train.get('latitude')).to.be.closeTo(1.5, 0.01)
             expect(train.get('longitude')).to.be.closeTo(1, 0.01)

     describe 'fractionalDistanceFromPreviousStation', ->
         it 'should return 0 if there is no connection', ->
            train.unset('connection')
            expect(train.fractionalDistanceFromPreviousStation()).to.equal(0)

         it 'should return 0 if there is no previous station', ->
             train.unset('previousStation')
             expect(train.fractionalDistanceFromPreviousStation()).to.equal(0)

         it 'should return the correct value if the connection and previous station are set', ->
             train.get('connection').set('timeBetweenStations', 2)
             expect(train.fractionalDistanceFromPreviousStation(1)).to.be.closeTo(0.5, 0.001)
