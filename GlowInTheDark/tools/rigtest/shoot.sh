#!/bin/bash
# TEST ONLY. shoot.sh <name> <map> <x> <y> <angle> "<extra console>" <pk3s...>: one frame from that spot, ~2 s in.
# Writes $OUT/shots/<name>.png and the probe's dump line. Frames are the left eye of the rig's simulated headset.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; OUT=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rsqgd_rig}
NAME=$1; M=$2; X=$3; Y=$4; A=$5; EXTRA=$6; shift 6
mkdir -p $OUT/shots
MAP=$M DUMP=${DUMP:-6} "$HERE/run.sh" "s_$NAME" ${SECS:-90} "$EXTRA; wait 40; ${CAM:-netevent rsgdp_tp $X $Y $A}; ${POST:-echo} ; wait ${HOLD:-40}; netevent rsgdp_dump; wait 3; quit" "$@" | head -3
D=$OUT/s_$NAME; F=$(ls $D/*.ppm 2>/dev/null | tail -2 | head -1)
[ -n "$F" ] && python3 -c "from PIL import Image; Image.open('$F').save('$OUT/shots/$NAME.png')"
grep -a "RSGDP\|RSQGD" $D/log | tail -2
rm -f $D/*.ppm
