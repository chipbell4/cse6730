module.exports = function(items) {
    // first sort the items numerically
    items.sort(function(a, b) {
        return Number(a) - Number(b);
    });

    // now build the offsets list
    var N = items.length;
    var offsets = [];
    for(var i = 1; i < N; i++) {
        offsets.push( items[i] - items[i-1] );
    }

    return offsets;
};
