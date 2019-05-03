#!/bin/bash

# NOTE: cd to dir with script before running it!

# Exit on first error
set -e
set +x

# General variables
CURRENT_PATH=$(pwd)
# All variables related to TMPFS
DEFAULT_TMPFS_DIR=tmpfs
DEFAULT_TMPDF_SIZE=16G
TMPFS_PATH="$CURRENT_PATH/$DEFAULT_TMPFS_DIR"
USE_TMPFS=0
# All variables realted to compiler
DEFAULT_CROSS_COMPILER=gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf
# ALL variables related to Qt
QT_VER=5.12.2


#=== Do not touch code below
# Inner variables
need_tmpfs=0
already_tmpfs=0
need_get_qt=0
need_clean=0
need_sunxi_mkspecs=0
need_sync_npi2host=0
need_sync_host2pi=0
need_config_qt=0
need_make_qt=0

# Great and simple idea got here: https://stackoverflow.com/a/53463162/867349
function cecho() {
    RED="\033[0;31m"
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    printf "${!1}${2} ${NC}\n"
}

function wecho() { # warning, yellow
    cecho "YELLOW" "[WARN] ${1}"
}

function eecho() { # error, red
    cecho "RED" "[ERROR] ${1}"
}

function iecho() { # info, green
    cecho "GREEN" "[INFO] ${1}"
}

function do_tmpfs() {
    mkdir -p $TMPFS_PATH
    iecho "Expecting $TMPFS_PATH ..."
    if mount | grep $TMPFS_PATH > /dev/null; 
    then
        eecho "$TMPFS_PATH is already mounted. Unmount it manually first. \
               Or skip -t argument and use --already-tmpfs."
        exit 1
    fi
    MOUNT_COMMAND="sudo mount -o size=$DEFAULT_TMPDF_SIZE -t tmpfs none $TMPFS_PATH"
    wecho "We need to use sudo to run next command: "
    wecho "\t $MOUNT_COMMAND"
    eval $MOUNT_COMMAND 
    if [ $? -eq 0 ];
    then
        iecho "Mounted tmpfs of $DEFAULT_TMPDF_SIZE to $DEFAULT_TMPFS_DIR:"
        mount | grep $TMPFS_PATH
        USE_TMPFS=1
        CURRENT_PATH=$TMPFS_PATH
    else
        eecho "Can't mount."
        exit 1
    fi
}

function use_already_tmpfs() {
    if [ "$USE_TMPFS" = 0 ];
    then
        CURRENT_PATH="$TMPFS_PATH"
        iecho "Use previously setted up tmpfs (at default location $CURRENT_PATH)"
    else
        eecho "Do not use -t and --already-tmpfs at the same time."
        exit 1
    fi
}

function check_compiler_availability() {
    if [ -d $CURRENT_PATH/$DEFAULT_CROSS_COMPILER ];
    then
        iecho "$DEFAULT_CROSS_COMPILER directory found."
    else
        iecho "Unpacking $DEFAULT_CROSS_COMPILER"
        tar xf $CURRENT_PATH/../$DEFAULT_CROSS_COMPILER.tar.xz -C $CURRENT_PATH
        
        if [ $? -eq 0 ];
        then
            iecho "Unpacked compiler."
        else
            eecho "Can't unpack compiler."
            exit 1
        fi
    fi
}

function get_qt() {
    iecho "Get Qt of version $QT_VER"
    cd $CURRENT_PATH
    CLONE_COMMAND="git clone --depth 20 -b $QT_VER https://github.com/qt/qt5.git"
    INIT_REPO="perl init-repository -f -module-subset=default,-qtwebengine,-qt3d,-qtcanvas3d,-qtcharts,-qtscript,-qtdatavis3d,-qtactiveqt,-qtandroidextras,-qtconnectivity,-qtgamepad,-qtlocation,-qtmacextras,-qtnetworkauth,-qtpurchasing,-qtqa,-qtremoteobjects,-qtrepotools,-qtsensors,-qtserialbus,-qtserialport,-qtspeech,-qttools,-qtvirtualkeyboard,-qtwayland,-qtwebglplugin,-qtwebsockets,-qtwebview,-qtwinextras"
 
    eval $CLONE_COMMAND
    if [ $? -eq 0 ]
    then
        cd qt5
        git checkout $QT_VER
        iecho "Got Qt $QT_VER"
    else
        eecho "Can't get Qt sources."
        exit 1
    fi

    cd qt5
    eval $INIT_REPO
    if [ $? -eq 0 ];
    then
        iecho "Already initialized Qt repo."
    else
        eecho "Can't init Qt repo."
        exit 1
    fi   
}

function clean_leftovers_qt() {
    # Clean all leftovers from previous build
    QT5_PATH=$CURRENT_PATH/qt5
    if [ -d "$QT5_PATH" ];
    then
        cd $QT5_PATH
        git submodule foreach --recursive "git clean -dfx" && git clean -dfx
        iecho "Cleaned folder $QT5_PATH."
    else
        wecho "Nothing to clean, since there is no such folder ($QT5_PATH)."
    fi
}

function sync_npi2host() {
    HOST=nano.pi
    USER=root
    SYSROOT=$CURRENT_PATH/sysroot
    
    iecho "We expect that:"
    iecho "\tyou have your NanoPi at $HOST"
    iecho "\tyour user is $USER"
    iecho "\tyour sysroot is at $SYSROOT"
    iecho "- - -"
    iecho "Prepare to provide your user ($USER) password several times."
    
    mkdir -p $SYSROOT $SYSROOT/usr $SYSROOT/opt

    rsync -avz --ignore-existing $USER@$HOST:/lib $SYSROOT
    rsync -avz --ignore-existing $USER@$HOST:/usr/include $SYSROOT/usr
    rsync -avz --ignore-existing $USER@$HOST:/usr/lib $SYSROOT/usr

    python $CURRENT_PATH/../sysroot-relativelinks.py $SYSROOT
}

