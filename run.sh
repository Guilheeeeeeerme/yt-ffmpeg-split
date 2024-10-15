#!/bin/sh

# get a variable LINK_YOUTUBE, default is https://www.youtube.com/watch?v=MbLirwiFe9I
LINK_YOUTUBE=${LINK_YOUTUBE:-https://www.youtube.com/watch?v=MbLirwiFe9I}

# get a variable NOISE, default is -20dB
NOISE=${NOISE:--20dB}

# get a variable NOISE_D, default is 0.5
NOISE_D=${NOISE_D:-0.5}

yt-dlp -f mp4 $LINK_YOUTUBE

mkdir -p /data
mkdir -p /data/parts

cp *.mp4 data/input.mp4

ffmpeg -i input.mp4 -af silencedetect=noise=$NOISE:d=$NOISE_D -f null - 2> vol.txt

echo '#!/bin/sh' > out.sh
echo 'myffmpeg() {'  >> out.sh
echo '    THRESHOLD=0.25'>> out.sh
echo '    VAR1=`awk "BEGIN{ print \$1 - \$THRESHOLD }"`'>> out.sh
echo '    VAR2=`awk "BEGIN{ print \$2 + \$THRESHOLD }"`'>> out.sh
echo "    ffmpeg -ss \$VAR1 -t \$VAR2 -i input.mp4 fragment_\$VAR1.mp4"  >> out.sh
echo "    mv fragment_* data/parts/" >> out.sh

echo '}'  >> out.sh

echo 'mkdir -p data/parts'>> out.sh
echo "rm -f data/parts/*" >> out.sh
echo "silence_end=0" >> out.sh
cat vol.txt | grep 'silence_' >> out.sh

sed -i 's/silence_/\nsilence_/g' out.sh
sed -i 's/ |//g' out.sh
sed -i 's/: /=/g' out.sh
sed -i 's/\[silencedetect.*//g' out.sh 
sed -i 's/silence_start.*/\0\nsong_duration=`awk "BEGIN{ print \$silence_start - \$silence_end }"`\nmyffmpeg $silence_end $song_duration/g' out.sh 

echo 'song_duration=`awk "BEGIN{ print $silence_start - $silence_end }"`\nmyffmpeg $silence_end $song_duration' >> out.sh

chmod +x out.sh
sh out.sh