FROM marcobaobao/yt-dlp-webui

RUN apk add --no-cache aria2
ADD entrypoint.sh /entrypoint.sh
ADD config.yml /app/config.yml
EXPOSE 3033
VOLUME /mnt/download

ENTRYPOINT ["/entrypoint.sh"]
