FROM alpine:3.19
ARG EASY_RSA_VERSION="3.1.7"

RUN apk add --no-cache openssl

ADD https://github.com/OpenVPN/easy-rsa/releases/download/v${EASY_RSA_VERSION}/EasyRSA-${EASY_RSA_VERSION}.tgz /
WORKDIR /EasyRSA-${EASY_RSA_VERSION}