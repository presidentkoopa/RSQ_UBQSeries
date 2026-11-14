#!/bin/bash
# rcE_full.sh <name> <secs> "<script>" [extra files]: TEST ONLY. rc2_full.sh with the recolour integration worktree
# (Q, default /home/claude/wt_rcE): his full order, his saved ini, -skill 6; RSQ Monsters (with the art driver) and the
# RSQ_MonsterArt_<Colour> pk3s come from Q/pk3. Run under flock /home/claude/rig.lock.
export Q=${Q:-/home/claude/wt_rcE}
exec "$(dirname "$(readlink -f "$0")")/rc2_full.sh" "$@"
