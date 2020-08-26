#! /bin/bash


_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_


echo $_HOME_
cd $_HOME_
mkdir -p build

export _SRC_=$_HOME_/build/
export _INST_=$_HOME_/inst/

echo $_SRC_
echo $_INST_

mkdir -p $_SRC_
mkdir -p $_INST_
mkdir -p $_HOME_/run/

export LD_LIBRARY_PATH=$_INST_/lib/
export PKG_CONFIG_PATH=$_INST_/lib/pkgconfig


if [ "$1""x" == "dockerx" ]; then

    echo "============ docker build ============"
    echo "============ docker build ============"
    echo "============ docker build ============"

    quiet_=1

    export qqq=""
    if [ "$quiet_""x" == "1x" ]; then
        export qqq=" -qq "
    fi

    redirect_cmd() {
        if [ "$quiet_""x" == "1x" ]; then
            "$@" > /dev/null 2>&1
        else
            "$@"
        fi
    }

    echo "installing system packages ..."

    redirect_cmd apt-get update $qqq

    redirect_cmd apt-get install $qqq -y --force-yes lsb-release
    system__=$(lsb_release -i|cut -d ':' -f2|sed -e 's#\s##g')
    version__=$(lsb_release -r|cut -d ':' -f2|sed -e 's#\s##g')
    echo "compiling on: $system__ $version__"

    pkgs_name="pkgs_"$(echo "$system__"|tr '.' '_')"_"$(echo $version__|tr '.' '_')
    echo "PKG:-->""$pkgs_name""<--"

    echo "installing more system packages ..."

    # ------ specific for Ubuntu_18_04 ------
    pkgs_Ubuntu_18_04='
        unzip
        zip
        automake
        autotools-dev
        build-essential
        check
        checkinstall
        libtool
        pkg-config
        rsync
        git
        libx11-dev
        x11-common
        x11-utils
        ffmpeg
        libasound2-dev
        libv4l-dev
        v4l-conf
        v4l-utils
        libavcodec-dev
        libavdevice-dev
        libsodium-dev
        libvpx-dev
        libopus-dev
        libx264-dev
    '
    # ------ specific for Ubuntu_18_04 ------

    # ------ specific for Ubuntu_16_04 ------
    pkgs_Ubuntu_16_04='
        software-properties-common
        :c:add-apt-repository\sppa:jonathonf/ffmpeg-4\s-y
        :u:
        ffmpeg
        unzip
        zip
        automake
        autotools-dev
        build-essential
        check
        checkinstall
        libtool
        pkg-config
        rsync
        git
        libx11-dev
        x11-common
        x11-utils
        libasound2-dev
        libv4l-dev
        v4l-conf
        v4l-utils
        libavcodec-dev
        libavdevice-dev
        libsodium-dev
        libvpx-dev
        libopus-dev
        libx264-dev
    '
    # ------ specific for Ubuntu_16_04 ------

    for i in ${!pkgs_name} ; do
        if [[ ${i:0:3} == ":u:" ]]; then
            echo "apt-get update"
            redirect_cmd apt-get update $qqq
        elif [[ ${i:0:3} == ":c:" ]]; then
            cmd=$(echo "${i:3}"|sed -e 's#\\s# #g')
            echo "$cmd"
            $cmd
        else
            echo "apt-get install -y --force-yes ""$i"
            redirect_cmd apt-get install $qqq -y --force-yes $i
        fi
    done
fi


# build toxcore -------------
cd $_SRC_
rm -Rf ./c-toxcore/
git clone https://github.com/zoff99/c-toxcore
cd c-toxcore/
git checkout "zoff99/zoxcore_local_fork"
git pull

export CFLAGS=" -DMIN_LOGGER_LEVEL=LOGGER_LEVEL_INFO -D_GNU_SOURCE -g -O3 -I$_INST_/include/ -fPIC -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable "
export LDFLAGS=" -O3 -L$_INST_/lib -fPIC "
./autogen.sh
./configure \
  --prefix=$_INST_ \
  --disable-soname-versions --disable-testing --enable-logging --disable-shared

make -j $(nproc) || exit 1
make install

# build tbw for linux X11 -------------

cd $_SRC_
git clone https://github.com/zoff99/ToxBlinkenwall
cd ToxBlinkenwall/
git checkout master
git checkout toxblinkenwall/toxblinkenwall.c
git pull


cd toxblinkenwall/

## configure for linux X11 ------------
sed -i -e 'sx^.*define HAVE_OUTPUT_OMX.*$x#define HAVE_FRAMEBUFFER 1x' toxblinkenwall.c
sed -i -e 'sx^.*// #define HAVE_X11_AS_FB 1.*$x#define HAVE_X11_AS_FB 1x' toxblinkenwall.c
cat toxblinkenwall.c |grep 'define HAVE_FRAMEBUFFER'
cat toxblinkenwall.c |grep 'define HAVE_X11_AS_FB'
## configure for linux X11 ------------


_OO_=" $C_FLAGS $CXX_FLAGS $LD_FLAGS "

gcc $_OO_ \
-Wno-unused-variable \
-fPIC -I$_HOME_/inst/include -o toxblinkenwall -lm \
toxblinkenwall.c rb.c \
-std=gnu99 \
-L$_HOME_/inst/lib/ \
$_HOME_/inst/lib/libtoxcore.a \
$_HOME_/inst/lib/libtoxav.a \
-lrt \
-lm \
-lX11 \
-lopus \
-lvpx \
-lx264 \
-lavcodec \
-lavutil \
-lswresample \
-lswscale \
-lsodium \
-lasound \
-lpthread -lv4lconvert \
-ldl || exit 1

ldd toxblinkenwall || exit 1
ls -hal toxblinkenwall

if [ "$1""x" == "dockerx" ]; then
    cp -av toxblinkenwall /artefacts/
    chmod -R u+rw /artefacts/
else
    cp -av toxblinkenwall $_HOME_/run/
    chmod u+rx $_HOME_/run/toxblinkenwall
    cd $_HOME_/
fi


