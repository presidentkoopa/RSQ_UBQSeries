#!/bin/bash
# TEST ONLY. Crack Knocks Enemies Back, the deliberate side (11-03): the yank scenario (mark, crack, wrap, pull back)
# with the switch off and on, plain doom2 and the full order; then RSQ Miniboss's Can't Be Yanked with the switch off
# (Miniboss/tools/rigtest/whip_yank_noyank1/0.txt: an imp miniboss 200 ahead; on -> "YANK ... heavy: you swing to it").
#   tools/rigtest/knock_runs2.sh <tag> [LO dir]
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; W="$(dirname "$(dirname "$HERE")")"; HUB="$(dirname "$W")"
TAG=$1; LOD=${2:-/home/claude/scratch/lo2}
GBP=${GBP:-/home/claude/scratch/upg/GunBonsai-0.10.6.pk3}
B=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/whp}
cd "$W"
for sw in 0 1; do
  S="rsqwp_whip_crackknock $sw; $(python3 "$HERE/whp_scripts.py" yank)"
  bash "$HERE/whp.sh" ${TAG}_yank_k$sw 40 "$S" | grep -E "^script errors"
  LO=$LOD BD=1 ALL=1 GB=1 PRE="$GBP" bash "$HERE/whp.sh" ${TAG}_yank_k${sw}_bd 110 "$S" | grep -E "^script errors"
done
( cd "$HUB/Miniboss/tools/rigtest/bossprobe" && rm -f "$B/bossprobe.pk3" && zip -q -r -X "$B/bossprobe.pk3" . )
for n in 1 0; do
  PRE="$HUB/pk3/RSQ_Miniboss.pk3 $B/bossprobe.pk3" bash "$HERE/whp.sh" ${TAG}_mb_noyank$n 40 "$(cat "$HUB/Miniboss/tools/rigtest/whip_yank_noyank$n.txt")" | grep -E "^script errors"
done
