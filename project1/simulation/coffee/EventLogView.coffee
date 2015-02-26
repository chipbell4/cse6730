Backbone = require 'backbone'
Backbone.$ = require 'jquery'

class EventLogView extends Backbone.View
    events:
        'keyup [name=event-filter]' : 'updateFilter'

    initialize: ->
        @listenTo(@collection, 'add', @render)
        @filterText = ''

    updateFilter: ->
        @filterText = @$('[name=event-filter]').val()
        @render()

    singleEventAsString: (event) ->
        displayText = event.get('name') + '\n'
        displayText += "\tAt " + event.get('timestamp') + " \n"
        
        data = event.get('data')
        if event.get('data') instanceof Backbone.Model
            data = data.toJSON()

        displayText += "\tData = " + JSON.stringify(data)

        return displayText

    render: ->
        filterText = @filterText
        logString = @collection.filter((event) ->
            event.get('name').indexOf(filterText) > -1
        ).map(@singleEventAsString).join('\n')

        $textarea = @$('textarea')
        $textarea.html logString
        $textarea.scrollTop $textarea[0].scrollHeight

module.exports = EventLogView
