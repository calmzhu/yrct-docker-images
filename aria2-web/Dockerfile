FROM nginx:stable-alpine as builder

RUN apk add yq
WORKDIR /tmp

RUN <<-EOF
version=`curl -s https://api.github.com/repos/mayswind/ariang/releases/latest | yq .tag_name`
wget "https://github.com/mayswind/AriaNg/releases/download/${version}/AriaNg-${version}.zip"
unzip AriaNg-${version}.zip
rm -f AriaNg-${version}.zip
EOF


FROM nginx:stable-alpine
RUN apk add --no-cache aria2
COPY --from=builder /tmp /html
ADD default.conf /etc/nginx/conf.d/default.conf
