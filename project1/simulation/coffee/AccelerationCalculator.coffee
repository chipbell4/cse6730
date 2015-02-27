
class AccelerationCalculator
    constructor: (@options) ->
        @options = @options || {}
        @defaultOption('accleration_max', 6.63)
        @defaultOption('velocity_max', 44) # In ft / s (instead of mph)
        @defaultOption('car_length', 16.407)
        @defaultOption('queue_index', 0)

    defaultOption: (key, value) ->
        @options[key] = @options[key] || value

    # A function for the position of a car at a given time
    position: (t) ->
        total = @options.velocity_max * t
        total -= @options.velocity_max ** 2 / @options.accleration_max * (1 - Math.exp(-@options.accleration_max * t / @options.velocity_max))
        total -= @options.car_length * (@options.queue_index - 1)

    # Since the function is fairly linear at this point, and I'm lazy
    velocity: (t) ->
        h = 0.02
        return (@position(t + h) - @position(t - h)) / (2 * h)


    timeToIntersection: (maxSteps = 10) ->
        currentStep = 0
        currentGuess = 2 # based off of looking at the graph
        while currentStep <= maxSteps
            currentStep += 1
            currentGuess = currentGuess - @position(currentGuess) / @velocity(currentGuess)

        return currentGuess

module.exports = AccelerationCalculator
