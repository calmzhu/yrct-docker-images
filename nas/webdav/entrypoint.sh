#!/bin/sh
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
#
#

htpasswd -bc /etc/nginx/htpasswd $USERNAME $PASSWORD
chown -R nginx /www
nginx -t

nginx -g "daemon off;"
