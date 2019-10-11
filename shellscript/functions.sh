#!/bin/bash
set -eu

DEBUG_LEVEL=0
DEFAULT_CPU_CORES=4
# ===============================================
# Logger
# Debug level (int)

show_message_by_level() {
  local _level=$1
  shift
  if [ $DEBUG_LEVEL -le $_level ]; then
    echo "$@" 1>&2
  fi
}

debug() {
  show_message_by_level 0 "[Debug]" $@
}

info() {
  show_message_by_level 1 "[Info]" $@
}

warn() {
  show_message_by_level 2 "[Warn]" $@
}

error() {
  show_message_by_level 3 "[Error]" $@
}

# ===============================================
# Misc functions

error_exit() {
  local error_code=1
  set +eu
  if [ ! -z "$1" ]; then
    error "$1"
  fi
  if [ ! -z "$2" ]; then
    error_code=$2
  fi
  set -eu
  exit $error_code
}

cpu_cores() {
  if [ -f '/proc/cpuinfo' ] ; then
    grep 'cpu MHz' /proc/cpuinfo | wc -l
  else
    info "Use default number of CPU cores: $DEFAULT_CPU_CORES"
    echo $DEFAULT_CPU_CORES
  fi
}

download() {
  set +eu
  local src=$1
  local out=$2
  set -eu
  if [ -x "`which curl 2>/dev/null`" ] ; then
    local downloader_bin="curl -s"
    if [ -z "$out" ] ; then
      local output_opt="-O"
    else
      local output_opt="-o $out"
    fi
  elif [ -x "`which wget 2>/dev/null`" ] ; then
    local downloader_bin="wget -q"
    if [ -z "$out" ] ; then
      local output_opt="-o"
    else
      local output_opt="-O $out"
    fi
  else
    error_exit "No downloader command found"
  fi
  debug "$downloader_bin $output_opt \"$src\""
  $downloader_bin $output_opt "$src"
}
