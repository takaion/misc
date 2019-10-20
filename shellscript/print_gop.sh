#!/bin/bash

get_gop_str() {
  input=$1
  result=$(ffprobe -hide_banner -show_frames "$input" 2>/dev/null | grep 'pict_type=' | sed 's/pict_type=//g' | head -n1000)
  echo "$result" | head -n1 | tr -d '\n'
  echo "$result" | tail -n+2 | sed '/I/,$d' | tr -d '\n'
  echo
}

print_gop() {
  input=$1
  echo "First Group Of Pictures: $input"
  result=$(get_gop_str "$input")
  echo "GOP Length: $(echo $result | wc -c)"
  echo $result
}

for f in "$@"
do
  print_gop "$f"
done
