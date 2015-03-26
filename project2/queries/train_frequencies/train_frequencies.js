var query = {
    Line: '${Line}',
    LocationCode: '${LocationCode}',
    DestinationCode: '${DestinationCode}',
    timestamp: { $gt: 1426496399 } // After monday
};
db.trains.find(query, { timestamp: true, Min: true }).forEach(function(train) {
    print(train.timestamp + ',' + train.Min);
});
