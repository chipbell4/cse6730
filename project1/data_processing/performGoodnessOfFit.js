var expectedExponentialFrequencies = require('./expectedExponentialFrequencies.js');
var mean = require('./mean.js');
var Bin = require('./bin.js');
var chiSquaredTest = require('chi-squared-test');

module.exports = function(rawData, binCount) {
    var binnedData = new Bin(rawData, binCount);

    // The maximum likelihood lambda value 1 / mean
    var mleLambda = 1 / mean(rawData);

    // the expected frequencies
    var expectations = expectedExponentialFrequencies(binnedData.binWidth, binCount, mleLambda);

    // the actual frequencies
    var N = rawData.length;
    var actualFrequencies = binnedData.bins.map(function(bin) {
        return bin.length / N;
    });

    return chiSquaredTest(actualFrequencies, expectations, 2);
};
