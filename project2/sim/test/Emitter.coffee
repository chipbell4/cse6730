expect = require('chai').expect
Backbone = require 'backbone'
Emitter = require '../coffee/Emitter.coffee'

describe 'Emitter', ->
    
    it 'should exist', ->
        expect(Emitter).to.be.ok
    
    describe 'emitNext', ->
        
        it 'should emit the correct type', ->
            eventQueue = new Backbone.Collection
            emitter = new Emitter(eventQueue, Backbone.Model, [0.5, 0.5], 1)

            emitter.emitNext()

            expect(eventQueue.length).to.equal(1)

            event = eventQueue.first()
            expect(event.get('data')).to.be.instanceof(Backbone.Model)
