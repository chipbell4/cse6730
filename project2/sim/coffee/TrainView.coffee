Backbone = require 'backbone'

class TrainView extends Backbone.View
    initialize: (options) ->
        @map = options.map
        @marker = L.marker([ @model.get('latitude'), @model.get('longitude') ],
            riseOnHover: true
        )
        @marker.addTo(@map)

    render: () ->
        @marker.setLatLng([ @model.get('latitude'), @model.get('longitude') ])
