currentTime = 0

module.exports =
    step: ->
        currentTime += 1
    reset: ->
        currentTime = 0
    jumpTo: (newTime) ->
        currentTime = newTime
    current: ->
        currentTime
