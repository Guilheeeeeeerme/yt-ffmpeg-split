FROM jauderho/yt-dlp:2024.10.07

WORKDIR /app

COPY run.sh run.sh
COPY template.sh template.sh

# install ffmpeg
RUN apk add --no-cache ffmpeg

RUN chmod +x run.sh
ENTRYPOINT [ "sh", "./run.sh" ]
