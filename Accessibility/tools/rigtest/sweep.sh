#!/bin/bash
# TEST ONLY. The 2026-10-31 sweep, one run: PK3=<pk3> OUT=<dir> [PICKS=1] [GDB=1] tools/rigtest/sweep.sh <name>
#  SLOWMO  Sound Cues Visual, slow motion on, cues off, slow motion off, cues on: smEdge must be 0 (no stale label)
#  LATCH   One-Handed + Hold to Toggle: the modifier latched on, save, load (it comes back off), one press: swap must be 1
#  PICKS=1 RUMBLE (44): a "ready" cue at Quake Haptics 0.8, at 0, and at 0 with Rumble Backup (GDB=1 logs T_VIBRATE)
#          BRACE (47): a gun in the off hand, the hands 25 cm apart, the off grip: stab=1, the cue (rumble + click)
#          MENU (45): Two-Hand Brace to Off through the menu (thumbstick), the grip again (stab must stay 0), then back
HERE="$(cd "$(dirname "$0")" && pwd)"
S='god; notarget; rsqat_every 5; wait 30;'
S="$S"' echo SLOWMO; rsqa_sound_cues 1; rsqat_slowmo 1; wait 20; rsqa_sound_cues 0; wait 10; rsqat_slowmo 0; wait 20; rsqa_sound_cues 1; wait 40;'
S="$S"' echo LATCH; rsqa_sound_cues 0; rsqa_onehand 1; rsqa_hold_toggle 1; wait 5; +rsqa_mod; wait 3; -rsqa_mod; wait 20; save rsqat_latch; wait 20; load rsqat_latch; wait 30;'
S="$S"' echo LATCH_PRESS; +rsqa_mod; wait 3; -rsqa_mod; wait 20; rsqa_onehand 0; rsqa_hold_toggle 0; wait 10;'
if [ -n "${PICKS:-}" ]; then
S="$S"' echo RUMBLE_Q08; rsqa_sound_cues 2; netevent rsqat_ready 1; wait 20; echo RUMBLE_Q0; vr_quake_haptic_level 0; netevent rsqat_ready 1; wait 20;'
S="$S"' echo RUMBLE_BACKUP; rsqa_rumble_backup 1; netevent rsqat_ready 1; wait 15; netevent rsqat_ready 0; wait 15; rsqa_sound_cues 0;'
S="$S"' echo BRACE; netevent rsqat_offgun; wait 60; rsqa_brace_cue 3; qz_rhand "0.15 1.3 -0.35 0 0 0"; qz_lhand "-0.1 1.3 -0.35 0 0 0"; wait 10;'
S="$S"' echo GRIP1; qz_lgrip 1; wait 30; qz_lgrip 0; wait 20;'
S="$S"' echo MENU_OFF; openmenu RSQA_Options; wait 5; rsqat_sel "Two-Hand Brace"; wait 5; qz_rstick "1 0"; wait 2; qz_rstick "0 0"; wait 10; closemenu; wait 10;'
S="$S"' echo GRIP2; qz_lgrip 1; wait 30; qz_lgrip 0; wait 10;'
S="$S"' echo MENU_BACK; openmenu RSQA_Options; wait 5; rsqat_sel "Two-Hand Brace"; wait 5; qz_rstick "1 0"; wait 2; qz_rstick "0 0"; wait 10; closemenu; wait 20;'
fi
S="$S"' quit'
exec "$HERE/run.sh" "$1" 500 "$S"
