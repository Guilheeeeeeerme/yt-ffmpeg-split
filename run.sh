#!/bin/sh

mkdir -p data
cat template.sh > data/main.sh
exit 1

# Check if the file input.mp4 does not exist
if [ ! -f input.mp4 ]; then
    # Ensure LINK_YOUTUBE is set, otherwise throw an error
    if [ -z "$LINK_YOUTUBE" ]; then
        echo "Error: LINK_YOUTUBE is not set"
        exit 1
    fi
    # Download the video from the provided YouTube link
    yt-dlp -f mp4 "$LINK_YOUTUBE" -o input.mp4
fi


# get a variable NOISE, default is -20dB
NOISE=${NOISE:--20dB}

# get a variable NOISE_D, default is 0.5
NOISE_D=${NOISE_D:-0.5}

ffmpeg -i input.mp4 -af silencedetect=noise=$NOISE:d=$NOISE_D -f null - 2> vol.txt

cat vol.txt | grep 'silence_' >> main.sh

sh finish-main.sh

chmod +x main.sh
sh main.sh