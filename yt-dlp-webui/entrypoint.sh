#!/bin/sh
#

if [[ "$1" == "/bin/sh" ]];then
    /bin/sh
else
    [[ -z "$WEBUI_USERNAME" ]] && echo "Error: WEBUI_USERNAME not set" && exit 1
    [[ -z "$WEBUI_PASSWORD" ]] && echo "Error: WEBUI_PASSWORD not set" && exit 1
    sed -i "s/REPLACE_WITH_USERNAME/$WEBUI_USERNAME/" /app/config.yml
    sed -i "s/REPLACE_WITH_PASSWORD/$WEBUI_PASSWORD/" /app/config.yml
     "./yt-dlp-webui" --db /mnt/download/.yt-dlp-webui.db --port 3033
fi
