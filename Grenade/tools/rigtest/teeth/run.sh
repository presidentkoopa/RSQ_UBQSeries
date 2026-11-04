#!/bin/bash
# TEST ONLY (never ships). run.sh <name> <secs> "<console script>" <pk3s...>
# The QZD 17.3 rig (tools/rig17's engine, /home/claude/g9/rig) on doom2 MAP01 with the given pk3s and this probe.
# Its own copy of the rig's ini per run (other lanes share the rig), under the rig lock.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rig}
NAME=$1; SECS=$2; SCRIPT=$3; shift 3
D="$OUT/$NAME"; rm -rf "$D"; mkdir -p "$D"
P="$D/gtp_probe.pk3"; (cd "$HERE" && zip -q -r -X "$P" zscript.txt MAPINFO.txt CVARINFO.txt zscript)
cd /home/claude/g9/rig && grep -v -E '^(rsqgn_|rsg_|gtp_)' config/qzdoom.ini > $D/qz.ini
EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig QZ_RES=${RES:-160} \
  timeout "$SECS" flock -o -x /home/claude/rig.lock ./qz -config $D/qz.ini -iwad /home/claude/iwad/doom2/doom2.wad -file "$@" "$P" \
  ${EXTRA:-} -nosound -warp ${MAP:-1} -skill 3 +logfile $D/log "+god; notarget; $SCRIPT" < /dev/null > $D/out 2>&1
echo "rc=$? $D/log"
grep -a -c -i "script error\|VM abort" $D/log
