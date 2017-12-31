#!/bin/sh
set -e
case $( uname -m ) in
armv7l)
  REPO="angelnu/glusterfs-arm"
  BASE_IMAGE="armv7/armhf-ubuntu"
  ;;
x86_64)
  REPO="angelnu/glusterfs-amd64"
  IMAGE="ubuntu"
  ;;
*)
  echo "Unknown arch $( uname -p )"
  exit 1
  ;;
esac
docker build --no-cache --build-arg IMAGE=$IMAGE -t $REPO .
docker push $REPO
