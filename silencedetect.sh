
ffmpeg -i input.mp3 -af silencedetect=noise=$NOISE:d=$NOISE_D -f null - 2> data/vol.txt
# ffmpeg -ss <silence_end - 0.25> -t <next_silence_start - silence_end + 2 * 0.25> -i input.mov word-N.mov