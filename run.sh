#!/bin/sh

# get a variable LINK_YOUTUBE as a url string, or throw an error
if [ -z "$LINK_YOUTUBE" ]; then
    echo "LINK_YOUTUBE is not set"
    exit 1
fi


# get a variable NOISE, default is -20dB
NOISE=${NOISE:--20dB}

# get a variable NOISE_D, default is 0.5
NOISE_D=${NOISE_D:-0.5}

yt-dlp -f mp4 $LINK_YOUTUBE

mkdir -p /data
mkdir -p /data/parts

mv *.mp4 data/input.mp4
ffmpeg -i data/input.mp4 -af silencedetect=noise=$NOISE:d=$NOISE_D -f null - 2> data/vol.txt

cat template.sh > data/out.sh
cat data/vol.txt | grep 'silence_' >> data/out.sh

sed -i 's/silence_/\nsilence_/g' data/out.sh
sed -i 's/ |//g' data/out.sh
sed -i 's/: /=/g' data/out.sh
sed -i 's/\[silencedetect.*//g' data/out.sh 
sed -i 's/silence_start.*/\0\nsong_duration=`awk "BEGIN{ print \$silence_start - \$silence_end }"`\nmyffmpeg $silence_end $song_duration/g' data/out.sh 
echo 'song_duration=`awk "BEGIN{ print $silence_start - $silence_end }"`\nmyffmpeg $silence_end $song_duration' >> data/out.sh

# cp *.sh data/

# chmod +x out.sh
# sh ./out.sh