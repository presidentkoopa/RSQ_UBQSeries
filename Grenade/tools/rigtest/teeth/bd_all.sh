#!/bin/bash
# TEST ONLY. bd_all.sh <tag> <BD22 pk3>: each pose scenario in its own run on the owner's BD order (brutal22test6,
# voxels, the given BD22 VR pk3, XMVE), so every scenario starts from a fresh pin.
HERE="$(cd "$(dirname "$0")" && pwd)"; TAG=$1; BD=$2; LO=/home/claude/scratch/lo2
OUT=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rig}
for s in S1 S2 S3 S4 S5 S6 S7; do
  EXTRA="+playerclass Doomer2" ONLY=$s "$HERE/run.sh" ${TAG}_$s 900 "rsr_debug 1; $(ONLY=$s "$HERE/poses.sh" bd | tr '\n' ' ')" $LO/01_brutal22test6.pk3 $LO/02_BD22_VoxelPack.pk3 "$BD" \
    $LO/04_XMVE_MonsterExpansion1.3.1-BD22.pk3 $LO/05_XMVE_MonsterExpansion_TUD.pk3 $LO/06_XMVE_MonsterExpansion_Doom2.pk3 $LO/07_XMVE_MonstersNoDropGuns-BD22.pk3 > /dev/null
  echo "== $s (script errors: $(grep -a -c 'Script error' $OUT/${TAG}_$s/log))"
  grep -a "GTP_S\|BD22 pin OUT\|RSG teeth" $OUT/${TAG}_$s/log
done
