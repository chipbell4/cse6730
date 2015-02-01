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
 * Provides an easy way to hook into filtering the CSV file
 */
module.exports = function(filters, finishCode) {

    var filterCount = filters.length;

    var stream = getCsv();

    // tag on all of the filters
    for(var i = 0; i < filterCount; i++) {
        stream = stream.pipe(csv.transform(filters[i]));
    }

    // now add the end stream listener
    stream.on('finish', finishCode);

    return stream;
};
