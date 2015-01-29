var Bin = function(items, binCount) {
    this.rawItems = items;
    this.binCount = binCount || 25;

    // Initialize bins
    this.bins = [];
    for(var i = 0; i < this.binCount; i++) {
        this.bins.push([]);
    }

    var N = items.length;
    this.maxValue = Math.max.apply(Math, items);
    this.minValue = Math.min.apply(Math, items);
    this.binWidth = (this.maxValue - this.minValue ) / this.binCount;
    var that = this;
    items.forEach(function(item) {
        var binIndex = that.whichBin(item, that.minValue, that.binWidth);
        that.bins[binIndex].push(item);
    });
};

Bin.prototype.whichBin = function(value) {
    return Math.floor((value - this.minValue) / this.binWidth);
};

Bin.prototype.binName = function(index) {
    var min = index * this.binWidth + this.minValue;
    var max = min + this.binWidth;
    return min.toPrecision(4) + "-" + max.toPrecision(4);
};

module.exports = Bin;