function sync_host2npi() {
    HOST=nano.pi
    USER=root
    SYSROOT=$CURRENT_PATH/sysroot
    
    iecho "We expect that:"
    iecho "\tyou have your NanoPi at $HOST"
    iecho "\tyour user is $USER"
    iecho "\tyour sysroot is at $SYSROOT"
    iecho "- - -"
    iecho "Prepare to provide your user ($USER)."
    
    HOSTDIR=$CURRENT_PATH/NanoPi
        
    export QT_PATH=$HOSTDIR/Qt5.12-target
    export QT_PI_PATH=/opt/qt512

    rsync -avz $QT_PATH/ $USER@$HOST:$QT_PI_PATH
}

function configure_qt() {
    CROSS_COMPILER_PATH="$CURRENT_PATH/$DEFAULT_CROSS_COMPILER/bin"
    # Prepare folder for shadow build
    BUILDDIR="$CURRENT_PATH/build"
    rm -rf "$BUILDDIR"
    mkdir -p "$BUILDDIR"
    cd "$BUILDDIR"
    
    ROOTFS=$CURRENT_PATH/sysroot
    mkdir -p $ROOTFS
    
    HOSTDIR=$CURRENT_PATH/NanoPi
    mkdir -p $HOSTDIR
    
    iecho "Going to do build in $BUILDDIR"
    iecho "Crosscompiler: $CROSS_COMPILER_PATH"
    
    $CURRENT_PATH/qt5/configure -v -release -opensource -confirm-license \
        -no-use-gold-linker -nomake examples -nomake tests -nomake tools -no-cups -no-pch \
        -opengl es2 -eglfs -linuxfb \
        -sysroot $ROOTFS -device linux-sunxi-g++ \
        -prefix /opt/qt512 \
        -extprefix $HOSTDIR/Qt5.12-target \
        -hostprefix $HOSTDIR/Qt5.12 \
        -device-option CROSS_COMPILE=$CROSS_COMPILER_PATH/arm-linux-gnueabihf- 
}

function make_qt() {
    BUILDDIR="$CURRENT_PATH/build"
    iecho "Going to do build in $BUILDDIR"
    cd $BUILDDIR
    time make -j 9
    iecho BUILD DONE. Going to make install
    make install
    
}

function prepare_sunxi_mkspecs() {
    QT5_PATH=$CURRENT_PATH/qt5
    MKSPECS_PATH=$CURRENT_PATH/../linux-sunxi-g++
    if [ -d $MKSPECS_PATH ] 
    then
        cp -r $MKSPECS_PATH $QT5_PATH/qtbase/mkspecs/devices/
        if [ $? -eq 0 ]
        then
            iecho "Copied Sunxi mkspecs to Qt folder:"
            ls -1d $QT5_PATH/qtbase/mkspecs/devices/ | grep linux-sunxi-g++
        else
            eecho "Can't copy files."
            exit 1
        fi
    else
        eecho "Can't find mkspecs folder required for Sunxi device ($MKSPECS_PATH)."
        exit 1
    fi
}

function parse_args() {
    while [[ "$#" -gt 0 ]]; 
    do 
        case $1 in
            -t|--tmpfs)         need_tmpfs=1 ;         shift;;
            -a|--already-tmpfs) already_tmpfs=1 ;      shift;;
            -g|--get-qt)        need_get_qt=1 ;        shift;;
            -c|--clean)         need_clean=1 ;         shift;;
            -s|--sunxi-mkspecs) need_sunxi_mkspecs=1 ; shift;;
            --npi2host)         need_sync_npi2host=1 ; shift;;
            --host2pi)          need_sync_host2pi=1 ;  shift;;
            -q|--config-qt)     need_config_qt=1 ;     shift;;
            -m|--make-qt)       need_make_qt=1 ;       shift;;
            *) eecho "Unknown parameter passed: $1" ; usage;;
        esac
#         shift 
    done
}

function usage() {
    cat <<HELP_USAGE
    TODO: Documentation is in progress.
    
    $0  [-tgcsqm]

      -t | --tmpfs          To prepare and use tmpfs.
      -a | --already-tmpfs
      -g | --get-qt         Obtain Qt sources.
      -c | --clean          Clean folder with Qt.
      -s | --sunxi-mkspecs  Copy Sunxi mkspecs.
      -q | --config-qt      Config Qt.
      -m | --make-qt        Build Qt.
      --npi2host
      --host2pi

HELP_USAGE
    exit 1
}

# Establish run order
function main() {
    iecho "Starting..."
    ((need_tmpfs))      && do_tmpfs             || iecho "No need for tmpfs."
    ((already_tmpfs))   && use_already_tmpfs    || iecho "No need to use predefined tmpfs"    
    ((need_get_qt))     && get_qt               || iecho "No need to get Qt."
    ((need_clean))      && clean_leftovers_qt   || iecho "No need to clean leftovers."
    ((need_sunxi_mkspecs)) && prepare_sunxi_mkspecs || iecho "No need to prepare Sunxi mkspecs."
    check_compiler_availability
    ((need_sync_npi2host)) && sync_npi2host     || iecho "No need to sync NPi with Host."
    ((need_config_qt))  && configure_qt         || iecho "No need to configure Qt." 
    ((need_make_qt))    && make_qt              || iecho "No need to make Qt."
    ((need_sync_host2pi)) && sync_host2npi      || iecho "No need to sync Host with NPi."
    iecho "Finished."
}

parse_args "$@"
main
