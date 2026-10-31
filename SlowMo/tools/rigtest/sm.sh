#!/bin/bash
# TEST ONLY (never ships). RSQ_SlowMo on the QuestZDoom 17.3 rig (RSQ_WeaponDepot's tools/rig/bin), in the
# owner's Brutal Doom order: doom2 -> brutal22test6 -> BD_VoxelPack -> BD22 VR Reloaded (+hotfix) -> the pk3 -> smprobe.
#   SlowMo/tools/rigtest/sm.sh <name> <secs> "<console script>"     PK3=<path> to test another build
# The log lands in build/logs/<name>.log; frames (QZ_DUMP_EVERY=n) in build/shots/<name>/.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; MOD="$(dirname "$(dirname "$HERE")")"; HUB="$(dirname "$MOD")"
B="$HERE/build"; mkdir -p "$B/logs" "$B/shots"
NAME=$1; SECS=$2; SCRIPT=$3
RIG=${QZ_RIG:-/home/claude/rsq_weapondepot/tools/rig/bin}
G=${GAMEDATA:-/home/claude/gamedata}
PK3=${PK3:-$HUB/pk3/RSQ_SlowMo.pk3}
( cd "$HERE/smprobe" && rm -f "$B/smprobe.pk3" && zip -q -r -X "$B/smprobe.pk3" . )
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"
rm -f "$B/logs/$NAME.log"
QZ_DUMP_DIR="$D" QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout "$SECS" "$RIG/qz" -iwad "$G/doom2.wad" -file \
  "$G/brutal22test6.pk3" "$G/BD_VoxelPack.pk3" "$G/BD22_VR-Reloaded_2_0_3h.pk3" "$G/BD22_VR-Reloaded_2.0.3ha_hotfix.pk3" \
  "$PK3" "$B/smprobe.pk3" -nosound -warp ${MAP:-1} -skill 3 +logfile "$B/logs/$NAME.log" "+$SCRIPT" > "$B/logs/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
(cd "$RIG" && git checkout -q config/qzdoom.ini 2>/dev/null)
echo "script errors (not BD_VoxelPack's voxeldef): $(grep 'Script error' "$B/logs/$NAME.log" | grep -v -c 'BD_VoxelPack.pk3:voxeldef')"
grep -E "errors? while compiling|Attempt to|Unknown identifier|VM execution aborted" "$B/logs/$NAME.log" | head -10
