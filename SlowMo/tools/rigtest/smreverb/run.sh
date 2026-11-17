#!/bin/bash
# TEST ONLY (never ships). RSQ SlowMo "LiveReverb Only When Down": the order of the sound-environment writes in each tic.
#   run.sh <name> <SlowMo dir, a copy: its reverb.zs gets ONE trace line> [EXTRA cvars]
# Builds the copy with tools/build_all.py, swaps it into hardlinks of the gate set, runs the owner's full order
# (boss_full.sh, MAP01, LiveReverb loaded) with this probe, and prints rv_order.py's table. Rig paths are the 11-17 rig's.
set -eu
N=$1; SM=$2; X=${3:-}
HERE="$(cd "$(dirname "$0")" && pwd)"; W=/tmp/smreverb_$N; rm -rf $W; mkdir -p $W/hub/tools $W/P
cp "$HERE/../../../../tools/build_all.py" $W/hub/tools/; cp -r "$SM" $W/hub/SlowMo
sed -i 's|^\(\t*\)pmo.CurSector.SetEnvironmentID(env);|&\n\1Console.Printf("RV t%d SlowMo write env %d", level.maptime, env);   // RIG TRACE ONLY|' $W/hub/SlowMo/zscript/rsqsm/reverb.zs
(cd $W/hub && python3 tools/build_all.py SlowMo)
ln /home/claude/rig/work/gate_rel4/*.pk3 $W/P/; rm $W/P/RSQ_SlowMo.pk3; cp $W/hub/pk3/RSQ_SlowMo.pk3 $W/P/
(cd "$HERE" && rm -f $W/probe.pk3 && zip -q -X $W/probe.pk3 zscript.txt MAPINFO.txt)
P=$W/P BDVR=/mnt/user-data/outputs/rel4/BD22_VR-Reloaded_2.0.5a.pk3 MAP=01 EVERY=100 EXTRA="+set rsqsm_debug 1 $X" \
  flock /home/claude/rig.lock /home/claude/rig/work/boss/boss_full.sh $N 590 "sv_cheats 1; notarget; wait 560; wait 10; quit" $W/probe.pk3
python3 -I "$HERE/rv_order.py" /home/claude/rig/work/runs/$N/run.log $N
