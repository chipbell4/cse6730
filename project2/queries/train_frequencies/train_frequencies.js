var query = {
    Min: '1',
    Line: '${Line}',
    LocationCode: '${LocationCode}',
    DestinationCode: '${DestinationCode}',
    timestamp: { $gt: 1426496399 } // After monday
};
db.trains.find(query, { timestamp: true }).sort({ timestamp: 1 }).forEach(function(train) {
    print(train.timestamp);
});
