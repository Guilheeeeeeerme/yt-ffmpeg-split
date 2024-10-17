#!/bin/sh

# get first argument as start_at
start_at=$1

# get second argument as end_at
end_at=$2

# get the third as folder
folder=$3

# start_threshold it the 4th paramenter, default if 0.25
if [ -z "$4" ]; then
    start_threshold=0.25
else
    start_threshold=$4
fi

# end_threshold is the 5th parameter, default is 0.25
if [ -z "$5" ]; then
    end_threshold=0.25
else
    end_threshold=$5
fi

echo "Splitting video at $start_at with end_at $end_at, start_threshold $start_threshold, end_threshold $end_threshold"

VAR1=`awk "BEGIN{ print \$start_at - \$start_threshold }"`
VAR2=`awk "BEGIN{ print \$end_at + \$end_threshold }"`
ffmpeg -ss $VAR1 -to $VAR2 -i data/input.mp4 fragment_$VAR1.mp4
mv fragment_* $folder

