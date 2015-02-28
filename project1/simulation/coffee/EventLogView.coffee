Backbone = require 'backbone'
Backbone.$ = require 'jquery'

###
# A view for displaying the event log
###
class EventLogView extends Backbone.View
    ###
    # The set of events to listen to. Essentially, if you type in the search box, re-search and render
    ###
    events:
        'keyup [name=event-filter]' : 'updateFilter'

    ###
    # Creates a new view, re-rendering whenever a new item is added. Also defaults the search text
    ###
    initialize: ->
        @listenTo(@collection, 'add', @render)
        @filterText = ''

    ###
    # Re-fetches the filter text and re-renders
    ###
    updateFilter: ->
        @filterText = @$('[name=event-filter]').val()
        @render()

    ###
    # Essentially pretty prints a string, so that it renders nicely in the textarea
    ###
    singleEventAsString: (event) ->
        displayText = event.get('name') + '\n'
        displayText += "\tAt " + event.get('timestamp') + " \n"
        
        data = event.get('data')
        if event.get('data') instanceof Backbone.Model
            data = data.toJSON()

        displayText += "\tData = " + JSON.stringify(data)

        return displayText

    ###
    # Redraws the view, by pretty printing ALL events into the log container
    ###
    render: ->
        filterText = @filterText
        logString = @collection.filter((event) ->
            event.get('name').indexOf(filterText) > -1
        ).map(@singleEventAsString).join('\n')

        $textarea = @$('textarea')
        $textarea.html logString
        $textarea.scrollTop $textarea[0].scrollHeight

module.exports = EventLogView
