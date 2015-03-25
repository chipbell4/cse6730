var query = {
    Min: '1',
    Line: '${Line}',
    LocationCode: '${LocationCode}',
    DestinationCode: '${DestinationCode}'
};
db.trains.find(query, { timestamp: true }).sort({ timestamp: 1 }).forEach(function(train) {
    print("#{train.timestamp}");
});
