var chart = require('ascii-chart');

var whichBin = function(value, binStart, binWidth) {
    return Math.floor((value - binStart) / binWidth);
};

/**
 * Draws an ascii histogram by bucketing the values in the passed array
 */
module.exports = function(data, options) {
    options = options || {};

    var binCount = options.bins || 10;
    
    var N = data.length;
    var maxValue = Math.max.apply(Math, data);
    var minValue = Math.min.apply(Math, data);
    var binWidth = (maxValue - minValue) / binCount;

    // initialize the bins to zero. From http://stackoverflow.com/a/13735425
    var bins = Array.apply(null, new Array(binCount)).map(Number.prototype.valueOf, 0);

    // populate the bins
    data.forEach(function(item) {
        var binIndex = whichBin(item, minValue, binWidth);
        bins[binIndex] += 1;
    });

    // now return the plotted result
    return chart(bins);
};
