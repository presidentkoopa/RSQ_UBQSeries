# RSQ VisualRewards: rig check 2026-11-27 (agent C)

Rig: scratch QuestZDoom 17.3 rig (rig2 for C_vr1, C_mb4), Freedoom 2, rig only. Runs: **C_vr1** (SlowMo, Score,
VisualRewards on plain Doom, CRIG01, `rsqgb_kr_debug 1` except where noted), **C_mb4** (full BD stack, a real Boss
fight), **C_sc1 / C_sc2 / C_sc3** (full BD stack), **C_sm3 / C_sm4** (DOWN). Logs in `logs/`, frames in `frames/VisualRewards/`.
Bits are counted by the test probe (`CBITS`: lying now / spawned since load; `CSPN`: each bit actor as it spawns).

## Today's changes
- **Ammo for Other Guns (the light green bit), 80/20:** of the ammo rolls of ordinary kills in C_vr1, 84 ammo bits and
  23 light green = 21.5% (C_vr1.log CBITS lines 199-223, burst bits taken out); across C_sc2+C_sc3+C_mb4 (BD) 100 vs 22 =
  18%. Picked up with a rocket launcher in hand and a shotgun and pistol/chaingun carried: Shell 13 -> 18 and Clip 75 -> 80,
  rockets unchanged (C_vr1.log:121-127). **WORKS** (the 1-in-5 of lines 26 and 136). Line 19's "One ammo roll in three"
  was **BROKEN** as written (**FIXED** 2026-11-27: README line 19 now says one in five, light green): the measured share is one in five, as the code's OTHER_SHARE 20 and the owner's 80/20 say.
- **Boss ammo burst ("burst.ammo"):** a real Boss fight (C_mb4): each lost life threw 6 ammo bits at the Boss's feet:
  t630 4 ammo + 2 light green (C_mb4.log:461 "life lost", 465-470), t846 1 + 5 (506, 510-518). 50 bursts asked through the
  service (C_vr1.log:147-196): 65 of 300 bits light green = 21.7%. **WORKS.**

