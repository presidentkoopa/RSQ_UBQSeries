# Handoff: session of 2026-11-10 / 11 (RSQ UBQ Series, "DoomVR - Arcade Edition")

Owner: presidentkoopa. Read /home/claude/rsq_ubqseries/CLAUDE.md first, then this file, then design/PARKED.md and
design/PLANNED_PROJECTS.md.

## Standing orders in force
- **"No rig test, code only until I say"** (owner, 11-11 15:07). Do not launch the rig or run /tmp/lc.sh (it starts the game).
  Everything built since 15:07 is **code only, not shown and not compiled**.
- Ask the owner **one question at a time** (AskUserQuestion), and never cut his options to "spare" him (11-11 14:09).
- Labels: "rig only, not headset-confirmed" / "code only, not shown" / "not yet run". Headset-confirmed: only Tactical Rig's
  cigarettes (older record).
- Keybinds are precious; no new keys. Commit by explicit path; never `git add -A`; never commit a pk3.
- Doom asset rips are fine with credit; ship originals with attribution; never redraw someone's art (11-10 22:55).

## Load order (current)
doom2 > brutal22test6 > BD_VoxelPack > **BD22 VR 2.0.4g** (rs_brutal22weaponsq/pk3, built, not committed) > LOB > Champions
(Mikk-) > Gun Bonsai 0.10.6 > the RSQ pk3s. LegenDoom (optional) goes right after doom2; never load the old
LegenDoom_BD22VR_Patch.pk3 (the patch is inside BD22 VR as "LD mode"). /tmp/lc.sh and the rig run.sh point at 2.0.4g.
**The RSQ pk3s in pk3/ were rebuilt by some agents but not all since the last changes: rebuild everything
(`python3 tools/build_all.py`) before anything goes to the owner.**

## Done this session (all pushed to main)
Rig only, not headset-confirmed (shown before 15:07), with evidence in design/rigtest_2026-11-10/ (RESULTS*.md):
- The packed batch P1-P4 and its fixes: Melee M1-M8, hands and throws, fights, looks and menus; plus Quick Grenade key,
  AMMO FULL, Miniboss first landing, Whip and Gun's stale diamond, M8F laser held off, the LaserSight glyph readout (At the
  Dot at one apparent size), Slappers vs Saber, the Force with gloves, ShieldSaw slanted shots, gloves in slot 1 and glove
  size, the Gun Cards item card (no big number on the saber), Graveyard obituary words and gold candle, Graveyard GIFs,
  Gun Bonsai VR screens, the five last checks (RESULTS_LAST.md), the cigarette slow-mo (15 s; only death or DOWN end it;
  carries across a level), Smoker invulnerability across a level, the Miniboss tier bonus on the strength order, Seated
  Auto pausing in DOWN, remote blocks = streak and slow only (no pip).
- README pass: every README's Controls and Status, the main page (the "DoomVR - Arcade Edition" overview, the DoomVR
  lineage, Champions credited to Mikk-), rig frames in 13 READMEs, Miniboss README separating "pick level" from "colour".

Code only, not shown, not compiled (after 15:07):
- **HUD (2afbb6cd, e0641993):** Score's line centred under the gauges; the ShieldSaw bar removed; no HUD over menus
  (Gun Bonsai VR, Score, Miniboss, SlowMo, Accessibility, Melee); status-screen pictures for the whip and fist; Display Info
  opens on the main hand. A ready rig launch: /home/claude/scratch/rig1110/HUD11A (+ HUD11_probe.pk3).
- **The ladder renumbered by strength (design/LADDER_RENUMBER.md):** 1 Common, 2 Green, 3 Blue, 4 Purple, 5 Cyan, 6 Brown,
  7 Yellow, 8 FireBlu, 9 Gray, 10 Red, 11 Abyss, 12 Black (boss, EX), 13 White (boss). Monsters, Miniboss, Score,
  VisualRewards, Grenade. EX monsters now tier up. The gem pictures were pushed early inside d2ad1ff9; they match from
  743b3f5b on.
- **DOWN eye height (BD22 VR 7b4892e = 2.0.4g; RSQ d2ad1ff9, fa31820f):** a StandEyeHeight helper in every pack that took
  ViewHeight as the eye.
- **Wheel 3D models (1d7db098):** saber hilt, shield, coiled whip, the FBX fist in the skin tone (glove when gloved).
- **Chest layout (90b6fa92, f2c049d2):** FnF's right-chest flare pocket off while the rig's flare holster is on; the
  flashlight now 0.21 m behind the flare holster on the off-hand hip (seated: beside the waist over it); cigarettes clear.
