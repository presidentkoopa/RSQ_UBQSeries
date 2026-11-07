#!/bin/bash
# TEST ONLY (2026-11-06): the Bones / battery / colours / tier round's ONE batched rig check on the full load order:
#   doom2 (Freedoom stand-in) -> brutal22test6 -> BD_VoxelPack -> BD22 VR 2.0.4a -> XMVE 04-07 -> LOB_v1.05 -> every RSQ pk3
#   but GunBonsaiVR -> bonesprobe (this folder). Its own ini copy (the rig's is never written): Bones Bridge on from the map's
#   start (set, then the room loaded twice: a server / user cvar set from the console lands only after the next map load), and an old Beam Colour (12 Sky) under settings version 2 to show the move to the
#   nearest of the six (FnF's Migrate runs at that map load). (Mod cvars cannot be put in the ini: the engine refuses them.)
#   The room: mkmap.py's BONES (in bonesprobe/maps). Frames: QZ_RES 480, every 2nd frame, in $OUT/frames. Log: $OUT/log.
#   Rig only, not headset-confirmed.
set -u
R=$(cd "$(dirname "$0")/../../.." && pwd); B=/home/claude/rs_brutal22weaponsq/pk3; P=$R/pk3
OUT=${OUT:-/tmp/bones_batch}; rm -rf $OUT; mkdir -p $OUT/frames
(cd "$(dirname "$0")" && python3 -I mkmap.py bonesprobe/maps/BONES.wad && cd bonesprobe && zip -q -r -X $OUT/bonesprobe.pk3 .)
LOB=${LOB:-/mnt/user-data/uploads/6ee12fdb-LOB_v1.05.pk3}
RSQ="$(ls $P/RSQ_*.pk3 | grep -v GunBonsaiVR | tr '\n' ' ')"
LO="/home/claude/gamedata/brutal22test6.pk3 /home/claude/gamedata/BD_VoxelPack.pk3 $B/03_BD22_VR-Reloaded_2.0.4a.pk3 $B/04_XMVE_MonsterExpansion1.3.1-BD22.pk3 $B/05_XMVE_MonsterExpansion_TUD.pk3 $B/06_XMVE_MonsterExpansion_Doom2.pk3 $B/07_XMVE_MonstersNoDropGuns-BD22.pk3 $LOB $RSQ $OUT/bonesprobe.pk3"
RIG=/home/claude/rsq_weapondepot/tools/rig/bin
cp $RIG/config/qzdoom.ini $OUT/qz.ini
L1='"-0.06 1.50 -0.30 30 0 0"'; LD='"-0.2 1.0 -0.35 30 0 0"'
S="wait 20; rsqff_fl_color 12; gy_bones 1; wait 10; rsqff_cfgver 2; wait 3; map BONES; wait 30; map BONES; wait 40; gl_lights 1; god; notarget; gy_bones_debug 1; rsqff_debug 1; rsqmb_debug 1; rsqff_fl_bits 1; rsqff_fl_batt 1; rsqmb_bf_ignore 1; rsqmb_bf_cooldown 0; rsqmb_bf_graves 1; rsqmb_bf_graves_area 1; rsqmb_bf_graves_radius 640; LOB_Respawn 1; qz_hmd \"0 1.70 0 0 0 0\"; qz_rhand \"0.25 1.0 -0.30 30 0 0\"; qz_lhand $L1;
echo S_SETUP; netevent bp_setup; gy_bones 0; wait 3; netevent bp_setup; gy_bones 1; wait 3;
echo S_STONES; netevent bp_stones; netevent rsqff_fl_take; wait 10;
echo S_ROW; netevent bp_row 500; wait 15; netevent bp_kill; wait 5; netevent bp_block; wait 120;
echo S_REP1; netevent bp_rep; wait 100; netevent bp_rep; netevent bp_unblock; wait 180; netevent bp_rep;
echo S_EMPTY; netevent bp_charge 0; wait 5; netevent rsqff_fl_toggle; wait 10; netevent bp_charge 500; wait 3; netevent rsqff_fl_toggle; wait 10;
echo S_BEAM; netevent bp_charge 300; wait 5; netevent bp_beamkill; wait 10;
echo S_LOB; netevent bp_clearundead; netevent bp_charge 200; netevent bp_lobkill 40; wait 80; netevent bp_bitdirect; wait 60; netevent bp_rep;
echo S_RISE; netevent bp_clearundead; LOB_Respawn 0; qz_lhand $LD; netevent bp_row 420 1; wait 15; netevent bp_kill; wait 90; netevent bp_rep;
echo S_TIER; netevent bp_lives 2; rsqmb_bf_tier_from 0; wait 3; netevent bp_tier1; rsqmb_bf_tier_from 1; wait 3; netevent bp_tier1; rsqmb_bf_tier_from 2; wait 3; netevent bp_tier1; rsqmb_bf_tier_from 3; wait 3; netevent bp_tier1;
echo S_BEAT; netevent bp_clearundead; netevent bp_ready; wait 140; echo S_PHOTO; rsqa_photosafe 1; wait 100; rsqa_photosafe 0;
echo S_CALLIN; netevent rsqmb_callin; wait 220; netevent bp_rep;
echo S_MAPGRAVES; netevent bp_graves_map; wait 120; netevent bp_rep; echo S_END; quit"
S=$(echo "$S" | tr '\n' ' ')
cd $RIG && QZ_RES=480 QZ_DUMP_EVERY=${EVERY:-2} QZ_DUMP_DIR=$OUT/frames timeout ${SECS:-900} flock -o -x /home/claude/rig.lock ./qz -config $OUT/qz.ini \
  -iwad /home/claude/gamedata/doom2.wad -file $LO -nosound -warp 1 -skill 3 +logfile $OUT/log "+$S" < /dev/null > $OUT/out 2>&1
echo "rc=$? log $OUT/log, $(ls $OUT/frames | wc -l) frames"
echo "script errors (not BD_VoxelPack's voxeldef): $(grep -a -i 'script error\|VM abort' $OUT/log | grep -v -c voxeldef)"
