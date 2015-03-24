#!/bin/bash

set -e

# Include the template script
my_dir=$(dirname $0)
. $my_dir/template.sh

template template.txt test.properties
