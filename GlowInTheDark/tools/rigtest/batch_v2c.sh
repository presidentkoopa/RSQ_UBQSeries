#!/bin/bash
# TEST ONLY. Third part: locked doors (probe camera), the splash flare, perf with animation.
cd "$(dirname "$0")"
NEW=/home/claude/RSQ_UBQSeries/pk3/RSQ_GlowInTheDark.pk3
FIX="rsqgd_reroll 0; rsqgd_debug 1"
S() { ./shoot.sh "$@" > /dev/null; }
export DUMP=3
for spot in "3 0" "5 0" "10 0" "10 1" "4 0"; do set -- $spot
  CAM="netevent rsgdp_door $2" S x_d$1_$2_off $1 0 0 0 "$FIX; rsqgd_things 0" $NEW
  CAM="netevent rsgdp_door $2" S x_d$1_$2_on $1 0 0 0 "$FIX" $NEW
  CAM="netevent rsgdp_door $2" POST="give all" HOLD=50 S x_d$1_$2_key $1 0 0 0 "$FIX" $NEW
done
POST="netevent rsqgd_test_flare" HOLD=12 S x_C_flare 22 -600 480 45 "$FIX" $NEW
IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=200 HOLD=250 POST="netevent rsqgd_test_mb 1; netevent rsqgd_test_combo 6" S x_perf_anim 12 0 0 0 "rsqgd_debug 2; rsqgd_profile 20" $NEW
echo BATCH DONE
