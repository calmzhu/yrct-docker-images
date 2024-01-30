#!/bin/sh
#

if [[ "$1" == "/bin/sh" ]];then
    /bin/sh
else
    [[ -z "$ARIA2_RPC_SECRET" ]] && echo "Error: no ARIA2_RPC_SECRET set" && exit 1
    [[ -e /mnt/download/.aria2_session ]] || touch /mnt/download/.aria2_session
    sed -i "s/REPLACE_WITH_RPC_SECRET/$ARIA2_RPC_SECRET/" /root/aria2.conf
    aria2c $*
fi
