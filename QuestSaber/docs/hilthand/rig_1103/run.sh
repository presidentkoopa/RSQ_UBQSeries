#!/bin/bash
# run.sh <name> <secs> "<console>" <pk3s...>   DUMP=n frames every n; RES; MAP; IWAD
set -u
OUT=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/hilt
NAME=$1; SECS=$2; SCRIPT=$3; shift 3
D="$OUT/$NAME"; rm -rf "$D"; mkdir -p "$D"
cd /home/claude/g9/rig && grep -v -E '^(ubqs_|rsqwp_|qz_)' config/qzdoom.ini > $D/qz.ini
QZ_DUMP_EVERY=${DUMP:-0} QZ_DUMP_DIR=$D EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig QZ_RES=${RES:-320} \
  flock -o -x /home/claude/rig.lock timeout "$SECS" ./qz -config $D/qz.ini -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file "$@" \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $D/log "+vid_maxfps 35; god; notarget; $SCRIPT" < /dev/null > $D/out 2>&1
echo "rc=$? frames=$(ls $D/*.ppm 2>/dev/null | wc -l) scripterrors=$(grep -a -c 'Script error' $D/log)"
grep -a -i -E "script error|VM abort|exception|Called from|Tried to|while compiling|Unknown" $D/log | grep -v -i "voxeldef" | head -12
