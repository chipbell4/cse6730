var exponential = require('./exponential.js');

/**
 * calculates the integral of the exponential pdf between two values
 */
var probabilityBetween = function(a, b, lambda) {
    return exponential.cdf(b, lambda) - exponential.cdf(a, lambda);
};

/**
 * Calculates the expected probabilities for a set of bins provided by:
 *
 * @param binWidth The width of each bin
 * @param binCount The number of bins
 * @param lambda   The lambda to use
 */
module.exports = function(binWidth, binCount, lambda) {
    var frequencies  = [];

    for(var i = 0; i < binCount; i++) {
        var leftBoundary = i * binWidth;
        var rightBoundary = (i + 1) * binWidth;
        frequencies.push(probabilityBetween(leftBoundary, rightBoundary, lambda));
    }

    return frequencies;
};
