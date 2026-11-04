#!/bin/bash
# TEST ONLY. ld.sh <name> [ld|plain|full] -- the LegenDoom pre-turn check (ldprobe) on the real qzd17.3 rig (tools/rig17/run17.sh).
#   ld    doom2 + LegenDoom Lite 4.2 + RSQ_HPBars + probe (default)   ld3  the same with LegenDoom 3.0
#   plain doom2 + RSQ_HPBars + probe (no LegenDoom: nothing may change)
#   chld  doom2 + Champions + LegenDoom Lite + RSQ_HPBars + probe (CMD="champion_legendoom 1; champion_dormant 1; ...")
# HPB=<pk3> tests another HP Bars build. LegenDoom pk3s are zipped from the owner's attachments into the scratchpad.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; HUB="$(dirname "$(dirname "$HERE")")"
SC=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad
ATT=/mnt/user-data/attachments/01ebc270-3953-5301-831b-c73a8b1320ca
mk() { [ -f "$SC/$1.pk3" ] && return; mkdir -p "$SC/$1.src"; (cd "$SC/$1.src" && unzip -o -q "$2" && zip -q -r -X "$SC/$1.pk3" .); rm -rf "$SC/$1.src"; }
mk ldl "$ATT/a95b1a86-LegenDoomLite_4.2.pk3.zip"; mk ld3 "$ATT/4f27e128-LegenDoom_3.0.pk3_1.zip"
( cd "$HERE/ldprobe" && rm -f "$SC/thpld.pk3" && zip -q -r -X "$SC/thpld.pk3" . )
HPB=${HPB:-$HUB/pk3/RSQ_HPBars.pk3}
case "${2:-ld}" in
  ld)    P="$SC/ldl.pk3 $HPB";;
  ld3)   P="$SC/ld3.pk3 $HPB";;
  plain) P="$HPB";;
  chld)  P="$ATT/a09b1892-mk-champions20210309.pk3 $SC/ldl.pk3 $HPB";;   # Champions (LegenDoom mode, dormant) + LegenDoom Lite
esac
PK3S="$P $SC/thpld.pk3" IWAD=/home/claude/iwad/doom2/doom2.wad bash "$HUB/tools/rig17/run17.sh" "$1" 60 "${CMD:-} wait 200; quit"
L=/home/claude/scratch/logs/$1.log
echo "script errors: $(grep -c 'Script error' $L)"; grep -A2 'Script error' $L | head
grep '^THPLD' $L
