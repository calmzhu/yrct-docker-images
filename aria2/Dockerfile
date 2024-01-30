FROM alpine:3.19

RUN apk add aria2

VOLUME "/mnt/download"
expose 6800
ADD entrypoint.sh /entrypoint.sh
ADD aria2.conf /root/aria2.conf

ENTRYPOINT ["/entrypoint.sh"]
