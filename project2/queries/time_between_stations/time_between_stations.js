db.trains.find({ Line: "BL", LocationCode: "C02", DestinationCode: "G05", Min: "1" }).forEach(function(localTrain) {
    var neighborTrain = db.trains.find({ Line: "BL", LocationCode: "C01", DestinationCode: "G05", timestamp: train.timestamp })[0];
    print(parseInt(neighborTrain.Min) - 1);
});

