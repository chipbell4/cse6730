var Bin = require('./bin.js');
var gammaCDF = require('gamma-distribution').cdf;
var fit = require('gamma-distribution').fit;
var chiSquaredTest = require('chi-squared-test');

var gammaCdfRange = function(a, b, k, theta) {
    return gammaCDF(b, k, theta) - gammaCDF(a, k, theta);
};

var calculateExpectations = function(binWidth, binCount, k, theta) {
    var bins = [];
    for(var i = 0; i < binCount; i++) {
        bins.push( gammaCdfRange(binWidth * i, binWidth * (i + 1), k, theta) );
    }

    return bins;
};

/**
 * Performs an exponential goodness-of-fit test to determine how good a fit some raw data is. Essentially performs a
 * chi-squared test
 */
module.exports = function(rawData, binCount) {
    rawData = rawData.filter(function(item) {
        return item > 0;
    });
    var binnedData = new Bin(rawData, binCount);

    var N = rawData.length;

    // the expected frequencies
    var params = fit(rawData);
    var expectations = calculateExpectations(binnedData.binWidth, binCount, params.k, params.theta).map(function(percent) {
        return percent * N;
    });

    // the actual frequencies
    var actualFrequencies = binnedData.bins.map(function(bin) {
        return bin.length;
    });

    return chiSquaredTest(actualFrequencies, expectations, 2);
};
