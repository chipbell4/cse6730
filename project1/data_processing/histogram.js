var histogram = require('ascii-histogram');

var whichBin = function(value, binStart, binWidth) {
    return Math.floor((value - binStart) / binWidth);
};

var binName = function(binIndex, binStart, binWidth) {
    var min = binIndex * binWidth + binStart;
    var max = (binIndex + 1) * binWidth + binStart;
    return min.toPrecision(4) + "-" + max.toPrecision(4);
}

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

    var binCount = options.bins || 10;
    var width = options.width || 80;
    
    var N = data.length;
    var maxValue = Math.max.apply(Math, data);
    var minValue = Math.min.apply(Math, data);
    var binWidth = (maxValue - minValue) / binCount;

    // initialize the bins to zero. From http://stackoverflow.com/a/13735425
    var bins = Array.apply(null, new Array(binCount + 1)).map(Number.prototype.valueOf, 0);

    // populate the bins
    data.forEach(function(item) {
        var binIndex = whichBin(item, minValue, binWidth);
        bins[binIndex] += 1;
    });

    console.log(bins);

    // Format as an object
    var histogramFormattedBins = {};
    bins.forEach(function(count, index) {
        histogramFormattedBins[ binName(index, minValue, binWidth) ] = count / N;
    });

    var outputString = "";
    for(var label in histogramFormattedBins) {
        outputString += label + ' | ';
        outputString += repeatString('=', histogramFormattedBins[label], width);
        outputString += "\n";
    }

    return outputString;

};
