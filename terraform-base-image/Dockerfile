FROM yrct/br:latest AS builder


FROM terraform/terraform:1.8
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories

RUN apk add --no-cache libgcc libstdc++ openssl gpg tzdata jq bash curl github-cli
RUN apk add yq --repository=http://mirrors.aliyun.com/alpine/edge/community --no-cache

COPY --from=builder /usr/bin/rclone /usr/bin/rclone
COPY --from=builder /usr/bin/pbzip2 /usr/bin/pbzip2
COPY --from=builder /etc/profile.d/br-function.sh /etc/profile.d/br-function.sh

RUN <<EOF
ln -sf /usr/bin/pbzip2 /usr/bin/pbunzip2
EOF
ENV ENV="/etc/profile"
ENTRYPOINT ["/bin/bash","-l"]
