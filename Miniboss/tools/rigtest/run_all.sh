#!/bin/bash
# TEST ONLY (2026-11-03): every rig run for the "Counts as a Boss" switches, and the key lines into evidence_1103.txt.
# Needs: the rig (tools/rig17), /home/claude/iwad/doom2/doom2.wad, Gun Bonsai 0.10.6 (/home/claude/scratch/upg),
# LegenDoom Lite 4.2 zipped as /home/claude/scratch/LegenDoomLite_4.2.pk3, the load order in /home/claude/scratch/lo2
# with 03 from rs_brutal22weaponsq/pk3. Rig only, not headset-confirmed.
T=$(cd "$(dirname "$0")" && pwd); R=$(cd "$T/../../.." && pwd); L=/home/claude/scratch/logs
GB=/home/claude/scratch/upg/GunBonsai-0.10.6.pk3; LDL=/home/claude/scratch/LegenDoomLite_4.2.pk3
MB=$R/pk3/RSQ_Miniboss.pk3; BP=$T/bossprobe.pk3
(cd $T/ldprobe && rm -f ../ldprobe.pk3 && zip -q -r ../ldprobe.pk3 .)
# the Grapple's GRV room (TEST ONLY, gitignored): built by its own script when missing
GRV=$R/Grapple/tools/rigtest/og_1103/grv.pk3
[ -f $GRV ] || (cd $R/Grapple/tools/rigtest/og_1103 && mkdir -p probe/maps && python3 mkmap.py probe/maps/GRV.wad && cd probe && zip -q -r ../grv.pk3 .)
$T/run.sh mb_flags 60 "$MB $BP" "$(cat $T/flags_script.txt)"
$T/run.sh mb_rewards 60 "$GB $R/pk3/RSQ_GunBonsaiVR.pk3 $MB $BP" "$(cat $T/rewards_script.txt)"
$T/run.sh mb_ld_gb 60 "$LDL $GB $R/pk3/RSQ_GunBonsaiVR.pk3 $R/pk3/RSQ_ShieldSaw.pk3 $MB $BP $T/ldprobe.pk3" "$(cat $T/ld_gb_script.txt)"
$T/run.sh mb_grapple 75 "$R/pk3/RSQ_Grapple.pk3 $GRV $MB $BP" "$(cat $T/grapple_script.txt)"
for v in 1 0; do
  (exec 9>/home/claude/rig.lock; flock -x 9; PRE="$MB $BP" OUT=/home/claude/scratch/mbwhip bash $R/Whip/tools/rigtest/whp.sh mb_whip$v 60 "$(cat $T/whip_yank_noyank$v.txt)" | grep "script errors")
  cp /home/claude/scratch/mbwhip/logs/mb_whip$v.log $L/
  $T/melee_run.sh mb_headlock$v $T/headlock_noheadlock$v.txt
done
ALL="$(ls $R/pk3/RSQ_*.pk3 | grep -v GunBonsaiVR | tr '\n' ' ')"
LO="/home/claude/scratch/lo2/01_brutal22test6.pk3 /home/claude/scratch/lo2/02_BD22_VoxelPack.pk3 /home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.3p.pk3 $(ls /home/claude/scratch/lo2/0[4-7]*.pk3 | tr '\n' ' ')"
S="$(cat $T/loadorder_script.txt)"
$T/run.sh lo_mb_alone 60 "$MB" "$S"
$T/run.sh lo_gb_alone 60 "$GB $R/pk3/RSQ_GunBonsaiVR.pk3" "$S"
$T/run.sh lo_gb_allrsq 90 "$GB $R/pk3/RSQ_GunBonsaiVR.pk3 $ALL" "$S"
$T/run.sh lo_full 150 "$LO $GB $R/pk3/RSQ_GunBonsaiVR.pk3 $ALL" "$S"

E=$T/evidence_1103.txt
{
echo "# RSQ Miniboss: Counts as a Boss switches -- rig only, not headset-confirmed (qzd17.3 rig, doom2, $(date -u +%F))"
echo "## Map-wide Roar + Can't Be Morphed (doom2 + Miniboss + bossprobe)"; grep -E "^CASE_|MBP (state|t.*morph)|RSQMB flags" $L/mb_flags.log | cut -c1-200
echo "## Boss Kill Rewards (Gun Bonsai + RSQ_GunBonsaiVR, drop chance 50%: a boss always drops; imp 60 hp = 6 bits, x3 boss)"; grep -E "^CASE_|RSQ KR.*DoomImp" $L/mb_rewards.log
echo "## LegenDoom: Best Health (LegenDoom Lite 4.2, LD_legendaryhealth 300; boss 200 (default), then 400; imp 60: 300% = 180, 400% = 240)"; grep -E "^CASE_|RSQMB LegenDoom|MBP_LD|MBP t.*hurt|MBP state" $L/mb_ld_gb.log | cut -c1-170
echo "## Can't Be Yanked: Grapple (GRV room, imp 400 ahead; og fling = you fly to it, og throw / launch = it is thrown)"; grep -E "^CASE_|T_GR t[0-9]+ h0 (og throw|og fling|bite)|T_GRM (og throw|launch|land)|MBP state" $L/mb_grapple.log | cut -c1-150
for v in 1 0; do echo "## Can't Be Yanked: Whip yank, rsqmb_boss_noyank $v"; grep -E "MBP state|T_WPW .*YANK" $L/mb_whip$v.log | head -3 | cut -c1-150; done
for v in 1 0; do echo "## Can't Be Headlocked: Melee headlock (Melee probe case 4), rsqmb_boss_noheadlock $v"; grep -E "MBP state|RSQML headlock|MLP t6[036] held" $L/mb_headlock$v.log | sort | uniq -c | cut -c1-150; done
echo "## Script errors (the 4 voxeldef lines are BD_VoxelPack's own)"
for n in mb_flags mb_rewards mb_ld_gb mb_grapple mb_whip1 mb_whip0 mb_headlock1 mb_headlock0 lo_mb_alone lo_gb_alone lo_gb_allrsq lo_full; do
  echo "$n: Script error $(grep -c 'Script error' $L/$n.log) (voxeldef $(grep -c 'No sprites specified for voxel' $L/$n.log))"; done
echo "## Load orders: miniboss chosen, killed by 'kill monsters'"; for n in lo_mb_alone lo_gb_allrsq lo_full; do echo "-- $n"; grep -E "RSQMB boss|RSQ KR.*miniboss" $L/$n.log | head -3; done
} > $E
cat $E
