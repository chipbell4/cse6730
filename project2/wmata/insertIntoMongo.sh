#!/bin/bash

fileToInsert="$1"

if [ -z "$fileToInsert" ]; then
    echo "Missing a file!"
    exit 1
fi

# convert the json by appending the timestamp of the file on first
timestamp=`echo $fileToInsert | cut -d'.' -f1`
cat $fileToInsert | python appendTimestamp.py $timestamp > documents.json

# now append into mongo
mongoimport --db metro --collection trains < documents.json

# cleanup
rm document.json
