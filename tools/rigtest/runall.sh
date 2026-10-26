#!/bin/bash
# runall.sh -- the series regression: all four Quest packs, both load orders, freedoom2 MAP01.
# Fails on any script error, VM abort, unknown class/actor or menu warning in the log.
G=/home/claude/work/RSQ_DistanceGrab/RSQ_DistanceGrab.pk3
L=/home/claude/work/RSQ_LaserSight/RSQ_LaserSight.pk3
S=/home/claude/scratch/coexist/ShieldSaw.pk3
Q=/home/claude/scratch/coexist/QuestSaber_rig.pk3
LOG=/home/claude/scratch/logs; mkdir -p $LOG
SCRIPT="${1:-wait 20; give all; wait 30; openmenu SSQ_Advanced; wait 5; closemenu; openmenu RSQLS_Options; wait 5; closemenu; wait 10; summon zombieman; wait 70; quit}"
fail=0
for order in A B; do
  if [ $order = A ]; then F="$G $L $S $Q"; else F="$Q $S $L $G"; fi
  rm -f $LOG/reg$order.log
  (cd /home/claude/rig && env QZ_RES=200 EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
    timeout 240 ./qz -iwad /home/claude/iwad/freedoom-0.13.0/freedoom2.wad -file $F \
    -nosound -warp 1 -skill 3 +logfile $LOG/reg$order.log "+$SCRIPT" > $LOG/reg$order.out 2>&1)
  rc=$?
  bad=$(grep -iE "script error|VM abort|exception|unknown (class|actor)|tried to|warning:|error:" $LOG/reg$order.log $LOG/reg$order.out | grep -viE "pw.conf|ALSA|ALSOFT|pipewire" | head -20)
  if [ -n "$bad" ] || ! grep -q "MAP01" $LOG/reg$order.log; then echo "order $order rc=$rc FAIL"; echo "$bad"; fail=1; else echo "order $order rc=$rc ok"; fi
done
exit $fail
