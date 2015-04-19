_ = require 'underscore'
Backbone = require 'backbone'
Time = require './Time'

###
# Long name, but essentially renders a colleciton of station connections so that the user can disable/enable tracks
###
class StationConnectionCollectionDisableView extends Backbone.View

    events:
        'click input[type=checkbox]' : 'toggleTrackAvailability'

    toggleTrackAvailability: (event) ->
        connection = @collection.get(cid: event.target.value)
        if connection.get('tracksDisabled') is 1
            connection.set('tracksDisabled', 2)
        else
            connection.set('tracksDisabled', 1)

        connection.awakenLines(Time.current())

    render: () ->
        # Generate a checkbox for each station, and dump them all as html onto the element
        @$el.html(@collection.map(@renderSingleConnection).join(''))

        # rebind events
        @delegateEvents()

    ###
    # Renders a single train connection display from a template. Essentially builds a checkbox
    ###
    renderSingleConnection: (connection) ->
        templateFunc = _.template '<label><input type="checkbox" value="<%= cid %>"> <%= name %></label><br/>'
        return templateFunc(
            cid: connection.cid
            name: connection.toString()
        )

module.exports = StationConnectionCollectionDisableView
