#!/bin/bash
# frun.sh <name> <secs> <scriptfile> <pk3...> ; env RES, EVERY, MAP. name must start F2_
n=$1; t=$2; sf=$3; shift 3
s=$(cat $sf)
L=/home/claude/rigdata/logs; F=/home/claude/f2scratch/runs/$n/frames
rm -rf /home/claude/f2scratch/runs/$n; mkdir -p $F
cp -r /home/claude/rigdata/rig2 /home/claude/rigdata/rig_$n 2>/dev/null
D=""; [ "${EVERY:-0}" != "0" ] && D="QZ_DUMP_EVERY=$EVERY QZ_DUMP_DIR=$F"
start=$(date +%s)
(cd /home/claude/rigdata/rig_$n && env $D QZ_RES=${RES:-200} ALSOFT_DRIVERS=null EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 timeout $t ./qz -iwad /home/claude/rigdata/freedoom2.wad -file "$@" -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$n.log "+$s" > $L/$n.out 2>&1)
rc=$?
bad=$(grep -aiE "script error|VM abort|exception|unknown (class|actor)|tried to|warning:|error:|errors while|Execution could not continue" $L/$n.log $L/$n.out 2>/dev/null | grep -viE "pw.conf|ALSA|ALSOFT|pipewire|voxeldef" | sort -u | head -12)
echo "== $n rc=$rc secs=$(( $(date +%s) - start )) frames=$(ls $F | wc -l) map01=$(grep -c MAP01 $L/$n.log)"; echo "$bad"
rm -rf /home/claude/rigdata/rig_$n
