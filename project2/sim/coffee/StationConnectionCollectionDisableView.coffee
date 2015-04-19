_ = require 'underscore'
Backbone = require 'backbone'

class StationConnectionCollectionDisableView extends Backbone.View


    renderSingleConnection: (connection) ->
        var templateFunc = _.template '<input type="checkbox" value="<%= cid %>"><%= name %><br/>'
        return templateFunc(
            cid: connection.cid
            name: connection.toString()
        )

module.exports = StationConnectionCollectionDisableView
