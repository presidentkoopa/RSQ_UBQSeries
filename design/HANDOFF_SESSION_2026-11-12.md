# Session handoff, 2026-11-12 (night of 11-11)

Owner's notes of 11-11 23:56, worked in a cloud session with the QuestZDoom 17.3 rig from `RSQ_Meshturbator/rig/bin`
(prebuilt, qzd17.3 9afc750) on his full order (doom2, TUD No End In Sight, LegenDoom 3.0, brutal22test6, voxel pack,
BD22 VR 2.0.4i, XMVE, LOB, Champions, No More Hitscans, Universal Entropy, Spawn Adjuster, the Environmental set,
MK Crits, Regen Shield, Shotgun Spawner, Gun Bonsai 0.10.6, the 21 RSQ pk3s). Every item below loaded with no script
error from an RSQ pack. All of it is RIG ONLY, not headset-confirmed. The rig has no sound.

## Done
- Wheel: the BD pistol's card shows its voxel (BD22 VR lends it through MODELDEF, now measured too); Flat Ring Up To
  defaults to 99 (a saved 10 is moved once, cfg gen 31); Data Sheet Size goes to 4.0.
- Score: Down 10 -> 13 (saved 10 moved once, cfgver 2).
- Miniboss + SlowMo: the meter and the two bars draw as Meter Size + 0.3.
- Whip: a heavy crack is always an MK Crits critical hit (rsqwp_whip_hardcrit); on a rope, fire lets go and alt-fire
  reels (rsqwp_rope_fire). The owner has PARKED the whip's direction: do not redesign it without him.
- SlowMo DOWN: the bar is the DEATH IN clock (thirds of the Clock; no refill on a target kill; Bar Step row gone);
  the eye keeps its height in a liquid's foot clip (MTO Liquids); LiveReverb only while DOWN (rsqsm_down_reverb).
- VisualRewards: words and HP bar stay under the ceiling; a legendary fist drop wears a fist mesh (look not confirmed).

## Not reproduced / open
- Holsters while DOWN: on the rig the right hip hovers, holsters and draws the same standing and DOWN, both crouch
  modes. The hips are below the floor while DOWN. Ask the owner to try Lower View When Down off.
- "Sometimes we don't get up": not pinned. Needs his log with rsqsm_debug on.
- LegenDoom's Gun Smoke / Casings / Bullet Puffs / Recoil settings are never read by BD22 VR: nothing to change.

## Next (owner: "all at your discretion")
- GunCards: cards animated like the SlowMo bars (toggle, on); level-up cards out of the way; rogue voxels (his image).
- The legendary power on the Gun Bonsai VR card; legendary drops tied to minibosses; bits.

## Later the same night
- On main, rig only: the word over a risen legendary is THREAT! and fades after 3 s (LEGENDARY Word Seconds);
  a gun's level-up is a wrist toast (Weapon Level-Up: Wrist Toast).
- Owner 01:19: NO RIG RUNS until he says so. Two changes after that are on the branch `wip/2026-11-12-uncompiled`,
  NOT COMPILED, NOT LOADED, NOT in his PK3TEST: do not merge or deliver them before a load check on his full order.
  - GunCards: Cards Alive (rsqgc_alive, on): every card's opacity breathes (card.zs CardAlpha).
  - Gun Bonsai VR status screen: a gun's LegenDoom power where WEAPON BOND was planned (skin_a_menus.zs DrawGun).
