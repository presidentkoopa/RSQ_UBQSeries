#!/bin/bash
# run.sh <name> <secs> <console script> [extra env...]  -- one rig run of RSQ_DistanceGrab on freedoom2
name=$1; secs=$2; script=$3; shift 3
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log $L/$name.out
cd /home/claude/rig && env QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 "$@" \
  timeout $secs ./qz -iwad ${IWAD:-/home/claude/iwad/freedoom-0.13.0/freedoom2.wad} \
  -file ${PRE_PK3} /home/claude/work/RSQ_DistanceGrab/RSQ_DistanceGrab.pk3 ${EXTRA_PK3} \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+$script" > $L/$name.out 2>&1
echo "rc=$?"
