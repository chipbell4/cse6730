#!/bin/bash

output_dir="$1"

if [ -z "$output_dir" ]; then
    output_dir="."
fi

# format the current date+time
output_file=`date +"%s.json"`

# pluck my subscription key, stripping newlines and things
subscription_key=`cat WMATA.txt`

# Hit the api, using my subscription key, and get ALL stations.
curl -X GET "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/All?api_key=$subscription_key" > $output_dir/$output_file
