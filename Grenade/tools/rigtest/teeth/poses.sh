#!/bin/bash
# TEST ONLY. poses.sh <mode> [hand] -> a console script of the owner's poses, one scenario after another, each starting
# from a fresh pin (the grenade put away with the trigger still held puts the pin back in, then taken out again).
# mode rsq|bd; hand main|off (off: RSQ Grenade only, switchhand 1). HMD at the pose's height, controller at the mouth
# about 12 cm under and 10 cm in front of the eyes (the cigarette lane's lips-and-chin), stage metres, pitch 30 = level.
M=$1; HAND=${2:-main}
if [ "$M" = rsq ]; then GIVE="use RSQGN_Grenade"; AWAY="use Fist"; else GIVE="take IsPlayingAsPurist; give HandGrenades; give GrenadeAmmo 5; use HandGrenades"; AWAY="use Melee_Attacks"; fi
if [ "$HAND" = off ]; then H=qz_lhand; T=qz_ltrigger; G=qz_lgrip; X=-0.02; REST="-0.2 1.1 -0.35 30 0 0"; OTHER=qz_rhand; ORST="0.2 1.1 -0.35 30 0 0"
else H=qz_rhand; T=qz_rtrigger; G=qz_rgrip; X=0.02; REST="0.2 1.1 -0.35 30 0 0"; OTHER=qz_lhand; ORST="-0.2 1.1 -0.35 30 0 0"; fi
SW=""; [ "$HAND" = off ] && SW="wait 25; switchhand 1; wait 10;"
# off hand (run one scenario a run, ONLY=S3): both triggers held while the grenade goes back to the main hand and away (no let-go reads as a release)
PRE=""; [ "$HAND" = off ] && PRE="qz_rtrigger 1; switchhand 0; wait 15;"
reset() { echo "$PRE $AWAY; wait 25; qz_rtrigger 0; $T 0; $G 0; $H \"$REST\"; wait 5; $GIVE; $SW wait 30;"; }
sc() {  # sc <label> <hmd y> <adj> <hand y> <hand z> <pitch> <grip 0/1> <secondary mappings 0/1>
  [ -n "${ONLY:-}" ] && [ "${1%%_*}" != "$ONLY" ] && return
  echo "echo GTP_$1; vr_height_adjust $3; vr_secondary_button_mappings $8; qz_hmd \"0 $2 0 0 0 0\"; wait 5; $H \"$X $4 $5 $6 0 0\"; wait 6; $G $7; $T 1; wait 30; $(reset)"
}
echo "wait 20; rsqgn_debug 1; gtp_trace 6; $OTHER \"$ORST\"; $H \"$REST\"; $GIVE; $SW wait 30;"
sc S1_MOUTH_170 1.70 0 1.58 -0.10 30 0 0
sc S2_CHIN_170 1.70 0 1.53 -0.08 30 0 0
sc S3_MOUTH_UPRIGHT_165 1.65 0 1.53 -0.09 80 0 0
sc S4_FIST_GRIP_TRIGGER_170 1.70 0 1.58 -0.10 30 1 1
sc S5_TALL_ADJ030_175 1.75 0.30 1.63 -0.10 30 0 0
sc S6_SEATED_120 1.20 0 1.08 -0.10 30 0 0
sc S7_CHEST_175_NOT_MOUTH 1.75 0 1.30 -0.30 30 0 0
echo "vr_height_adjust 0; vr_secondary_button_mappings 0; wait 5; quit"
