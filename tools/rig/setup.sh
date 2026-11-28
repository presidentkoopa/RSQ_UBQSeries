#!/bin/bash
# TEST ONLY, never ships. One command from a fresh clone to a working rig:
#   sh tools/rig/setup.sh               the test packs (seconds), using the prebuilt QuestZDoom 17.3
#                                       rig in tools/rig/bin (from RS_ModelSwapper gate/qz_rig/bin, F12)
#   B22_RIG=<dir> sh tools/rig/setup.sh the same, checking another rig instead of tools/rig/bin
#   sh tools/rig/setup.sh build         rebuild the engine from source into build/rig/ (~20-40 min);
#                                       use it with B22_RIG=tools/rig/build/rig
# The engine is ALWAYS QuestZDoom 17.3, the commits in PINS. The launcher (engine/qz = bin/qz) refuses
# any other engine: a prebuilt rig from a later, unreleased commit (4.15pre) was shipped here on
# 2026-10-26 and ran silently; it was removed the same day. tools/rig/bin is the correct 17.3 build.
# Builds under tools/rig/build/ (gitignored):
#   build/src/qzd   emawind84/gzdoom @ QZD_REV (tag qzd17.3), + s_sound_log.patch
#   build/src/qzw   emawind84/questzdoom @ QZW_REV (the Android wrapper: VR input code, headers)
#   build/rig/      the Linux rig: real QZD engine, OpenXR replaced by glue/qz_linux_glue.cpp
#   build/probe.pk3, build/upstream.pk3   test-only zscript (log lines; upstream attackdown)
#   build/BD22Q_now.pk3   the set under work ($RSQ_SET, default ../rs_brutal22weaponsq beside this checkout), built by its own build.py
#   build/BD22Q_192.pk3   RS_Brutal22WeaponsQ tag 1.92 (the owner's behavioural baseline)
# Building needs: git, cmake, make, a C++ compiler, zip, python3 + Pillow, SDL2/EGL/GLES/OpenAL/libvpx headers.
# The game data is the owner's: doom2.wad, brutal22test6.pk3, BD_VoxelPack.pk3. rig.py looks in
# $RSQ_GAMEDATA (default: a gamedata folder beside the Depot) or B22_IWAD / B22_BD22 / B22_VOX.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; DEPOT="$(cd "$HERE/../.." && pwd)"; B="$HERE/build"
. "$HERE/PINS"
mkdir -p "$B/src" "$B/logs" "$B/shots"

fetch() {	# dir url rev
  [ -d "$1/.git" ] || { git init -q "$1"; git -C "$1" remote add origin "$2"; }
  [ "$(git -C "$1" rev-parse HEAD 2>/dev/null)" = "$3" ] || { git -C "$1" fetch -q --depth 1 origin "$3"; git -C "$1" checkout -q -f FETCH_HEAD; }
}
if [ "$1" = build ]; then
  fetch "$B/src/qzd" "$QZD_REPO" "$QZD_REV"
  [ "$(git -C "$B/src/qzd" rev-parse HEAD)" = "$QZD_REV" ] || { echo "setup: engine source is not $QZD_REV" >&2; exit 3; }
  git -C "$B/src/qzd" submodule update -q --init --depth 1 2>/dev/null || true
  ( cd "$B/src/qzd" && { git apply --check "$HERE/s_sound_log.patch" 2>/dev/null && git apply "$HERE/s_sound_log.patch"; } || true )
  fetch "$B/src/qzw" "$QZW_REPO" "$QZW_REV"
  # build.sh reads the ZMusic pin from the wrapper's submodule entry
  git -C "$B/src/qzw" fetch -q --depth 1 origin "$QZW_REV" 2>/dev/null || true
  mkdir -p "$B/rig"; cp -a "$HERE/engine/." "$B/rig/"; cp "$HERE/PINS" "$B/rig/PINS"
  QGZ="$B/src/qzd" JNI="$B/src/qzw/Projects/Android/jni" bash "$B/rig/build.sh"
fi
[ -x "$B/rig/qzdoom" ] && { cp "$HERE/engine/qz" "$B/rig/qz"; cp "$HERE/PINS" "$B/rig/PINS"; }
if [ "$1" = build ]; then RIG="${B22_RIG:-$B/rig}"; else RIG="${B22_RIG:-$HERE/bin}"; fi
[ -x "$RIG/qzdoom" ] && [ -x "$RIG/qz" ] || { echo "setup: no engine at $RIG (expected tools/rig/bin from git, or: sh tools/rig/setup.sh build)" >&2; exit 3; }
( cd "$HERE/probe" && rm -f "$B/probe.pk3" && zip -q -r -D "$B/probe.pk3" . )
( cd "$HERE/probe_input" && rm -f "$B/probe_input.pk3" && zip -q -r -D "$B/probe_input.pk3" . )	# R1: inputproof.py's probe
T=$(mktemp -d); cp "$HERE/upstream_zscript.txt" "$T/zscript.txt"; cp "$HERE/upstream_MAPINFO.txt" "$T/MAPINFO.txt"
( cd "$T" && rm -f "$B/upstream.pk3" && zip -q -r -D "$B/upstream.pk3" . ); rm -rf "$T"
SET="${RSQ_SET:-$DEPOT/../rs_brutal22weaponsq}"; rm -f "$B/BD22Q_now.pk3"
if [ -f "$SET/build.py" ]; then	# the set's own build (BD22: .md3 as LZMA, FBX hand blocks moved to model slot 7)
  P=$(cd "$SET" && python3 build.py now | head -1) && mv "$P" "$B/BD22Q_now.pk3" || { echo "setup: $SET/build.py failed" >&2; exit 3; }
else ( cd "$SET/src" && zip -q -r -D "$B/BD22Q_now.pk3" . ); fi
if [ ! -f "$B/BD22Q_192.pk3" ]; then
  fetch "$B/src/bd22q_192" https://github.com/presidentkoopa/RS_Brutal22WeaponsQ refs/tags/1.92 2>/dev/null || \
    { rm -rf "$B/src/bd22q_192"; git clone -q --depth 1 --branch 1.92 https://github.com/presidentkoopa/RS_Brutal22WeaponsQ "$B/src/bd22q_192"; }
  ( cd "$B/src/bd22q_192/src" && zip -q -r -D "$B/BD22Q_192.pk3" . )
fi
timeout 120 "$RIG/qz" -norun >/dev/null 2>"$B/logs/engine_check.txt" || true
grep -q 'qz: engine OK' "$B/logs/engine_check.txt" || { cat "$B/logs/engine_check.txt" >&2; echo "setup: the rig at $RIG is not QuestZDoom 17.3" >&2; exit 3; }
echo "rig ready: $RIG/qz ($(grep 'qz: engine OK' "$B/logs/engine_check.txt" | cut -c15-))"
echo "try: cd $HERE && python3 cmp2.py build/BD22Q_192.pk3 build/BD22Q_now.pk3 BrutalPistol t1"
