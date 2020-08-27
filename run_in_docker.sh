#! /bin/bash

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

echo $_HOME_
cd $_HOME_

# docker info

mkdir -p $_HOME_/artefacts
mkdir -p $_HOME_/script
mkdir -p $_HOME_/workspace
cat "$_HOME_"/do_it_systemlibs.sh > $_HOME_/script/do_it_systemlibs.sh
chmod a+rx $_HOME_/script/do_it_systemlibs.sh


# change to the type of your local linux system:
# system_to_build_for="ubuntu:20.04"
system_to_build_for="ubuntu:18.04"
# system_to_build_for="ubuntu:16.04"
# system_to_build_for="debian:10"
# system_to_build_for="debian:9"
# system_to_build_for="alpine:3.12.0"
# system_to_build_for="archlinux:20200605"
# system_to_build_for="gentoo/stage3-amd64:latest"

cd $_HOME_/
docker run -ti --rm \
  -v $_HOME_/artefacts:/artefacts \
  -v $_HOME_/script:/script \
  -v $_HOME_/workspace:/workspace \
  -e DISPLAY=${DISPLAY} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device=/dev/video0:/dev/video0 \
  --net=host \
  "$system_to_build_for" \
  /bin/sh -c "apk add bash 2>/dev/null; /bin/bash /script/do_it_systemlibs.sh docker run"


