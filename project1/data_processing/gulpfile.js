var gulp = require('gulp');
var ngsim = require('./ngsimFilters.js');
var inputDistribution = require('./inputDistributionTaskFactory.js');

gulp.task('northbound', inputDistribution(ngsim.direction.NORTH, '3'));

gulp.task('default', ['northbound']);
