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

    # echo "installing system packages ..."

    export DEBIAN_FRONTEND=noninteractive

    # cat /etc/os-release

    os_release=$(cat /etc/os-release 2>/dev/null|grep 'PRETTY_NAME=' 2>/dev/null|cut -d'=' -f2)
    if [ "$os_release""x" != "x" ] ;then
        echo "using /etc/os-release"
        system__=$(cat /etc/os-release 2>/dev/null|grep '^NAME=' 2>/dev/null|cut -d'=' -f2|tr -d '"'|sed -e 's#\s##g')
        version__=$(cat /etc/os-release 2>/dev/null|grep '^VERSION_ID=' 2>/dev/null|cut -d'=' -f2|tr -d '"'|sed -e 's#\s##g')
    else
        redirect_cmd apt-get update $qqq
        echo "using lsb-release"
        redirect_cmd apt-get install $qqq -y --force-yes lsb-release
        system__=$(lsb_release -i|cut -d ':' -f2|sed -e 's#\s##g')
        version__=$(lsb_release -r|cut -d ':' -f2|sed -e 's#\s##g')
    fi

    echo "compiling on: $system__ $version__"

    pkgs_name="pkgs_"$(echo "$system__"|tr '.' '_'|tr '/' '_')"_"$(echo $version__|tr '.' '_'|tr '/' '_')
    echo "PKG:-->""$pkgs_name""<--"

    echo "installing more system packages ..."

    # ------ specific for Ubuntu_18_04 ------
    pkgs_Ubuntu_18_04='
        :u:
        passwd
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
        libjpeg8-dev
        libavcodec-dev
        libavdevice-dev
        libsodium-dev
        libvpx-dev
        libopus-dev
        libx264-dev
    '
    # ------ specific for Ubuntu_18_04 ------

    # ------ specific for Ubuntu_20_04 ------
    pkgs_Ubuntu_20_04="$pkgs_Ubuntu_18_04"
    # ------ specific for Ubuntu_20_04 ------

    # ------ specific for pkgs_DebianGNU_Linux_9 ------
    pkgs_DebianGNU_Linux_9="$pkgs_Ubuntu_18_04"
    # ------ specific for pkgs_DebianGNU_Linux_9 ------

    # ------ specific for pkgs_DebianGNU_Linux_10 ------
    pkgs_DebianGNU_Linux_10="$pkgs_Ubuntu_18_04"
    # ------ specific for pkgs_DebianGNU_Linux_10 ------

    # ------ specific for Ubuntu_16_04 ------
    pkgs_Ubuntu_16_04='
        :u:
        software-properties-common
        :c:add-apt-repository\sppa:jonathonf/ffmpeg-4\s-y
        :u:
        passwd
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
        libjpeg8-dev
        libavcodec-dev
        libavdevice-dev
        libsodium-dev
        libvpx-dev
        libopus-dev
        libx264-dev
    '
    # ------ specific for Ubuntu_16_04 ------

    # ------ specific for AlpineLinux_3_12_0 ------
    pkgs_AlpineLinux_3_12_0='
        :c:apk\supdate
        :c:apk\sadd\sunzip
        :c:apk\sadd\szip
        :c:apk\sadd\smake
        :c:apk\sadd\sgcc
        :c:apk\sadd\slinux-headers
        :c:apk\sadd\smusl-dev
        :c:apk\sadd\sautomake
        :c:apk\sadd\sautoconf
        :c:apk\sadd\scheck
        :c:apk\sadd\slibtool
        :c:apk\sadd\srsync
        :c:apk\sadd\sgit
        :c:apk\sadd\slibx11-dev
        :c:apk\sadd\sffmpeg
        :c:apk\sadd\sffmpeg-dev
        :c:apk\sadd\salsa-lib
        :c:apk\sadd\salsa-lib-dev
        :c:apk\sadd\sv4l-utils
        :c:apk\sadd\sv4l-utils-dev
        :c:apk\sadd\slibjpeg
        :c:apk\sadd\slibsodium
        :c:apk\sadd\slibsodium-dev
        :c:apk\sadd\slibsodium-static
        :c:apk\sadd\slibvpx
        :c:apk\sadd\slibvpx-dev
        :c:apk\sadd\sopus
        :c:apk\sadd\sopus-dev
        :c:apk\sadd\sx264
        :c:apk\sadd\sx264-dev
    '
    # ------ specific for AlpineLinux_3_12_0 ------


    # ------ specific for pkgs_ArchLinux_ ------
    pkgs_ArchLinux_='
        :c:pacman\s-Sy
        :c:pacman\s-S\s--noconfirm\sbase-devel
        :c:pacman\s-S\s--noconfirm\sglibc
        :c:pacman\s-S\s--noconfirm\score/make
        :c:pacman\s-S\s--noconfirm\sffmpeg
        :c:pacman\s-S\s--noconfirm\slibsodium
        :c:pacman\s-S\s--noconfirm\sv4l-utils
        :c:pacman\s-S\s--noconfirm\sautomake
        :c:pacman\s-S\s--noconfirm\slibx11
        :c:pacman\s-S\s--noconfirm\sextra/check
        :c:pacman\s-S\s--noconfirm\sautoconf
        :c:pacman\s-S\s--noconfirm\sgit
    '
    # ------ specific for pkgs_ArchLinux_ ------

    # ------ specific for pkgs_Gentoo_ ------
    pkgs_Gentoo_='
        :c:emerge-webrsync
        :c:emerge\s-u1\ssys-apps/portage
        :c:emerge\s-u1\ssys-devel/gcc
        :c:emerge\s-u1\sdev-vcs/git
        :c:emerge\s-u1\slibsodium
        :c:emerge\s-u1\ssys-devel/autoconf
        :c:emerge\s-u1\smedia-libs/libv4l
        :c:emerge\s-u1\smedia-libs/alsa-lib
        :c:emerge\s-u1\smedia-libs/x264
        :c:emerge\s-u1\smedia-libs/libvpx
        :c:emerge\s-u1\smedia-libs/opus
        :c:emerge\s-u1\sffmpeg
        :c:emerge\s-u1\sx11-libs/libX11
    '
    # ------ specific for pkgs_Gentoo_ ------


    echo '# install commands for : '"$system__ $version__" > /artefacts/install_commands.txt

    for i in ${!pkgs_name} ; do
        if [[ ${i:0:3} == ":u:" ]]; then
            echo "apt-get update"
            echo "apt-get update" >> /artefacts/install_commands.txt
            redirect_cmd apt-get update $qqq
        elif [[ ${i:0:3} == ":c:" ]]; then
            cmd=$(echo "${i:3}"|sed -e 's#\\s# #g')
            echo "$cmd"
            echo "$cmd" >> /artefacts/install_commands.txt
            $cmd
        else
            echo "apt-get install -y --force-yes ""$i"
            echo "apt-get install -y --force-yes ""$i" >> /artefacts/install_commands.txt
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