- Already built before this session, nothing to do: the LegenDoom power on the HUD (pickup card and gauge row,
  GunBonsaiOffhandVR rsq/ui/legendoom.zs); legendary guns only from Bossfights (BD22 VR rsld_bossfight_only, on, with
  Champions and RSQ Miniboss's Bossfights).
- Blocked on the owner: GunCards rogue voxels (his image); holsters while DOWN (not reproduced; ask him to try Lower
  View When Down off); "sometimes we don't get up" (his log with rsqsm_debug on).
- Bits: ideas only (he asked for ideas): a cap on bits alive at once, one merged bit per kill. Not built.
- The whip's direction is PARKED by the owner.

## 01:50: the uncompiled branch is merged
The owner allowed one load check. All six changes loaded on his full order with no script error from an RSQ pack and
no VM abort, in one run that also exercised them: a heavy crack critted and held the imp 50 tics, the yank left it
"staggered where it stands (Whip Pulls Monsters off)", a barrel (RSQGN_Barrel) was set off, a slow motion with a reason
ran, and the Gun Bonsai VR status screen was opened and closed. Merged to main, pk3s in his PK3TEST.
NOT SEEN (no frames were taken): the barrel's size and the Neon Crescent's colour, the cards breathing, the legendary
power line on the status screen, the reason line's SOTN look. The commit subjects still say NOT COMPILED: they are
compiled and loaded now, not shown.
Also on main from that branch: Grenade barrels (size x2, reach x1.5, Neon Crescent room colour), SlowMo reason line.
Whip controls (fire snaps the lock to a monster, alt-fire locks onto geometry) are NOT written.
The owner rejected both badge sketches; rank badges on the HP bar are dropped.

## 03:41 batch (owner: "write new whip ... barrels are good ... big 4 is gunbonsai, score, monsters, arcade design")

All on `main`. One load on the full order (no script errors past the four voxeldef lines, no VM abort). Nothing here was run
on the rig beyond that load, and nothing is headset-confirmed.

- **The Big Four** (the owner's words): Gun Bonsai, Score, Monsters, Arcade design.
- **Barrels**: signed off ("barrels are good").
- **The new whip** (Whip, Lock-On Controls `rsqwp_lockwhip`, on): the whip hand's ray is always out. Fire marks the monster
  nearest along the hand with no button held, fire again moves to the next. Alt-fire locks the gold cursor's spot, the
  crack snags there; alt-fire again lets it go. On a rope: alt-fire reels, fire lets go. A crack on a monster stuns and
  comes back: no wrap (Crack Wraps Monsters `rsqwp_whip_wrap`, off), no pull, no lasso. The other hand is never read.
  `swing.zs` LockWhipOn / geoLock, `weapon.zs` Tend. **Whip/README.md is NOT updated: the owner signs the whip off first.**
- **Holsters while DOWN** (TacticalRig, Holsters Ride Up When Down `rsqtr_down_lift`, on): the view stays lowered. While
  SlowMo holds the pawn's ViewHeight low, every holster under the head is squeezed toward the head so the lowest clears
  the floor by 0.14 m (the hips come up about 6 units). `rig.zs` DownLift.
- **LEVEL UP / REVIVE / REVENGE band** (VisualRewards): 20 degrees under the gaze (`BAND_LOW`), where the DOWN bar is.
- **Enhanced Ballistics** (BD22 VR 2.0.4j, its own repo): default Low; a saved Stock is moved to Low once.
- **Level card in place of the small gun card** (owner 03:58: "clean sweep, thinner line, faster. good to go"): built.
  VisualRewards' wrist toast is the level card; one thin white line crosses it in 4 tics as LV n lands (`SWEEP_T0`,
  `SWEEP_TICS`, part `P_SWEEP`). It asks `RSQGC_Service` "levelcard" by name and Gun Cards fades that hand's small card out
  for the toast's 45 tics (Level-Up Card Replaces Small Card, `rsqgc_lvlcard`, on). Loads only: the line's look (the
  band texture under the white flash translation) has not been seen in a frame.

## 04:17: DOWN is one target and a shorter clock (owner: "instead of increasing the number of kills ... 9 seconds, then ... 6 seconds, then ... 3")

SlowMo, on `main`. Loads on the full order only; not run on the rig, not headset-confirmed.

- Every DOWN owes ONE kill: the monster that downed you (or its copy). The DOWNs since the last Score life spent set the
  clock you start with: 9 s, 6 s, 3 s (`StartShare`). The bar and the tier already read the clock, so it starts 2/3 or 1/3 full.
- A target that its own mod swaps for another actor (BD22's Imp in deep water becomes ImpFish) after you damaged it is
  your kill (`tHurt`). Before, it added one more kill owed.
- Labels (`plate.zs` BonusTick, through RSQVR_Service "word.hold"): TARGET over the target; the nearest four other
  monsters in sight get a small white crosshair and "+1 SEC" / "+0.5 SEC" / "+2 SEC" / "+10 SEC". The chevron trail and
  the edge arrows stay the target's alone.
- Taken back out the same night: an on-screen "no room to stand" message the owner did not ask for.
- 04:22 (owner: "I said 0.5 and 0.25"): the Time rows' defaults are now 0.25 s (small monsters, Lost Souls) and 0.5 s
  (anything above, bosses too), with a one-time move of saved values (`rsqsm_down_cfg`). The labels read +0.25 SEC / +0.5 SEC.

## 04:45 to 05:35 (rig tests allowed again: "rig check everything you need to, update readmes accordingly")

- **Whip**: on the rig the new presses worked but nothing on screen had changed, and a crack spent the mark. Now the cast
  is always drawn (pale; gold with the diamond where alt-fire can lock a snag), the ray snaps to the mark, and the mark
  stays through cracks (runs whiplock2/3). README still waits for the owner's sign-off.
- **GunCards "rogue voxels"** (owner's screenshot 04:56): a watch card seen edge on (the other hand's item card while one
  wrist is checked). Watch cards are drawn only facing the eyes and within 45 degrees of the gaze (runs facecull/2).
  STILL OPEN: one green glyph of the saber card's LIT word sits away from the card (layers, voxel files and pivots all
  check out; not found).
- **Melee Barrel Launch** + SlowMo `start.barrel` / `stop` (run barrelfly).
- **Miniboss inner-wrist card** START (skull) FIGHT? + Use (runs wrist1-5); flat along the forearm since 05:26.
- **DOWN** 9 / 6 / 3 s and one kill owed: run down3. Labels and bonus crosshairs not looked at in frames.
- Not rig-checked: Holsters Ride Up When Down, the lowered LEVEL UP band, the level card's sweep.

## 05:37 (owner: "remove LIT from saber ... The fight card does not care about the rules ... minibosses drop legendary guns and refill cigarettes")

- GunCards: the saber's card no longer says LIT / OFF (which also removes the stray green piece).
- Miniboss: the inner-wrist card calls a Bossfight in with no rules and whatever the meter holds (`force`); only "No
  Monsters" and "No Room" can still stop it. Rig: run fightcard (it overrode Too Early and the fight arrived).
- BD22 VR 2.0.4k: a Bossfight's legendary drop rolls its rarity by tier (55 / 28 / 12 / 5 at the first tier, rarer
  gaining 50% x its rank per tier). Miniboss tiers count from 0.
