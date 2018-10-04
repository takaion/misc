#!/bin/bash
set -eu

PREFIX=$HOME/usr
WORK_DIR=$HOME/usr/local/src

YASM_VERSION=1.3.0
NASM_VERSION=2.13.03

MAKE_CORES=4

# Initialize
ORIGINAL_DIR=$PWD
mkdir -p $WORK_DIR
cd $WORK_DIR

install_yasm () {
  if [ -x $PREFIX/bin/yasm ] ; then
    echo "yasm already installed" >&2
    return
  fi
  YASM_BASENAME=yasm-$YASM_VERSION
  if [ ! -f $YASM_BASENAME.tar.gz ] ; then
    wget http://www.tortall.net/projects/yasm/releases/$YASM_BASENAME.tar.gz
    tar xf $YASM_BASENAME.tar.gz
  fi
  cd $YASM_BASENAME
  ./configure --prefix=$PREFIX
  make -j$MAKE_CORES
  make install
  cd $WORK_DIR
}

install_nasm () {
  if [ -x $PREFIX/bin/nasm ] ; then
    echo "nasm already installed" >&2
    return
  fi
  if [ ! -x $PREFIX/bin/yasm ] ; then
    install_yasm
  fi

  NASM_BASENAME=nasm-$NASM_VERSION
  if [ ! -f $NASM_BASENAME.tar.bz2 ] ; then
    wget https://www.nasm.us/pub/nasm/releasebuilds/$NASM_VERSION/$NASM_BASENAME.tar.bz2
    tar xf $NASM_BASENAME.tar.bz2
  fi
  cd $NASM_BASENAME
  ./autogen.sh
  ./configure --prefix=$PREFIX
  make -j$MAKE_CORES
  make install
  cd $WORK_DIR
}

install_x264 () {
  if [ -x $PREFIX/bin/x264 ] ; then
    echo "x264 already installed" >&2
    return
  fi
  if [ ! -x $PREFIX/bin/nasm ] ; then
    install_nasm
  fi

  if [ ! -d x264 ] ; then
    git clone git://git.videolan.org/x264.git
  fi
  cd x264
  ./configure --enable-static --disable-opencl --prefix=$PREFIX
  make -j$MAKE_CORES
  make install
  cd $WORK_DIR
}

install_ffmpeg () {
  if [ -x $PREFIX/bin/ffmpeg ] ; then
    echo "ffmepg already installed" >&2
    return
  fi
  if [ ! -x $PREFIX/bin/x264 ] ; then
    install_x264
  fi

  if [ ! -d ffmpeg ] ; then
    git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git
  fi
  cd ffmpeg
  ./configure --extra-cflags="-I$PREFIX/include" --extra-ldflags="-L$PREFIX/lib" --extra-libs="-ldl" --prefix=$PREFIX \
              --enable-gpl --enable-libx264 --enable-static
  make -j$MAKE_CORES
  make install
}

install_ffmpeg

# Finalize
cd $ORIGINAL_DIR