| README claim (line) | Verdict | Evidence | What actually happened (BROKEN/PARTLY) |
|---|---|---|---|
| Hit a monster: a health bar over it (14) | WORKS | frames/VisualRewards/vr1_hpbar_numbers_f60_f72_f108_f120.png: a green bar over the hit imp | |
| Damage numbers jet up (15); running total and xN combo (16); kill slam (18) | CAN'T TEST | the same frames show small red marks by the bar after 5-damage hits (f108, f120), too small at this resolution to read a number or an xN | |
| HEADSHOT word on a BD head hit (17) | CAN'T TEST | no frame at a BD head hit | |
| Kill: one roll per 10 health, each 50%, a boss drops every roll x3; ammo share (19) | FIXED (was BROKEN) | per-10 and 50%: C_vr1.log:76, 90-99 (Imp 60 hp: "of 6 rolled", 1-5 bits). BUT **a monster of more than 1000 spawn health throws no bits at all**: plain Doom Cyberdemon (4000): no bit spawned (C_vr1.log:210-212, CBITS unchanged); BD Baron (1200): none (C_sc2.log:854-861 kill, CBITS 860-873 unchanged); Baron 1000 (100 rolls) still drops (C_vr1.log:206-208, 219 "52 bits of 100 rolled"). With Debug Log on the same kill aborts the VM: C_sc1.log:509-515 "array access out of bounds. Size = 0, current index = 0 / Called from RSQ_KRHandler.BurstCapped at killrewards.zs, line 557 / Burst line 439 / WorldThingDied line 319" (BD Baron 1200). And line 19's "one ammo roll in three" teal: measured one in five (above) | over the 100-bit cap (BurstCapped) nothing drops; Debug Log on: VM abort, the game stops — **FIXED 2026-11-27.** Cause: killrewards.zs BurstCapped (line 517 before the fix) declared a local `int kinds = 0;`; ZScript names are case-blind, so the local stood in for the class constant `KINDS` (6) and every `for (k < KINDS)` loop ran 0 times: no slot, no bit actor, and the debug line read `slots[0]` of an empty array (line 557, the VM abort). Reproduced alone on the rig (a test class with the same two declarations: "slots 0 kinds 0"; renamed: "slots 6"). Fix: the local removed. Rig: plain Doom Cyberdemon 4000 without Debug Log: lying bits 46 -> 146 (F_vr1.log CBITS t41 / t52); with Debug Log: "RSQ KR t55: Cyberdemon: 1200 bits of value over the 100-bit cap -> 100 bit actors", no abort (F_vr1.log). Full BD stack, Debug Log on: BD Baron 1200 "65 bits ... -> 65 bit actors", CBITS 0 -> 65 (F_bd1.log:310-321); BD Cyberdemon 5000 "1500 bits of value over the 100-bit cap -> 100 bit actors" (F_bd1.log:328-332); no VM abort in the run. README line 19 now says one ammo roll in five (light green) |
| Bits: health +25, armour +10, ammo +5 for each gun in your hands (20) | PARTLY | health 50 -> 75 on one health bit (C_vr1.log:106-111); a bit flying in at 90 units: rockets 32 -> 37 with the launcher in hand (133-142) | armour went 0 -> 20 and other ammo moved several at once: neighbouring bits flew in on the same tic, so single-bit armour / ammo amounts are not isolated |
| Bits within 2 m fly to you (20) | WORKS | C_vr1.log:128-142: player still, imp killed 90 units away, its ammo bit taken without moving (rockets +5) | |
| Light green bit: +5 for each carried type held in neither hand (21) | WORKS | above (Shell +5, Clip +5, rockets in hand unchanged) | |
| Gold bit: +5 gold in Score; only Bosses / Big Bosses / legendary champions (22) | WORKS | C_mb4.log:572 "PistolZombie threw 21 gold bit(s) (... 20 fountain, a Boss)"; 395, 417, 426 thralls "may not drop gold"; 667-676 each pickup "+5 -> bank 5, 10, 15, 20" | |
| Steel bit (23), battery bit (24) | CAN'T TEST | Gun Cards' Weapon Condition / FnF battery not set up | |
| Fight Kill Rewards: +2 health +2 armour on a close or quick fight kill (25) | CAN'T TEST | not isolated | |
| Boss life lost: 6 ammo bits, one in five light green (26) | WORKS | above | |
| DOWN: bits fly into the DOWN plate, health/armour bank (27) | WORKS | C_sc3.log:588-594 "player 0 is DOWN: these bits fly to his plate and bank", "a health bit flew into player 0's DOWN plate: +25 banked" | |
| Gains on You (28) | CAN'T TEST | not run | |
| LEVEL UP (29, 39-40) | CAN'T TEST | needs Gun Bonsai (not on this machine) | |
| Invulnerability bar (30) | CAN'T TEST | not inspected in a frame | |
| REVIVE! in cyan + toast "REVIVE! +100 HP ... INVULNERABLE" (31) | WORKS | frames/VisualRewards/sm4_REVIVE_word_toast_f390.png; C_sm3.log:443 | |
| REVENGE! over the target in magenta + toast (32) | FIXED (was PARTLY) | same frame: REVENGE! toast and the magenta REVENGE! word; C_sm3.log:438 | the target was gone (killed), so the word stood "in front of you": in the frame it is drawn across RSQ Score's score line, the two overlapping ("RE!SCORE: 466E!") — **FIXED 2026-11-27.** Cause: the word stood 10 units over the target's standing height (worldwords.zs WorldBase, WK_OVER; the log: "world word REVENGE! (magenta, kind 0 ...) on DoomImp": over the dying imp, not "in front of you"), drifting up 1.4 letters: a target taller than your eye, 300 units off, put it into the top stack round the gaze. The other moments stay low (REVIVE! rises from the floor to 6 units under the eye; LEVEL UP! at the muzzle; a crate's 1UP the same as REVIVE!). Fix: a "low" key (worldwords.zs, asked by down.zs for REVENGE!): the word's top, drift and all, never above a slope 0.7 degrees under the eye (words.zs DrawWord), the floor still holding it up. Rig (F_sm4, the same DOWN-front fight): frames/VisualRewards/F_sm4_REVENGE_under_score_rows_REVIVE_under_it_f102_f114_f120.png: REVENGE! under SCORE: 120 and under its bonus rows, REVIVE! rising to rest under REVENGE!, no overlap. README line 32 reworded to say where it stands |
| 1UP on a Score life (33) | PARTLY | C_sc2.log:836, 863 Score asks banner "LIFEUP|lives:8" -> 1 | not framed; Score's debug shows the banner request only |
| "+0.4s" over a hit while DOWN (34) | WORKS | C_sm3.log:426 'DOWN time "+0.1s" ... over DoomImp'; frames/SlowMo/dumptest_DOWN_target_crosshair_f70.png "+0.25 SEC" | |
| LegenDoom drop words, THREAT! (35, 41) | CAN'T TEST | LegenDoom not on this machine | |
| Only Where I Aim, Overkill, Damage Chunk (36-38) | CAN'T TEST | option variants not run | |

## Counts
Table rows WORKS 8, PARTLY 3, BROKEN 1 (line 19: monsters over 1000 spawn health drop nothing / Debug Log VM abort; and the 1-in-3 wording)
(2026-11-27 fix job: line 19 and line 32 FIXED, see their rows: now WORKS 8, FIXED 2, PARTLY 2, BROKEN 0), CAN'T TEST 9; plus the two today's-change items (both WORKS).
