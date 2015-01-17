var gulp = require('gulp');
var csv = require('csv');
var fs = require('fs');

gulp.task('input-distribution', function(taskDone) {
    fs.createReadStream('demo.csv')
        .pipe(csv.parse())
        .pipe(csv.transform(function(row, rowFinished) {
            // check if 
        }))
        .pipe(csv.stringify())
        .pipe(process.stdout);
});

gulp.task('default', ['input-distribution'], function() {
});
