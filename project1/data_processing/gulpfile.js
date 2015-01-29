var gulp = require('gulp');
var csv = require('csv');
var fs = require('fs');
var array_interval = require('./array_interval.js');
var mean = require('./mean.js');
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
            // calculate the intervals between arrivals
            var startOffsets = array_interval(startTimes);
            
            console.log(startOffsets);
            console.log(histogram(startOffsets, { bins: 30 }));

            // calculate the mean
            var meanOffset = mean(startOffsets);
            console.log("Raw Mean is " + meanOffset + " seconds");

            var reducedOffsets = startOffsets.filter(function(value) {
                return value < 40;
            });
            var reducedMean = mean(reducedOffsets);
            console.log('Reduced mean is ' + reducedMean);

            taskDone();
        });
});

gulp.task('default', ['northbound-input-distribution']);
