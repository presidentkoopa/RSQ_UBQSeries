#!/bin/bash
# TEST ONLY. errcheck.sh: the three load orders, ~6 s of play each with rsqgd_debug 1; counts script errors.
cd "$(dirname "$0")"
NEW=/home/claude/RSQ_UBQSeries/pk3/RSQ_GlowInTheDark.pk3
DD=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/glow/dd
OUT=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rig}
LO=/home/claude/scratch/lo2
FULL="$LO/01_brutal22test6.pk3 $LO/02_BD22_VoxelPack.pk3 /home/claude/rs_brutal22weaponsq/pk3/03_BD22_VR-Reloaded_2.0.3q.pk3 $LO/04_XMVE_MonsterExpansion1.3.1-BD22.pk3 $LO/05_XMVE_MonsterExpansion_TUD.pk3 $LO/06_XMVE_MonsterExpansion_Doom2.pk3 $LO/07_XMVE_MonstersNoDropGuns-BD22.pk3 /home/claude/scratch/upg/GunBonsai-0.10.6.pk3 $(ls /home/claude/RSQ_UBQSeries/pk3/RSQ_*.pk3 | grep -v GlowInTheDark)"
S="rsqgd_debug 1; wait 200; netevent rsgdp_dump; ${EXTRA:-}; wait 20; quit"
check() { n=$1; shift; SECS=${SECS:-150} ./run.sh $n ${SECS:-150} "$S" "$@" > /dev/null; L=$OUT/$n/log
  echo "$n: script errors $(grep -a -c 'Script error' $L), our errors $(grep -a -i -E 'script error|VM abort|Called from|Tried to' $L | grep -a -i -c 'rsqgd\|GlowInTheDark'), voxeldef $(grep -a -i -c 'voxel' $L) | $(grep -a '\[RSQGD\]' $L | tail -1 | cut -c1-150)"; }
check e_alone $NEW
check e_ddz $DD $NEW
check e_full $FULL $NEW
check e_full_ddz $FULL $DD $NEW
