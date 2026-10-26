#!/bin/bash
# run17.sh <name> <secs> <console script> -- one run on the REAL qzd17.3 rig (/home/claude/g9/rig), freedoom2 MAP01.
# Loads $PK3S (space-separated). Strips archived mod cvars first.
sed -i -E '/^(rsqdg_|rsqls_|ssq_|ubqs_|rsqdgt_)/d' /home/claude/g9/rig/config/qzdoom.ini
name=$1; secs=$2; script=$3
L=/home/claude/scratch/logs; mkdir -p $L; rm -f $L/$name.log $L/$name.out
cd /home/claude/g9/rig && env QZ_RES=${QZ_RES:-200} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 LD_LIBRARY_PATH=/home/claude/g9/rig \
  timeout $secs ./qz -iwad ${IWAD:-/home/claude/iwad/freedoom-0.13.0/freedoom2.wad} -file $PK3S \
  -nosound -warp ${MAP:-1} -skill 3 +logfile $L/$name.log "+$script" > $L/$name.out 2>&1
echo "rc=$?"
