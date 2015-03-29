var departingStation = {
    Line: "${Line}",
    LocationCode: "${DepartingStation}",
    DestinationCode: "${DestinationCode}",
    Min: "1"
};

var arrivingStation = {
    Line: "${Line}",
    LocationCode: "${ArrivingStation}",
    DestinationCode: "${DestinationCode}"
};

db.trains.find(departingStation).forEach(function(localTrain) {
    arrivingStation.timestamp = localTrain.timestamp;
    var neighborTrain = db.trains.find(arrivingStation)[0];
    print(parseInt(neighborTrain.Min) - 1);
});
