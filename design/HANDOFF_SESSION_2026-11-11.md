# Handoff: session of 2026-11-10 / 11 (RSQ UBQ Series, "DoomVR - Arcade Edition")

Owner: presidentkoopa. Read /home/claude/rsq_ubqseries/CLAUDE.md first, then this file, then design/PARKED.md and
design/PLANNED_PROJECTS.md. Last updated 11-11 22:00 (end of session).

## Standing orders in force
- **Rig:** the owner reopened batched rig tests at 15:35 ("expect to hit weekly limit"), then said "no rig checks" for the
  19:23 items. Ask before the next rig run. The load check (/tmp/lc.sh: builds, then loads the full order with no game)
  has been used for every change, and every change since then has loaded with no script errors.
- Ask the owner **one question at a time** (AskUserQuestion), and never cut his options (11-11 14:09).
- **Don't argue, don't sass, and don't blame his setup.** He had LegenDoom at 0.99 when I suggested the load order.
  Stop when told: he stopped the voxel hunt at 16:5x.
- Labels: "rig only, not headset-confirmed" / "code only, not shown" / "not yet run".
- **Keybinds:** precious; no new keys.
- **Commits:** by explicit path; never `git add -A`; never commit a pk3.
- **Art:** Doom asset rips are fine with credit; never redraw someone's art.
- **Delivery:** every pk3 goes to C:\Users\Command\Desktop\PK3TEST via SendUserFile, then device_commit_files with the fileUuid
  (a reused stagedPath can deliver a stale copy).

## Load order (current)
doom2 > LegenDoom (optional, right after doom2) > brutal22test6 > BD_VoxelPack > **BD22 VR 2.0.4i**
(rs_brutal22weaponsq ef99cb5, pk3 built in its pk3/, not committed) > LOB > Champions (Mikk-) > Gun Bonsai 0.10.6 > the
RSQ pk3s. /tmp/lc.sh and the rig's run.sh point at 2.0.4i. **The owner's PK3TEST folder still holds 2.0.4g and 2.0.4h: he
must delete those two so only one BD22 VR loads.**
At 22:00, pk3/ in this repo and Desktop\PK3TEST matched for all 21 RSQ pk3s (same sizes, built from HEAD).

## Done 11-11 afternoon and evening (all pushed to main)
Rig only, not headset-confirmed (design/rigtest_2026-11-10/RESULTS_R1.md, RESULTS_R2.md under R2/R3/R4, RESULTS_LDH.md):
- **HUD11A:**
  - Score's line;
  - no ShieldSaw bar;
  - no HUD over menus;
  - Display Info opens on the main hand;
  - the off-hand fist picture (case-blind `rsq_hands` match, d0d23f86).
- **Wheel:** one fist card; the 3D cards; the Wheel's 3 compile errors fixed (NROWS).
- **Chest:** the flare diamond is gone; the flashlight behind the flare holster; cigarettes reachable.
- **Ladder renumber:** all 13 tiers, gems and tier-ups are right; Score rows paid. Yellow wasn't paid on its own.
- **DOWN holsters:** they drop with the hands.
- **BD22 VR 2.0.4h, buzz:** no muzzle flash on a buzz (shown by log); whether the buzz still kicks the gun isn't proved.
- **BD22 VR 2.0.4i, hands:** BD22 VR's hands come back to the off hand when the main hand switches to a gun after a glove
  pick. The shotgun pump is shown with gloves on and off.
- **BD22 VR 2.0.4i, revolver:** the speedloader revolver throws one casing per empty chamber, all on the opening tic (log).
- **BD22 VR 2.0.4i, DOWN muzzle glow:** BD22's PlayerMuzzle1 now sits on the drawn muzzle instead of at standing chest height.
  Log only; the owner should judge whether it was the "shots from the right".
- **SlowMo:** the green world bar for the revive and the cigarette; the cigarette and world slow-mo add up. An automatic
  slow-mo during a smoke needs `rsqsm_auto_cooldown` 0 or a lapsed cooldown.
- **LegenDoom HUD direction D** (GBOVR `rsq/ui/legendoom.zs`, VisualRewards `rsqvr/ldword.zs`): no word at full health,
  LEGENDARY risen, the V3 card, its fold, the MURDEROUS X3 row, the off switches. The row and rarity-tick placement fix
  after the run is code only; the row may touch Score's line. LegenDoom's buff row (ACS HudMessage id 0) can't be hidden.
