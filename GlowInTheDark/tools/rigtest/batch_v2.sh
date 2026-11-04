#!/bin/bash
# TEST ONLY. The v2 proof: reactions, extensions, profiles, re-rolls, DarkDoomZ, lights, the real mods, perf.
cd "$(dirname "$0")"
NEW=/home/claude/RSQ_UBQSeries/pk3/RSQ_GlowInTheDark.pk3
OLD=/mnt/user-data/attachments/01ebc270-3953-5301-831b-c73a8b1320ca/4eb37ffb-Environmental_Lighting03_GlowInTheDark.pk3
DD=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/glow/dd
P=/home/claude/RSQ_UBQSeries/pk3
FIX="rsqgd_reroll 0; rsqgd_debug 2"
A="11 -400 1900 180"; B="2 900 1100 60"; C="22 -600 480 45"
S() { ./shoot.sh "$@" > /dev/null; }
# 1 the default (Classic 1.1) next to the old pk3
S v_A_old $A "echo" $OLD
S v_A_new $A "rsqgd_debug 2" $NEW
S v_B_new $B "rsqgd_debug 2" $NEW
# 2 miniboss tint (test trigger), without and with DarkDoomZ
S v_A_fix $A "$FIX" $NEW
POST="netevent rsqgd_test_mb 1" HOLD=90 S v_A_mb $A "$FIX" $NEW
S v_A_ddz $A "$FIX" $DD $NEW
POST="netevent rsqgd_test_mb 1" HOLD=90 S v_A_ddz_mb $A "$FIX" $DD $NEW
S v_A_ddzonly $A "echo" $DD
# 3 level-up wave, three moments
for h in 4 10 18; do POST="netevent rsqgd_test_wave" HOLD=$h S v_A_wave$h $A "$FIX" $NEW; done
POST="netevent rsqgd_test_wave" HOLD=8 S v_B_wave8 $B "$FIX" $NEW
S v_B_fix $B "$FIX" $NEW
# 4 combo chain
POST="netevent rsqgd_test_combo 4" HOLD=60 S v_B_combo4 $B "$FIX" $NEW
POST="netevent rsqgd_test_combo 10" HOLD=60 S v_B_combo10 $B "$FIX" $NEW
# 5 slow motion
POST="netevent rsqgd_test_slowmo 250" HOLD=60 S v_A_slowmo $A "$FIX" $NEW
POST="netevent rsqgd_test_slowmo 250" HOLD=60 S v_B_slowmo $B "$FIX" $NEW
# 6 living liquid and a splash flare
HOLD=21 S v_C_live $C "$FIX" $NEW
POST="netevent rsqgd_test_flare" HOLD=6 S v_C_flare $C "$FIX" $NEW
HOLD=21 S v_C_still $C "$FIX; rsqgd_living 0" $NEW
# 7 locked doors in key colours
for spot in "d03 3 4304 2728 90" "d10 10 -1048 -1120 180" "d05 5 1664 -632 180"; do set -- $spot
  S v_${1}_off $2 $3 $4 $5 "$FIX; rsqgd_things 0" $NEW; S v_${1}_on $2 $3 $4 $5 "$FIX" $NEW; done
# 8 re-roll on map load (Every Map): the same spot twice
S v_B_roll1 $B "rsqgd_debug 1" $NEW; S v_B_roll2 $B "rsqgd_debug 1" $NEW
# 9 re-roll on death: die, restart the map, look again
SECS=120 HOLD=30 POST="god; kill; wait 50; +use; wait 2; -use; wait 40; netevent rsgdp_tp 900 1100 60" S v_B_death $B "rsqgd_reroll 2; rsqgd_debug 1" $NEW
# 10 profiles contact sheet (fixed seed), room B and the nukage room A
for p in 3 4 5 6 7 9 10 13 14 17 20 25 28 29 33 35; do S v_B_p$p $B "$FIX; rsqgd_profile $p" $NEW; done
for p in 4 9 12 16 19 26; do S v_A_p$p $A "$FIX; rsqgd_profile $p" $NEW; done
# 11 PCVR lights, Normal and Subdued
S v_A_lights $A "$FIX; rsqgd_liq_lights 4; rsqgd_item_lights 6; rsqgd_light_style 0" $NEW
S v_A_lights_sub $A "$FIX; rsqgd_liq_lights 4; rsqgd_item_lights 6; rsqgd_light_style 1" $NEW
# 12 the real mods
POST="netevent rsqmb_choose" HOLD=120 SECS=150 S v_B_realmb $B "$FIX" $P/RSQ_Miniboss.pk3 $NEW
POST="netevent rsqsm_start:test 4000 25 0" HOLD=40 S v_A_realsm $A "$FIX" $P/RSQ_SlowMo.pk3 $NEW
POST="netevent bonsai-debug,w-xp,5000" HOLD=12 S v_A_realgb $A "$FIX" /home/claude/scratch/upg/GunBonsai-0.10.6.pk3 $P/RSQ_GunBonsaiVR.pk3 $NEW
POST="kill monsters" HOLD=40 S v_B_realsc $B "$FIX" $P/RSQ_Score.pk3 $NEW
# 13 perf: freedoom2 MAP12 (863 sectors), still and animated + tint
IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=150 HOLD=200 S v_perf_still 12 0 0 0 "rsqgd_debug 2; echo" $NEW
IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=150 HOLD=200 POST="netevent rsqgd_test_mb 1; netevent rsqgd_test_combo 6" S v_perf_anim 12 0 0 0 "rsqgd_debug 2; rsqgd_profile 20" $NEW
echo BATCH DONE
