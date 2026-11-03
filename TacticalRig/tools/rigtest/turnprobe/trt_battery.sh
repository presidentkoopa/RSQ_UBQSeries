#!/bin/bash
# trt_battery.sh <tag> <fps> <pk3...> -- every turn script on the rig, one log each:
# /home/claude/scratch/logs/<tag>_<script><fps>.log, then trt_check.py over each. TEST ONLY.
# env: TESTS (default: snap snapj smooth smoothj room room2 look lookj), PROBE=ss (ShieldSaw without TacticalRig), PRECMD.
tag=$1; fps=$2; shift 2
D=$(cd "$(dirname "$0")" && pwd)
for t in ${TESTS:-snap snapj smooth smoothj room room2 look lookj}; do
  w=$t; [ $t = smooth ] && [ $fps -lt 60 ] && w=smooth35
  FPS=$fps PK3S="$*" PRECMD="$PRECMD" $D/trt_run.sh ${tag}_${t}${fps} $w 200 > /dev/null
  L=/home/claude/scratch/logs/${tag}_${t}${fps}.log
  echo "== $tag $t @${fps} fps: script errors $(grep -c "Script error" $L), compile errors $(grep -cE "Attempt to|Execution could not continue|Unknown identifier" $L), VM aborts $(grep -ci "VM execution aborted" $L)"
  python3 $D/trt_check.py $L
done
