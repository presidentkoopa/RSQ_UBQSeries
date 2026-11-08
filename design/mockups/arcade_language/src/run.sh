#!/bin/bash
# run.sh <name> <map> <secs> "<console script>"   (env EVERY, QZ_RES)
set -u
NAME=$1; MAP=$2; SECS=$3; SCRIPT=$4
T=/home/claude/scratch/arcmock; G=/home/claude/gamedata; BD=/home/claude/rs_brutal22weaponsq/pk3
RIG=/home/claude/rsq_weapondepot/tools/rig/bin
D=$T/frames/$NAME; rm -rf $D; mkdir -p $D $T/logs
files=($G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 "$(ls -t $BD/03_BD22_VR*.pk3 | head -1)" ${EXTRAFILES:-} $T/probe.pk3)
/home/claude/scratch/trux/tools/squeeze.sh $D & SQPID=$!
QZ_DUMP_EVERY=${EVERY:-10} QZ_DUMP_DIR=$D QZ_RES=${QZ_RES:-640} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout $SECS "$RIG/qz" -iwad $G/doom2.wad -file "${files[@]}" -nosound \
  +logfile $T/logs/$NAME.log -warp $MAP -skill 3 "+$SCRIPT" > $T/logs/$NAME.out 2>&1
RC=$?; touch $D/.stop; wait $SQPID; rm -f $D/.stop
git -C /home/claude/rsq_weapondepot checkout -q tools/rig/bin/config/qzdoom.ini
echo "rc=$RC frames=$(ls $D | wc -l) errors=$(grep -c 'Script error' $T/logs/$NAME.log)"
grep "^AM " $T/logs/$NAME.log | grep -v " t[0-9]" | head -20; grep "AM t" $T/logs/$NAME.log | tail -1
