Backbone = require 'backbone'

class Train extends Backbone.Model
    interpolatePosition: (station1, station2, percent) ->
        latitude1 = station1.get('latitude')
        longitude1 = station1.get('longitude')
        latitude2 = station2.get('latitude')
        longitude2 = station2.get('longitude')
        @set(
            latitude: latitude1 + (latitude2 - latitude1) * percent
            longitude: longitude1 + (longitude2 - longitude1) * percent
        )

module.exports = Train
