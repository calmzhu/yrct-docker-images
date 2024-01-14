FROM alpine:3.19 as builder
WORKDIR /build
RUN apk add g++ make bash unzip curl
ENTRYPOINT '/bin/bash'

FROM builder as bzip2-builder
RUN <<EOF
wget 'https://gitlab.com/bzip2/bzip2/-/archive/bzip2-1.0.8/bzip2-bzip2-1.0.8.zip'
unzip bzip2-bzip2-1.0.8.zip
cd bzip2-bzip2-1.0.8
make
EOF

FROM builder as pbzip2-builder
RUN <<EOF
apk add  g++ make bzip2-dev
wget 'https://launchpad.net/pbzip2/1.1/1.1.13/+download/pbzip2-1.1.13.tar.gz'
tar -xzf pbzip2-1.1.13.tar.gz
EOF
COPY  --from=bzip2-builder /build/bzip2-bzip2-1.0.8/libbz2.a /build/pbzip2-1.1.13/libbz2.a
RUN <<EOF
cd /build/pbzip2-1.1.13
make pbzip2-static
EOF

FROM builder as rclone-builder
RUN curl -s https://rclone.org/install.sh | bash

FROM alpine
RUN apk add  --no-cache libgcc libstdc++ openssl gpg tzdata

COPY --from=rclone-builder /usr/bin/rclone /usr/bin/rclone
COPY --from=pbzip2-builder /build/pbzip2-1.1.13/pbzip2 /usr/bin/pbzip2
ADD br-function.sh /etc/profile.d/br-function.sh
RUN <<EOF
ln -sf /usr/bin/pbzip2 /usr/bin/pbunzip2
ln -sf /usr/bin/pbzcat /usr/bin/pbzcat
EOF
ENV ENV="/etc/profile"
