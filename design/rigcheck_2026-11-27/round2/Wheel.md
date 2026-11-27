# RSQ Wheel: rig check round 2 (2026-11-27)

**IWAD:** every run in this file is **Doom II** (`doom2.wad`).

Rig: rig2 (copied per run), rig only.
- Map: R2TR01 (TEST-ONLY room).
- Pk3s: `RSQ_Wheel` + `RSQ_TacticalRig` (plain Doom), `wr_debug 1`, Open Wheel bound to Tab (`rig_key Tab`).
- Hands were aimed at cards from the Wheel's own readout (`netevent wr_test_cards`: each card's place, and where each
  hand's beam lands). Calibration (R2_TR2b): the pose pitch is 30 + the aim's rise and the pose yaw is the aim's yaw - 90.
- Runs: R2_WH0 (layout), R2_WH1, R2_WH2_* (four tries at the drag, one landed), R2_WH3; the BD-stack runs R2_TR2..TR7 for
  the ShieldSaw card (ShieldSaw.md).
- Logs: `/home/claude/rigcheck_round2/logs/`. Frames: `frames/Wheel/`.

Only round 1's CAN'T TEST rows and its PARTLY rows with a part not run are re-checked here. The other rows stand as round
1 has them (`/home/claude/rigcheck_ab/rigcheck_2026-11-27/Wheel.md`), including #6 and #14 (PARTLY: real results).

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 15 | Trigger or alt fire while pointing at the data sheet: swallowed, nothing happens (26) | WORKS | R2_WH1.log:201 (main beam `-> card -1 (the data sheet)`), 203 / 235 (`Clip 170` before and after the trigger and the alt key: no shot), 234 (hands unchanged: main Chaingun, off none), 237 (`open 1`: the ring stays up) | |
| 21 | When Crowded: rest the beam on a "+N" card a fifth of a second: a fan of the slot's other weapons opens (32) | WORKS | `wr_ring_layout 1`, `wr_subcards_max 3`, 6 weapons: R2_WH0.log / R2_WH1.log:194-200 (one card per slot; Shotgun's card holds SuperShotgun); 293 (main beam on card 3, Shotgun); frame wh1_row21_fan_opens_on_dwell.png (f138: the Shotgun card lit, its corner mark; f145 / f160: a SuperShotgun fan card out below it) | The "+N" text in the corner is a small mark at this size, not read as "+1" |
| 22 | Hold the trigger on a fan card, move to another place, let go: the gun takes that place, the order saved (33) | WORKS | R2_WH2_5_0_-12_0.log:191 (`dropped SuperShotgun, wr_slot_order "3:SuperShotgun,Shotgun;"`), 203 (the slot card is now SuperShotgun) | Three other aims (R2_WH2_7_3/9_5/3_0) missed the fan card. Two of them picked the slot card's Shotgun instead (a press on the slot card) |
| 23 | Skip Holstered Guns: next/prev skip holstered guns; the guns it reaches wear a gold running light (34) | WORKS | Skip: round 1 (A_W2.log:698-699). Light: R2_WH3 (Chaingun holstered at the right hip, R2_WH3.log:108); frame wh3_row23_skip_holstered_cards.png (f105 skip off: plain card edges; f140 / f152 skip on: gold points running on the reachable cards' edges); 266 (`next ... Fist -> Chainsaw`) | The not-framed half of round 1, now seen |
| 32 | Open at Level Start: the ring opens by itself (42) | WORKS | R2_WH1 started with `wr_autoopen=true` seeded in the run copy's ini: R2_WH1.log:58 (`t5 ... open 1` before any key), 78-80 (Tab closed it) | |
| K | Open Wheel's default bind LThumb (Keys) | CAN'T TEST (observation, as round 1) | rig ini `LThumb=crouch` | Not a play claim |

## Note on round 1's BROKEN #10 / #24 (off hand's alt fire on a card)
Not part of the CAN'T TEST re-check, but it changes how those rows read:
- Pressing the key actually bound to `+oh_altatk` (`rig_key Alt`, the ini's `Alt=+oh_altatk`) with the off hand's beam on
  the Pistol card and the main beam off the ring gave: R2_WH1.log:267-268 ("pick Pistol (card Pistol) -> hand 1 (the
  wheel stays open)", "off-hand alt-fire picked Pistol for the off hand, the wheel stays open"); 285 (off Pistol).
- Round 1 drove that press as gun-hand grip + left trigger. In this run that pair reached the off-hand **trigger** route
  (R2_TR1.log:1899-1904, Tactical Rig's keys).
- So #10's "nothing happened" may be the rig input, not the Wheel. Also, the code now picks by the off hand's own beam
  (2026-11-27), and the Off Hand Alt Picks switch #24 is retired in the code.
- Re-run #10 / #24 with a known `+oh_altatk` press before trusting either verdict.

## Counts (rows re-checked here)
6 rows: WORKS 5, CAN'T TEST 1 (K, observation only), BROKEN 0, PARTLY 0.
