#!/bin/bash
# TEST ONLY. sw.sh <name> <secs> "<script>" [extra args before the script, e.g. +set x 1]: doom2 + SWINGTST + the Whip under test + the whp probe
N=$1; S=$2; SC=$3; shift 3
M=/home/claude/presidentkoopa/rsq_meshturbator; RIG=$M/rig/bin
WHIP=${WHIP:-/home/claude/wt_whipdoc/pk3/RSQ_Whip.pk3}
T=/home/claude/rig/work/runs/wp13_$N; rm -rf $T; mkdir -p $T/frames
git -C $M checkout -q rig/bin/config/qzdoom.ini
cd $RIG
ALSOFT_DRIVERS=null QZ_DUMP_EVERY=${EVERY:-10} QZ_DUMP_DIR=$T/frames QZ_RES=${RES:-320} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
 timeout $S ./qz -iwad /home/claude/rig/packs/doom2.wad -file /home/claude/rig/work/swingtst.wad $WHIP /home/claude/rig/work/wp13/whp.pk3 -nosound -nomusic +logfile $T/run.log \
 +set sv_cheats 1 "$@" +map SWINGTST -skill 3 "+$SC" </dev/null >$T/run.out 2>&1
RC=$?
git -C $M checkout -q rig/bin/config/qzdoom.ini
echo "rc=$RC frames=$(ls $T/frames | wc -l)"
grep -a -i -E -A3 'Script error|VM abort|Execution could not|while compiling' $T/run.log | head -20
