Backbone = require 'backbone'

###
# Represents a single station, like Metro Center
###
class Station extends Backbone.Model
    ###
    # Since WMATA uses a station code to provide a unique ID, we'll use it here as well
    ###
    idAttribute: 'code'

module.exports = Station
