#!/bin/bash

# cron schedule (all the time): * * * * * *

output_dir="."
subscription_key="NOPE"

while getopts "h?o:?k:" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: ./pingApi.sh -k <API_KEY> [-o output_directory]"
        exit 0
        ;;
    o)
        output_dir=$OPTARG
        ;;
    k)
        subscription_key="$OPTARG"
        ;;
    esac
done

# format the current date+time
output_file=`date +"%s.json"`

# Hit the api, using my subscription key, and get ALL stations.
curl -X GET "https://api.wmata.com/StationPrediction.svc/json/GetPrediction/All?api_key=$subscription_key" > $output_dir/$output_file
