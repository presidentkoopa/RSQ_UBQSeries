#!/bin/bash
# (copied from /home/claude/scratch/hsrig/run.sh: the 2026-11-09 rig run; the probe pk3 was zipped from probe/ into /tmp/hsprobe.pk3, never into the repo)
# ONE rig session (owner's allowance, 2026-11-09): RSQ Score head-shot proof + RSQ Miniboss mockup backgrounds.
set -u
T=/home/claude/scratch/hsrig; G=/home/claude/gamedata; R=/home/claude/rsq_ubqseries
RIG=/home/claude/rsq_weapondepot/tools/rig/bin
D=$T/frames; rm -rf $D; mkdir -p $D
P=$(ls $R/pk3/RSQ_*.pk3 | xargs -n1 realpath | tr '\n' ' ')
BDVR=/home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.4c.pk3
/home/claude/scratch/trux/tools/squeeze.sh $D & SQPID=$!
S='bd_tips 0; screenblocks 12; crosshair 0; show_messages 0; set champion_OverrideChance 0; set rsqmb_enabled 0; set rs_score_slowmo 0; set rs_score_hitstop 0; set rs_score_hs_log 1; set rs_score_debug 1; wait 2750; quit'
QZ_DUMP_EVERY=1 QZ_DUMP_DIR=$D QZ_RES=960 EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout 2400 "$RIG/qz" -iwad $G/doom2.wad -file $G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 $BDVR \
  $G/LOB_v1.05.pk3 $G/mk-champions20210309.pk3 $G/GunBonsai-0.10.6.pk3 $P /tmp/hsprobe.pk3 -nosound \
  +logfile $T/run.log -warp 02 -skill 3 "+$S" > $T/run.out 2>&1
RC=$?; touch $D/.stop; wait $SQPID; rm -f $D/.stop
git -C /home/claude/rsq_weapondepot checkout -q tools/rig/bin/config/qzdoom.ini
echo "rc=$RC frames=$(ls $D | wc -l) errors=$(grep -c 'Script error' $T/run.log)"
