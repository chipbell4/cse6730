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

gulp.task('default', function(cb) {
    var intervals = readIntervals('data/all_northbound.csv');
    var inliers = onevar.inliers(intervals);
    console.log(histogram(inliers));
    cb();
});
