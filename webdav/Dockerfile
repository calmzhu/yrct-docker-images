FROM alpine:3


RUN apk add --no-cache nginx-mod-http-dav-ext apache2-utils nginx

VOLUME /www
EXPOSE 8000
COPY nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh
