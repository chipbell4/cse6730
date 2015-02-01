var gulp = require('gulp');
var ngsim = require('./ngsimFilters.js');
var inputDistribution = require('./inputDistributionTaskFactory.js');

gulp.task('northbound', inputDistribution({
    direction: ngsim.direction.NORTH,
    intersection: '3',
    movement: ngsim.movement.THROUGH
}));

gulp.task('southbound', inputDistribution({
    direction: ngsim.direction.SOUTH,
    intersection: '3'
}));

gulp.task('default', ['northbound']);
