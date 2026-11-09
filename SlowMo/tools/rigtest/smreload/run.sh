#!/bin/bash
# TEST ONLY (never ships). For the ONE combined rig session at the end (owner 11-09 17:42: rig checks saved until the end): RSQ SlowMo's reload options and RSQ Tactical Rig's Dual-to-main and
# pouch reach. Order: doom2 -> brutal22test6 -> BD_VoxelPack -> BD22 VR Reloaded 2.0.4e -> LOB, Champions, Gun Bonsai ->
# this checkout's RSQ pk3s -> the probe. Log in $T/run.log.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../../.." && pwd)"
T=${T:-/home/claude/scratch/wtb_rig}; G=/home/claude/gamedata; RIG=/home/claude/rsq_weapondepot/tools/rig/bin
mkdir -p $T; (cd "$HERE" && python3 gen_script.py && rm -f $T/probe.pk3 && zip -qr $T/probe.pk3 zscript.txt MAPINFO.txt)
P=$(ls $REPO/pk3/RSQ_*.pk3 | xargs -n1 realpath | tr '\n' ' ')
BDVR=/home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.4e.pk3
D=$T/frames; rm -rf $D; mkdir -p $D
QZ_DUMP_EVERY=${EVERY:-0} QZ_DUMP_DIR=$D QZ_RES=${QZ_RES:-320} EGL_PLATFORM=surfaceless LIBGL_ALWAYS_SOFTWARE=1 \
  flock -o -x /home/claude/rig.lock timeout ${SECS:-1500} "$RIG/qz" -iwad $G/doom2.wad -file $G/brutal22test6.pk3 $G/BD_VoxelPack.pk3 $BDVR \
  $G/LOB_v1.05.pk3 $G/mk-champions20210309.pk3 $G/GunBonsai-0.10.6.pk3 $P $T/probe.pk3 -nosound \
  +logfile $T/run.log -warp 01 -skill 3 "+$(cat $HERE/script.txt)" > $T/run.out 2>&1
RC=$?
git -C /home/claude/rsq_weapondepot checkout -q tools/rig/bin/config/qzdoom.ini
echo "rc=$RC frames=$(ls $D | wc -l) errors=$(grep -c 'Script error' $T/run.log)"
