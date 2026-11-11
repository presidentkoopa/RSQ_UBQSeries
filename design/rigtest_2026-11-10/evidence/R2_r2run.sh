#!/bin/bash
# TEST ONLY (scratch, R2): run.sh with BD22 VR 2.0.4h, and LegenDoom right after doom2 when LD=1.
set -u
T=$(realpath $1); shift
G=/home/claude/gamedata; R=/home/claude/rsq_ubqseries
RIG=/home/claude/rsq_weapondepot/tools/rig/bin
BDVR=/home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.4i.pk3
LDF=""; [ "${LD:-0}" = 1 ] && LDF=/mnt/user-data/uploads/1f3eb79e-LegenDoom_3.0.pk3
D=$T/frames; rm -rf $D; mkdir -p $D
P=$(ls $R/pk3/RSQ_*.pk3 | xargs -n1 realpath | tr '\n' ' ')
EVERY=${EVERY:-2}
/home/claude/scratch/trux/tools/squeeze.sh $D & SQPID=$!
ALSOFT_DRIVERS=null QZ_DUMP_EVERY=$EVERY QZ_DUMP_DIR=$D QZ_RES=${RES:-480} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock sh -c 'git -C /home/claude/rsq_weapondepot checkout -q tools/rig/bin/config/qzdoom.ini; exec "$@"' RIGINI_RESET timeout ${SECS:-1500} "$RIG/qz" -iwad $G/doom2.wad -file $LDF $G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 $BDVR \
  $G/LOB_v1.05.pk3 $G/mk-champions20210309.pk3 $G/GunBonsai-0.10.6.pk3 $P "$@" -nomusic ${NOMON:-} \
  +logfile $T/run.log -warp ${MAP:-01} -skill 3 "+$(cat $T/script.txt)" < /dev/null > $T/run.out 2>&1
RC=$?
touch $D/.stop; wait $SQPID; rm -f $D/.stop
git -C /home/claude/rsq_weapondepot checkout -q tools/rig/bin/config/qzdoom.ini
echo "rc=$RC frames=$(ls $D | wc -l) errors=$(grep -a -c -i -E 'Script error|VM abort|Execution could not' $T/run.log)"
