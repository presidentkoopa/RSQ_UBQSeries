#!/bin/bash
# rungdb.sh <name> <secs> <console script>: like run.sh, under gdb logging every QzDoom_Vibrate
name=$1; secs=$2; script=$3
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log $L/$name.out
cd /home/claude/rig && [ -e libGLESv3.so ] || ln -sf /usr/lib/x86_64-linux-gnu/libGLESv2.so.2 libGLESv3.so
env QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/rig ${ENVX} \
  timeout $secs gdb -q -batch -x /home/claude/scratch/gdbvib.cmd --args ./qzdoom -iwad ${IWAD:-/home/claude/iwad/freedoom-0.13.0/freedoom2.wad} \
  -file ${PRE_PK3} /home/claude/work/RSQ_DistanceGrab/RSQ_DistanceGrab.pk3 /home/claude/scratch/probe.pk3 \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+$script" > $L/$name.out 2>&1
echo "rc=$?"
