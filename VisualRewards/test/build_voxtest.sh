#!/bin/bash
# build_voxtest.sh -- TEST ONLY: voxtest/VOXELDEF.txt plus a copy of BD_VoxelPack's SPDEU.KVX taken from the
# rig's unpacked BD_VoxelPack at build time (third-party art: never committed, never shipped).
set -e
ME="$(cd "$(dirname "$0")" && pwd)"
SC=/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad
T=$(mktemp -d); mkdir -p $T/voxels
cp "$ME/voxtest/VOXELDEF.txt" $T/
unzip -p /mnt/user-data/uploads/DOOMWork/BD_VoxelPack.pk3 "Voxels/Decorations/SPDEU.KVX" > $T/voxels/spdeu.kvx
rm -f $SC/voxtest.pk3; (cd $T && zip -q -r -X $SC/voxtest.pk3 .); rm -rf $T
echo "built $SC/voxtest.pk3"
