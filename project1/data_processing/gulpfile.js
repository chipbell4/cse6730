var gulp = require('gulp');
var csvFilter = require('./csvFilter.js');
var ngsimFilters = require('./ngsimFilters.js');
var array_interval = require('./array_interval.js');
var mean = require('./mean.js');
var performGoodnessOfFit = require('./performGoodnessOfFit.js');
var histogram = require('./histogram.js');

gulp.task('northbound-input-distribution', function(taskDone) {

    var startTimes = [];

    var filters = [];

    // Only northbound
    filters.push(ngsimFilters.direction(ngsimFilters.direction.NORTH));

    // only through our intersection
    filters.push(ngsimFilters.intersection('3'));

    // only keep the first occurrences
    filters.push(ngsimFilters.firstKeeper());

    // track the start times
    filters.push(function(row) {
        startTimes.push(Number(row[3]));
        return row;
    });

    var finish = function() {
        // calculate the intervals between arrivals (in seconds)
        var startOffsets = array_interval(startTimes).map(function(interval) {
            return interval / 1000;
        });

        var chiSquaredResults = performGoodnessOfFit(startOffsets, 25);
        console.log('N = ' + startOffsets.length);
        console.log("Chi-Squared Test : p = " + chiSquaredResults.probability + " chi^2 = " + chiSquaredResults.chiSquared);
        console.log(histogram(startOffsets, { }));

        taskDone();
    };

    csvFilter(filters, finish);
});

gulp.task('default', ['northbound-input-distribution']);
