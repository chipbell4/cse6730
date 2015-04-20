###
# Module to wrap Math.random to help with testing. However, I'm pretty sure you'll find places where I'm inconsistent
# and forget to use it.
###
module.exports =
    ###
    # Returns a random number in the range provided, defaulting to [0,1]
    ###
    random: (a = 0, b = 1) ->
        a + (b - a) * Math.random()
   
    ###
    # Returns a random int in the range of a to b, including a, but excluding b
    ###
    randomInt: (a, b) ->
        return Math.floor(this.random(a, b))
