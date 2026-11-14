#!/bin/bash
# rcD_run.sh NAME SECS "$(rcD_script.py ...)": TEST ONLY rig run: rcE_full.sh (owner's full order, his ini, -skill 6) with this worktree's
# pk3s (RSQ Monsters with the art driver, RSQ_BDXMTiers_<Colour>), rig01 and the rcD demo (RCD_PK3: rcDdemo zipped).
# Test-only settings: Universal Entropy recolour, laser sight, Kill Rewards, bars, damage numbers, weapon and crosshair off.
N=$1; S=$2; SC=$3
export EXTRA="+set sv_cheats 1 +set ue_recolour 0 +set rsqls_on 0 +set rsqgb_kr_enabled 0 +set rsqthp_on 0 +set rsqthp_dmg 0 +set r_drawplayersprites 0 +set crosshair 0 $EXTRA2"
export Q=/home/claude/wt_rcD
cd /home/claude/wt_rcD/Monsters/tools/recolour/rig
flock /home/claude/rig.lock bash ./rcE_full.sh "$N" "$S" "$SC" /home/claude/wt_rcD/TestRig/maps/rig01.wad ${RCD_PK3:-/tmp/rcD/rcd.pk3}
