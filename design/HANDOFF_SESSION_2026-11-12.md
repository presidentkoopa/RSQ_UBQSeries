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
