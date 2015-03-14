#!/bin/bash

fileToInsert="$1"

if [ -z "$fileToInsert" ]; then
    echo "Missing a file!"
    exit 1
fi

# convert the json by appending the timestamp of the file on first
timestamp=`echo $fileToInsert | cut -d'.' -f1`
document=`cat $fileToInsert | sed "s/^{/{\"timestamp\":$timestamp,/"`

# now append into mongo
echo "use metro; db.trains.insert($document);" | mongo
