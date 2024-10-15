
sed -i 's/silence_/\nsilence_/g' main.sh
sed -i 's/ |//g' main.sh
sed -i 's/: /=/g' main.sh
sed -i 's/\[silencedetect.*//g' main.sh 
sed -i 's/silence_start.*/\0\nsong_duration=`awk "BEGIN{ print \$silence_start - \$silence_end }"`\nmyffmpeg $silence_end $song_duration/g' main.sh 

echo 'song_duration=`awk "BEGIN{ print $silence_start - $silence_end }"`\nmyffmpeg $silence_end $song_duration' >> main.sh