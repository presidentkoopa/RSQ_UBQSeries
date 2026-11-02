# RSQ Gun Bonsai VR

An addon for ToxicFrog's **Gun Bonsai 0.10.6** (guns level up and earn upgrades as you use them). Stock
Gun Bonsai thinks you hold one gun. With a gun in each hand, this addon gives each hand its own XP, its own
upgrades and its own HUD, and pays each gun for the damage it really did. It also adds upgrade paths for
the series' tools (gloves, sabers and the Force, the ShieldSaw, Distance Grab, Tactical Rig, SlowMo,
Grapple, two hands, the body), the owner's own Gun Bonsai screens, and an option to earn XP from RSQ
Score's style points. Gun Bonsai itself is never changed: the addon's files load after it and take its
place where needed.

**Moved to RSQ Melee (2026-11-01):** SuperPunchOut's boxing gloves, the punch, Slappers Only, Start With
Gloves and the moves Guard, Hadouken, Wall Splat and Heavy Hands now live in [RSQ_Melee](../Melee/). This
addon keeps their **upgrades** (Gun Bonsai offering them, their levels, their numbers) under the same class
names, so a save keeps what you learned. With RSQ_Melee loaded the glove upgrades work as before; without
it there are no gloves and none is offered (nor Guard).

Pk3: `pk3/RSQ_GunBonsaiVR.pk3` (it was `Gameplay_GB_VR_Offhand_Patch.0.10.6.pk3`; delete the old one).

## Load order

doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3 ->
BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> (any other RSQ pk3s) -> **GunBonsai-0.10.6.pk3** ->
**RSQ_GunBonsaiVR.pk3** (last)

- Needs Gun Bonsai 0.10.6 by ToxicFrog (not included). Put it right before this pk3.
- Needs no other RSQ pk3. Each series upgrade path is offered only while its mod is loaded (the glove
  upgrades and Guard with RSQ_Melee).
- Plain Doom 2 without Brutal Doom: the addon uses no Brutal Doom code and should work, but every recorded
  run used the Brutal Doom order. Needs a dual-wield VR engine (QuestZDoom).
- Other Gun Bonsai patches that replace the same files will clash with this one. Not recommended together.

## Setup

- In **Gun Bonsai's own options**, set its upgrade binding mode to **per weapon**. With a gun in each hand,
  per-class binding thrashes; the addon warns once at start-up if it is not set.
- Buttons: Gun Bonsai's own (its Show Info key opens the status and level-up screens; it can now reach a
  level the off hand earned). Bind them where Gun Bonsai puts them in Customize Controls; their names are
  Gun Bonsai's and are not in this repo. The addon adds no binds of its own.
- Menu: Options -> Radiant Silvergun Options -> **RSQ Gun Bonsai VR** (numbers on its **Tuning and Debug**
  page). Gun Bonsai's own options page also gets a link to this page at its bottom.

## What to do in VR

- Shoot with either hand: each gun earns its own XP.
- With RSQ_Melee's gloves on, punch (its README): left-right-left punches and a punch as a monster winds
  up its attack feed the glove upgrades.

## Features

RSQ Gun Bonsai VR page:

