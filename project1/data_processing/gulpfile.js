var gulp = require('gulp');
var ngsimFilters = require('./ngsimFilters.js');
var inputDistributionTaskFactory = require('./inputDistributionTaskFactory.js');

gulp.task(
    'northbound-input-distribution',
    inputDistributionTaskFactory(ngsimFilters.direction.NORTH, '3')
);

gulp.task('default', ['northbound-input-distribution']);
