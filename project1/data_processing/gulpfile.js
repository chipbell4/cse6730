var gulp = require('gulp');
var fs = require('fs');
var array_interval = require('./array_interval.js');
var histogram = require('./histogram.js');
var onevar = require('./one_var_stats.js');
var goodnessOfFit = require('./performGoodnessOfFit.js');

var gammaPdf = require('gamma-distribution').pdf;
var em = require('./em.js');
var fit = require('gamma-distribution').fit;

var readIntervals = function(path) {
    var timestamps = fs.readFileSync(path)
        .toString()
        .split('\n')
        .filter(function(item) {
            return item.length > 0;
        })
        .map(function(item) {
            return Number(item) / 1000;
        })
        .sort(function(a, b) {
            return a - b;
        });

    return array_interval(timestamps);
};

gulp.task('northbound-inliers', function(cb) {
    var intervals = readIntervals('data/all_northbound.csv');
    intervals = intervals.filter(function(item) {
        return item > 0.001;
    });
    console.log(histogram(intervals));

    console.log('Single Gamma Chi-Squared Fit');
    var chiSquaredResults = goodnessOfFit(intervals, 25);
    var fittedValues = fit(intervals);
    console.log('k = ' + fittedValues.k + ' theta = ' + fittedValues.theta);
    console.log('chi-squared = ' + chiSquaredResults.chiSquared);
    console.log('p = ' + chiSquaredResults.probability);

    console.log('Mixture Model Chi-Squared Fit');
    var emFit = function(data) {
        var result = fit(data);
        return [result.k, result.theta]; // since EM wants an array
    };

    var initialParams = [
        [1, 2],
        [7.5, 1],
    ];

    var result = em(gammaPdf, emFit, initialParams, intervals);
    console.log(result);

    cb();
});

gulp.task('northbound-outliers', function(cb) {
    var intervals = readIntervals('data/all_northbound.csv');
    var outliers = onevar.outliers(intervals);
    console.log(histogram(outliers));
    cb();
});

gulp.task('default', ['northbound-inliers', 'northbound-outliers']);
