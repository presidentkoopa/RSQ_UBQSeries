#!/bin/sh
# TEST ONLY, never ships (2026-11-03): grv.pk3 (GRV room + GRV_Probe, logs the player's / a monster's velocity every tic)
# and jp_og.pk3 (jp_original/ packed as-is, so jpalomo's own hook runs on the rig for comparison).
# Then e.g.:  PK3S="$PWD/jp_og.pk3 $PWD/grv.pk3" ./run.sh og1 220 "$(python3 seq.py og)"
#             PK3S="<repo>/pk3/RSQ_Grapple.pk3 $PWD/grv.pk3" ./run.sh ours1 220 "$(python3 seq.py ours 'rsqgr_debug 1')"
#             python3 arc.py <logs>/og1.log <logs>/ours1.log
cd "$(dirname "$0")" && mkdir -p probe/maps && python3 mkmap.py probe/maps/GRV.wad && (cd probe && rm -f ../grv.pk3 && zip -q -r ../grv.pk3 .) && \
J=../../../jp_original && rm -rf og && mkdir og && cp -r $J/decorate.txt $J/loadacs $J/acs $J/sndinfo.txt $J/sounds $J/sprites og/ && \
(cd og && rm -f ../jp_og.pk3 && zip -q -r ../jp_og.pk3 .) && rm -rf og && echo built grv.pk3 jp_og.pk3
