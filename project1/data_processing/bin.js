/**
 * Helper class for binning a list of items (a frequency distribution calculator)
 */
var Bin = function(items, binCount) {
    this.rawItems = items;
    this.binCount = binCount || 25;

    // Initialize bins
    this.bins = [];
    for(var i = 0; i < this.binCount; i++) {
        this.bins.push([]);
    }

    var N = items.length;
    this.maxValue = Math.max.apply(Math, items) * 1.05;
    this.minValue = Math.min.apply(Math, items);
    this.binWidth = (this.maxValue - this.minValue ) / this.binCount;
    var that = this;
    items.forEach(function(item) {
        var binIndex = that.whichBin(item, that.minValue, that.binWidth);
        that.bins[binIndex].push(item);
    });
};

/**
 * Returns the bin index that a value would fall into
 */
Bin.prototype.whichBin = function(value) {
    return Math.floor((value - this.minValue) / this.binWidth);
};

/**
 * Determines a "pretty name" for a bin
 */
Bin.prototype.binName = function(index) {
    var min = index * this.binWidth + this.minValue;
    var max = min + this.binWidth;
    return min.toPrecision(4) + "-" + max.toPrecision(4);
};

module.exports = Bin;
