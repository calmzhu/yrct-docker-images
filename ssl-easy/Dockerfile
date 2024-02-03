FROM registry.cn-shanghai.aliyuncs.com/yrct-mirror/certbot:v2.8.0

WORKDIR /tmp
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

ADD hooks /hooks
