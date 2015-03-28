#!/bin/bash

set -e

#########################################
# Skips the first $1 lines passed to it #
#########################################
skip() {
    # skip the lines, if we actually have some to skip
    if [ "$1" -ne "0" ]; then
        for i in $(seq 1 $1); do
            read line
        done
    fi

    # just echo the rest
    while read line; do
        echo $line
    done
}

#######################################################################
# Gets a trains endpoint by color $1, and direction $2 (East or West) #
#######################################################################
get_train_endpoint() {
    cat ../../data/endpoints.csv | grep $1 | grep $2 | cut -d',' -f1
}

########################################
# Gets the station for the $1-th train #
########################################
get_station_by_index() {
    cat ../../data/stations.csv | skip $1 | head -n1
}

#############################################
# Gets the station code for the $1-th train #
#############################################
get_station_code_by_index() {
    get_station_by_index $1 | cut -d',' -f1
}

##############################################
# Gets a file friendly station name by index #
##############################################
get_station_name_by_index() {
    get_station_by_index $1 | cut -d',' -f2 | sed "s/ /_/g" | sed "s/\'//g" | tr "[:upper:]" "[:lower:]"
}

station_count=`cat ../../data/stations.csv | wc -l | tr -d "[:blank:]"`
track_section_count=`expr "$station_count" - 1`

# for all stations
for station_index in $(seq 0 $(($track_section_count-1))); do
    next_station_index=`expr "$station_index" + 1`
    east_station=`get_station_name_by_index $station_index`
    west_station=`get_station_name_by_index $next_station_index`

    # for all colors
    for line in BL SV OR; do
        west_destination=`get_train_endpoint West $line`
        # build the westbound properties file
        westbound_file="${west_station}_west_${line}.properties"
        echo $westbound_file
        touch $westbound_file
        echo "Line=$line" >> $westbound_file
        echo "DepartingStation=$east_station" >> $westbound_file
        echo "ArrivingStation=$west_station" >> $westbound_file
        echo "DestinationCode=$west_destination" >> $westbound_file
        
        east_destination=`get_train_endpoint East $line`
        # build the westbound properties file
        eastbound_file="${west_station}_east_${line}.properties"
        echo $eastbound_file
        touch $eastbound_file
        echo "Line=$line" >> $eastbound_file
        echo "DepartingStation=$west_station" >> $eastbound_file
        echo "ArrivingStation=$east_station" >> $eastbound_file
        echo "DestinationCode=$east_destination" >> $eastbound_file
    done
done
