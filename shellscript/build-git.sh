#!/bin/bash
# Required commands: curl/wget, unzip, gcc (or other C compilers)
# Required libraries: ?
# -----
# Required packages (Debian/Ubuntu): curl gcc make libssl-dev zlib1g-dev libcurl4-openssl-dev libexpat1-dev gettext

set -eu
PREFIX=$HOME/usr
current_dir=$PWD

source `dirname $0`/functions.sh

download_uri="https://github.com/git/git/archive/master.zip"
download $download_uri git.zip
if [ -d git-master ] ; then
  rm -rf git-master
fi
unzip git.zip
cd git-master

set +e
make -j`cpu_cores` prefix=$PREFIX
result=$?
if [ $result != 0 ] ; then
  error_exit "make failed with code $result"
fi
set -e

cd $current_dir
