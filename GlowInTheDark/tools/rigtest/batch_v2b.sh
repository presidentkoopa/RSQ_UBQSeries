#!/bin/bash
# TEST ONLY. Second half of the v2 proof (after the wave/darken fixes).
cd "$(dirname "$0")"
NEW=/home/claude/RSQ_UBQSeries/pk3/RSQ_GlowInTheDark.pk3
DD=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/glow/dd
P=/home/claude/RSQ_UBQSeries/pk3
FIX="rsqgd_reroll 0; rsqgd_debug 2"
A="11 -400 1900 180"; B="2 900 1100 60"; C="22 -600 480 45"
S() { ./shoot.sh "$@" > /dev/null; }
export DUMP=3
for h in 10 18 28; do POST="netevent rsqgd_test_wave" HOLD=$h S w_A_wave$h $A "$FIX" $NEW; done
POST="netevent rsqgd_test_wave" HOLD=14 S w_B_wave14 $B "$FIX" $NEW
POST="netevent rsqgd_test_flare" HOLD=12 S w_C_flare $C "$FIX" $NEW
HOLD=12 S w_C_noflare $C "$FIX" $NEW
POST="netevent rsqgd_test_mb 1" HOLD=90 S w_A_ddz_mb $A "$FIX" $DD $NEW
for p in 4 5 6 7; do S v_B_p$p $B "$FIX; rsqgd_profile $p" $NEW; done
POST="netevent bonsai-debug,w-xp,5000" HOLD=80 SECS=150 S w_A_realgb $A "$FIX" /home/claude/scratch/upg/GunBonsai-0.10.6.pk3 $P/RSQ_GunBonsaiVR.pk3 $NEW
IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=200 HOLD=250 S w_perf_still 12 0 0 0 "rsqgd_debug 2" $NEW
IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=200 HOLD=250 POST="netevent rsqgd_test_mb 1; netevent rsqgd_test_combo 6" S w_perf_anim 12 0 0 0 "rsqgd_debug 2; rsqgd_profile 20" $NEW
IWAD=/home/claude/iwad/freedoom-0.13.0/freedoom2.wad SECS=200 HOLD=250 S w_perf_none 12 0 0 0 "echo"
echo BATCH DONE
