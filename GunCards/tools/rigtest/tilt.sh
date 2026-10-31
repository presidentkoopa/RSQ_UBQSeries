#!/bin/bash
# TEST ONLY. Tilt to Your Eyes (rsqgc_tilt), frames: OUT=<dir> QZ_DUMP_EVERY=20 QZ_RES=320 tools/rigtest/tilt.sh <name>
# Three wrist poses, each with the tilt off and then on (the GCT lines give the panel's psp.x / psp.y).
#   P1 the gun level, ahead   P2 the gun pointing up 50 degrees   P3 the gun turned 70 degrees across the body
HERE="$(cd "$(dirname "$0")" && pwd)"
S='god; notarget; rsqgct_every 10; rsqgc_card 1; rsqgc_watch 0; rsqgc_look 0; wait 80;'
S="$S"' echo P1_OFF; qz_rhand "0.08 1.45 -0.6 0 0 0"; wait 70; echo P1_ON; rsqgc_tilt 1; wait 70; rsqgc_tilt 0;'
S="$S"' echo P2_OFF; qz_rhand "0.08 1.4 -0.55 50 0 0"; wait 70; echo P2_ON; rsqgc_tilt 1; wait 70; rsqgc_tilt 0;'
S="$S"' echo P3_OFF; qz_rhand "0.0 1.45 -0.55 0 70 0"; wait 70; echo P3_ON; rsqgc_tilt 1; wait 70; quit'
exec "$HERE/run.sh" "$1" 400 "$S"
