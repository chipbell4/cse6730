/**
 * Calculates the weights for each probability distribution, based on how many points are assigned to it
 *
 * @param assignments A jagged array of assignments
 * @return array
 */
var calculateMixtureProbabilities = function(assignments) {
    var mixtureProbabilities = [];
    var distributionCount = assignments.length;

    // add the counts in
    for(var i = 0; i < distributionCount; i++) {
        mixtureProbabilities.push(assignments[i].length);
    }

    // get totals
    var totalPoints = mixtureProbabilities.reduce(function(accumulator, count) {
        return accumulator + count;
    }, 0);

    // scale down to probabilities
    return mixtureProbabilities.map(function(count) {
        return count / totalPoints;
    });
};

/**
 * Uses a cdf to calculate the area between two x-values
 *
 * @param cdf        The cumulative distribution function
 * @param a          The left limit of integration
 * @param b          The right limit of integration
 * @param parameters The parameters to use for the distribution
 */
var cdfBetween = function(cdf, a, b, parameters) {
    var aParameters = parameters.slice();
    aParameters.unshift(a);
    var bParameters = parameters.slice();
    bParameters.unshift(b);

    return cdf.apply(cdf, bParameters) - cdf.apply(cdf, aParameters);
};

/**
 * Calculates the full probability between two points for the true mixture model
 *
 * @param cdf                  The cumulative distribution function to use
 * @param a                    The left limit of integration
 * @param b                    The right limit of integration
 * @param parameterList        The list of parameters to use for each distribution
 * @param mixtureProbabilities The mixture probabilites for the mixture model
 *
 * @return Number
 */
var calculateMixtureCdfBetween = function(cdf, a, b, parameterList, mixtureProbabilities) {
    var total = 0;
    var distributionCount = mixtureProbabilities.length;

    for(var i = 0; i < distributionCount; i++) {
        total += mixtureProbabilities[i] * cdfBetween(cdf, a, b, parameterList[i]);
    }

    return total;
};

/**
 * Builds an array of the expected probabilities to fall within a set of buckets
 *
 * @param binWidth      the width of each bin
 * @param binCount      The number of bins to calculate for
 * @param cdf           The cumulative distribution function to use
 * @param parameterList The list of parameters that define the mixture model
 * @param assignments   The assignments of data points in the mixture model. Used for calculating mixture probabilites
 * @return Array
 */
module.exports = function(binWidth, binCount, cdf, parameterList, assignments) {
    var mixtureProbabilities = calculateMixtureProbabilities(assignments);

    var buckets = [];

    for(var i = 0; i < binCount; i++) {
        var bucketLeft = i * binWidth;
        var bucketRight = (i + 1) * binWidth;
        buckets.push(calculateMixtureCdfBetween(cdf, bucketLeft, bucketRight, parameterList, mixtureProbabilities));
    }

    return buckets;
};
