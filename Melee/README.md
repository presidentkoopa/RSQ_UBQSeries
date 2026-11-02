# RSQ Melee

Fighting with your body: Melee's own hands (Ermac's hand, or BD22 VR's FBX hand; fist or open palm), the punch, the
open-palm swat, SuperPunchOut's boxing gloves, Slappers Only, the Guard, the Hadouken, Wall Splat, Heavy Hands, the
gun-butt shove (BD22 VR Reloaded's) with a slow-motion beat after it, and the off-hand **Headlock**. Each blow shows
its own hit spark. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3 (script and data only, no
engine changes).

**Nothing here is headset-confirmed.** Every check below ran on the simulated rig (scripted hand poses through the
rig's `qz_rhand` / `qz_lhand`): rig only, not headset-confirmed.

Pk3: `pk3/RSQ_Melee.pk3`. Where each mechanic lives: [WHO_OWNS_WHAT.md](../WHO_OWNS_WHAT.md).

## Load order

```
doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE
          -> RSQ_Melee.pk3 (any order among the RSQ pk3s)
          -> GunBonsai-0.10.6.pk3 -> RSQ_GunBonsaiVR.pk3 (last; only with Gun Bonsai)
```

- **Needs no other pk3.** Everything works on plain Doom 2 alone; other mods only add to it (Works with).
- With **BD22 VR Reloaded** loaded: Melee Hands' Auto picks its FBX hand (with its Hand Skin Tone), and the gun-butt
  shove stands down for BD's own butt strike (the slow-mo follows BD's strike instead).
- **Saves:** the classes kept their names (RSQ_Glove / RSQ_GloveOff are Melee's hands), so older saves load and Gun
  Bonsai upgrades stay learned.

## Setup

- Menu: Options -> Radiant Silvergun Options -> **RSQ Melee**. Fine numbers, Debug Log and Reset All are on its
  **Tuning and Debug** page. RSQ Accessibility's *Reset Every Series Mod* runs this Reset All too.
- Melee's hands: **Start With Melee Hands** (each level, raised in both hands), **Slappers Only**, or weapon slot 1.
- No buttons to bind. The Headlock reads the off-hand grip directly (`rsqml_keys_off`, 443 436, the same keys RSQ
  Distance Grab and the Tactical Rig read).

## What to do in VR

- **Fist or open palm:** tap a hand's own fire (main hand: fire; off hand: the off-hand fire). Each hand starts as a
  fist. Boxing gloves stay fists.
- **Punch** (fist): from a slow hand, throw it at least 15 cm, 2 m/s on average for the weakest punch, 7 m/s for full
  power, into a monster. Straight, from the side or rising: jab, hook, uppercut. An **uppercut lifts** the monster.
- **Swat** (open palm): swing the palm through a monster's fireball (1.5 m/s or more): it is knocked aside.
- **Hadouken** (fist, when it is on): punch a monster's fireball: it flies back at whoever fired it.
- **Guard** (when it is on): both hands up at your face, no gun in either hand, and hold.
- **Wall Splat** (when it is on; Gun Bonsai VR calls it Wallflower): punch a monster toward a wall about a metre
  behind it.
- **Ground Pound** (when it is on; needs RSQ Gestures): swing both fists down hard together, past your hips, at
  3 m/s or more.
- **Clear Out** (when it is on; needs RSQ Gestures): thrust both palms forward together, side by side, nothing but
  Melee's hands in either hand.
- **Gun-butt shove:** with a gun in your main hand, shove it hard (3.6 m/s) at a monster within about 2 m.
- **Headlock:** off hand on a living monster (within 30 cm), squeeze the grip. You hold it by the collar, its face at
  your hand, for 3 s; punch it with the other hand. Swing the off hand hard to throw it. Let go of the grip to drop it.

## Features

**Base moves vs upgrades (decided 2026-11-01).** Melee's hands, the punch, the swat, the gloves, Slappers Only, the
shove and the Headlock are **base moves**. Guard, Hadouken, Wall Splat and Heavy Hands are Gun Bonsai upgrades:
**with RSQ Gun Bonsai VR loaded** each works only once Gun Bonsai has granted it (on Melee's hands; Guard on the
player), at the learned level's numbers, and **Melee's four rows for them do nothing**. **Without Gun Bonsai VR** each
has a Melee row, **off** by default, that plays it at the upgrade's level 1.

RSQ Melee page:

| Row | Default | What it does |
|---|---|---|
| Melee Hands | Auto | Auto: BD22 VR's FBX hand when RSQ's BD22 VR weapons mod is loaded (found by name), else Ermac's hand. Or Ermac / FBX (BD22 VR). Fist = each model's fist frame, open palm = its relaxed open hand (frame 0 of each). |
| Boxing Gloves | Option (off) | Melee's hands wear SuperPunchOut's boxing gloves: always fists (no open palm, no swat). |
| Open-Palm Swat | On | An open palm swung through a monster's missile knocks it aside. |
| Slappers Only | Option (off) | Boxing gloves on both hands, every gun put away, gun pickups vanish while it lasts. You keep the series' melee and the game's own melee (flagged melee, using no ammo, or melee by Gun Bonsai's inference). Off: your guns come back (no free ammo), each in the hand it was in. |
| Start With Melee Hands | Option (off) | Hands you Melee's hands at each level start and raises them in both hands. |
| Gun Butt Shove | On | The main hand's shove with a gun hits: 14 damage (62 with the Berserk), knocked away from you, once every 12 tics. Stands down when BD22 VR Reloaded is loaded. |
| Slow-Mo After a Shove | On | A landed butt shove (ours, or BD22 VR Reloaded's) asks RSQ SlowMo for a 300 ms pulse at 35 % world speed; while it lasts, every shotgun hit bleeds twice and a kill pays RSQ Score's award. Needs RSQ_SlowMo. |
| Headlock | On | The off grip on a living monster holds it (up to demon weight, Doom mass 400) for 3 s. |
| Headlock: Human Shield (hold until let go) | Option (off) | Held as long as you hold the grip (a minute at most), facing away. |
| Headlock Punch Extra Blood | On | Punching a monster you hold bleeds more: x1.3, x1.6, then x2.0. |
| Guard | Option (off) | Without Gun Bonsai VR: both hands up at your face for 4 tics, no gun in either hand, and a blow from in front (within 55 degrees) does 60 % of its damage; you slide back a step. A blow of 35 or more breaks the guard: full damage, no guard for 0.4 s. |
| Hadouken | Option (off) | Without Gun Bonsai VR: a fist at punch speed that meets a monster's missile sends it back at whoever fired it, 15 % faster, hitting for 150 %. |
| Wall Splat | Option (off) | Without Gun Bonsai VR: a monster your punch knocks into a wall at 3 map units a tic or more takes 10, up to 20 for a hard slam, bounces off and reels 15 tics. |
| Heavy Hands | Option (off) | Without Gun Bonsai VR: a landed punch freezes the monster for 2 tics (4 at half speed or more) and knocks it 25 % further. |
| Ground Pound | Option (off) | Without Gun Bonsai VR: both fists swung down together at 3 m/s (RSQ Gestures' "both hands down"): a shockwave 2.5 m round you hits for 30, pushes out and staggers 15 tics. Needs RSQ Gestures. |
| Clear Out | Option (off) | Without Gun Bonsai VR: both palms thrust forward together (RSQ Gestures' "both palms thrust"): everything in a 90-degree wedge 2.5 m in front is shoved back hard, takes 15 and staggers 10 tics. Needs RSQ Gestures. |

Tuning and Debug: **Punch Min Speed** (2.0 m/s), **Punch Full Speed** (7.0), **Punch Damage** (10, doubled at full
speed), **Butt Shove Speed** (3.6), **Shove Slow-Mo Length** (300 ms), **Headlock: Reach** (0.30 m), **Headlock:
Heaviest** (400), **Headlock: Seconds** (3), **Headlock: Throw At** (3.0 m/s, 0 = never), **Headlock Throw Weight %**
(30), **Debug Log**, **Reset All**. Not on the menu: `rsqml_punch_rehit` (6 tics), `rsqml_punch_uppercut_rise` (0.5),
`rsqml_punch_pad` (4), `rsqml_keys_off` (443 436).

Always on (no row):

- **The Berserk pack makes a punch x5** (2026-11-02, the owner's call; Doom's own fist is x10): a full-speed punch
  does 100 while you hold it. Before this the pack did nothing to a punch. Not yet run.
- **Hit sparks** (Capcom vs. SNK 2's), one per blow, at the impact point: jab -> Normal Spark (orange), hook and the
  swat -> Special Spark (blue), uppercut and the Hadouken's return -> Super Spark (violet; the return adds the
  Hadouken hit burst from Random Sprite Rips), the guard taking a blow -> the Guard flash (blue, about 35 cm from your
  eyes toward the blow, with stock Doom 2's tick, DSTINK). About a monster's head in size; **Hit Spark Size** (1.0,
  0.25 to 3) scales them all.
- **The uppercut lifts:** up 5 to 9 map units a tic and back 2 to 5 (x 100 / mass; a BOSS x 0.3 more), held in its
  pain for the flight. An imp goes about 0.9 m up. **With RSQ Gun Bonsai VR the uppercut is an unlock** (its Fists
  tree, 2026-11-02): until a glove learns Uppercut, a rising punch from it lands as a jab and lifts nothing. Its
  levels 2-3 and Launcher add lift; Launcher staggers the monster when it lands; Juggle re-lifts a monster you
  launched with your next punch while it is in the air (2 s); Meteor hurts what a launched monster falls on, and it.
- **Two-hand moves come from RSQ Gestures** as its network event `rsqg_pair` (0 both hands down: Ground Pound; 3 both
  palms thrust: Clear Out). Gestures' Two-Hand Events row may stay off: a player who has either move keeps them read.
  A Ground Pound, a Clear Out and a Meteor are paid to the glove (Gun Bonsai VR's claim) but are not punches.
- **The Headlock holds the monster itself at your hand:** moved each tic to the off hand, its face at your hand's
  height, facing you, never into you (your radius + its radius + 2) or into a wall; each punch shows its pain frame
  for 6 tics with its pain sound and a spark at its face. No shrinking, no new art: any monster.
- **Which punch:** read from the whole swing in real space (the vertical x the pixel stretch), so a rising punch that
  curls into the chin is still an uppercut. A punch never lands through a wall, and a hand pulled back out of a body is
  not a punch.
- **The Hadouken's window** (2026-11-02, see Known limits): the missile counts from 2.5 tics behind it to 2 tics ahead,
  and the reach is the hand plus at least 6 for the missile plus 6. An off hand holding a Headlock neither punches
  nor returns fireballs.
- **One-Two, counters, body blows, Star Punch** are read on every punch for Gun Bonsai VR's glove upgrades, and
  (2026-11-02, its Combos) the last three kinds you landed inside a second (`punch.kinds`, jab, jab, hook = 112) and
  the Dempsey run (alternating hooks, each inside 0.6 s, `punch.run`); in a run a glove with Dempsey re-arms faster.

## Test it

Rig results (scripted hands, logs and frames of 2026-11-02 under `/home/claude/scratch/logs` and
`/home/claude/scratch/mlframes`) in brackets. All of it: **rig only, not headset-confirmed.**

1. **Hadouken on Brutal Doom:** full load order, Hadouken on (or with Gun Bonsai VR: learned), let a Brutal Doom imp
   fire at you and punch the fireball with fists held up near your face. It flies back and burns the imp.
   [`hh_new`: FireBall_ met 17.2 from the fist's path, back at 18.4, imp 80 -> 50; the same punch with the build
   before this one, `hh_old`: missed, it hit you. `hado_bd_gb` (Gun Bonsai VR, upgrade learned): returned, imp
   80 -> 50, frames `hado_bd_sheet.png`]
2. **Hadouken on plain Doom 2:** [`hv_row` (row on): returned, imp 60 -> 51; `hv_gb1` (Gun Bonsai VR, learned):
   returned; `hv_gb0` (Gun Bonsai VR loaded, NOT learned, row on): not returned -- as designed, the row does nothing]
3. **Uppercut:** a rising punch into an imp: violet spark, it goes up and back. [`up_v`: "uppercut", lifted to 26.9
   map units, 3.1 back; frames `up_sheet.png`]
4. **Jab and hook:** orange and blue sparks. [`jab_v`, `hook_v`; frames `jabhook.png`]
5. **Guard** on, both hands at the face, a zombieman's blow from in front: blue flash in front of you, 20 -> 12.
   [`guard_v`; frames `guard_sheet.png`]
6. **Hands:** Ermac's fist and open hand, the FBX fist and open hand, the boxing gloves. [`hands_v`, `hands_v2`;
   frames `hands_sheet.png` (Ermac fist / open, gloves), `fbx2.png` (FBX fist / open); under the full order Auto drew
   the FBX hand: `hado_bd_sheet.png`]
7. **Swat:** tap fire (open palm), swing it sideways through an imp's fireball. [`swat_v`: knocked 76 degrees off
   its way, hit a wall; frames `swat_sheet.png`]
8. **Headlock:** off hand on an imp, grip, punch it with the main hand. [`hl_bd` (full order): held at the hand,
   facing you, 2 units from you; each punch: its pain frame, then back; frames `hl_bd_sheet.png`. `hlt_dg`: thrown
   through RSQ Distance Grab at 10.7 m/s; `hlt_alone`: Melee's own toss, hit a wall]
9. **Slappers Only**, **Wall Splat**, **Heavy Hands**, the **shove** and its slow-mo: unchanged since 2026-11-01
   (their rig logs `mel_*` of that day). [`err_alone`, `err_bd`: every row flipped on, no script error]
10. Reset All on Tuning and Debug.

## Works with

- **RSQ Gun Bonsai VR** (+ Gun Bonsai 0.10.6): Guard, Hadouken, Wall Splat and Heavy Hands become its upgrades
  (`RSQ_MeleeUpgradeService`); it pays a returned fireball and a wall slam to the hand ("claim"); Wall Splat's reel
  is its stagger; Slappers Only and the Guard ask its melee inference. Its glove upgrades read the last punch through
  `RSQML_Service`.
- **BD22 VR (RS_Brutal22WeaponsQ):** found by its `RSQ_HandTone` class; Melee Hands' Auto shows its FBX hand, worn in
  its Hand Skin Tone (`rsq_hand_tone`, read by name; the tinted textures are read from BD22 VR's own pk3).
- **RSQ Distance Grab:** a thrown Headlock monster flies through its throw (`headlock.throw`); the off grip press is
  decided between the two (`near.dist` / `headlock.claim`).
- **RSQ SlowMo:** the slow-mo after a shove (`rsm_pulse`) and `slowmo.active`.
- **RSQ Score:** the Headlock touches "grab.hold" (its Headlock combo); the shotgun kill in the slow-mo pays an award.
  The Fists tree's moves touch their hooks (GBOVR_TREES.md 4.1): hit.heavy, hit.body, punch.uppercut, launch, juggle,
  meteor, pound, clearout.
- **RSQ Gestures:** Ground Pound and Clear Out (`rsqg_pair`; Melee asks "pair.ago" to keep the two-hand events read).
- **RSQ HP Bars:** a held monster shows the padlock.
- **BD22 VR Reloaded:** the shove stands down; its own butt strike starts the slow-mo.
- **RSQ Grapple / RSQ Wheel:** the shove is quiet on the rope or with the ring open.
- **RSQ Tactical Rig:** a hand in a holster is the rig's; the Headlock does not take it.
- **RSQ Accessibility:** Rumble Strength, Seated Play (the Guard's box), the Off-Hand Modifier.

Service for other mods: `ServiceIterator.Find("RSQML_Service")` -- "loaded", "punch.glove" / "punch.kind" /
"punch.body" / "punch.counter" / "punch.star" / "punch.chain" / "punch.hand" / "punch.kinds" / "punch.run" (GetInt) and "punch.power" /
"punch.speed" (GetDouble), objectArg the blow's inflictor; "guard" (pawn: tics up); "headlock.claim" (pawn);
"headlock.holding" (monster); "launch.age" (monster, intArg the player: tics since that player launched it, while
it is still in the air; -1 not).

## Known limits / open

- **Why the Hadouken failed on Brutal Doom** (measured on the rig 2026-11-02): Brutal Doom's imp fires FireBall_
  (speed 16, radius 4; vanilla's DoomImpBall is 10 and 6) whose own sprite is TNT1: what you see is its trail puffs,
  invisible for their first tic, so the picture is 1-2 tics (0.5-0.9 m) behind the real fireball, and the old test
  only took one tic either side of the real one and a reach of 15 map units. A fist held up at the face, punched at a
  fireball aimed at your middle, missed by 17 and the fireball hit you. The window above fixes that. Also: with RSQ
  Gun Bonsai VR loaded, the Hadouken row does nothing until Gun Bonsai grants the upgrade.
- The swat and Hadouken see a monster's missiles only (not hitscan bullets), and only missiles that do damage.
- With Gun Bonsai VR loaded the four upgrade rows do nothing (by design); without it each plays level 1.
- The Headlock's grip press is a raw key the rig cannot press: the tests sent `rsqml_hgrip` directly. Human Shield
  was not tested. A monster taller than your hand is high stays on its feet (it is held by the collar, not lifted).
- The off-hand fire is read as `BT_OFFHANDATTACK`; with RSQ Accessibility's Off-Hand Modifier swapping controllers
  the taps follow the buttons, not the swap (not checked).
- The butt shove's 3.6 m/s is BD's number at the stock's tip; ours is the hand's average.
- No netplay in QuestZDoom; hand-driven decisions are the local player's and leave as network events.

## Credits

See `CREDITS.txt` (in the pk3, with `credits/`):

- Hand model by Ermac (iAmErmac), Rusted Legacy / Doom Force Unleashed, MIT licence (`credits/Ermac_RustedLegacy_LICENSE.txt`).
- The FBX hand is BD22 VR's (RS_Brutal22WeaponsQ, presidentkoopa).
- Capcom vs. SNK 2 hit sparks, ripped and converted by Phantom.of.the.Server; property of Capcom, non-commercial
  (`credits/CvS2hitsparks_Readme.txt`).
- Random Sprite Rips, ripped by Phantom.of.the.Server: "Use it freely. The sprites are property of their respective
  game companies, so they cannot be used for any commercial purposes." (`credits/RandomSpriteRips_Readme.txt`).
- Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa); glove mesh and fit by Ermac (iAmErmac); sounds
  from Punch Out Doom (DerrickDavison) via Virtual Punch Out.
