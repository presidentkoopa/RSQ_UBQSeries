#!/bin/bash
# TEST ONLY (never ships). tools/rigtest/run.sh <name> <secs> "<console script>" <pk3s...>
# Runs the QZD 17.3 rig on doom2 ($MAP, default 2) with the given pk3s then the probe. Frames with DUMP=n.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rig}
NAME=$1; SECS=$2; SCRIPT=$3; shift 3
D="$OUT/$NAME"; rm -rf "$D"; mkdir -p "$D"
P="$OUT/probe.pk3"; rm -f "$P"; (cd "$HERE/probe" && zip -q -r -X "$P" .)
# Its own copy of the rig's config per run: other lanes share the rig and its ini, and an engine that exits
# writes back every cvar it read, so a shared ini carries one run's settings into the next.
cd /home/claude/g9/rig && grep -v -E '^(rsqgd_|color_)' config/qzdoom.ini > $D/qz.ini
QZ_DUMP_EVERY=${DUMP:-0} QZ_DUMP_DIR=$D EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig QZ_RES=${RES:-320} \
  timeout "$SECS" flock -o -x /home/claude/rig.lock ./qz -config $D/qz.ini -iwad /home/claude/iwad/doom2/doom2.wad -file "$@" "$P" \
  -nosound -warp ${MAP:-2} -skill ${SKILL:-3} +logfile $D/log "+god; notarget; $SCRIPT" < /dev/null > $D/out 2>&1
echo "rc=$? frames=$(ls $D/*.ppm 2>/dev/null | wc -l)"
grep -a -i -E "script error|VM abort|exception|Called from|Tried to|warning|error" $D/log | grep -v -i "voxeldef\|GL_EXT\|GL_ARB" | head -12
