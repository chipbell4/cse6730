var gulp = require('gulp');
var del = require('del');
var coffeeify = require('gulp-coffeeify');
var mocha = require('gulp-mocha');
var uglify = require('gulp-uglify');

gulp.task('bundle', function() {
    return gulp.src('coffee/main.coffee')
        .pipe(coffeeify())
        //.pipe(uglify({ "source-map" : "main.js.map" }))
        .pipe(gulp.dest('.'));
});

gulp.task('test', function() {
    // So the coffee transform for mocha works
    require('coffee-script/register');

    return gulp.src('test/**/*.coffee')
        .pipe(mocha({
            reporter: 'spec',
            compilers: 'coffee:coffee-script'
        }));
});

gulp.task('clean', function(cb) {
    del('main.js', cb);
});

gulp.task('default', ['bundle']);

gulp.task('watch', ['bundle'], function() {
    return gulp.watch('coffee/*', ['bundle']);
});
