FROM jauderho/yt-dlp:2024.10.07

WORKDIR /app

COPY *.sh .

# install ffmpeg
RUN apk add --no-cache ffmpeg

RUN chmod +x run.sh

ENTRYPOINT [ "sh", "run.sh" ]
