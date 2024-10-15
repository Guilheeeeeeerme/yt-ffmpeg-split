#!/bin/sh

mkdir -p data
cat template.sh > data/main.sh

# Check if the file data/input.mp4 does not exist
if [ ! -f data/input.mp4 ]; then
    # Ensure LINK_YOUTUBE is set, otherwise throw an error
    if [ -z "$LINK_YOUTUBE" ]; then
        echo "Error: LINK_YOUTUBE is not set"
        exit 1
    fi
    # Download the video from the provided YouTube link
    yt-dlp -f mp4 "$LINK_YOUTUBE" -o data/input.mp4
fi

# get a variable NOISE, default is -20dB
NOISE=${NOISE:--20dB}

# get a variable NOISE_D, default is 0.5
NOISE_D=${NOISE_D:-0.5}

ffmpeg -i data/input.mp4 -af silencedetect=noise=$NOISE:d=$NOISE_D -f null - 2> data/vol.txt
cat data/vol.txt | grep 'silence_' >> data/main.sh

sed -i 's/silence_/\nsilence_/g' data/main.sh
sed -i 's/ |//g' data/main.sh
sed -i 's/: /=/g' data/main.sh
sed -i 's/\[silencedetect.*//g' data/main.sh 
sed -i 's/silence_start.*/\0\nsong_duration=`awk "BEGIN{ print \$silence_start - \$silence_end }"`\nmyffmpeg $silence_end $song_duration/g' data/main.sh 
echo 'song_duration=`awk "BEGIN{ print $silence_start - $silence_end }"`' >> data/main.sh
echo 'myffmpeg $silence_end $song_duration' >> data/main.sh

chmod +x data/main.sh
sh data/main.sh