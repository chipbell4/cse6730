var histogram = require('ascii-histogram');
var Bin = require('./bin.js');

/**
 * Repeats a string
 *
 * @param string  The string to repeat
 * @param percent The percentage of the full width to stretch
 * @param width   The size that 100% means
 */
var repeatString = function(string, percent, width) {
    var count = Math.round(percent * width);
    var outputString = "";
    for(var i = 0; i < count; i++) {
        outputString += string;
    }

    return outputString;
}

/**
 * Draws an ascii histogram by bucketing the values in the passed array
 */
module.exports = function(data, options) {
    options = options || {};

    var width = options.width || 80;
    
    var bin = new Bin(data, options.bins);

    // Format as an object
    var histogramFormattedBins = {};
    for(var i = 0; i < bin.binCount; i++) {
        histogramFormattedBins[ bin.binName(i) ] = bin.bins[i].length / bin.rawItems.length;
    }

    var outputString = "";
    for(var label in histogramFormattedBins) {
        outputString += label + ' | ';
        outputString += repeatString('=', histogramFormattedBins[label], width);
        outputString += "\n";
    }

    return outputString;
};
