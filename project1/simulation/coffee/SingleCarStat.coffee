Backbone = require 'backbone'

class SingleCarStat extends Backbone.Model

    defaults:
        carId: -1
        arrivalTime: 0
        exitTime: -1

    getDuration: ->
        return @get('exitTime') - @get('arrivalTime')

    hasExited: ->
        return @get('exitTime') >= 0

module.exports = SingleCarStat
