_ = require 'underscore'
Backbone = require 'backbone'
Time = require './Time'

###
# Long name, but essentially renders a collection of station connections so that the user can disable/enable tracks
###
class StationConnectionCollectionDisableView extends Backbone.View

    ###
    # The event that this view handles. When a check box is clicked, toggle a track's availability
    ###
    events:
        'change input[type=checkbox]' : 'toggleTrackAvailability'

    ###
    # Handler for when a check box is clicked. Figures out which connection the event refers to, and then toggles a
    # track for that connection.
    ###
    toggleTrackAvailability: (event) ->
        connection = @collection.get(cid: event.target.value)
        if connection.get('tracksDisabled') is 1
            connection.set('tracksDisabled', 0)
        else
            connection.set('tracksDisabled', 1)

        connection.realignTrains()
        connection.awakenLines(Time.current())

    ###
    # "Renders" the view. Essentially drops a checkbox in the DOM for every connection that this view represents
    ###
    render: () ->
        # Generate a checkbox for each station, and dump them all as html onto the element
        @$el.html(@collection.map(@renderSingleConnection).join(''))

        # rebind events
        @delegateEvents()

    ###
    # Renders a single train connection display from a template string that is compiled via underscore. Essentially
    # builds a checkbox
    ###
    renderSingleConnection: (connection) ->
        templateFunc = _.template '<label><input type="checkbox" value="<%= cid %>"> <%= name %></label><br/>'
        return templateFunc(
            cid: connection.cid
            name: connection.toString()
        )

module.exports = StationConnectionCollectionDisableView
