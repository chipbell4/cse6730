/**
 * Calculates the median of a set of numbers
 */
var median = function(numbers) {
    var sorted = numbers.sort(function(a, b) {
        return Number(a) - Number(b);
    });

    var middle = Math.floor(sorted.length / 2);
    if(sorted.length % 2 == 1) {
        return sorted[middle];
    }
    else {
        return 0.5 * (sorted[middle] + sorted[middle-1]);
    }
};

/**
 * Calculates the first quartile of the set of numbers
 */
var firstQuartile = function(numbers) {
    var medianOfSet = median(numbers);
    var lowerHalf = numbers.filter(function(item) {
        return item < medianOfSet;
    });

    return median(lowerHalf);
};

/**
 * Calculates the third quartile of the set of numbers
 */
var thirdQuartile = function(numbers) {
    var medianOfSet = median(numbers);
    var upperHalf = numbers.filter(function(item) {
        return item > medianOfSet;
    });

    return median(upperHalf);
};

/**
 * Calculates the interquartile range
 */
var IQR = function(numbers) {
    var q1 = firstQuartile(numbers);
    var q3 = thirdQuartile(numbers);
    return q3 - q1;
};

/**
 * Gets the outliers of a given set
 */
var outliers = function(numbers) {
    var medianOfSet = median(numbers);
    var iqrOfSet = IQR(numbers);
    return numbers.filter(function(item) {
        return Math.abs(item - medianOfSet) >= iqrOfSet;
    });
};

/**
 * Gets the non-outliers of a given set
 */
var inliers = function(numbers) {
    var medianOfSet = median(numbers);
    var iqrOfSet = IQR(numbers);
    return numbers.filter(function(item) {
        return Math.abs(item - medianOfSet) <= iqrOfSet;
    });
};

module.exports = {
    median: median,
    firstQuartile: firstQuartile,
    thirdQuartile: thirdQuartile,
    outliers: outliers,
    inliers: inliers
};
