#!/bin/bash

set -e

# Include the template script
my_dir=$(dirname $0)
. $my_dir/template.sh

query() {
    # $1 is the template
    # $2 is the properties file

    template $1 $2 | mongo metro
}

query trainFrequencies/trainFrequencies.js trainFrequencies/westboundBlue.properties
