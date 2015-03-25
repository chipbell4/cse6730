#!/bin/bash

# For train frequencies, we want interarrival times, so we do running diffs
for file in `ls train_frequencies/*.csv`; do
    parameter_set_name=`basename $file | sed 's/.csv//g'`
    cat $file | ../utils/running_difference > ${parameter_set_name}_diffs.csv
done

# bundle them up
tar czvf train_frequencies.tgz *_diffs.csv
rm *_diffs.csv
