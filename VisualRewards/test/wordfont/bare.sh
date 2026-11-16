#!/bin/bash
# bare.sh <name> <secs> "<script>" [files]: doom2 + the given files only (flock'd), the owner's ini (a copy)
N=$1; S=$2; SC=$3; shift 3
M=/home/claude/presidentkoopa/rsq_meshturbator; RIG=$M/rig/bin
T=/home/claude/rig/work/runs/$N; mkdir -p $T/frames; find $T/frames -name '*.ppm' -delete
cp /mnt/user-data/uploads/9bea7d55-qzdoom_portable.ini $T/config.ini; chmod u+w $T/config.ini
exec 9>/home/claude/rig.lock; flock 9
cd $RIG
ALSOFT_DRIVERS=null QZ_DUMP_EVERY=${EVERY:-10} QZ_DUMP_DIR=$T/frames QZ_RES=${RES:-480} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
 timeout $S ./qz -config $T/config.ini -iwad /home/claude/rig/packs/doom2.wad -file "$@" -nomusic +logfile $T/run.log -warp ${MAP:-01} -skill 3 +set sv_cheats 1 +set rsqtr_eye_m 1.6 $EXTRA "+$SC" </dev/null >$T/run.out 2>&1
RC=$?
echo "rc=$RC frames=$(ls $T/frames | wc -l)"
grep -a -i -E -A3 'Script error|VM abort|Execution could not|error' $T/run.log | grep -v GL_ | head -40
