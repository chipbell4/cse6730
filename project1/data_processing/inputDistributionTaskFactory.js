var csvFilter = require('./csvFilter.js');
var ngsimFilters = require('./ngsimFilters.js');
var array_interval = require('./array_interval.js');
var mean = require('./mean.js');
var performGoodnessOfFit = require('./performGoodnessOfFit.js');
var histogram = require('./histogram.js');

/**
 * Helper for appending all filters to the csv file
 */
var getFilters = function(options) {
    var filters = [];

    // loop over all of the config options provided
    for(var key in options) {
        filters.push(ngsimFilters[key](options[key]));
    }

    return filters;
};

/**
 * Factory function for building a gulp task for filtering the NGSIM data for a certain direction and intersection of the road
 */
module.exports = function(options) {
    return function(taskDone) {
        var startTimes = [];

        var filters = getFilters(options);

        // only keep the first occurrences
        filters.push(ngsimFilters.firstKeeper());

        // track the start times
        filters.push(function(row) {
            startTimes.push(Number(row[3]));
            return row;
        });

        var finish = function() {

            // calculate the intervals between arrivals (in seconds)
            var startOffsets = array_interval(startTimes).map(function(interval) {
                return interval / 1000;
            });

            var chiSquaredResults = performGoodnessOfFit(startOffsets, 25);
            console.log('N = ' + startOffsets.length);
            console.log("Chi-Squared Test : p = " + chiSquaredResults.probability + " chi^2 = " + chiSquaredResults.chiSquared);
            console.log(histogram(startOffsets, { }));

            taskDone();
        };

        csvFilter(filters, finish);
    };
};
