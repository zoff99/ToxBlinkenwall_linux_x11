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


# change to what your local system is
system_to_build_for="ubuntu:18.04"

cd $_HOME_/
docker run -ti --rm \
  -v $_HOME_/artefacts:/artefacts \
  -v $_HOME_/script:/script \
  -v $_HOME_/workspace:/workspace \
  --net=host \
  "$system_to_build_for" \
  /bin/bash \
  /script/do_it_systemlibs.sh docker


