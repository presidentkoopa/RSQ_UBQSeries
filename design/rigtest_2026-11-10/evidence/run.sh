#!/bin/bash
# TEST ONLY (scratch). rig1110: run.sh <launch dir> [extra pk3/wad ...]. The launch dir holds script.txt (one console line).
# The owner's order: doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4f > LOB > Champions > GunBonsai > RSQ pk3s > extras.
set -u
T=$(realpath $1); shift
G=/home/claude/gamedata; R=/home/claude/rsq_ubqseries
RIG=/home/claude/rsq_weapondepot/tools/rig/bin
BDVR=/home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.4f.pk3
D=$T/frames; rm -rf $D; mkdir -p $D
P=$(ls $R/pk3/RSQ_*.pk3 | xargs -n1 realpath | tr '\n' ' ')
EVERY=${EVERY:-2}
/home/claude/scratch/trux/tools/squeeze.sh $D & SQPID=$!
ALSOFT_DRIVERS=null QZ_DUMP_EVERY=$EVERY QZ_DUMP_DIR=$D QZ_RES=${RES:-480} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout ${SECS:-1500} "$RIG/qz" -iwad $G/doom2.wad -file $G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 $BDVR \
  $G/LOB_v1.05.pk3 $G/mk-champions20210309.pk3 $G/GunBonsai-0.10.6.pk3 $P "$@" -nomusic ${NOMON:-} \
  +logfile $T/run.log -warp ${MAP:-01} -skill 3 "+$(cat $T/script.txt)" < /dev/null > $T/run.out 2>&1
RC=$?
touch $D/.stop; wait $SQPID; rm -f $D/.stop
git -C /home/claude/rsq_weapondepot checkout -q tools/rig/bin/config/qzdoom.ini
echo "rc=$RC frames=$(ls $D | wc -l) errors=$(grep -a -c -i -E 'Script error|VM abort|Execution could not' $T/run.log)"
