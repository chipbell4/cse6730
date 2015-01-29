var gulp = require('gulp');
var csv = require('csv');
var fs = require('fs');
var array_interval = require('./array_interval.js');
var mean = require('./mean.js');
var performGoodnessOfFit = require('./performGoodnessOfFit.js');
var histogram = require('./histogram.js');

/**
 * Helper method for querying the CSV file
 */
var getCsv = function() {
    // return a stream filtered and transformed into a new format
    return fs.createReadStream('data.csv')
        .pipe(csv.parse());
};

/**
 * Helper method for only getting the first appearances of the cars
 */
var keepFirst = function() {
    var seenCars = {};
    var firstTracker = function(row) {
        var car_id = row[0];

        // if we've seen the car skip it
        if(seenCars[car_id]) {
            return null;
        }

        seenCars[car_id] = true;
        return row;
    };

    return csv.transform(firstTracker);
};

gulp.task('northbound-input-distribution', function(taskDone) {

    var startTimes = [];

    getCsv()
        .pipe(csv.transform(function(row) {
            // Filter only rows that are northbound, and in the correct section of road
            if(row[17] != '3' || row[18] != '2') {
                return;
            }

            return row;
        }))
        .pipe(keepFirst())
        .pipe(csv.transform(function(row) {
            startTimes.push(Number(row[3]));
            return row;
        }))
        .on('finish', function() {
            // calculate the intervals between arrivals (in seconds)
            var startOffsets = array_interval(startTimes).map(function(interval) {
                return interval / 1000;
            });
            
            var chiSquaredResults = performGoodnessOfFit(startOffsets, 25);
            console.log("Chi-Squared Test : p = " + chiSquaredResults.probability + " chi^2 = " + chiSquaredResults.chiSquared);

            // try skipping the last quarter of points?
            var subListLength = Math.round(startOffsets.length * 0.25);
            chiSquaredResults = performGoodnessOfFit(startOffsets.slice(0, subListLength), 25);
            console.log("Skipped points Chi-Squared Test : p = " + chiSquaredResults.probability + " chi^2 = " + chiSquaredResults.chiSquared);

            taskDone();
        });
});

gulp.task('default', ['northbound-input-distribution']);