- **Watch-check rogue rods (c9005184, 14425b39):** a watch check turns off BOTH hands' lasers. The cause is NOT confirmed:
  the owner sees a green and a gray rod parallel to the laser; the only rods in his load order are Laser Sight's (the off
  hand's green halo and its near-white core in the PC VR look). **Owner check in the headset:** if the rods remain, turn
  off Laser Sight's Off Hand row, or set Laser to Quest, then watch-check.

## Open and unexplained
- **DOWN: shots seem to come from the right.** Not explained by reading; needs the one rig run in RESULTS_DOWNSHOT.md.
- **LegenDoom: no hands on guns.** Cause not found (RESULTS_LEGENHANDS.md). Waiting on the owner: where LegenDoom was in
  his order, whether the old patch pk3 was loaded; he is re-running it. Then one rig run (planned in that file).
- **BD22 VR side bug, not fixed:** rsq/flash.zs and recoil.zs treat every player hitscan as a shot, so each Rumble Backup
  buzz (Quake Haptics 0) flashes the muzzle, plays the tail and kicks the gun. Fix: skip our 0.1-range no-damage buzz traces
  (tag them with their own puff class).

## Owner decisions waiting to be BUILT
- **LegenDoom HUD, direction D** (design/mockups/legendoom_hud/README.md): no words over a legendary until it rises, then
  **LEGENDARY** (with LegenDoom's red pentagram and after-images); minibosses and thralls unchanged (GUARD!/TARGET!);
  pickup card **V3 (SOTN shimmer title)**; afterwards **option 1, a row under the gun hand's Gun Bonsai VR gauge**.
  Champions words PARKED (maybe none needed).
  **Built 11-11 (after this handoff):** GBOVR `rsq/ui/legendoom.zs` (card, row) and VisualRewards `rsqvr/ldword.zs` (LEGENDARY);
  one rig run, `design/rigtest_2026-11-10/RESULTS_LDH.md` (rig only; the placement fix after it is code only).

## Owner answers 11-11 evening
- Rifle grenade (M203) load: WORKS in his headset (19:10). The rig's failure was the rig's poses.
- Q1: RSQ Monsters is for minibosses, events and set-pieces; he plays with BD monsters almost always. So minibosses
  climb to Black/White whatever Monsters' boss settings are (as built). No change.
- Q2: his call to me; kept "Tier" (it means the 1-13 strength number everywhere). No change.
- Q3 answered by a decision: Colourful Hell (CH) monsters stop being a selectable spawn set; they are used for
  encounters only (minibosses, thralls, set-pieces). Then a map's own monsters are BD monsters, never Black/White, so
  Q3 is moot. NOT BUILT: goes into the queued Monsters pass.
- Q4: a remote block pays NOTHING (built: QuestSaber CountBlock -> CountDeflect(false); code only, not shown).
- Voxel hunt over the upside-down rifle: STOPPED by the owner (16:5x). Don't restart unless he asks.

## Questions still to ask the owner (one at a time)
1. Miniboss: if RSQ Monsters' Black Boss / White Boss settings are off, may a miniboss still climb to Black / White?
   (The agent allowed it.)
2. Miniboss: menu labels still say "Tier" (Tier From, Score Per Tier, Tier-Up Hits the Whole Map, Tier Up Each Life);
   rename to match "pick level" / "colour"?
3. Miniboss: with Thralls From = the map's own monsters, a thrall starting on Black/White keeps it. OK?
4. Saber remote: a blocked bolt still pays the deflect's small points (20). Keep, or pay nothing?
5. Wheel: "when the gloves are worn" was taken as Melee's Slappers Only / Boxing Gloves settings. Right?
6. Score's line gap under the gauges (1% of screen): judge in the headset.

## Queued projects (design/PLANNED_PROJECTS.md)
Monsters pass (menu: 29 problems; 256 compile warnings) · Gun Bonsai VR and Score Big Passes · Grapple 2.0 · the Big Four
(Score, GBOVR, Arcade, ...) · boss bar under Monster Assembly · then 2.0, maintenance mode, the move to REMA.

## Rig notes for when it is allowed again
/home/claude/scratch/rig1110/BRIEF.md (harness, traps, rules); run.sh resets qzdoom.ini inside the lock; launches waiting:
HUD11A, the DOWNSHOT plan, the LEGENHANDS plan, the WATCHVOX probe plan, a Wheel 3D frame, the ladder renumber (gems on
monsters), the chest layout (reach the cigarettes; the flashlight behind the flare).
