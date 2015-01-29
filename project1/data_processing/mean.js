module.exports = function(items) {
    return items.reduce(function(accumulator, item) {
        return accumulator + item;
    }, 0) / items.length;
};
