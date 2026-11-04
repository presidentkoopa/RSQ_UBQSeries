#!/bin/bash
# TEST ONLY. The whole v2 proof in one go (frames in $OUT/shots, logs in $OUT/s_<name>/log).
cd "$(dirname "$0")"
NEW=/home/claude/RSQ_UBQSeries/pk3/RSQ_GlowInTheDark.pk3
OLD=/mnt/user-data/attachments/01ebc270-3953-5301-831b-c73a8b1320ca/4eb37ffb-Environmental_Lighting03_GlowInTheDark.pk3
DD=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/glow/dd
P=/home/claude/RSQ_UBQSeries/pk3
FIX="rsqgd_reroll 0; rsqgd_debug 1"
A="11 -400 1900 180"; B="2 900 1100 60"; C="22 -600 480 45"
OUT=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rsqgd_rig}
S() { [ -f "$OUT/shots/$1.png" ] && return; ./shoot.sh "$@" > /dev/null; }
export DUMP=3
S A_old $A "echo" $OLD
S A_new $A "rsqgd_debug 1" $NEW
S A_fix $A "$FIX" $NEW
POST="netevent rsqgd_test_mb 1" HOLD=90 S A_mb $A "$FIX; rsqgd_debug 2" $NEW
S A_ddzonly $A "echo" $DD
S A_ddz $A "$FIX" $DD $NEW
POST="netevent rsqgd_test_mb 1" HOLD=90 S A_ddz_mb $A "$FIX" $DD $NEW
for h in 18 28; do POST="netevent rsqgd_test_wave" HOLD=$h S A_wave$h $A "$FIX" $NEW; done
S B_fix $B "$FIX" $NEW
POST="netevent rsqgd_test_wave" HOLD=14 S B_wave14 $B "$FIX" $NEW
POST="netevent rsqgd_test_combo 10" HOLD=60 S B_combo10 $B "$FIX" $NEW
POST="netevent rsqgd_test_slowmo 250" HOLD=60 S A_slowmo $A "$FIX" $NEW
POST="netevent rsqgd_test_slowmo 250" HOLD=60 S B_slowmo $B "$FIX" $NEW
HOLD=12 S C_noflare $C "$FIX" $NEW
POST="netevent rsqgd_test_flare" HOLD=12 S C_flare $C "$FIX" $NEW
HOLD=21 S C_still $C "$FIX; rsqgd_living 0" $NEW
for spot in "3 0" "5 0" "10 1" "4 0"; do set -- $spot
  CAM="netevent rsgdp_door $2" S d$1_off $1 0 0 0 "$FIX; rsqgd_things 0" $NEW
  CAM="netevent rsgdp_door $2" S d$1_on $1 0 0 0 "$FIX" $NEW
  CAM="netevent rsgdp_door $2" POST="give all" HOLD=50 S d$1_key $1 0 0 0 "$FIX" $NEW
done
S B_roll1 $B "rsqgd_debug 1" $NEW; S B_roll2 $B "rsqgd_debug 1" $NEW
SECS=150 HOLD=30 POST="god; kill; wait 50; +use; wait 2; -use; wait 40; netevent rsgdp_tp 900 1100 60" S B_death $B "rsqgd_reroll 2; rsqgd_debug 1" $NEW
for p in 2 4 7 9 10 13 14 17 20 26 33 35; do S B_p$p $B "$FIX; rsqgd_profile $p" $NEW; done
for p in 4 12 19; do S A_p$p $A "$FIX; rsqgd_profile $p" $NEW; done
S A_lights $A "$FIX; rsqgd_debug 2; rsqgd_liq_lights 4; rsqgd_item_lights 6; rsqgd_light_style 0" $NEW
S A_lights_sub $A "$FIX; rsqgd_debug 2; rsqgd_liq_lights 4; rsqgd_item_lights 6; rsqgd_light_style 1" $NEW
POST="netevent rsqmb_choose" HOLD=120 SECS=150 S B_realmb $B "$FIX; rsqgd_debug 2" $P/RSQ_Miniboss.pk3 $NEW
POST="netevent rsqsm_start:test 4000 25 0" HOLD=40 S A_realsm $A "$FIX; rsqgd_debug 2" $P/RSQ_SlowMo.pk3 $NEW
POST="netevent bonsai-debug,w-xp 600000" HOLD=20 SECS=150 S A_realgb $A "$FIX; rsqgd_debug 2" /home/claude/scratch/upg/GunBonsai-0.10.6.pk3 $P/RSQ_GunBonsaiVR.pk3 $NEW
DUMP=0 IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=200 HOLD=250 S perf_still 12 0 0 0 "rsqgd_debug 2" $NEW
DUMP=0 IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=200 HOLD=250 POST="netevent rsqgd_test_mb 1; netevent rsqgd_test_combo 6" S perf_anim 12 0 0 0 "rsqgd_debug 2; rsqgd_profile 20" $NEW
DUMP=0 IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=200 HOLD=250 POST="netevent rsqgd_test_mb 1; netevent rsqgd_test_combo 6" S perf_anim_pcvr 12 0 0 0 "rsqgd_debug 2; rsqgd_profile 20; rsqgd_budget 512" $NEW
echo BATCH DONE
