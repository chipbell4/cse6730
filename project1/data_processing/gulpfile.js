var gulp = require('gulp');
var fs = require('fs');
var array_interval = require('./array_interval.js');
var histogram = require('./histogram.js');
var onevar = require('./one_var_stats.js');

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
    var inliers = onevar.inliers(intervals);
    console.log(histogram(inliers));
    cb();
});

gulp.task('northbound-outliers', function(cb) {
    var intervals = readIntervals('data/all_northbound.csv');
    var outliers = onevar.outliers(intervals);
    console.log(histogram(outliers));
    cb();
});

gulp.task('default', ['northbound-inliers', 'northbound-outliers']);