- Already there, nothing changed: a dead miniboss refills cigarettes (Tactical Rig `CigGive ... "miniboss"`).
- The owner's direction, not built: boosted legendary champions as the "pinatas".
- Asked 05:38: the fly-in crosshairs (Predator / Virtual Cop) are parked in design/PARKED.md with his two clips in
  design/refs/crosshair_flyin/. Crosshairs and chevrons are drawn only by SlowMo's DOWN today.
- 05:44 (owner): the fight card needs the FULL METER again. My reading of "without restrictions" as "ignore the meter too" was wrong; only the guardrails are skipped.

## 05:50 (owner's numbers and the DOWN marks)

- BD22 VR 2.0.4l drop weights (Common / Uncommon / Rare / Epic): thralls 85/12/2/1, 75/20/3/2, 65/35/6/4 by tier;
  the miniboss 50/30/15/5 to start (past the first tier: 2.0.4k's easing, my numbers).
- DOWN: the target's crosshair flies in from offscreen (three copies closing over 9 tics, then the assembly; the PARKED
  Predator / Virtual Cop note, for DOWN only). Bonus monsters: ten of the nearest twenty in sight, chosen in play, a new
  one as each dies; ONLY they and the target buy clock time now. Their crosshairs are whole and fade in.

## 14:11 work order (26 items; the organised list was sent back to the owner at 14:26)

