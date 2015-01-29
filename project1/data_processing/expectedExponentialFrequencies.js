var exponential = require('./exponential.js');

var probabilityBetween = function(a, b, lambda) {
    return exponential.cdf(b, lambda) - exponential.cdf(a, lambda);
};

module.exports = function(binWidth, binCount, lambda) {
    var frequencies  = [];

    for(var i = 0; i < binCount; i++) {
        var leftBoundary = i * binWidth;
        var rightBoundary = (i + 1) * binWidth;
        frequencies.push(probabilityBetween(leftBoundary, rightBoundary, lambda));
    }

    return frequencies;
};
