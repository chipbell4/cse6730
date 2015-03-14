import sys, json

def appendTimestampToSingleTrain(train, timestamp):
    train['timestamp'] = timestamp
    return train

if len(sys.argv) is 1:
    sys.exit(1)

timestamp = int(sys.argv[1])

inputJson = sys.stdin.read().replace('\n', '')

inputJson = json.loads(inputJson)

trains = []
for train in inputJson['Trains']:
    trains.append(appendTimestampToSingleTrain(train, timestamp))

print(json.dumps(trains))