Vocabulary (owner 14:20): say MINIBOSS, never "bossfight". A miniboss encounter: the meter fills, the fight card calls
it; the miniboss (itself a boosted legendary champion that absorbs its thralls' powers, cap five, plus its own) arrives
with 3-5 thralls, each a boosted legendary champion; thralls drop NOTHING; the miniboss drops a legendary weapon and
refills cigarettes. A "boosted legendary dormant champion" is what a monster IS (LegenDoom legendary + Champion), out in
the map: it drops a legendary weapon too.

Done and delivered: thralls legendary champions with different colours, 3-5 of them, power cap 5 (run thralls2); no SS
soldier; TARGET / GUARD small; no meter-ready sound; drops only miniboss + legendary champions (BD22 VR 2.0.4m, run
thralls); drop word only within 1.7 m, no rarity word; Wheel inspect card only within 1.7 m; GunCards watch card back
(the face test hid every real check) and no off-hand card while two-handing; SlowMo dive (leap 16, lift 3, burst 8);
no "Grip inside the ring" text; Score Down at least 13; boss bar mockups A-E on the canvas (E = the arrival sequence).

NOT done: per-gun 6-axis small card adjust; Wheel models (SMG, flamethrower, grenade launcher, rocket launcher,
BFG10k) and the fisheye card sizes; lasers when canted while two-handing; why distance grab still fires when
two-handing; whip hand-over-hand climbing; frozen purple imp; BD22 imp attack frame drops; the candle's floating
monster; the game-exit sound; rogue voxels out in the map; whether Running Total shows in the SOTN look; building
the boss bar.

## 14:36 to 15:10, down the 14:11 work order (UBQ b0b95cd49d, BD 2.0.4n 3bb4046)

Done and in PK3TEST:
- Wheel: the five guns' models (voxel size was read from the same-named sprite; `KvxDims` tries every lump, runs voxsize / wheelvox4).
- Wheel: the data sheet grows with the ring (owner 14:36; run sheetgrow). Picked card 1.8, neighbours 1.35 and 1.12
  (`PICK_*`, group `mul` in wr_q_shim.zs; seen only at 1.5 / 1.22 / 1.08 with a forced pick, run pickbig5; the rig's hand never picked a card).
- DistanceGrab: both controllers within 16 cm counts as two-handing (`TWO_HAND_CLASP`, run ls2h).
- LaserSight: an aimed gun (within 40 degrees of the view) keeps its laser through the watch check (`Aimed`). Loads only.
- Miniboss: "brain/sight" on arrival removed (handler.zs rage start). Loads only.
- BD 2.0.4n: menu/quit1, quit2 silent (they were LegenDoom's, its SNDINFO:717-718).
- Monsters: NOICEDEATH on every RS_ monster at spawn (RS_RetierHandler.WorldThingSpawned); the "frozen purple imp" was the
  engine's ice death from LegenDoom's Freezing guns (runs ice0 before, ice1 after).

Found, not fixed:
- GunCards per-gun six axes: the hand-drawn small card is 16,442 baked voxels turned by a layer's two angles; roll and a
  move apart from the turn cannot be drawn without a re-bake per step or an engine change. Only a world-drawn card can
  take all six. Asked the owner.
- Rogue voxels: not reproduced. Checked and ruled out on the rig: the laser's arc learner (rifle, SMG, shotguns, MGs all
  read STRAIGHT; `rsq_hands` does learn a false arc from Shotgunparticles2 but draws no laser). Asked for a screenshot.
- Floor candle: `Candlestick` on the owner's order is a plain candle on the rig (runs candle3_1 / candle3_0). The voxel
  pack's "Evil Candle" replaces Doom's EvilEye (a floating eye over a stand): candidate, not shown. Asked for a screenshot.

Not started: whip climb (off hand grabs the snagged whip, Use climbs), BD22 imp frame drops, HUD boss bar (mockup E on the canvas, not approved).

## 15:28 to 16:20

Done, in PK3TEST (rig only, not headset-confirmed):
- Miniboss bar where Be Quick or Be Dead is, its size, mockup E's look from baked series art (tools/gen_bossbar.py:
  MBFG/MBFS glyphs, RSQMBHD, RSQMBX01..10); raised BB_LIFT 110; LED clock only during the 3 s charge; thrall bars in
  their Champion colour (ChampColour); GUARD shakes and lights gold on a blocked hit (b.guardHitTic, GUARD_SHAKE);
  Start Fight card off hand only; README renders rig_bar_charge.jpg, rig_bar_guard_hit.jpg.
- Thralls are real Champions only with Champions' "Legendoom Compatibility" on (the owner's Boosted/Dormant Legendary
  Champions): LegenDoom's guaranteed pickup makes them legendary, Champions' champion_LDoomDelayer makes them Champions.
  The rig's default (off) gave token-only fakes: always run miniboss rig tests with
  `champion_legendoom 1; champion_dormant 1; champion_booster 1; map map01`. A thrall that does not fit tries 24 spots.
  Champions' Override Chance cannot be set from play (server cvar, run champ2).
