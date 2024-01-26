
'''bash


# put your openvpn config at dir /ovpn-conf (or other dir)

export conf_dir=/ovpn-conf

docker run -d --name ovpn \
    --cap-add=NET_ADMIN \
    -v $conf_dir:/ovpn \
    --device /dev/net/tun \
    --net host \
    --restart always \
    yrct/openvpn ovpn.conf
'''

