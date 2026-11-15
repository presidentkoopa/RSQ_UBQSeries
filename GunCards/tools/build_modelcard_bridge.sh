#!/bin/sh
# build_modelcard_bridge.sh [out.pk3] -- RSQ Gun Cards' BD22 VR bridge: the small card drawn by models on BD22 VR
# Reloaded's off-hand guns (bridge_bd22vr/, written by tools/gen_modelcard.py). Load it with BD22 VR (anywhere after
# it); without BD22 VR it must not be loaded (QuestZDoom 17.3 refuses a MODELDEF block for a class that is not there).
# The models and skins are in RSQ_GunCards.pk3; this holds only the blocks and the list of guns.
set -e
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$HERE/../pk3/RSQ_GunCards_BD22VR.pk3}"
case "$OUT" in /*) ;; *) OUT="$(pwd)/$OUT" ;; esac
cd "$HERE/bridge_bd22vr"
rm -f "$OUT"
zip -q -r -X "$OUT" MODELDEF.txt models
echo "built $OUT"
