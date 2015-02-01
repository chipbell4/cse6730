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
//

/**
 * Factory for a filter that only keeps the first occurrence of car
 */
var keepFirst = function() {
    var seenCars = {};
    var firstTracker = function(row) {
        var car_id = row[0];

        // if we've seen the car skip it
        if(seenCars[car_id]) {
            return null;
        }

        seenCars[car_id] = true;
        return row;
    };

    return firstTracker;
};

module.exports = {
    direction: filterDirection,
    intersection: filterIntersection,
    firstKeeper: keepFirst,
    factory: filterFactory
};
