#!/bin/bash

set -e

# Include the template script
my_dir=$(dirname $0)
. $my_dir/template.sh

######################################################################################################
# Runs all queries within a particular directory, assuming the query's name is the directory as well #
######################################################################################################
query() {
    # $1 Is the query folder/query name
    query_file=$1/$1.js

    for property_file in `ls $1/*.properties`; do
        echo "Running $1 with $property_file"
        output_file=`echo $property_file | sed 's/properties$/csv/g'`
        template $query_file $property_file | mongo metro > $output_file
    done
}

query train_frequencies
