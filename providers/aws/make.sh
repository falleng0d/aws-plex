#!/bin/bash
COMMAND=$1
INSTANCE=$2
ARG=$3

case $COMMAND in
  init)
    cp ./.ssh/id_rsa ~/.ssh/plex_id_rsa
    cp ./.ssh/id_rsa.pub ~/.ssh/plex_id_rsa.pub
    chmod 600 ~/.ssh/plex_id_rsa*
  ;;

  connect)
    echo ssh -i ~/.ssh/plex_id_rsa -t "ubuntu@$INSTANCE"
    ssh -i ~/.ssh/plex_id_rsa -t "ubuntu@$INSTANCE"
	;;

  top)
    ssh -i ~/.ssh/plex_id_rsa -t "ubuntu@$INSTANCE" 'top'
  ;;
esac
