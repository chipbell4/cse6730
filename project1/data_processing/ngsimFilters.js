/**
 * Basic function for building a filter for a given row on a certain column
 */
var filterFactory = function(columnIndex, value) {
    return function(row) {
        if(row[columnIndex] != value) {
            return;
        }

        return row;
    };
};

/**
 * Factory for building a filter for direction
 */
var filterDirection = function(direction) {
    return filterFactory(18, direction); // 18 is direction
};

filterDirection.EAST = '1';
filterDirection.NORTH = '2';
filterDirection.WEST = '3';
filterDirection.SOUTH = '4';

/**
 * Filters by intersection
 */
var filterIntersection = function(intersection) {
    return filterFactory(16, intersection);
};

// TODO: Name the intersections, so users have something to work with

module.exports = {
    direction: filterDirection,
    intersection: filterIntersection,
    factory: filterFactory
};
