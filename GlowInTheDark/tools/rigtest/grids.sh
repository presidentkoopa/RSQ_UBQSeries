#!/bin/bash
# TEST ONLY. Builds the proof grids in docs/frames from $OUT/shots (after batch_final.sh).
OUT=${OUT:-/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/rsqgd_rig}
F="$(cd "$(dirname "$0")/../.." && pwd)/docs/frames"; M="$(cd "$(dirname "$0")" && pwd)/montage.py"
mkdir -p "$F"; cd "$OUT/shots" || exit 1
python3 $M $F/v2_default_vs_old.png 3 "1.1 (old pk3)=A_old.png" "port v2 default (Classic 1.1)=A_new.png" "v2, fixed seed=A_fix.png"
python3 $M $F/v2_miniboss_ddz.png 3 "Classic, fixed seed=A_fix.png" "miniboss tint (map darkened)=A_mb.png" "DarkDoomZ only (no glow)=A_ddzonly.png" "DarkDoomZ + glow=A_ddz.png" "DarkDoomZ + miniboss (its post-gain lowered)=A_ddz_mb.png" "real RSQ Miniboss (rsqmb_choose)=B_realmb.png"
python3 $M $F/v2_wave_combo_slowmo.png 4 "no wave=A_fix.png" "level-up wave 18 tics=A_wave18.png" "wave 28 tics=A_wave28.png" "real Gun Bonsai ready-to-level wave=A_realgb.png" "room B=B_fix.png" "B wave 14 tics=B_wave14.png" "B combo chain 10=B_combo10.png" "B slow motion 25%=B_slowmo.png" "A slow motion 25%=A_slowmo.png" "real RSQ SlowMo=A_realsm.png"
python3 $M $F/v2_liquids.png 3 "lava, still (living off)=C_still.png" "lava, living=C_noflare.png" "lava, splash flare=C_flare.png" "PCVR lights Normal=A_lights.png" "PCVR lights Subdued=A_lights_sub.png" "Quest (no lights)=A_fix.png"
python3 $M $F/v2_locked_doors.png 3 "MAP03 things off=d3_off.png" "MAP03 blue door=d3_on.png" "MAP03 key held=d3_key.png" "MAP05 off=d5_off.png" "MAP05 red door=d5_on.png" "MAP05 key held=d5_key.png" "MAP10 off=d10_off.png" "MAP10 blue door=d10_on.png" "MAP10 key held=d10_key.png" "MAP04 off=d4_off.png" "MAP04 red door=d4_on.png" "MAP04 key held=d4_key.png"
python3 $M $F/v2_rerolls.png 3 "Every Map: load 1=B_roll1.png" "Every Map: load 2=B_roll2.png" "On Each Death: after dying=B_death.png"
python3 - "$M" "$F" <<'EOF'
import re, subprocess, sys
M, F = sys.argv[1], sys.argv[2]
src = open(F + '/../../zscript/rsqgd/profiles.zs').read()
rows = re.findall(r'^\s+"([^"|]*)\|[^"]*",?\s*$', src, re.M)
B = [2, 4, 7, 9, 10, 13, 14, 17, 20, 26, 33, 35]
subprocess.run(['python3', M, F + '/v2_profiles_roomB.png', '4'] + ['%s=B_p%d.png' % (rows[p], p) for p in B])
subprocess.run(['python3', M, F + '/v2_profiles_nukage.png', '3'] + ['%s=A_p%d.png' % (rows[p], p) for p in [4, 12, 19]])
EOF
du -sh $F
