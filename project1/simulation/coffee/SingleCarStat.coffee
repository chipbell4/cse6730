Backbone = require 'backbone'

###
# A model for representing a single car's "experience" in the simulation (Travel time)
###
class SingleCarStat extends Backbone.Model
    ###
    # Default values
    ###
    defaults:
        carId: -1
        arrivalTime: 0
        exitTime: -1

    ###
    # Calculates how long a car was waiting at the light
    ###
    getDuration: ->
        return @get('exitTime') - @get('arrivalTime')

    ###
    # Returns true if the car has exited
    ###
    hasExited: ->
        return @get('exitTime') >= 0

module.exports = SingleCarStat
