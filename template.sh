#!/bin/sh

mkdir -p data/parts
rm -f data/parts/*

myffmpeg() {
    THRESHOLD=0.25
    VAR1=`awk "BEGIN{ print \$1 - \$THRESHOLD }"`
    VAR2=`awk "BEGIN{ print \$2 + \$THRESHOLD }"`
    ffmpeg -ss $VAR1 -t $VAR2 -i input.mp4 fragment_$VAR1.mp4
    mv fragment_* data/parts/
}

silence_end=0