| Row | Default | What it does |
|---|---|---|
| Stock Gun Bonsai Upgrades | Silvergun | Silvergun: Gun Bonsai's own upgrades that do not mesh with the series are out of the pool everywhere (ours, the player, BD22's guns): Dark Harvest, Life / Armour / Ammo Leech (Kill Rewards covers them), Intuition (HP Bars does it), Juggler, Player Damage, Thorns. All: every stock upgrade back. Takes effect within a second; an upgrade a save already holds keeps working. (2026-11-02, not yet run.) |
| Kill Rewards | On | Monsters burst into bits of health (25), armour (10) and ammo (5 rounds) when they die: SoM's Universal Kill Rewards, folded in (2026-11-02, not yet run). By Health: one bit per 10 health, x3 for a boss (a Cyberdemon: 1200 bits). Its page: Bits per Kill (Few / Standard / Many), Boss Fountain (x1 / x3 / x5), What Drops (Even Mix / Mostly Health / Armour / Ammo), Bits Vanish After (Never / 15 s / 30 s / 1 min), Ammo Bits Give (The Gun in Hand / Any Gun I Carry), Bits Fly to Me (m). SoM's raw numbers (Drop Mode, ratios, chance, the two ammo types, Range) sit under Tuning on the same page. |
| XP Source | Damage | Damage (Gun Bonsai's own) / Style (RSQ Score's bonus points become XP, split along the combo chain: the finishing tool 50 %, the setup tools 50 %, plus 10 % to the player bar) / Both. Style without RSQ Score acts as Damage. |
| ShieldSaw Gauge | Option (off) | A third gauge, top centre, for the ShieldSaw while it rides on your shoulder. RSQ Score moves down to make room. |
| Screen Skin | Mockup | Which screens draw Gun Bonsai: Gun Bonsai (its own) / Mockup (the owner's mockups) / Hex Rail / Terminal. |
| Ammo And Health | On | With a skin: per-hand ammo, health, face and armour along the bottom (hides Brutal Doom's HUD under it). |

Tuning and Debug page: Force Base Strength (0.6: an unlearned Force power works at this share), First Star
After (1), Star Every (2) (Star Punch's banking, read by RSQ_Melee's punch), Grapple XP (1.0), Style XP Scale
(1.0), Style Player Share % (10), HUD Inset (0.04), HUD Size (1.0). (Slappers Only, Start With Gloves and
Punch Min Speed / Full Speed / Damage are on RSQ Melee's page now.)

Not on the menu: the dual HUD switch and the HUD positions (both on and set by default), and the
start-up binding warning.

Always on (no row):

- **Two live weapons**: each hand has its own XP, upgrade tree and upgrade effects (the off hand's Rapid
  Fire, Shield, Lightning and Bandoliers now run).
- **Credit follows the gun**: shots, fragments, explosions, minions and burns pay the gun that fired them,
  even after you switch or drop it. Two guns burning one monster each get their share.
- **Two HUDs**: main hand top right, off hand top left, mirror images. Left-handed (RSQ_Accessibility's
  Handedness, else QuestZDoom's scheme): swapped.
- **Knockdown and Executioner** are sized by the health a monster started with (works on LegenDoom
  legendaries and champions).
- **Upgrade paths for the series** (offered when that weapon or the player levels):
  - **Gloves: the Fists tree** (GBOVR_TREES.md 4.1, built branch by branch from 2026-11-02; each node is offered to a
    glove only once that glove holds its parent). **A. Power:** Heavy Hands (root) -> Haymaker -> Wallflower (shown
    name of Wall Splat) -> Knockdown; Heavy Hands 2 -> Body Blow (Body Blow 3 -> Knockdown); Heavy Hands -> Uppercut
    (an unlock: until it, a rising punch is a jab) -> Launcher (Uppercut 2) -> Juggle, Meteor (Launcher 2), Ground
    Pound (Launcher 3); Heavy Hands 2 -> Clear Out. Ground Pound and Clear Out need RSQ Gestures. Star Punch is no
    longer offered (folded into Uppercut and Launcher; a save that has it keeps it). **B. Elemental** (one element per
    glove: learning one closes the other three on that glove): Explosive Fist (after Haymaker; a punch at half speed or
    more blasts round the hit, twice as wide under the Berserk), Frost Fist (after Body Blow; frozen solid in the Ice
    colours, the next punch shatters it for x2.5 and up; a boss is slowed instead), Shock Fist (after One-Two; arcs to
    the nearest monsters within 3 m for 50% of the punch and up, each staggered), Fire Fist (after Heavy Hands 2; burns
    3 every half second, a punch on a burning monster flares x1.5). Their blasts, arcs and burns are paid to the glove.
    The look is particles and stock sounds until the art pass. **C. Combos:** One-Two (root) -> Three-Hit (One-Two 2;
    jab, jab, hook inside a second, either hand: the hook x1.75 and up, staggers) -> Dempsey (alternating hooks each
    inside 0.6 s: +10% a hook in the run a level, the glove re-arms in 4, 3, 2 tics) and Finisher (Three-Hit 2 and
    Executioner on that glove: the last hit of a 3+ chain on a staggered monster below 30% kills it, with a slow-mo
    pulse). **D. Counter:** Guard (the player's; RSQ Melee's row Start With Guard gives level 1 before it is learned) ->
    Parry (player: hands driven into the blow just before it lands: nothing through, the attacker reels), Reflect Guard
    (player, Guard 2: a missile meeting the raised Guard goes back at its shooter; at 3 a bullet does too) -> Absorb and
    Release (player, Reflect Guard 2: what the Guard takes charges it; both hands thrown apart let it out round you;
    needs RSQ Gestures). On a glove, after the player's Guard: Counterpunch, Swat Back (the open palm's swat goes back
    at the shooter) -> Hadouken (after Swat Back or Counterpunch). Catch and Bullet Time Fists are designed and off.
  - Gloves (RSQ_Melee's), before the tree: Haymaker, One-Two, Star Punch, Counterpunch, Body Blow, Knockdown, and the owner's
    picks 52-54 (2026-11-01), whose moves RSQ_Melee does and whose numbers are here: **Heavy Hands** (a landed
    punch freezes the monster for a beat: 2 tics at level 1 up to 4, +2 for a punch at half speed or more; and
    knocks it back 25% further a level; up to level 4), **Hadouken** (renamed from Return Fire, 2026-11-01: a punch
    that meets a monster's missile sends it back at whoever fired it, 15% faster a level, and it hits for 150% at
    level 1, +25% a level; up to level 4), **Wall Splat** (a monster your punch knocks into a wall at 3 map units a
    tic or more takes 10 at level 1, +5 a level, up to double for a hard slam; it bounces off and reels; up to
    level 5)
  - Sabers: Momentum, Riposte Edge, Piercing Return, Saber Throw, Chain Choke, Dual Harmony, Deflector;
    the Force: Force Push, Force Pull, Force Choke, Force Jump
  - ShieldSaw: Broadening, Lockstep, Ricochet, Meat Grinder, Hunter's Return, Bulwark, Rebound, Battering Ram
  - Any melee: Lunge, Executioner, Adrenaline
  - Player, each only while its mod is loaded: Distance Grab (Long Arm, Iron Grip, Heavy Hitter, Air Catch,
    Powder Keg); Tactical Rig (Quick Draw, Pair Draw, Showdown with SlowMo); SlowMo (Marksman, Dodger,
    Second Wind, Time Dilation); two hands (Akimbo, Crossfire, Alternator); the body (Evasion, Southpaw,
    Steady Aim; and pick 55 (2026-11-01) **Guard** (the move is RSQ_Melee's, offered while it is loaded):
    both hands up at your face, a blow from in front does 60% of its damage at level 1, 10% less a level, down to
    30% at level 4; a blow of 35 or more at level 1 (+10 a level) breaks the guard); Grapple (Long Line, Fast Reel, Heavy Haul, Get Over Here, Bowling, Barbed Claw, Slingshot,
    Steady Line, Double Hook from player level 5).

## Test it

Load the order above (Gun Bonsai 0.10.6, then RSQ_GunBonsaiVR.pk3 last). Its handoff says it was never run
on the owner's headset; nothing below is headset-confirmed.

1. Start MAP01. Two Gun Bonsai gauges: top right (main hand), top left (off hand) once both hands hold guns.
   With only one gun, one gauge, like stock Gun Bonsai.
2. Shoot with the off-hand gun only: the top-left gauge's XP grows, the top-right does not.
3. Swap guns between hands: each gun keeps its own level (credit follows the gun).
4. Level the off-hand gun and press Gun Bonsai's Show Info: you can spend the off hand's level.
5. The screens: the status and level-up screens use the Mockup skin. Screen Skin -> Gun Bonsai: Gun
   Bonsai's own screens come back. Try Hex Rail and Terminal.
6. Ammo And Health On (with a skin): ammo, health, face and armour along the bottom; Brutal Doom's HUD is
   hidden under it. Screen Skin -> Gun Bonsai puts Brutal Doom's HUD back.
7. (The gloves, the punch through a wall and Slappers Only are tested in RSQ_Melee's README now.)
8. XP Source -> Style, with RSQ_Score loaded: a plain kill pays little XP; a kill with bonus rows (a combo,
    No-Look) pays more, split between the tools used.
9. ShieldSaw Gauge On, with RSQ_ShieldSaw: a third gauge at top centre while the shield is on your
    shoulder; RSQ Score's display moves down.
10. With RSQ_Wheel: the data sheet shows the gun's Gun Bonsai level and upgrades. With RSQ_GunCards: the
    watch card shows level, XP bar and upgrades. (service checked on the rig 2026-10-31: not yet
    headset-confirmed)
11. RSQ_Accessibility Handedness -> Left-Handed: the two gauges swap sides. Text Size 2: the screens' text
    grows.

The owner's picks 52-55 (2026-11-01), with RSQ_Melee loaded (it does the moves; this addon offers them and
sets their numbers). Offered at a level-up like the others (the three glove ones when the gloves level, Guard when
the player levels) and work once learned; RSQ Melee's own rows for them do nothing while this addon is loaded.
Rig-checked (logs) only: **not yet headset-confirmed**.

12. Heavy Hands on the gloves: punch an imp. It stops dead for a beat, then flies back further than before.
13. Wall Splat: punch an imp standing about a metre from a wall, toward the wall. It slams into the wall with a
    smash, bleeds, bounces off and reels.
14. Hadouken: let an imp throw a fireball at you and punch it as it arrives. It flies back at the imp and
    hurts it.
15. Guard (empty hands, fists or the gloves): hold both fists up in front of your face and let a zombieman or imp
    hit you from in front. Both hands knock, you slide back a little and take less. Let a big hit land (a baron's
    claw): the guard breaks with a smash and you take it all. Hands down: no guard. A gun in either hand: no guard.
16. With RSQ Accessibility (Seated Play, Rumble Strength): RSQ_Melee's README; it reads them for the Guard now.

## Works with

- **RSQ_Melee** (the gloves, the punch, Slappers Only, Guard, Hadouken, Wall Splat, Heavy Hands since 2026-11-01):
  it asks RSQ_MeleeUpgradeService for upgrade levels ("level", "plevel"), their numbers ("upgrade.num"), Gun
  Bonsai's melee inference ("is.melee"), "stagger" and "claim" (a returned fireball or a wall slam paid to the
  glove); the glove upgrades ask RSQ_Melee's RSQML_Service about the last punch ("punch.power", "punch.chain",
  "punch.star", "punch.counter", "punch.body", "punch.glove"). Both by name.
- **Read by RSQ_Wheel and RSQ_GunCards**: a gun's level, XP and upgrades (RSQGB_Service).
- **Read by RSQ_Saber, RSQ_ShieldSaw, RSQ_DistanceGrab, RSQ_Grapple** (and the Wheel / Gun Cards): their
  upgrade levels (RSQ_MeleeUpgradeService). Without this addon each behaves as before (the ShieldSaw's
  Double Block Radius option then still doubles the plate; with the addon the plate grows by Broadening).
- **Read by RSQ_Score**: how far the ShieldSaw gauge reaches, so the score moves down.
- **Reads RSQ_Score**: a kill's bonus points and combo chain (XP Source: Style).
- **Reads RSQ_SlowMo**: is the world slowed; Adrenaline adds to SlowMo's meter.
- **Reads RSQ_Grapple**: what the hook did, for hook XP and the Grapple paths.
- **RSQ_Whip and RSQ_Grenade (2026-11-02, not yet run)**: each pays its hits to its own weapon record through
  this patch's service (the whip's `Hurt` inside the claim bracket; the thrown grenade claimed with the grenade
  weapon as master), so both level like weapons and can carry the paths in GBOVR_TREES.md. The whip is typed
  melee in `bonsairc.rsq`.
- **Service, for the owning mods**: `RSQ_MeleeUpgradeService` "unlocked" (a weapon node learned, level >= 1) and
  "punlocked" (a player node), beside "level" and "plevel". `RSQ_Upgrade_Base.Has / PHas / LevelOf` are how a
  tree node asks for its parent in `IsSuitableFor*`.
- **Reads RSQ_Accessibility**: Handedness (HUD sides), Colour Blind Mode (HUD and status screen), Text Size
  (screens). Also (2026-11-01, not yet headset-confirmed): Rumble Strength scales every rumble of this addon
  (gloves, guard); Seated Play lowers the Guard box with your eyes (QuestZDoom keeps the view height where it
  was when you sit, so seated fists at the face were below the box). (Those two reads for the gloves and Guard are
  RSQ_Melee's own now.)
- Tactical Rig draws pay the drawn gun like any shot.
- Score-to-XP (Gun Bonsai's own setting): if on, keep Gun Bonsai's damage-to-XP at 0, or kills pay twice.

## Known limits / open

- Picks 52-55: what each move became, and its limits (Guard's box, Hadouken seeing missiles only, Wall Splat
  counting walls only): RSQ_Melee's README.
- Never run on the owner's headset (its handoff). The 2026-10-31 work (the RSQGB_Service rig check, the
  punch wall check) is rig only.
- How often Knockdown and Executioner fire on legendaries in real play is not measured.
- Gun Bonsai's upgrade toggle / tune menu still addresses one weapon (its own protocol can only name one).
- Both HUDs draw the player XP bar (it is in the frame art).
- Credit for a shot in flight across a save / load or a level change is dropped (better than crediting
  the wrong gun).
- Screen Skin defaults to Mockup (on). The independent review asked for Gun Bonsai's own (off) unless the
  owner chose it: the owner's call.
- Removing the addon with a skin on leaves Brutal Doom's HUD type changed: pick your HUD again in Brutal
  Doom's options.
- A Distance Grab throw's points went to the main-hand gun on the rig; which hand wins in the headset is not
  measured.

## Credits

From the old README:

> Gun Bonsai is by Rebecca "ToxicFrog" Kelly, MIT licensed. This is a derivative
> work under the same terms.
>
> Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa); glove mesh and fit by Ermac
> (iAmErmac); sounds from Punch Out Doom (DerrickDavison) via Virtual Punch Out.
>
> (2026-11-01: the gloves, the punch reader and the punch and star sounds moved to RSQ_Melee, whose
> credits carry these lines. Knockdown's sound and the count stay here.)
>
> vr patch conceptualized by PresidentKoopa, authored with agentic ai

From the old README's screens section: "Screens designed by presidentkoopa." The gauge frame is Gun Bonsai's
own HUD art; the screens write in Doom's own IWAD fonts.

From `readme.txt`, unchanged:

```
CREDITS
-------
Gun Bonsai: Rebecca "ToxicFrog" Kelly, MIT. This patch and the melee upgrades:
presidentkoopa, same terms. Gloves, punch reader and sounds: SuperPunchOut
(presidentkoopa); the glove mesh and its fit are Ermac's (iAmErmac, PunchOutVR /
Virtual Punch Out); punch, star and knockdown sounds from Punch Out Doom
(DerrickDavison) through Virtual Punch Out; the count is the Super Punch-Out!!
announcer, as SuperPunchOut ships it. Punch-Out!! is Nintendo's.
```

Gun Bonsai's MIT licence and the note on files derived from it: `COPYING.md`.

## Appendix: for builders (the earlier README, unchanged)

The patch ships replacement copies of nine Gun Bonsai source files at their
original paths. GZDoom's later-lump-wins rule substitutes them; there is no
patching step. Everything else in Gun Bonsai is untouched.

```
ca.ancilla.bonsai/PerPlayerStats.zsc        two live infos, provenance registry, Claim API
ca.ancilla.bonsai/EventHandler.zsc          dual HUD render, hitscan bracket, offhand ShowInfo
ca.ancilla.bonsai/WeaponInfo.zsc            cross-hand rebind guard
ca.ancilla.bonsai/WeaponTypeInference.zsc   type hints from claimed shots
ca.ancilla.bonsai/HUD.zsc                   per-hand anchoring
ca.ancilla.bonsai/debug.zsc                 bonsai-debug,hands
ca.ancilla.bonsai/upgrades/Dot.zsc          proportional burn credit
ca.ancilla.bonsai/upgrades/Juggler.zsc      both hands
ca.ancilla.bonsai/upgrades/RapidFire.zsc    per-hand psprite, null guard
```

Any file shipped here that is *not* actually modified should be deleted — an
unchanged shadowed file is collision surface with other patches for no benefit.

**2026-11-01:** `rsq/zscript/gloves.zs` and `slappers.zs` and the Guard pose referred to below moved to
RSQ_Melee (`Melee/zscript/rsqml/gloves.zs`, `slappers.zs`, `guard.zs`, `splat.zs`); `rsq_punch_debug` is
`rsqml_debug` there. The notes below are kept as they were written.

### Handoff (2026-10-27) -- read first

Not yet run on the owner's headset. Rig B = QZD 17.3 Linux, doom2 MAP01, the owner's order
(brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions -> LegenDoom Lite 4.2 -> the suite ->
GunBonsai-0.10.6 -> this patch). Probe `pol/kdprobe` in the session scratchpad (real BD imps, LegenDoom
Lite's guaranteed legendary pickup, the upgrade objects called with level 1).

**Done, measured**
- *Knockdown and Executioner size against the health the monster STARTED with* (`RSQM.StartHealth`,
  branch `agent-polish`): Champions' StartHealth as before, and for a LegenDoom Lite legendary
  (transformed or not) the class's spawn health x `LD_legendaryhealth` / 100 (the ACS's own integer
  arithmetic, the ShieldSaw's TierHealth rule), the larger winning. Knockdown level 1 (share 0.44),
  damage in 5s until down: plain imp 40 -> 40; untransformed legendary imp (240 hp) 40 -> **110**;
  transformed legendary (refilled to 240) 40 -> **110**. A legendary champion (StartHealth already 240)
  stays 240, not 720. Executioner level 1 on a transformed legendary at 30 hp: no execution before
  (threshold 12), executed now (threshold 36).
- *Executioner after the victim's damage factors* (1f32468, `agent-compat`) still holds with the change:
  an imp taking half (DamageFactor 0.5) at 10 hp, staggered: blow 5 -> 22, 11 dealt, dead.
- *Brutal Doom's HUD type* (8b4b24f): the skins hide BD's HUD with `bd_sbartype` 5, a type BD knows;
  full order + save/load twice + map change: no `Unknown item type sbartype0` line (0 in the log).

**Done earlier today, recorded in commits** (their own numbers, not re-measured here): melee upgrade
paths, gloves, Slappers Only and the claim bracket (0f2f48d); Adrenaline charges SlowMo's meter
(b9f142e, rig: two charges of 10 read 20); suite upgrade paths for the ShieldSaw, saber, grab, rig,
SlowMo, hands and body (a460f51); punch and swing sounds renamed so they no longer replace BD's own
(a1ae4fb); COPYING.md (f357289); the screens and their fonts (e9b7eb8, d64248c, 90e80f2); left-handed
dual HUD reflected (6973ddb); Grapple player perks (fcf0a7a); colour-blind HUD (4bdd8c7); accessibility
round two (1b986bb); XP Source (49fd7c0, section below).

**Done 2026-10-30, not measured -- wall occlusion on the punch contact test**
- *A punch no longer lands through a wall* (`rsq/zscript/gloves.zs`, `RSQ_GloveHandler.ClearPath`
  at `:310`, called from `Contact` at `:268`). `BlockThingsIterator` is a blockmap query and never
  looks at a linedef, so the broad phase returned a body on the far side of a thin wall and the
  nearest-approach test only measured distance; `02_MELEE_BUILD.md` §2.3 named this as the live
  bug to fix first. The narrow phase is one `LineTrace` per candidate the nearest-approach test
  would otherwise accept, `TRF_ABSPOSITION` from the glove's contact point to the body's axis at
  the height it met it, `TRF_THRUACTORS` so the player's own body, the victim and any third
  monster between them are all transparent and only geometry can stop it. `CheckSight` was
  rejected: it starts at the actor's eyes and cannot be told where to start, and it rolls the
  playsim RNG on an invisible target. No Z conversion -- a hand pose is an absolute map position
  already (the pixelstretch division is inside the weapon transform), which is why the existing
  `p.z` vs `mo.pos.z` test is right as it stands. Nothing else moved: Score needs no change,
  because a punch that does not land is not scored.
- Cost: zero traces on a tic no swing passes the arm/approach gate; on the tic one does, one trace
  per foe overlapping that glove's sphere that improves on the best candidate so far -- one in
  practice, per hand.
- **Not compiled.** There is no build in this working tree; the first real check is the headset.
  `rsq_punch_debug 1` prints `RSQ punch blocked: type <HitType> at <dist> of <dist> to <class>`
  on a rejection, which is how to prove the trace fired at all.

**Not done / headset**: how often Knockdown and Executioner fire on legendaries in real play.

**Open**
- `rsq_ui_skin` defaults to 1 (the screens on). The independent review (10-27, item 1) asks for 0 unless
  the owner chose 1; 90e80f2 turned it back on after cee9be2 had shelved it. The owner's call.

### RSQGB_Service: a gun's level and upgrades, for any mod (`rsq/zscript/service.zs`)

Asked by name (`ServiceIterator.Find("RSQGB_Service")`), so the asker needs no Gun Bonsai to compile.
Pass the Weapon (either hand, the backpack, or a dropped one a record still names), or the pawn with
intArg 0 main / 1 off hand. `GetInt` "level", "xp", "xp.next", "xp.permille", "count", "hand";
`GetString` "upgrades" = `Name:level:max:Class:on:Colour|...` (Gun Bonsai's own display name without
its colour code, then the code's colour) and "name". Read-only: no Gun Bonsai method is called.
RSQ Wheel's sheet uses it. Rig (2026-10-31, owner's order + gb 0.10.6): Rifle "HE Shots:2:2:...|Searing
Inscription:1:1:TFLV_Upgrade_IncendiaryShots:1:ORANGE|...", off-hand Shotgun's five, a dropped Rifle's three.

**Punch wall occlusion, measured 2026-10-31** (rig, simulated glove, `rsq_punch_debug 1`, a Demon at
36 units): behind a 4-unit closed door, fist on the near face: blocked (`type 3 at 1.0 of 36.0`), no
damage; same distances in the open: lands (150 -> 137); monster on a 24-unit step, fist 5 units below the
step top: blocked by the step's face (`type 3 at 1.0 of 36.3`); fist at the step top, 2 above, at the
shin: all land. The clamp of the aim point to the monster's feet only blocks a fist that is below the
step top, where the step really is in the way; no change made. A fist pushed through the door to the far
side still lands (the trace starts at the fist).

### Suite upgrades (`rsq/`)

New files only, compiled by a second ZSCRIPT lump (`zscript.txt` at the root): weapon upgrade paths
for the boxing gloves, the sabers and the Force, the ShieldSaw and any melee weapon; player upgrade
paths for Distance Grab, the Tactical Rig, SlowMo, the two hands and the body (each offered only
while its mod is loaded); **Slappers Only**. See `readme.txt` for the list, who earns which XP, and
the score-as-XP settings. The saber, the ShieldSaw and the grab ask `RSQ_MeleeUpgradeService` for
their levels by name; nothing links to anything.

The changes to shadowed files: `PerPlayerStats.zsc` (the claim bracket `claimStack`, the player
pool for throws, score XP shared per kill, `HandOfShot`, the XP Source gate `RSQ_XPSource` and the
per-monster credit `NoteStyleHit`, `GetShieldStats`), `HUD.zsc` (`DrawShield`), `EventHandler.zsc`
(the shield gauge's one call) and `debug.zsc` (the pool in the hands dump).

### XP Source: Damage, Style, Both (`rsq/zscript/stylexp.zs`)

Options -> the suite upgrades' page -> **XP Source** (`rsq_xp_source`, server): **Damage** (Gun Bonsai's
own, the default: nothing changes -- measured: the same 17 scripted kills left every weapon record, the
pool and the player XP identical to master), **Style**, **Both**. Style needs RSQ Score (asked by name);
without it Style reads as Damage.

With **Style** a kill's style points -- RSQ Score's bonus rows for that kill, the total less the base,
Champions' and LegenDoom Lite's rows included -- become XP (x `rsq_xp_style_scale`, 1.0), split along
its combo chain (RSQ Score's `kill.chain`, the finishing blow last): the **finisher's tool 50 %**, the
**setup tools share 50 %** equally (a chain of one tool: the finisher takes it all), and on top
`rsq_xp_style_player` (10 %) to the player pool. Damage pays no XP; the stock score-to-XP and the
hook's action XP stand down (they would pay the same kill again). **Both** keeps damage XP and adds the
style. Each share goes down the patch's existing paths: a gun to the gun(s) Gun Bonsai credited with
hitting that monster (`PerPlayerStats.NoteStyleHit`), the saber and the Force to the saber (up_saber),
the shield's tools to the ShieldSaw (up_shield), the gloves to the gloves (up_gloves), a punch, kick,
blade or finisher to the melee weapon that hit it (up_melee), the hook, the whip and a grab throw to the
player pool (up_hook's and the grab's perks are player upgrades). Measured (imp, base 60):
whip > ShieldSaw bash, style 66 -> ShieldSaw 33, pool 33 + 6.6; gun > saber cut > kick, style 69 -> kick
34.5 (pool), gun 17.25 (Shotgun), saber 17.25; four tools, style 66 -> finisher 33, three setups 11 each.
The XP bars look exactly as before.

### The ShieldSaw gauge (`rsq_hud_shield`, off by default)

Options -> the suite upgrades' page -> **ShieldSaw Gauge** (user). A third Gun Bonsai gauge -- the stock
art, colours, bars and text, through the same `DrawHUD` the hand gauges use -- for the ShieldSaw while it
rides on the shoulder (stowed or thrown; in a hand, that hand's gauge shows it), centred at the top
between the two hand gauges, just under their bars (22 % of a hand gauge's height down), scaled to fit
the gap (90 % of it, between half and full size of a hand gauge; `TFLV_HUD.ShieldScale`). RSQ Score
moves its display down by as far as the gauge reaches (`RSQ_HudService "shield.gauge.drop"`). Off,
nothing is drawn and nothing moves. It shows once the ShieldSaw has a Gun Bonsai record (it has been
held, or has earned XP).

### The screens (`rsq/ui/`)

The owner's Gun Bonsai mockups, drawn instead of Gun Bonsai's own HUD, status screen and level-up
menus. Options: **RSQ Gun Bonsai VR** (Screen Skin, Ammo And Health; HUD inset and size under Tuning and Debug).

```
rsq_ui_skin       0 Gun Bonsai's own, 1 Mockup (the recreation), 2 Hex Rail, 3 Terminal
rsq_ui_inset      fraction of each screen edge kept clear (the headset's edge of view)
rsq_ui_hud_scale  HUD size
rsq_ui_bottom     per-hand ammo, health, face and armour along the bottom
```

How it hooks Gun Bonsai: `RSQUI_Handler` draws the skin's HUD round Gun Bonsai's own XP gauges, which
draw themselves (no Gun Bonsai HUD code is skipped any more: d64248c). Gun Bonsai opens its menus by name, and this
patch's MENUDEF points those three names at routers (`rsq/ui/router.zs`) that are Gun Bonsai's own
menus with skin 0 and open the skin's screen otherwise. No other Gun Bonsai file is shadowed.

RS Score's display and Gun Bonsai's XP gauges draw themselves, untouched. With the bottom row on, a
skin sets Brutal Doom's `bd_sbartype` to 5 (a type Brutal Doom knows but draws nothing for; its
fullscreen HUD would sit under the row). It is put back when the skin is set to 0. Remove the patch
with a skin on and it stays as set: pick your HUD again in Brutal Doom's options (or `bd_sbartype 1`).

The screens write in Doom's own fonts from the IWAD (SmallFont, BigFont, NewSmallFont; owner, 10-27:
"just use the doom fonts"); the baked OFL fonts were removed in d64248c. `tools/rsqui_bake.py` makes
the remaining art; gun pictures come from `tools/rsqui_gunshots.py` (the gun's own model on the test
rig, keyed and cropped into `graphics/rsqui/guns/<Class>.png`; a gun without one shows its icon or
pickup sprite). The gauge frame is Gun Bonsai's own HUD art. Screens designed by presidentkoopa.

### Known collisions

Other Gun Bonsai patches that shadow the same files will silently clobber, or be
clobbered by, this one. GunBonsai has a number of addons and patches which alter its main behavior. I would not recommend using any of those with this patch. Maybe load this last if you do, but expect problems.

More detail (settings, diagnostics, claiming shots, who earns which XP): `readme.txt`.
