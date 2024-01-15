FROM alpine:3.19
ARG VERSION
ARG PLATFORM=linux-amd64
WORKDIR /app

RUN <<EOF
set -eu
wget https://github.com/snail007/goproxy/releases/download/v${VERSION}/proxy-${PLATFORM}.tar.gz -O /tmp/proxy.tar.gz
tar -xf /tmp/proxy.tar.gz
rm -f /tmp/proxty.tar.gz
EOF

ENTRYPOINT ["/app/proxy"]