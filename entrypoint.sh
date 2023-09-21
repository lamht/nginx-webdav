#!/bin/bash

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]
then
    apk add --no-cache apache2-utils
	htpasswd -bc /etc/nginx/htpasswd $USERNAME $PASSWORD
    apk del apache2-utils
	echo Set Webdav user done.
else
    echo Using no auth.
	sed -i 's%auth_basic "Restricted";% %g' /etc/nginx/nginx.conf
	sed -i 's%auth_basic_user_file htpasswd;% %g' /etc/nginx/nginx.conf
fi

if [ -n "$UID" ] && [ -n "$GID" ] && [ "$UID" -eq 1000 ] && [ "$GID" -eq 1000 ]; then
    echo "UID is 1000 and GID is 1000"
    id nginx
else
    apk add --no-cache shadow
    usermod --uid $UID nginx
    groupmod --gid $GID nginx
    apk del shadow
    id nginx
    echo "Update nginx user to UID $UID and GID $GID"
fi