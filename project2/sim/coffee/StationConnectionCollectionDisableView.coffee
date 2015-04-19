_ = require 'underscore'
Backbone = require 'backbone'

###
# Long name, but essentially renders a colleciton of station connections so that the user can disable/enable tracks
###
class StationConnectionCollectionDisableView extends Backbone.View

    events:
        'click input[type=checkbox]' : 'toggleTrackAvailability'

    toggleTrackAvailability: () ->
        console.log 'TOGGLE!'

    render: () ->
        # Generate a checkbox for each station, and dump them all as html onto the element
        @$el.html(@collection.map(@renderSingleConnection).join(''))

        # rebind events
        @delegateEvents()

    ###
    # Renders a single train connection display from a template. Essentially builds a checkbox
    ###
    renderSingleConnection: (connection) ->
        templateFunc = _.template '<input type="checkbox" value="<%= cid %>"><%= name %><br/>'
        return templateFunc(
            cid: connection.cid
            name: connection.toString()
        )

module.exports = StationConnectionCollectionDisableView
