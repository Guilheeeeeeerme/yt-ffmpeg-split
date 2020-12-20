# RUN ffmpeg -ss <silence_end - 0.25> -t <next_silence_start - silence_end + 2 * 0.25> -i input.mov word-N.mov
# RUN ffmpeg -i "input.mov" -af silencedetect=noise=-30dB:d=0.5 -f null - 2> vol.txt

FROM kmb32123/youtube-dl-server as downloader
ARG LINK_YOUTUBE

WORKDIR /app/
RUN youtube-dl -f mp4 $LINK_YOUTUBE

FROM jrottenberg/ffmpeg
ARG NOISE
ARG NOISE_D

WORKDIR /app/
COPY --from=downloader /app/*.mp4 .
RUN mv *.mp4 input.mp4

RUN mkdir -p data
# RUN ffmpeg -i "input.mp4" -af silencedetect=noise=-30dB:d=0.5 -f null - 2> data/vol.txt
RUN ffmpeg -i "input.mp4" -af silencedetect=noise=$NOISE:d=$NOISE_D -f null - 2> data/vol.txt

RUN touch out.sh
RUN echo 'myffmpeg() {'  >> out.sh
RUN echo '    THRESHOLD=0.25'>> out.sh
RUN echo '    VAR1=`awk "BEGIN{ print \$1 - \$THRESHOLD }"`'>> out.sh
RUN echo '    VAR2=`awk "BEGIN{ print \$2 + \$THRESHOLD }"`'>> out.sh
RUN echo "    ffmpeg -ss \$VAR1 -t \$VAR2 -i input.mp4 fragment_\$VAR1.mp4"  >> out.sh
# RUN echo "    ffmpeg -ss \$var1 -t \$var2 -i input.mp4 fragment_\$var1.mp4"  >> out.sh
# RUN echo "    ffmpeg -ss \$1 -t \$2 -i input.mp4 fragment_\$1.mp4"  >> out.sh
RUN echo '}'  >> out.sh

RUN echo "silence_end=0" >> out.sh
RUN cat data/vol.txt | grep 'silence_' >> out.sh

RUN sed -i 's/silence_/\nsilence_/g' out.sh
RUN sed -i 's/ |//g' out.sh
RUN sed -i 's/: /=/g' out.sh
RUN sed -i 's/\[silencedetect.*//g' out.sh 
RUN sed -i 's/silence_start.*/\0\nsong_duration=`awk "BEGIN{ print \$silence_start - \$silence_end }"`\nmyffmpeg $silence_end $song_duration/g' out.sh 

RUN echo 'song_duration=`awk "BEGIN{ print $silence_start - $silence_end }"`\nmyffmpeg $silence_end $song_duration' >> out.sh
RUN echo "rm -f data/*" >> out.sh
RUN echo "mv fragment_* data/" >> out.sh

RUN chmod +x out.sh

# ENTRYPOINT [ "cat", "out.sh" ]
ENTRYPOINT [ "sh", "out.sh" ]

# COPY silencedetect.sh silencedetect.sh

# RUN cat silencedetect.sh > entrypoint.sh
# RUN chmod +x entrypoint.sh

# ENTRYPOINT [ "sh", "entrypoint.sh" ]
