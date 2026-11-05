#!/bin/bash
# TEST ONLY. run.sh <name> <secs> <bd 0/1> "<console script>" <pk3...>   (QZ_HMD etc pass through)
N=$1; S=$2; BD=$3; SCRIPT=$4; shift 4
H="$(cd "$(dirname "$0")" && pwd)/build"; RIG=/home/claude/rsq_weapondepot/tools/rig/bin; G=/home/claude/gamedata
mkdir -p $H/logs $H/shots
files=(); [ "$BD" = 1 ] && files+=($G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 $G/BD22_VR-Reloaded_2_0_3h.pk3 $G/BD22_VR-Reloaded_2.0.3ha_hotfix.pk3)
files+=("$@")
L=$H/logs/$N.log; rm -f $L; D=$H/shots/$N; rm -rf $D; mkdir -p $D
QZ_DUMP_DIR=$D EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 QZ_RES=${QZ_RES:-160} timeout $S flock -o -x /home/claude/rig.lock $RIG/qz -iwad $G/freedoom2.wad -file "${files[@]}" -nosound -warp ${MAP:-1} -skill 3 +logfile $L "+$SCRIPT" > $H/logs/$N.out 2>&1
echo "rc=$?"
(cd $RIG && git checkout -q config/qzdoom.ini 2>/dev/null)
e=$(grep -c "Script error" $L); v=$(grep -A1 "Script error" $L | grep -c "voxeldef")
echo "$N: script errors $((e - v)) (+$v BD voxeldef), fatal $(grep -cE "errors? while compiling|Execution could not continue|VM abort|VM execution aborted" $L), frames $(ls $D | wc -l)"
grep -A2 "Script error" $L | grep -v -i "voxeldef\|No sprites specified" | head -8
grep -E "errors? while compiling|Execution could not|VM abort|Unknown identifier|Attempt to" $L | head -6
