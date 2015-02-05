Backbone = require 'backbone'
Backbone.$ = require 'jquery'

class EventLogView extends Backbone.View
    initialize: ->
        @listenTo(@collection, 'add', @render)

    singleEventAsString: (event) ->
        displayText = event.get('name') + '\n'
        displayText += "\tAt " + event.get('timestamp') + " \n"
        
        data = event.get('data')
        if event.get('data') instanceof Backbone.Model
            data = data.toJSON()

        displayText += "\tData = " + JSON.stringify(data)

        return displayText

    render: ->
        logString = @collection.map(@singleEventAsString).join('\n')
        @$el.html logString
        @$el.scrollTop @el.scrollHeight

module.exports = EventLogView
