#!/bin/sh

export PATH="/usr/bin:/usr/sbin:/bin:/sbin"

notify_ip () {
  for dev in $(ip addr | grep '^[0-9]' | sed 's#^[0-9]\+: ##;s#: <.\+$##'); do
    echo $dev
    if ip addr show $dev | grep 'link/loopback' >/dev/null; then
      echo '-> Skipped (Loopback interface)'
      continue
    fi
    ipaddr="$(ip addr show $dev | grep 'inet ' | sed 's#^\s\+inet ##;s#/.\+$##')"
    if [ -z "$ipaddr" ]; then
      echo '-> Skipped (No IP address)'
      continue
    fi
    arping -A -c 1 -I $dev $ipaddr
  done
}

if ! which arping >/dev/null 2>&1; then
  echo 'arping command not found'
  exit 1
fi
notify_ip
