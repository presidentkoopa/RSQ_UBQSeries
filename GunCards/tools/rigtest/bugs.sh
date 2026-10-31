#!/bin/bash
# TEST ONLY. The 2026-10-31 sweep's two bugs and two picks, one run: PK3=<pk3> OUT=<dir> tools/rigtest/bugs.sh <name>
#  WATCH  the watch check (no RSQ Gestures: forearm across, wrist before the eyes) with Show Cards Off, then the hand
#         away: the small card's layers (GCT layers=N/..) must stay 0 while the watch card (side=N) fades
#  WORLD  the world small card's Left / Right slider: GCW "across view" must change, "along forearm" must not
#  RELOAD Show Cards: On Reload (4), a gun in each hand: the main card on +mh_reload only, the off card on +oh_reload only
HERE="$(cd "$(dirname "$0")" && pwd)"
S='god; notarget; set rsqgct_every 1; rsqgc_card 0; rsqgc_watch 1; rsqgc_linger 10; rsqgc_fade 4; wait 60;'
S="$S"' echo POSE_WATCH; qz_rhand "0.0 1.45 -0.3 0 90 0"; wait 50; echo POSE_AWAY; qz_rhand "0.25 1.0 -0.2 0 0 0"; wait 50;'
S="$S"' set rsqgct_every 5; echo WORLD_SIDE0; rsqgc_card 1; rsqgc_watch 0; rsqgc_world 1; qz_rhand "0.25 1.3 -0.3 -11 -30 90"; wait 30;'
S="$S"' echo WORLD_SIDE20; rsqgc_side 20; wait 30; echo WORLD_IN6; rsqgc_side 0; rsqgc_in 6; wait 30; rsqgc_in 0; rsqgc_world 0;'
if [ -n "${PICKS:-}" ]; then
S="$S"' echo RELOAD_MODE; rsqgc_card 4; rsqgc_linger 20; netevent rsqgct_offgun; wait 60;'
S="$S"' echo PRESS_MAIN; +mh_reload; wait 10; -mh_reload; wait 60; echo PRESS_OFF; +oh_reload; wait 10; -oh_reload; wait 60;'
fi
S="$S"' quit'
exec "$HERE/run.sh" "$1" 400 "$S"
