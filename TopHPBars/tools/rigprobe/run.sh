#!/bin/bash
# TEST ONLY (never ships). RSQ HP Bars on the QuestZDoom 17.3 rig, the owner's Brutal Doom order.
#   tools/rigprobe/run.sh <name> <secs> "<console script>" [extra pk3s loaded before ours...]
# Builds the probe, runs doom2 -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded 2.0.3h -> its hotfix ->
# [extras] -> pk3/RSQ_HPBars.pk3 -> probe, MAP01. Log and frames: $OUT/<name>/ (frames only with DUMP=n).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; SER="$(cd "$HERE/../../.." && pwd)"
OUT=${OUT:-/tmp/claude-0/-home-claude/62d9a60b-b086-5c5f-814f-934c01a876fc/scratchpad/thp}
G=/home/claude/gamedata; RIG=/home/claude/rsq_weapondepot/tools/rig/bin
NAME=$1; SECS=$2; SCRIPT=$3; shift 3
D="$OUT/$NAME"; rm -rf "$D"; mkdir -p "$D"
# OLDPROBE=1: the probe without the fields the pre-sweep pk3 lacks (bar.stat, handler.aim), for a "before" run
P=$(mktemp -d); cp "$HERE"/MAPINFO.txt "$HERE"/CVARINFO.txt "$P"/; cp "$HERE/zscript${OLDPROBE:+_old}.txt" "$P/zscript.txt"
rm -f "$OUT/probe_$NAME.pk3"; (cd "$P" && zip -q -r -X "$OUT/probe_$NAME.pk3" zscript.txt MAPINFO.txt CVARINFO.txt); rm -rf "$P"
QZ_DUMP_EVERY=${DUMP:-0} QZ_DUMP_DIR=$D EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 QZ_RES=${RES:-320} timeout "$SECS" \
  flock -o -x /home/claude/rig.lock $RIG/qz -iwad $G/doom2.wad -file $G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 \
  $G/BD22_VR-Reloaded_2_0_3h.pk3 $G/BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 "$@" "${PK3:-$SER/pk3/RSQ_HPBars.pk3}" "$OUT/probe_$NAME.pk3" \
  -nosound -warp 1 -skill 3 +logfile $D/log "+god; notarget; $SCRIPT" > $D/out 2>&1
echo "rc=$? frames=$(ls $D/*.ppm 2>/dev/null | wc -l)"
(cd $RIG && git checkout -q config/qzdoom.ini)
grep -i -E "script error|VM abort|exception|Called from|Tried to" $D/log | grep -v -i voxeldef | head -10