- **Headset-confirmed by the owner:** the rifle grenade (M203) load works (19:10).

Code only, not shown (each loads clean on the full order):
- **Melee:**
  - Start With Melee Hands puts the gloves in the inventory only, so BD22's start weapon and BD22 VR's off hand stay;
  - the gloves are out of slot 1 (one fist on weapon next).
- **Saber:** a remote bolt blocked on the blade pays no points; the streak and slow stay.
- **Score:** the line centred top middle, level with the middle of the two Gun Bonsai VR gauges; GBOVR publishes
  `gauges.top`.
- **SlowMo DOWN:** a target that plays dead (Champions' Dark Red: buddha, 1 HP, invisible, not shootable) counts as killed, so
  the owner revives.
- **Wheel:**
  - cards use the Spawn frame a gun really shows (BD22's pistol was drawing vanilla PIST A);
  - the data sheet is drawn 0.5 m from the eyes along the line of sight, at the same angular size (Data Sheet Distance;
    0 = at the ring).
- **Reverted:** both watch-check changes (76daa8ca two-hand gate, 5a08eeca forearm-across). The owner liked the watch card as
  it was.

## Open
- **Extra pieces over an upside-down rifle (owner's 16:36 frame, evidence/OWNER_1636_*):** STOPPED by the owner. The rig
  shows they are layer 1, the Rifle's own model (its M203 and barrel). His frame looks like the M203 tube slid open. Don't
  restart unless he asks.
- **Waiting on his headset:**
  - hands after a Wheel glove pick;
  - the Melee start;
  - the DOWN glow and the Dark Red revive;
  - the revolver;
  - SlowMo bars and stacking;
  - the Saber block;
  - Score's place;
  - the Wheel pistol card and sheet distance;
  - the LegenDoom HUD.
- **Not asked yet:** the main grip flipped BD22's pistol between Burst and Semi on the rig. Should it?
- **Not built, decided:** Colourful Hell monsters for encounters only, no longer a spawn set. This goes into the Monsters pass.
- **Built 22:00, code only:** the words over a LegenDoom drop (VisualRewards ldword.zs, row "LegenDoom: Drop Words"). X3 is shown for Murderous only.

## Owner answers 11-11 evening
- Q1: RSQ Monsters is for minibosses, events and set-pieces; he plays with BD monsters almost always. Minibosses climb to
  Black/White whatever Monsters' boss settings are (as built).
- Q2: kept "Tier" (it means the 1-13 strength number everywhere).
- Q3: CH monsters for encounters only (see above). Moot.
- Q4: a remote block pays nothing (built).
- Q5: "gloves worn" = Melee's Slappers Only or Boxing Gloves (as built).
- Q6: Score centred top middle between the XP gauges (built).
- Wheel data card: "Bring it closer" (built). He did not pick bigger text, short-first or facing.
- Start With Melee Hands: "Inventory only". Slot 1: "Take both gloves out".

## Parked (design/PARKED.md)
- **Crosshairs fly in from offscreen** (Predator / Virtual Cop clips in design/refs/crosshair_flyin/). This applies to
  Be Quick or Be Dead, Miniboss and others.
- **Not decided yet:** the Champions words, and the boxing gloves' own role.

## Queued projects (design/PLANNED_PROJECTS.md)
- the Monsters pass (now including CH monsters for encounters only);
- the Gun Bonsai VR and Score Big Passes;
- Grapple 2.0;
- the Big Four;
- the boss bar under Monster Assembly;
- then 2.0, maintenance mode, and the move to REMA.

## Rig notes
- **Harness:** /home/claude/scratch/rig1110/BRIEF.md (harness, traps, rules). run.sh resets qzdoom.ini inside the lock.
- **R2's harness:** design/rigtest_2026-11-10/evidence/R2_r2run.sh.
- **Off-hand grip:** it can't be pressed on the rig. Probes send the `rsqtr_grip` / `rsqff_grip` events and hold them about
  8 tics.
- **Hand roll:** it reaches the renderer but not scripts. Use `rsqg_inspect_twist 0` to bring up the watch card.
- **Resolution:** at 1080, +attack/-attack can fall inside one frame. Use 480-720.
