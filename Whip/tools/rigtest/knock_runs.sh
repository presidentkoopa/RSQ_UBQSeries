#!/bin/bash
# TEST ONLY. Crack Knocks Enemies Back (rsqwp_whip_crackknock, 11-03): a surviving cracked monster's per-tic position and
# velocity (the probe's whp_V lines), switch off (the default) vs on, plain doom2 and the owner's full order.
#   tools/rigtest/knock_runs.sh <tag> [LO dir of the 01-07 pk3s]      -> logs <tag>_*.log in whp.sh's OUT; then
#   python3 tools/rigtest/knock_metrics.py <logs...>
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; W="$(dirname "$(dirname "$HERE")")"
TAG=$1; LOD=${2:-/home/claude/scratch/lo2}
GBP=${GBP:-/home/claude/scratch/upg/GunBonsai-0.10.6.pk3}
cd "$W"
for sw in 0 1; do
  for sc in crackhitm crackhito lasso1i; do
    if [ "$sc" = lasso1i ]; then S=$(python3 "$HERE/whp_scripts.py" lasso1 | sed 's/use RSQWP_WhipWeapon;/netevent whp_summon 0 220 15; use RSQWP_WhipWeapon;/');
    else S=$(CH_DIST=150 python3 "$HERE/whp_scripts.py" $sc); [ $sc = crackhito ] && S=$(CH_DIST=64 python3 "$HERE/whp_scripts.py" $sc); fi
    S="rsqwp_whip_crackknock $sw; $S"
    bash "$HERE/whp.sh" ${TAG}_${sc}_k$sw 40 "$S" | grep -E "^script errors"
    LO=$LOD BD=1 ALL=1 GB=1 PRE="$GBP" bash "$HERE/whp.sh" ${TAG}_${sc}_k${sw}_bd 110 "$S" | grep -E "^script errors"
  done
done
