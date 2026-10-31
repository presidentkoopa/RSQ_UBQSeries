#!/bin/bash
# picks_rig.sh <name> <console-script file> [dump-every]  -- one BD-order rig run of RSQ_DistanceGrab + the probe
# (TEST ONLY). Console scripts come from picks_gen.py (swing, collar, hitstop, switch). Output in $OUT/<name>/.
# Grip presses are sent as the grip sends them: `netevent rsqdg_ngrip <hand> <1|0>`.
W=$(cd "$(dirname "$0")/../../.." && pwd)
S=${OUT:-/tmp/rsqdg_rig}; mkdir -p "$S"
G=/home/claude/gamedata; RIG=/home/claude/rsq_weapondepot/tools/rig/bin
name=$1; script="$(cat "$2")"; every=${3:-0}
D=$S/$name; rm -rf "$D"; mkdir -p "$D"
(cd "$W/DistanceGrab/tools/rigtest/probe" && rm -f "$S/probe.pk3" && zip -q -X "$S/probe.pk3" zscript.txt MAPINFO.txt CVARINFO.txt)
env QZ_DUMP_EVERY=$every QZ_DUMP_DIR=$D EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 QZ_RES=${QZ_RES:-240} timeout ${TMO:-500} \
  flock -o -x /home/claude/rig.lock $RIG/qz -iwad $G/doom2.wad -file $G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 \
  $G/BD22_VR-Reloaded_2_0_3h.pk3 $G/BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 "$W/pk3/RSQ_DistanceGrab.pk3" ${NOPROBE:-$S/probe.pk3} \
  -nosound -warp ${MAP:-1} -skill 3 +logfile "$D/log" "+god; notarget; rsqdg_debug 1; $script; quit" > "$D/out" 2>&1
echo "rc=$?"
(cd $RIG && git checkout -q config/qzdoom.ini)
grep -E "Script error|VM abort|RSQ_DistanceGrab" "$D/log" | grep -v "No sprites specified for voxel"
