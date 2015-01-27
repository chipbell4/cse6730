var gulp = require('gulp');
var csv = require('csv');
var fs = require('fs');

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
var keepEntrances = function() {
    var seenCars = {};
    var keepFirst = function(row) {
        var car_id = row[0];

        // if we've seen the car skip it
        if(seenCars[car_id]) {
            return null;
        }

        seenCars[car_id] = true;
        return row;
    };

    return getCsv().pipe(csv.transform(keepFirst));
};

gulp.task('input-distribution', function(taskDone) {
    return keepEntrances()
        .pipe(csv.stringify())
        .pipe(process.stdout);
});

gulp.task('default', ['input-distribution']);
