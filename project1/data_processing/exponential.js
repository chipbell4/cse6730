/**
 * The exponential distribution
 */
module.exports = {
    pdf: function(x, lambda) {
        return lambda * Math.exp(-lambda * x);
    },
    cdf: function(x, lambda) {
        return 1 - Math.exp(-lambda * x);
    }
};
