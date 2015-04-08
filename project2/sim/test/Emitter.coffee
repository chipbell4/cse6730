expect = require('chai').expect
Backbone = require 'backbone'
Random = require '../coffee/Random.coffee'
Emitter = require '../coffee/Emitter.coffee'

describe 'Emitter', ->
    
    it 'should exist', ->
        expect(Emitter).to.be.ok

    describe 'chooseBinRandomly', ->
        it 'should choose the first bin if the chosen random number is 0', ->
            Random.random = () -> 0
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0.1, 0.2, 0.3, 0.4],
                min: 0,
                max: 1
            )

            expect(emitter.chooseBinRandomly()).to.equal(0)

        it 'should choose the last bin if the chosen random number is 1', ->
            Random.random = () -> 1
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0.1, 0.2, 0.3, 0.4],
                min: 0,
                max: 1
            )

            expect(emitter.chooseBinRandomly()).to.equal(3)

        it 'should choose a middle bin if the random number falls there in the cdf', ->
            Random.random = () -> 0.5
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0, 0.1, 0, 0.2, 0.1, 0.1, 0.2, 0.3]
                min: 0,
                max: 1
            )

            expect(emitter.chooseBinRandomly()).to.equal(5)

    describe 'calculateBinWidth', ->
        it 'should calculate the bin width correctly with a 0 min', ->
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0.1, 0.2, 0.3, 0.4],
                min: 0,
                max: 10
            )

            expect(emitter.calculateBinWidth()).to.be.closeTo(2.5, 0.01)

        it 'should calculate the bin with correctly with a 0 max', ->
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0.1, 0.2, 0.3, 0.4],
                min: -10,
                max: 0
            )

            expect(emitter.calculateBinWidth()).to.be.closeTo(2.5, 0.01)
        
        it 'should calculate the bin with correctly with a non-zero max and min', ->
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0.1, 0.2, 0.3, 0.4],
                min: 1,
                max: 5
            )

            expect(emitter.calculateBinWidth()).to.be.closeTo(1, 0.01)

    describe 'uniformSampleWithinBin', ->
        it 'should return the left edge of the bin if the random number is 0', ->
            Random.random = () -> 0
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0.1, 0.2, 0.3, 0.4],
                min: 1,
                max: 5
            )

            expect(emitter.uniformSampleWithinBin(1)).to.be.closeTo(2, 0.01)
            expect(emitter.uniformSampleWithinBin(2)).to.be.closeTo(3, 0.01)
            expect(emitter.uniformSampleWithinBin(3)).to.be.closeTo(4, 0.01)

        it 'should return the right edge of the bin if the random number is 1', ->
            Random.random = () -> 1
            emitter = new Emitter(new Backbone.Collection, Backbone.Model,
                pdf: [0.1, 0.2, 0.3, 0.4],
                min: 1,
                max: 5
            )

            expect(emitter.uniformSampleWithinBin(1)).to.be.closeTo(3, 0.01)
            expect(emitter.uniformSampleWithinBin(2)).to.be.closeTo(4, 0.01)
            expect(emitter.uniformSampleWithinBin(3)).to.be.closeTo(5, 0.01)

    
    describe 'emitNext', ->
        
        it 'should emit the correct type', ->
            eventQueue = new Backbone.Collection
            emitter = new Emitter(eventQueue, Backbone.Model,
                pdf: [0.5, 0.5],
                min: 0,
                max: 1
            )

            emitter.emitNext()

            expect(eventQueue.length).to.equal(1)

            event = eventQueue.first()
            expect(event.get('data')).to.be.instanceof(Backbone.Model)
