var expectedExponentialFrequencies = require('./expectedExponentialFrequencies.js');
var mean = require('./mean.js');
var Bin = require('./bin.js');
var chiSquaredTest = require('chi-squared-test');

/**
 * Performs an exponential goodness-of-fit test to determine how good a fit some raw data is. Essentially performs a
 * chi-squared test
 */
module.exports = function(rawData, binCount) {
    var binnedData = new Bin(rawData, binCount);

    // The maximum likelihood lambda value 1 / mean
    var mleLambda = 1 / mean(rawData);

    var N = rawData.length;

    // the expected frequencies
    var expectations = expectedExponentialFrequencies(binnedData.binWidth, binCount, mleLambda).map(function(percent) {
        return percent * N;
    });

    // the actual frequencies
    var actualFrequencies = binnedData.bins.map(function(bin) {
        return bin.length;
    });

    return chiSquaredTest(actualFrequencies, expectations, 2);
};
