#!/bin/bash
# TEST ONLY (never ships). The whip on the QuestZDoom 17.3 rig (RSQ_WeaponDepot's tools/rig/bin).
#   tools/rigtest/whip.sh <name> <secs> "<console script>"     BD=1: the owner's Brutal Doom order first
# Builds RSQ_Grapple.pk3 and whipprobe.pk3; frames (QZ_DUMP_EVERY=n) land in build/shots/<name>/,
# the log in build/logs/<name>.log. The probe moves the right controller per tic (wpr_motion).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; GR="$(dirname "$(dirname "$HERE")")"
B="$HERE/build"; mkdir -p "$B/logs" "$B/shots"
NAME=$1; SECS=$2; SCRIPT=$3
RIG=${QZ_RIG:-$GR/../../rsq_weapondepot/tools/rig/bin}
IWAD=${IWAD:-$GR/../../gamedata/freedoom2.wad}
( cd "$GR" && rm -f "$B/RSQ_Grapple.pk3" && zip -q -r -X "$B/RSQ_Grapple.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt CREDITS.txt MODELDEF.txt zscript sprites sounds models )
( cd "$HERE/whipprobe" && rm -f "$B/whipprobe.pk3" && zip -q -r -X "$B/whipprobe.pk3" . )
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"
files=()
if [ -n "${BD:-}" ]; then G="$(dirname "$IWAD")"
	for f in brutal22test6.pk3 BD_VoxelPack.pk3 BD22_VR-Reloaded_2_0_3h.pk3 BD22_VR-Reloaded_2.0.3ha_hotfix.pk3; do files+=("$G/$f"); done
fi
files+=("$B/RSQ_Grapple.pk3" "$B/whipprobe.pk3")
rm -f "$B/logs/$NAME.log"
QZ_DUMP_DIR="$D" QZ_RES=${QZ_RES:-240} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  timeout "$SECS" flock -o -x /home/claude/rig.lock "$RIG/qz" -iwad "$IWAD" -file "${files[@]}" \
  -nosound $( [ -n "${MAPNAME:-}" ] && echo "+map $MAPNAME" || echo "-warp ${MAP:-1}" ) -skill 3 +logfile "$B/logs/$NAME.log" "+$SCRIPT" > "$B/logs/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
(cd "$RIG" && git checkout -q config/qzdoom.ini 2>/dev/null)
echo "script errors: $(grep -c 'Script error' "$B/logs/$NAME.log")"
grep -E "errors? while compiling|Attempt to|Unknown identifier" "$B/logs/$NAME.log" | head -10
grep -A2 "Script error" "$B/logs/$NAME.log" | grep -v -i voxeldef | head -20
