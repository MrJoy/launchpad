#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

FNAME=${1:-}

if [[ $FNAME == "" ]]; then
  echo "Usage: extract_midi_monitor_sample.sh <save_file.mmon>"
  exit 1
fi

plutil -convert xml1 $FNAME

xpath $FNAME "//dict/data" 2>/dev/null |
  grep -v -E '(^<data>)|(</data>$)' |
  base64 -D |
  plutil -convert xml1 - -o - > ${FNAME%.mmon}.tmp

# Not sure we're guaranteed to get the same number of elements every time,
# so the `5` below may be brittle!
xpath ${FNAME%.mmon}.tmp "//dict/array/dict[5]/data" 2>/dev/null |
  grep -v -E '(^<data>)|(</data>$)' |
  base64 -D > ${FNAME%.mmon}.1.raw

xpath ${FNAME%.mmon}.tmp "//dict/array/dict[9]/data" 2>/dev/null |
  grep -v -E '(^<data>)|(</data>$)' |
  base64 -D > ${FNAME%.mmon}.2.raw

rm ${FNAME%.mmon}.tmp
