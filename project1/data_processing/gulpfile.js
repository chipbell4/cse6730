var gulp = require('gulp');
var csv = require('csv');
var fs = require('fs');
var sqlite3 = require('sqlite3');
var db = new sqlite3.Database('data.sqlite');

gulp.task('stub-db', function(taskDone) {
    db.run('CREATE TABLE trajectories IF NOT EXISTS', taskDone);
});

gulp.task('input-distribution', function(taskDone) {
    fs.createReadStream('demo.csv')
        .pipe(csv.parse())
        .pipe(csv.transform(function(row, rowFinished) {
            // check if 
        }))
        .pipe(csv.stringify())
        .pipe(process.stdout);
});

gulp.task('default', ['build-db'], function() {
});
