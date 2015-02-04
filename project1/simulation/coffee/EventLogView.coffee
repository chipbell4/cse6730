Backbone = require 'backbone'

class EventLogView extends Backbone.View
    initialize: ->
        @listenTo(@collection, 'change', @render)

    singleEventAsString: (event) ->
        return '''#{ event.get('name') } at #{ event.get('timestamp') }'''

    render: ->
        logString = @collection.map(@singleEventAsString).join('\n');
        @$el.html logString
