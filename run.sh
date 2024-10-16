#!/bin/sh

mkdir -p data

# Ensure LINK_YOUTUBE is set, otherwise throw an error
if [ -z "$LINK_YOUTUBE" ]; then
    echo "Error: LINK_YOUTUBE is not set"
    exit 1
fi
# Download the video from the provided YouTube link
yt-dlp -f mp4 "$LINK_YOUTUBE" -o data/input.mp4

# get a variable NOISE, default is -20dB
NOISE=${NOISE:--20dB}

# get a variable NOISE_D, default is 0.5
NOISE_D=${NOISE_D:-0.5}

ffmpeg -i data/input.mp4 -af silencedetect=noise=$NOISE:d=$NOISE_D -f null - 2> data/vol.txt


noise_duration=0  # Initialize noise_duration

while IFS= read -r line; do
  if echo "$line" | grep -q "silence_start:"; then
    silence_start=$(echo "$line" | awk '{print $NF}')
    # noise_duration is last silence_end (if it exists) minus current silence_start
    if [ -n "$silence_end" ]; then
      noise_duration=$(awk "BEGIN{ print $silence_start - $silence_end }")
    fi
  elif echo "$line" | grep -q "silence_end:"; then
    silence_end=$(echo "$line" | awk '{print $NF}' | tr -d '|')
    # if noise_duration is greater than 0, run split.sh
    [ $(echo "$noise_duration > 0" | bc) -eq 1 ] && sh split.sh $silence_end $noise_duration data/parts
  fi
done < "data/vol.txt"