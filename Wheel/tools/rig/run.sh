#!/bin/bash
# TEST ONLY (never ships). RSQ Wheel on the real QuestZDoom 17.3 rig.
#   tools/rig/run.sh <name> <secs> "<console script>" [extra pk3...]
# Engine: RSQ_WeaponDepot's tools/rig/bin (QuestZDoom 17.3, version-guarded), set QZ_RIG to
# point elsewhere. IWAD: $IWAD (default freedoom2.wad in ../gamedata beside the series repo).
# Packs build/RSQ_Wheel.pk3 and build/probe.pk3 from this checkout first. Frames: set
# QZ_DUMP_EVERY=n and QZ_RES; they land in build/shots/<name>/. Log: build/logs/<name>.log.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; WHEEL="$(dirname "$(dirname "$HERE")")"
B="$HERE/build"; mkdir -p "$B/logs" "$B/shots"
NAME=$1; SECS=$2; SCRIPT=$3; shift 3
RIG=${QZ_RIG:-$WHEEL/../../rsq_weapondepot/tools/rig/bin}
IWAD=${IWAD:-$WHEEL/../../gamedata/freedoom2.wad}
( cd "$WHEEL" && rm -f "$B/RSQ_Wheel.pk3" && zip -q -r -X "$B/RSQ_Wheel.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF \
	MENUDEF.txt SNDINFO.txt MODELDEF.txt TEXTURES.txt CREDITS.txt zscript sounds models graphics sprites 2>/dev/null )
( cd "$HERE/probe" && rm -f "$B/probe.pk3" && zip -q -r -X "$B/probe.pk3" . )
D="$B/shots/$NAME"; rm -rf "$D"; mkdir -p "$D"
files=("$B/RSQ_Wheel.pk3"); for f in "$@"; do files+=("$(realpath "$f")"); done
[ -z "${NOPROBE:-}" ] && files+=("$B/probe.pk3")
rm -f "$B/logs/$NAME.log"
QZ_DUMP_DIR="$D" QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  timeout "$SECS" flock -o -x /home/claude/rig.lock "$RIG/qz" -iwad "$IWAD" -file "${files[@]}" \
  -nosound -warp 1 -skill 3 +logfile "$B/logs/$NAME.log" "+$SCRIPT" > "$B/logs/$NAME.out" 2>&1
echo "rc=$? frames=$(ls "$D" | wc -l) log=$B/logs/$NAME.log"
(cd "$RIG" && git checkout -q config/qzdoom.ini 2>/dev/null)
echo "script errors: $(grep -c 'Script error' "$B/logs/$NAME.log")"
