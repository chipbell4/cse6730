var gulp = require('gulp');
var async = require('async');
var exec = require('child_process').exec;
var del = require('del');

// Converts a string command into an async exec call, to be chained with async.series
var asyncCommand = function(commandText) {
    return function(callback) {
        exec(commandText, callback);
    };
};

gulp.task('clean', function(cb) {
    del(['*.{aux,bbl,blg,dvi,log,pdf,out}'], cb);
});


gulp.task('default', ['clean'], function(cb) {
    var latex = 'pdflatex -halt-on-error main';
    var bibtex = 'bibtex main';
    
    async.series([
        asyncCommand(latex),
        asyncCommand(bibtex),
        asyncCommand(latex),
        asyncCommand(latex)
    ], cb);
});

gulp.task('watch', ['default'], function() {
    return gulp.watch(['main.bib', 'main.tex'], ['default']);
});
