#!/bin/bash
# run1.sh <name> <secs> <console script> <pk3...>
n=$1; t=$2; s=$3; shift 3
cp -r /home/claude/rigdata/rig /home/claude/rigdata/rig_$n 2>/dev/null
(cd /home/claude/rigdata/rig_$n && env QZ_RES=200 EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 timeout $t ./qz -iwad /home/claude/rigdata/freedoom2.wad -file "$@" -nosound -warp 1 -skill 3 +logfile /home/claude/rigdata/logs/$n.log "+$s" > /home/claude/rigdata/logs/$n.out 2>&1)
rc=$?
bad=$(grep -iE "script error|VM abort|exception|unknown (class|actor)|tried to|warning:|error:|errors while|Execution could not continue" logs/$n.log logs/$n.out 2>/dev/null | grep -viE "pw.conf|ALSA|ALSOFT|pipewire" | sort -u | head -12)
if [ -n "$bad" ] || ! grep -q "MAP01" logs/$n.log 2>/dev/null; then echo "== $n rc=$rc FAIL"; echo "$bad"; else echo "== $n rc=$rc ok"; fi
rm -rf /home/claude/rigdata/rig_$n
