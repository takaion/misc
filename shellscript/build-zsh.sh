#!/bin/bash
# Required commands: curl/wget, tar, xz, gcc (or other C compilers)
# Required libraries: ?
# -----
# Required packages (Debian/Ubuntu): curl xz-utils gcc libncurses-dev make

set -eu
DOWNLOAD_VERSION=5.7.1
PREFIX=$HOME/usr
current_dir=$PWD

source `dirname $0`/functions.sh

download_uri="https://jaist.dl.sourceforge.net/project/zsh/zsh/$DOWNLOAD_VERSION/zsh-$DOWNLOAD_VERSION.tar.xz"
download $download_uri zsh.tar.xz
tar xf zsh.tar.xz
cd zsh-$DOWNLOAD_VERSION
set +e
./configure --prefix=$PREFIX
result=$?
if [ $result != 0 ] ; then
  error_exit "configure failed with code $result"
fi
set -e

set +e
make -j`cpu_cores` prefix=$PREFIX
result=$?
if [ $result != 0 ] ; then
  error_exit "make failed with code $result"
fi
set -e

cd $current_dir
