#!/bin/bash
# TEST ONLY. The QoL round (AC1-AC8) on the rig: OUT=<dir> tools/rigtest/qol.sh <steady|comfort|reset>
#  steady   AC6 a jittered hand held, swung fast, held (Steady Hands on, then off); AC3 headset 1.62 -> 1.20 -> 1.62 m;
#           AC7 the taps answer. Read it with tools/rigtest/qol_analyse.py <OUT>/steady.log
#  comfort  AC5 a throw (velocity +18 sideways) with Vignette on Knockback off and on, a fall with it on and off;
#           AC8 a ZombieMan 250 away at 150 deg woken by your noise, then teleported to 250 at 150 deg; a barrel blast 40 ahead; Wake Cues off: the same;
#           AC2 a "ready" rumble at Rumble Strength 1, 0.5, 2, 0 (AT_BUZZ amp lines); AC4 the preset's three settings
#  reset    AC1 with RSQ SlowMo, Grapple and Gun Cards loaded: their settings changed, "Reset Every Series Mod"
#           picked and confirmed through the menu, their settings read back
HERE="$(cd "$(dirname "$0")" && pwd)"; HUB="$(cd "$HERE/../../.." && pwd)"
OUT=${OUT:-${TMPDIR:-/tmp}/rsqa_qol}; mkdir -p "$OUT"
case "$1" in
steady)
	python3 "$HERE/qol_cfg.py" steady "$OUT/steady.cfg"
	exec "$HERE/run.sh" steady 300 "god; notarget; wait 30; exec $OUT/steady.cfg" ;;
comfort)
	S='god; wait 30; rsqat_qol 1; rsqat_every 1000; rsqa_debug 1; rsqa_vignette 2;'
	# QuestZDoom wipes vel.xy every grounded tic (vr_momentum 0: teardown 00_CAPABILITIES gotcha 1; rig: a +18
	# sideways throw on the ground, even with +10 up, left v = vz only), so the throw is given in mid-air (lifted
	# 150 first). The barrel: a real blast 40 ahead, under buddha (god mode takes no thrust).
	S="$S"' echo KNOCK_OFF; netevent rsqat_lift 150; wait 3; netevent rsqat_throw 18 0 0; wait 50;'
	S="$S"' rsqa_vig_knock 1; echo KNOCK_ON; netevent rsqat_lift 150; wait 3; netevent rsqat_throw 18 0 0; wait 60;'
	S="$S"' echo BARREL_ON; god; buddha; netevent rsqat_barrel 40; wait 60; buddha; god;'
	S="$S"' echo FALL_ON; netevent rsqat_lift 400; wait 60;'
	S="$S"' rsqa_vig_knock 0; echo FALL_OFF; netevent rsqat_lift 400; wait 60;'
	S="$S"' rsqat_qol 0; echo WAKE_ON; rsqa_sound_cues 3; rsqa_cue_wake 1; netevent rsqat_behind 250 150; wait 10; netevent rsqat_alert; wait 30;'
	S="$S"' echo TELE_ON; netevent rsqat_tele 250 -150; wait 30;'
	S="$S"' echo WAKE_OFF; rsqa_cue_wake 0; netevent rsqat_behind 250 150; wait 10; netevent rsqat_alert; wait 20; netevent rsqat_tele 250 -150; wait 20;'
	S="$S"' echo RUMBLE; rsqa_sound_cues 2; netevent rsqat_ready 0; wait 10; rsqa_rumble_scale 0.5; netevent rsqat_ready 0; wait 10;'
	S="$S"' rsqa_rumble_scale 2; netevent rsqat_ready 0; wait 10; rsqa_rumble_scale 0; netevent rsqat_ready 0; wait 10; rsqa_rumble_scale 1;'
	S="$S"' rsqa_vignette 0; wait 3; echo PRESET; openmenu RSQA_Options; wait 5; rsqat_sel "Comfort Preset"; wait 5; qz_rstick "1 0"; wait 2; qz_rstick "0 0"; wait 10;'
	S="$S"' closemenu; wait 5; echo PRESET_READ; rsqa_vignette; rsqa_slowmo_ramp; rsqa_photosafe; wait 5; quit'
	exec "$HERE/run.sh" comfort 400 "$S" ;;
reset)
	S='god; notarget; wait 30; rsm_depth 0.9; rsqsm_radius 77; rsqgr_on 0; rsqgc_card 3; rsqa_colorblind 2;'
	S="$S"' wait 3; echo BEFORE; rsm_depth; rsqsm_radius; rsqgr_on; rsqgc_card; rsqa_colorblind; wait 5;'
	# the A button picks the row, A again answers the message box's "Yes" (real menu input: a menu command
	# run from anything but menu code is fatal, "Attempt to execute CCMD ... outside of menu code")
	S="$S"' openmenu RSQA_Options; wait 5; rsqat_sel "Reset Every Series Mod"; wait 5; qz_rbuttons 1; wait 3; qz_rbuttons 0; wait 15;'
	S="$S"' echo CONFIRM; qz_rbuttons 1; wait 3; qz_rbuttons 0; wait 15; closemenu; wait 5;'
	S="$S"' echo AFTER; rsm_depth; rsqsm_radius; rsqgr_on; rsqgc_card; rsqa_colorblind; wait 5; quit'
	EXTRA="$HUB/pk3/RSQ_SlowMo.pk3 $HUB/pk3/RSQ_Grapple.pk3 $HUB/pk3/RSQ_GunCards.pk3" exec "$HERE/run.sh" reset 300 "$S" ;;
esac
