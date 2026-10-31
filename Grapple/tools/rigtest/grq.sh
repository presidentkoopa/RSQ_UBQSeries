#!/bin/bash
# TEST ONLY (never ships). RSQ_Grapple on the shared QuestZDoom 17.3 rig (RSQ_WeaponDepot's tools/rig/bin), in the
# owner's Brutal Doom order: doom2 -> brutal22test6 -> BD_VoxelPack -> BD22 VR Reloaded (+hotfix) -> the pk3 -> grprobe.
#   Grapple/tools/rigtest/grq.sh <name> <secs> "<console script>"      (QoL round, 2026-10-31)
# The script usually starts "map GRTEST" (build_probe.sh makes grprobe.pk3 with the map). Log: build/<name>.log.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; MOD="$(dirname "$(dirname "$HERE")")"; HUB="$(dirname "$MOD")"
B="$HERE/build"; mkdir -p "$B"
NAME=$1; SECS=$2; SCRIPT=$3
RIG=${QZ_RIG:-/home/claude/rsq_weapondepot/tools/rig/bin}
G=${GAMEDATA:-/home/claude/gamedata}
PK3=${PK3:-$HUB/pk3/RSQ_Grapple.pk3}
D="$B/shots_$NAME"; rm -rf "$D"; mkdir -p "$D"
rm -f "$B/$NAME.log"
QZ_DUMP_DIR="$D" QZ_RES=${QZ_RES:-240} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout "$SECS" "$RIG/qz" -iwad "$G/doom2.wad" -file \
  "$G/brutal22test6.pk3" "$G/BD_VoxelPack.pk3" "$G/BD22_VR-Reloaded_2_0_3h.pk3" "$G/BD22_VR-Reloaded_2.0.3ha_hotfix.pk3" \
  "$PK3" "$HERE/grprobe.pk3" -nosound -skill 3 +logfile "$B/$NAME.log" "+$SCRIPT" > "$B/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/$NAME.log"
(cd "$RIG" && git checkout -q config/qzdoom.ini 2>/dev/null)
echo "script errors (not BD_VoxelPack's voxeldef): $(grep 'Script error' "$B/$NAME.log" | grep -v -c 'BD_VoxelPack.pk3:voxeldef')"
grep -A2 "Script error" "$B/$NAME.log" | grep -v voxeldef | head -12
grep -E "Attempt to|Unknown identifier|VM execution aborted" "$B/$NAME.log" | grep -v "invalid state" | head -10
