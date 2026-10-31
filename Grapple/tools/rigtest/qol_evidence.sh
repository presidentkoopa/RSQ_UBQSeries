#!/bin/sh
# TEST ONLY: the key lines of the QoL round's rig runs (2026-10-31) into test/evidence/qol_1031.txt.
cd "$(dirname "$0")/../.."
B=tools/rigtest/build
O=test/evidence/qol_1031.txt
echo "# QoL round 2026-10-31, rig only (shared QZD 17.3 rig, BD order, GRTEST via tools/rigtest/grq.sh). Key lines." > $O
echo "## GR5 use lines (rsqgr_use_lines 1): switch on ledge B's east wall, Ceiling_LowerByValue(2,8,64)" >> $O
grep -E "T_GR t2[0-9] h0 (fire|use|drop)|T_ALCOVE t(20|25|30|80|85|90) " $B/gr5.log | sed -E 's/ claw.*//' >> $O
echo "## GR8 tap window (8, then rsqgr_tap_tics 3) + GR4 slack rope on the floor" >> $O
grep -E "P_TAP|P_FLOOR|T_GR t[0-9]+ h0 (fire|latch|letgo|drop|slack)|T_GR t92 h0 reel" $B/gr48.log | sed -E 's/ claw.*//' >> $O
echo "## GR1 calm (stick back from t166)" >> $O
grep -E "T_STICK|T_GR t1(5[0-9]|6[0-9]|7[0-9]|8[0-9]) h0 swing|T_GR t2(0[0-9]|8[0-9]) h0 swing" $B/gr1.log | sed -E 's/ claw.*//' >> $O
echo "## GR7 lasso flick (slow sweep 0.7 m/s, then a flick)" >> $O
grep -E "P_SLOW|P_FLICK|T_GRM (lasso|flick|air|land)|T_GR t[0-9]+ h0 (bite|letgo)" $B/gr7.log | sed -E 's/ claw.*//' >> $O
echo "## GR6 aim dot (off hand pointing, then lowered)" >> $O
grep -E "P_POINT|P_DOWN|aim dot" $B/gr6.log | head -6 >> $O
wc -l $O