# set 640x480 camera resolution to get better fps ---
cat toxblinkenwall.c | grep 'int video_high ='
sed -i -e 's#int video_high = 1;#int video_high = 0;#' toxblinkenwall.c
cat toxblinkenwall.c | grep 'int video_high ='
# set 640x480 camera resolution to get better fps ---

_OO_=" $C_FLAGS $LD_FLAGS "

gcc $_OO_ \
-Wno-unused-variable \
-fstack-protector-all --param=ssp-buffer-size=1 \
-fPIC -I$_HOME_/inst/include -o toxblinkenwall \
toxblinkenwall.c rb.c \
-std=gnu99 \
-L$_HOME_/inst/lib/ \
$_HOME_/inst/lib/libtoxcore.a \
$_HOME_/inst/lib/libtoxav.a \
-lsodium \
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
-lv4lconvert \
-lasound \
-lpthread \
-ldl || exit 1

ldd toxblinkenwall || exit 1
ls -hal toxblinkenwall

if [ "$1""x" == "dockerx" ]; then
    cp -av toxblinkenwall /artefacts/
    chmod -R u+rw /artefacts/
    if [ "$2""x" == "runx" ]; then
        cd /artefacts/
        useradd -ms /bin/bash user01
        # apt-get install -y --force-yes xterm
        # su user01 -c "echo $DISPLAY;xterm"
        echo "---------------------------------------------------"
        echo "please locally allow this numeric userid with xhost"
        cat /etc/passwd | grep user01
        echo "please locally allow this numeric userid with xhost"
        echo "---------------------------------------------------"
        su user01 -c 'echo $DISPLAY;cd /artefacts/;./toxblinkenwall </dev/null &'
        tail -f /artefacts/toxblinkenwall.log
    fi
else
    cp -av toxblinkenwall $_HOME_/run/
    chmod u+rx $_HOME_/run/toxblinkenwall
    cd $_HOME_/
fi


