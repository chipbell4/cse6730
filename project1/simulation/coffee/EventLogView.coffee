Backbone = require 'backbone'
Backbone.$ = require 'jquery'

class EventLogView extends Backbone.View
    initialize: ->
        @listenTo(@collection, 'add', @render)

    singleEventAsString: (event) ->
        return "#{ event.get('name') } at #{ event.get('timestamp') }"

    render: ->
        logString = @collection.map(@singleEventAsString).join('\n');
        @$el.html logString

module.exports = EventLogView
