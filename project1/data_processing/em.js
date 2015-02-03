/**
 * Finds the likelihood for a given pdf, x value, and parameter list
 *
 * @param pdf        The pdf function to use
 * @param x          The x value
 * @param parameters The PDF parameters
 */
var likelihood = function(pdf, x, parameters) {
    // copy the array
    var pdfParameters = parameters.slice();

    // push x on the front
    pdfParameters.unshift(x);

    // call the pdf
    return pdf.apply(pdf, pdfParameters);
};

/**
 * Chooses the most likely distribution that the given x belongs to
 *
 * @param pdf           The pdf function to use
 * @param x             The x value to test
 * @param parameterList The list of parameters to try
 */
var mostLiklyDistribution = function(pdf, x, parameterList) {
    var N = parameterList.length;
    var greatestLikelihood = -1;
    var greatestLikelihoodIndex = 0;

    for(var i = 0; i < N; i++) {
        var currentLikelihood = likelihood(pdf, x, parameterList[i]);

        if(currentLikelihood > greatestLikelihood) {
            greatestLikelihood = currentLikelihood;
            greatestLikelihoodIndex = i;
        }
    }

    return greatestLikelihoodIndex;
};

/**
 * Performs distribution assignment, given a pdf, set of x values, and parameter list
 *
 * @param pdf           The pdf to use
 * @param xList         A list of x values to assign
 * @param parameterList A list of parameters for the mixture model distribution
 */
var assignToDistribution = function(pdf, xList, parameterList) {
    var distributionCount = parameterList.length;
    var i;

    // initialize assignments
    var assignments = [];
    for(i = 0; i < distributionCount; i++) {
        assignments.push([]);
    }

    // now loop over each x and assign accordingly
    var xCount = xList.length;
    for(i = 0; i < xCount; i++) {
        var index = mostLiklyDistribution(pdf, xList[i], parameterList);
        assignments[index].push(xList[i]);
    }

    return assignments;
};

/**
 * Refits data to a distribution for each assignment in the list
 *
 * @param fitFunction The function to use for fitting the data
 * @param assignments The list of current assignments
 */
var refitData = function(fitFunction, assignments) {
    var distributionCount = assignments.length;
    var parameterList = [];

    for(var i = 0; i < distributionCount; i++) {
        parameterList.push(fitFunction(assignments[i]));
    }

    return parameterList;
};

/**
 * Performs expectation minimization for a given PDF mixture model
 *
 * @param pdf               A PDF function for the distribution to maximize. Assumes the first argument is x, and the rest are
 *                          parameters
 * @param fitData           A function that returns the MLE estimators for a given set of data (an array)
 * @param initialParameters An array of arrays. Each internal array is a list of parameters to initialize with. This is
 *                          also how the al
 * @param xList             The list of data to fit
 */
module.exports = function(pdf, fitData, initialParameters) {
    var maxSteps = 1000;

    var assignments;
    var parameterList = initialParameters;

    for(var step = 0; step < maxSteps; step++) {
        assignments = assignToDistribution(pdf, xList, parameterList);
        parameterList = refitData(fitData, assignments);
    }

    return {
        assignments: assignments,
        parameterList: parameterList
    };
};
