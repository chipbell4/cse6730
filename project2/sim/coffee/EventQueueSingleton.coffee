EventQueue = require './EventQueue'

###
# This module simply exposes a single instance of an event queue. Other modules can require this in, and all have
# access to the same object, so it doesn't have to be passed around. This hurts testing some, though
###
module.exports = new EventQueue
