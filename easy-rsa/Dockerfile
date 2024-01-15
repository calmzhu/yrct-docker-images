FROM alpine:3.19
ARG EASY_RSA_VERSION

RUN apk add --no-cache openssl

ADD https://github.com/OpenVPN/easy-rsa/releases/download/v${EASY_RSA_VERSION}/EasyRSA-${EASY_RSA_VERSION}.tgz /
RUN <<EOF
cd /
tar -xzf /EasyRSA-${EASY_RSA_VERSION}.tgz
rm -rf /EasyRSA-${EASY_RSA_VERSION}.tgz
EOF
WORKDIR /EasyRSA-${EASY_RSA_VERSION}
