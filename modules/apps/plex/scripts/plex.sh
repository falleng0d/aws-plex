#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

until [[ $(which aptdcon) ]]; do echo 'Waiting for aptdcon installation...'; sleep 5; done

curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
aptdcon --add-repository "deb https://downloads.plex.tv/repo/deb public main"

aptdcon --refresh

yes | aptdcon --hide-terminal --install plexmediaserver
