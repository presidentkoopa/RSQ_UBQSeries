#!/bin/bash
# TEST ONLY. run.sh <name> <secs> "<console script>" ; PK3S = absolute pk3 list (probe appended). DUMP=n frames.
SP=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/fhprobe
RIG=/home/claude/g9/rigSB
name=$1; secs=$2; script=$3
D=$SP/out/$name; rm -rf $D; mkdir -p $D
cp $RIG/config/qzdoom.ini.orig $RIG/config/qzdoom.ini 2>/dev/null || cp $RIG/config/qzdoom.ini $RIG/config/qzdoom.ini.orig
sed -i -E '/^(rsqdg_|rsqls_|ssq_|ubqs_|rsqdgt_|rsqtr_|rsqtrt_|vr_control_scheme|rsq_hand_tone)/d' $RIG/config/qzdoom.ini
cd $RIG && env QZ_DUMP_EVERY=${DUMP:-0} QZ_DUMP_DIR=$D QZ_RES=${QZ_RES:-320} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=$RIG \
  timeout $secs stdbuf -oL -eL ./qz -iwad ${IWAD:-/home/claude/iwad/doom2/doom2.wad} -file $PK3S $SP/fhprobe.pk3 \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $D/log "+$script" 2>&1 | python3 -I -u -c '
import sys,time
for l in sys.stdin: sys.stdout.write("%.4f %s" % (time.time(), l))' > $D/out
echo "rc=$? frames=$(ls $D/*.ppm 2>/dev/null | wc -l)"
grep -i -E "script error|VM abort|exception|Called from|Tried to|voxeldef" $D/log | head -20
