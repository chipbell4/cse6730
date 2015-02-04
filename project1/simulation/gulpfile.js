var gulp = require('gulp');
var del = require('del');
var coffeeify = require('gulp-coffeeify');

gulp.task('bundle', function() {
    return gulp.src('coffee/main.coffee')
        .pipe(coffeeify())
        .pipe(gulp.dest('.'));
});

gulp.task('clean', function(cb) {
    del('main.js', cb);
});

gulp.task('default', ['bundle']);

gulp.task('watch', ['bundle'], function() {
    gulp.watch('coffee/*', 'bundle');
});