- Remove HUD Health and Armor: rsq_hud_nohp (BD 2.0.4o CVARINFO.rsq; SBARINFO via tools/hud/make_sbarinfo.py; RSQ Gun
  Bonsai VR's Skin A bottom row, which is the HUD actually drawn on the owner's order); row in GunCards' menu.
- Whip: hand over hand: Use on the whip hand (HandFree allows RSQWP_WhipWeapon, non-strict) and the off hand's grip
  alternate (run useclimb with XCMD="rsqwp_lockwhip 0": rope 274 -> 168 -> 157 -> 145). Whip README still waits.

Found, not fixed: BD22 imp frame drops. A BD22 Imp attacking on the rig adds ~9 actors a shot (FireBall_ + 3 trail
sprites a tic, one IMPBALL light); nothing heavy. Asked the owner whether it is every attack or the first one.
Still open: floor candle and rogue voxels (screenshots asked).

## PAUSE (owner 2026-11-12 17:56): outstanding, tabled, parked

Everything below is also in the reply to the owner. All packs current in pk3/ (pushed) and PK3TEST (BD 2.0.4o).

Outstanding issues
1. BD22 Imp vanishes for a frame or two before it throws (every time, owner 17:13). Not reproduced on the rig: per-tic
   log (impatk3) shows TRO1 A t96-103, TRO1 B t104-105, TROO G t106-111, never invisible, style 6 (Champions sets every
   monster Translucent), alpha 1. Next: owner's headset test without Champions; if it goes away, put monsters Champions
   did not make ghosts back to Normal style.
2. Rogue voxels still seen "here and there". Fixed so far: GunCards watch-card cull (11-12), Monsters' three effects that
   opened on BAR1 (the voxel pack's barrel). Not confirmed.
3. RSQ Monsters shares sprite names with the load order (36 with brutal22test6, 43 with XMVE, 11 with Champions, 3 with
   Legion of Bones; e.g. BLUD, CBAL, BSPL). Ours, loaded last, replace theirs. Only WICK renamed (the candle). Since RSQ
   Monsters only feeds the miniboss now (owner 17:21), renaming all of ours is safe.
4. The floor candle's flame now draws nothing (its WICK art is not in the load order; ours was standing in).
5. Thrall arrival beams use RSQ Monsters' tier colour (grey for Common), the bars use the Champion colour: asked, unanswered.
6. Miniboss thralls are real Champions only with Champions' Legendoom Compatibility on (the owner's setting); off, they
   get a colour token in name only. Rig runs need `champion_legendoom 1; champion_dormant 1; champion_booster 1`.
7. Old BD22_VR-Reloaded_2.0.4i..n in PK3TEST (cannot delete from here).
Not yet seen working (code or loads only): GunCards wider sliders; Start Fight card on the off-hand wrist; lasers held
gangsta style; crisis dive; Wheel picked-card sizes at 1.8/1.35/1.12; level card place and sweep; DOWN fly-in crosshair,
TARGET / +SEC labels; holster lift. Nothing from 11-12 is headset-confirmed.

Tabled / parked
- Fly-in crosshairs (Predator / Virtual Cop, design/refs/crosshair_flyin): built for DOWN's target; not for the miniboss.
- GunCards full per-gun roll / pitch / yaw (needs the card drawn in the world); owner took wider sliders instead.
- Words over Champions monsters (11-11).
- Melee boxing gloves with moves of their own (11-11).
- Rumble Backup through RSQ Accessibility for every mod (queued 11-10).
- Wheel holster web drawn with Tactical Rig's mirror (later, 11-07).
- Laser Sight Quest beam stray bright voxels (11-07).
