###
# A simple class to help calculate how long it will take for a car to reach the intersection if it is at a complete
# stop, and is the "queue_index"th car back
###
class AccelerationCalculator
    ###
    # Creates a new acceleration calculator, utilizing a default options hash
    ###
    constructor: (@options) ->
        @options = @options || {}

        # Set of couple of options that we'll need to define our position function. Should be self-explanatory
        @defaultOption('accleration_max', 6.63)
        @defaultOption('velocity_max', 44) # In ft / s (= 30 mph)
        @defaultOption('car_length', 16.407)
        @defaultOption('queue_index', 0)

    ###
    # A helper method to get a default option for a particular key
    ###
    defaultOption: (key, value) ->
        @options[key] = @options[key] || value

    ###
    # A function for the position of a car at a given time
    ###
    position: (t) ->
        total = @options.velocity_max * t
        total -= @options.velocity_max ** 2 / @options.accleration_max * (1 - Math.exp(-@options.accleration_max * t / @options.velocity_max))
        total -= @options.car_length * (@options.queue_index - 1)

    ###
    # The velocity function. Since I'm lazy, and position(t) is fairly linear when it's positive, we'll just
    # approximate
    ###
    velocity: (t) ->
        h = 0.02
        return (@position(t + h) - @position(t - h)) / (2 * h)

    ###
    # Performs Newton's method to find the zero of the position function. Newton's method is a great choice here
    # because of how linear position(t) is at the zero
    ###
    timeToIntersection: (maxSteps = 10) ->
        currentStep = 0
        currentGuess = 2 # based off of looking at the graph
        while currentStep <= maxSteps
            currentStep += 1
            currentGuess = currentGuess - @position(currentGuess) / @velocity(currentGuess)

        return currentGuess

module.exports = AccelerationCalculator
