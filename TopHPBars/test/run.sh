#!/bin/bash
# run.sh <name> <secs> <console script> [order] -- the test pk3 on rig A (/home/claude/scratch/run17A.sh).
#   order v     doom2 + ours (default)
#         vm    doom2 + Champions + LegenDoom Lite 4.2 + ours   (ld / ch: only one of them)
#         full  doom2 -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions -> LegenDoom Lite
#               -> the UBQ suite pk3s -> ours (the owner's order, 10-27)
#         fullnm  the same without the two monster mods
# PRE= pk3s loaded just before ours (e.g. coldcite's own). EXTRA= more pk3s appended after ours (e.g. damnums). FRAMES=n dumps every n-th eye frame as PNG.
SC=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad
T=${TESTPK3:-$SC/rsqthp_test.pk3}
D=/mnt/user-data/uploads/DOOMWork; U=/home/claude/scratch/ubq_zip
M=$SC/mod   # this round's builds of the grapple, shield and saber (marker answers)
CH=$SC/monmods/ch.pk3; LD="/mnt/user-data/attachments/01ebc270-3953-5301-831b-c73a8b1320ca/a95b1a86-LegenDoomLite_4.2.pk3.zip"
SUITE="$U/UltraBadassQuestSaber.pk3 $U/UltraBadassShieldSaw.pk3 $U/RSQ_TacticalRig.pk3 $U/RSQ_SlowMo.pk3 $U/RSQ_DistanceGrab.pk3 $U/RSQ_LaserSight.pk3 $U/RSQ_Grapple.pk3 $U/RSQ_Score.pk3"
BD="$D/brutal22test6.pk3 $D/BD_VoxelPack.pk3 $D/BD22_VR-Reloaded_1.99x-lb-r7-saveload.pk3"
case "${4:-v}" in
  v) P="$PRE $T";;
  vm) P="$CH $LD $PRE $T";;
  ld) P="$LD $PRE $T";;
  ch) P="$CH $PRE $T";;
  gr) P="$U/RSQ_Grapple.pk3 $PRE $T";;
  mk) P="$M/RSQ_Grapple.pk3 $M/UltraBadassShieldSaw.pk3 $M/UltraBadassQuestSaber.pk3 $PRE $T";;
  fullmk) P="$BD $CH $LD $U/RSQ_TacticalRig.pk3 $U/RSQ_SlowMo.pk3 $U/RSQ_DistanceGrab.pk3 $U/RSQ_LaserSight.pk3 $U/RSQ_Score.pk3 $M/RSQ_Grapple.pk3 $M/UltraBadassShieldSaw.pk3 $M/UltraBadassQuestSaber.pk3 $PRE $T";;
  full) P="$BD $CH $LD $SUITE $PRE $T";;
  fullnm) P="$BD $SUITE $PRE $T";;
esac
export PK3S="$P $EXTRA"
F=$SC/frames/$1; rm -rf $F
if [ -n "$FRAMES" ]; then mkdir -p $F; export QZ_DUMP_EVERY=$FRAMES QZ_DUMP_DIR=$F; fi
/home/claude/scratch/run17A.sh "$1" "$2" "$3"
if [ -n "$FRAMES" ]; then
  python3 -c "
import glob
from PIL import Image
for f in glob.glob('$F/*.ppm'):
    Image.open(f).save(f[:-4]+'.png')
"; rm -f $F/*.ppm; echo "frames: $(ls $F | wc -l) in $F"; fi
grep -n -i -E "script error|VM abort|exception|Called from|Tried to|unknown" /home/claude/scratch/logsA/$1.log | grep -v -i voxeldef | head -20
