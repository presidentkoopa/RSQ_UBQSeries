#!/bin/bash
# TEST ONLY (2026-11-03): every run behind Grapple/test/evidence/gb_1103.txt, then the key lines into it.
cd "$(dirname "$0")"; ./build.sh >/dev/null
R=/home/claude/RSQ_UBQSeries; G=$R/Grapple/tools/rigtest/og_1103/grv.pk3; B=/home/claude/scratch/upg/GunBonsai-0.10.6.pk3
LOGS=/home/claude/scratch/logs; OUT=$R/Grapple/test/evidence/gb_1103.txt
ALL=$(ls $R/pk3/RSQ_*.pk3 | tr '\n' ' '); LO=/home/claude/scratch/lo2
FULL="$LO/01_brutal22test6.pk3 $LO/02_BD22_VoxelPack.pk3 /home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.3o.pk3 $LO/04_XMVE_MonsterExpansion1.3.1-BD22.pk3 $LO/05_XMVE_MonsterExpansion_TUD.pk3 $LO/06_XMVE_MonsterExpansion_Doom2.pk3 $LO/07_XMVE_MonstersNoDropGuns-BD22.pk3 $B $ALL"
GB="$B $R/pk3/RSQ_GunBonsaiVR.pk3 $R/pk3/RSQ_Grapple.pk3 $R/pk3/RSQ_Melee.pk3 $G $PWD/gbp.pk3"
PK3S="$GB" ./run.sh gbfr 200 "$(python3 seq.py fastreel)"
for m in twin0 twin1 twin2; do PK3S="$GB" ./run.sh gb$m 120 "$(python3 seq.py $m)"; done
PK3S="$GB" ./run.sh gbsc 150 "$(python3 seq.py scorpion)"
PK3S="$GB" ./run.sh gbex 60 "$(python3 seq.py extreme)"
PK3S="$R/pk3/RSQ_Grapple.pk3 $G" ./run.sh d2gr 60 "$(python3 seq.py fastreel)"
PK3S="$B $R/pk3/RSQ_GunBonsaiVR.pk3" ./run.sh d2gb 30 "wait 30; quit"
PK3S="$B $ALL $G $PWD/gbp.pk3" ./run.sh d2all 200 "$(python3 seq.py scorpion)"
PK3S="$FULL $G $PWD/gbp.pk3" ./run.sh fullfr 300 "$(python3 seq.py fastreel)"
PK3S="$FULL $G $PWD/gbp.pk3" ./run.sh fullsc 300 "$(python3 seq.py scorpion)"
K='^(SHOT|HANG|REEL|TAP|DROP|OFFERS)|^GBP|og fling f|og throw [A-Z]|fire speed|arrived|stopped short|scorpion|twin lines|h. (latch|drop|letgo) '
{
echo "# Gun Bonsai VR x Grapple, 2026-11-03 (rig only, not headset-confirmed). Kit: Grapple/tools/rigtest/gb_1103 (evidence.sh)."
for n in gbfr gbtwin0 gbtwin1 gbtwin2 gbsc gbex fullfr fullsc; do echo; echo "## $n"; grep -E "$K" $LOGS/$n.log | sed -E 's/ segs.*//' | cut -c1-200; done
echo; echo "## imp hp around Scorpion's arrivals (gbsc, the probe's M lines)"
grep -E "^M t(13[89]|14[01]|26[6-9]|37[4-7]|46[6-9]) " $LOGS/gbsc.log | sed -E 's/ dv\(.*\|vxy\|/ |vxy|/' | cut -c1-140
echo; echo "## Twin Lines 1, the hang and the right reel alone (gbtwin1, every 6th rope line)"
grep -E "^T_GR t(2[3-9][0-9]|30[0-9]) h. (swing|reel)" $LOGS/gbtwin1.log | awk 'NR%6==1' | sed -E 's/ segs.*//'
echo; echo "## the fling's track, Fast Reel 4 from 600, and Long Line 4 + Fast Reel 4 from 1380 (stops on the wall at 2383.5)"
grep -E "^V t(28[2-9]|29[0-4]) " $LOGS/gbfr.log | sed -E 's/ dv\(.*//'
grep -E "^V t(12[0-9]|13[0-2]) " $LOGS/gbex.log | sed -E 's/ dv\(.*//'
echo; echo "## Script errors"
for n in gbfr gbtwin0 gbtwin1 gbtwin2 gbsc gbex d2gr d2gb d2all fullfr fullsc; do echo "$n: $(grep -c 'Script error' $LOGS/$n.log) ($(grep -A1 'Script error' $LOGS/$n.log | grep -c 'No sprites specified for voxel') of them BD_VoxelPack's voxeldef)"; done
echo "gb* = doom2 -> GunBonsai 0.10.6 -> RSQ_GunBonsaiVR -> RSQ_Grapple -> RSQ_Melee (+ test probes); d2gr = doom2 -> RSQ_Grapple; d2gb = doom2 -> GunBonsai -> RSQ_GunBonsaiVR"
echo "d2all = doom2 -> GunBonsai -> every pk3/RSQ_*.pk3; full* = lo2 01, 02, 03_BD22_VR-Reloaded_2.0.3o (rs_brutal22weaponsq), 04-07 -> GunBonsai -> every pk3/RSQ_*.pk3"
} > $OUT
echo wrote $OUT
