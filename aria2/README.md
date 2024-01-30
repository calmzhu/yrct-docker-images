# aria2 with rpc enabled

```
docker run -it  -eARIA2_RPC_SECRET=123456 -p 6800:6800 -v /download:/mnt/download yrct/aria2 --conf-path=/root/aria2.conf
```
