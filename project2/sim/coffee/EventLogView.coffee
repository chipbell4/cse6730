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
        displayText = event.get('name') + ' at ' + event.get('timestamp') + '\n'
        
        if event.get('data').connection?
            displayText += '\tConnection: ' + event.get('data').connection.toString() + '\n'
        if event.get('data').train?
            displayText += '\tTrain: ' + event.get('data').train.cid + '\n'
        if event.get('data').station?
            displayText += '\tStation: ' + event.get('data').station.get('name') + '\n'

        return displayText

    ###
    # Redraws the view, by pretty printing ALL events into the log container
    ###
    render: ->
        filterText = @filterText.toLowerCase()
        logString = @collection.filter((event) ->
            inName = event.get('name').toLowerCase().indexOf(filterText) > -1
            inTrain = event.get('data').train.cid.toLowerCase().indexOf(filterText) > -1
            inConnection = event.get('data').connection.toString().toLowerCase().indexOf(filterText) > -1
            return inName or inTrain or inConnection
        ).map(@singleEventAsString).join('\n')

        $textarea = @$('textarea')
        $textarea.html logString
        $textarea.scrollTop $textarea[0].scrollHeight

module.exports = EventLogView
