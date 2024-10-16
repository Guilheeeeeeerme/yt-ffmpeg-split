#!/bin/sh

# get first argument as start_at
start_at=$1

# get second argument as duration
duration=$2

# get the third as folder
folder=$3

THRESHOLD=0.25
VAR1=`awk "BEGIN{ print \$start_at - \$THRESHOLD }"`
VAR2=`awk "BEGIN{ print \$duration + \$THRESHOLD }"`
echo "ffmpeg -ss $VAR1 -t $VAR2 -i data/input.mp4 fragment_$VAR1.mp4"
ffmpeg -ss $VAR1 -t $VAR2 -i data/input.mp4 fragment_$VAR1.mp4
mv fragment_* $folder

