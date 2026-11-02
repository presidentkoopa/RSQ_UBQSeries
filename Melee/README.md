# RSQ Melee

Fighting with your body: punches and SuperPunchOut's boxing gloves, Slappers Only, the Guard, the Hadouken, Wall
Splat, Heavy Hands, the gun-butt shove (BD22 VR Reloaded's) with a slow-motion beat after it and the **F.E.A.R.
Effect**, and the off-hand **Headlock**. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3
(script and data only, no engine changes).

New 2026-11-01 (owner-approved): the code moved here from three mods, so each mechanic has one home
([WHO_OWNS_WHAT.md](../WHO_OWNS_WHAT.md)): the gloves, the punch, Slappers Only and the four moves from RSQ Gun
Bonsai VR; the shove, its slow-mo and the F.E.A.R. Effect from RSQ Gestures; the Headlock from RSQ Distance Grab.
**Nothing here is headset-confirmed**: every check below ran on the simulated rig.

Pk3: `pk3/RSQ_Melee.pk3`.

## Load order

```
doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE
          -> RSQ_Melee.pk3 (any order among the RSQ pk3s)
          -> GunBonsai-0.10.6.pk3 -> RSQ_GunBonsaiVR.pk3 (last; only with Gun Bonsai)
```

- **Needs no other RSQ pk3.** Everything works on plain Doom 2 alone: the punch, the gloves, Slappers Only, the
  shove, the Headlock (and the four upgrade moves through their menu rows). Other mods only add to it (Works with).
- **Plain Doom 2:** works (every check below ran on it). With **BD22 VR Reloaded** loaded the gun-butt shove stands
  down for BD's own butt strike; the slow-mo and the F.E.A.R. Effect follow BD's strike instead.
- Replaces nothing: the old settings are gone from the other mods (`rsq_slappers`, `rsq_gloves`, `rsq_punch_*`,
  `rsqg_shove*`, `rsqdg_collar*`); set the new ones here once.
- **Saves:** a game saved before 2026-11-01 loads (the classes kept their names), and Gun Bonsai upgrades you had
  learned are still learned. Load it with RSQ_Melee.pk3 in the list: it holds the gloves now.

## Setup

- No buttons to bind. The Headlock reads the off-hand grip directly (key codes `rsqml_keys_off`, 443 436, not on
  the menu: QuestZDoom's off grip, as RSQ Distance Grab and the Tactical Rig read it).
- Menu: Options -> Radiant Silvergun Options -> **RSQ Melee**. Fine numbers, Debug Log and Reset All are on its
  **Tuning and Debug** page. RSQ Accessibility's *Reset Every Series Mod* runs this Reset All too.
- The gloves: **Start With Gloves** (each level) or **Slappers Only**, or `give RSQ_Glove` / `RSQ_GloveOff`.

## What to do in VR

- **Punch** (gloves on): from a slow hand, throw it at least 15 cm and fast enough (2 m/s average for the weakest
  punch, 7 m/s for full power) into a monster. Straight, from the side or rising (jab, hook, uppercut).
- **Guard** (when it is on, below): both fists up at your face, no gun in either hand, and hold.
- **Hadouken** (when it is on): punch a monster's fireball as it arrives.
- **Wall Splat** (when it is on): punch a monster toward a wall about a metre behind it.
- **Gun-butt shove:** with a gun in your main hand, shove it hard (3.6 m/s) at a monster within about 2 m in front
  of the hand. Then, in the slow motion that follows, fire a shotgun into monsters: twice the blood, and a kill is
  the **F.E.A.R. Effect**.
- **Headlock:** off hand, palm on a living monster (within 30 cm), squeeze the grip. It is held frozen in front of
  you for 3 s; punch it with the main hand. Swing the off hand hard to throw it. Let go of the grip to let go.

## Features

**Base moves vs upgrades (decided 2026-11-01).** The punch, the gloves, Slappers Only, the shove and the Headlock
are **base moves**: everyone has them with Melee loaded. Guard, Hadouken, Wall Splat and Heavy Hands were Gun
Bonsai upgrades and stay so: **with RSQ Gun Bonsai VR loaded** each works only once Gun Bonsai has granted it (on
the gloves; Guard on the player), at the learned level's numbers, and Melee's rows for them do nothing. **Without
Gun Bonsai VR** each has a Melee row, **off** by default, that plays it at the upgrade's level 1.

RSQ Melee page:

| Row | Default | What it does |
|---|---|---|
| Slappers Only | Option (off) | Boxing gloves on both hands, every gun put away, gun pickups vanish while it lasts (a gun handed to you later is put away within a quarter second). You keep the series' melee and the game's own melee (flagged melee, using no ammo, or melee by Gun Bonsai's inference with it loaded). Off: your guns come back (no free ammo), each in the hand it was in. |
| Start With Gloves | Option (off) | Hands you the boxing gloves at each level start. |
| Gun Butt Shove | On | The main hand's shove with a gun hits: 14 damage (62 with the Berserk), knocked straight away from you, reach 60 map units ahead of the hand plus 12, once every 12 tics. Stands down when BD22 VR Reloaded is loaded. |
| Slow-Mo After a Shove | On | A landed butt shove (ours, or BD22 VR Reloaded's own when it is loaded) asks RSQ SlowMo for a 300 ms pulse at 35 % world speed. While that slow motion lasts: the **F.E.A.R. Effect** (every shotgun hit on a monster bleeds twice; a kill by it pays 200 to RSQ Score's "F.E.A.R. Effect"). Needs RSQ_SlowMo for the slow motion. |
| Headlock | On | The off grip on a living monster holds it (up to demon weight, Doom mass 400) for 3 s. |
| Headlock: Human Shield (hold until let go) | Option (off) | The headlock lasts as long as you hold the grip (a minute at most), the monster facing away. |
| Headlock Punch Extra Blood | On | Punching a monster you hold bleeds more: x1.3 on the first punch, x1.6 on the second, x2.0 from the third on. |
| Guard | Option (off) | Without Gun Bonsai VR: both hands up at your face for 4 tics, no gun in either hand, and a blow from in front (within 55 degrees) does 60 % of its damage; you slide back a step and both hands knock. A blow of 35 or more breaks the guard: full damage, no guard for 0.4 s. |
| Hadouken | Option (off) | Without Gun Bonsai VR: a glove at punch speed that meets a monster's missile sends it back at whoever fired it, 15 % faster, and it hits for 150 %. |
| Wall Splat | Option (off) | Without Gun Bonsai VR: a monster your punch knocks into a wall at 3 map units a tic or more takes 10, up to 20 for a hard slam (6 or more), bounces off and reels 15 tics. |
| Heavy Hands | Option (off) | Without Gun Bonsai VR: a landed punch freezes the monster for 2 tics (4 for a punch at half speed or more) and knocks it back 25 % further. |

Tuning and Debug: **Punch Min Speed** (2.0 m/s), **Punch Full Speed** (7.0), **Punch Damage** (10, doubled at full
speed), **Butt Shove Speed (m/s)** (3.6), **Shove Slow-Mo Length (ms)** (300), **Headlock: Reach (m)** (0.30),
**Headlock: Heaviest** (400), **Headlock: Seconds** (3), **Headlock: Throw At (m/s, 0 = never)** (3.0), **Headlock
Throw Weight %** (30: a thrown monster counts as this share of its weight), **Debug Log** (Off), **Reset All**.

Not on the menu: `rsqml_punch_rehit` (6 tics), `rsqml_punch_uppercut_rise` (0.5), `rsqml_punch_pad` (4 map units
of reach past the glove's 9 cm), `rsqml_keys_off` (443 436).

Always on (no row):

- **A punch never lands through a wall** (a door, a step's face): one trace from the glove to the body.
- **Punch power** decides the damage: 10 at the slowest punch that counts to 20 at full speed (Brutal Doom's own
  fist is 10, its strong punch 20), and the knock back.
- **One-Two, counters, body blows, Star Punch** are read on every punch and written onto the glove for Gun Bonsai
  VR's glove upgrades (Haymaker, One-Two, Star Punch, Counterpunch, Body Blow, Knockdown) to use.
- **The shove is read here**, not asked of RSQ Gestures: one swing is one blow whichever mods are loaded.
- Quiet on RSQ Grapple's rope and with RSQ Wheel's ring open (the shove), as in Gestures.

### The gun butt shove: where every number comes from

BD22 VR Reloaded's butt strike (the owner's mod; `zscript/rsvr/melee.zs`, the same in 2.0-b1m and 1.99x-lb-r7),
parsed, and Brutal Doom's own (`brutal22test6.pk3`):

| What | Number | From |
|---|---|---|
| Swing needed | 3.6 m/s | melee.zs `BUTT_SWING` (BD measures at the stock's tip, we at the hand: no gun model here) |
| Reach | 60 map units ahead along the swing, padded 12 (about 2.1 m) | melee.zs `BUTT_REACH`, `BUTT_PAD` (BD22's kick envelope); a clear line from the hand needed (melee.zs `Clear`) |
| Damage | 14, type Kick; 62 under the Berserk | the blow BD lands is BD22's `KickAttack` / `SuperKickAttack` (Melee.dec) |
| Knock back | the engine's kickback (away from you), plus Brutal Doom's `Pain.Kick` thrust per monster: zombieman / shotgun guy 10 back + 7.5 up; imp 5 + 5; spectre 7.5 up; chaingunner, baron, SS 3.75 up; hell knight 1.25 up; the rest kickback only | Brutal Doom's monsters (actors/Enemies) do it themselves when Brutal Doom is loaded; vanilla monsters get the same numbers here |
| Wait | 12 tics | melee.zs `whooshWait` |
| Sounds | swing: Brutal Doom's `Melee/SwingStrong`, else stock Doom's `skeleton/swing`; hit: Brutal Doom's `Kick/flesh`, else stock Doom's punch | melee.zs, Melee.dec `KickAttack` |
| Alert | monsters within 200 hear the hit | `KickAttack`'s `A_AlertMonsters(200)` |

The swing reader is RSQ Gestures' punch-and-shove reader, copied for the main hand (a swing counts after 15 cm at 2
m/s on average from a slow hand, driving forward, a gun in the hand; then the shove needs 3.6). A light rumble in the
main hand on a hit.

## Test it

Load the order above plus RSQ_Melee.pk3. Everything is **not yet headset-confirmed**; the rig results (simulated
hands, plain Doom 2 MAP01, logs `mel_*` of 2026-11-01) are in brackets.

1. Options -> Radiant Silvergun Options -> RSQ Melee. Turn on **Start With Gloves**, start a new level: gloves in
   both hands.
2. Punch an imp: it takes damage and is knocked back; a fast punch more. [`mel_punch`: a 6.7 m/s punch, imp 60 ->
   41]
3. Punch a monster through a closed door or from below a step's face: no damage. [the same code was measured on the
   rig on 2026-10-31 in Gun Bonsai VR (its README); not re-run after the move]
4. **Slappers Only** On: gloves on both hands, guns gone, gun pickups vanish. Off: guns back in the hands they were
   in, no free ammo. [`mel_load_alone`, `mel_save_load`: the flip runs without a script error]
5. Without Gun Bonsai VR: **Heavy Hands** On, punch an imp: it stops dead for a beat, then flies back further.
   [`mel_punch`: frozen 4 tics, knock 9.5]
6. **Wall Splat** On: punch an imp standing about a metre from a wall, toward the wall. It slams into it with a
   smash, bleeds, bounces off and reels. [`mel_splat`: punched 60 -> 40, slam at 6 map units a tic -> 19 more]
7. **Hadouken** On: let an imp throw a fireball at you and punch it as it arrives. It flies back at the imp and
   hurts it. [`mel_hado`: back at 11.5, the hit x1.5]
8. **Guard** On, gloves or empty hands: hold both fists up in front of your face and let a zombieman hit you from in
   front. Both hands knock, you slide back a little and take less. A big hit (a baron's claw) breaks it. From behind:
   full damage. A gun in either hand: no guard. Guard Off: no guard. [`mel_guard`: 20 -> 12 in front, 20 behind, 50
   broke it; `mel_guard_off`: 20]
9. **Gun-butt shove** on plain Doom 2 or Brutal Doom without BD22 VR Reloaded: walk up to a zombieman, pistol or
   shotgun in the main hand, shove it at him hard. He takes a blow, flies back about a body length and up, and you
   feel a short rumble. Gun Butt Shove Off: nothing. [`mel_shove`, Melee alone, no Gestures: zombieman 20 -> 6,
   knocked 11.8 back, 7.5 up]
10. With RSQ_SlowMo: the shove that lands slows the world briefly. Slow-Mo After a Shove Off: no slow motion.
    [`mel_fear`: rsm_pulse 300 ms, slowmo.active 1 from 3 tics after]
11. With RSQ_SlowMo and RSQ_Score, shotgun in hand: shove a shotgun guy, then kill a monster with the shotgun while
    the world is still slow. More blood; "F.E.A.R. Effect" shows low in the view and in Score's breakdown. The same
    kill at full speed: no award. [`mel_fear`: Score paid 200; the window closed when the slow motion ended]
12. With BD22 VR Reloaded: our shove does nothing (BD's own strike does the hitting). With BD's *Two-Handed Butt
    Strike* on and a long gun up, land one: the world slows briefly and step 11 works. [`mel_bd_shove`: "stands
    down"; a BD KickAttack fired by a test probe at the shove -> rsm_pulse]
13. **Headlock**: off hand, grip on an imp in reach. It freezes in front of you for 3 s; punch it with the main hand.
    [`mel_hl_alone`: held, freezetics re-asserted 2, no gravity]
14. Headlock again, then swing the off hand hard: the imp is thrown and hurts what it hits. With RSQ_DistanceGrab it
    flies through Distance Grab's throw (aim assist, its impact); without it, Melee's own toss. [`mel_hl_dg`: thrown
    at 11.8 m/s by Distance Grab, died on impact; `mel_hl_alone`: tossed at 11.6 m/s, hit at 11.6 -> 95]
15. With RSQ_DistanceGrab: palm on an imp with a barrel nearer the palm: the grip takes the barrel (Distance Grab),
    not the imp. The imp alone: the Headlock. [`mel_hl_dg2`]
16. Turn on *Headlock: Human Shield*. The monster stays held, facing away, while you keep the grip.
    **(not tested on the rig: the grip is a raw key there)**
16a. Headlock a monster and punch it three times: each punch bleeds more than the last (x1.3, x1.6, x2.0). Turn
    off *Headlock Punch Extra Blood*: normal blood. **(not yet headset-confirmed)**
17. With RSQ_Score: hold a monster in the Headlock and punch it to death: the **Headlock** combo pays.
    [`mel_combo`: "Combo Chain[Headlock 0.50]", chain grab.hold>glove]
18. With RSQ Gun Bonsai VR: the four rows do nothing until Gun Bonsai grants the upgrade; then the move works at
    its level. [`mel_gb_punch0` (row on, not learned: no freeze); `mel_gb_punch2` (Heavy Hands 2, Haymaker 2: 60 ->
    23, frozen 5); `mel_gb_guard0` / `mel_gb_guard2` (Guard 2: 20 -> 10); `mel_gb_hado` (level 3: x2.0, speed
    14.5); `mel_gb_splat` (level 2: slam 30)]
19. With RSQ Accessibility, Seated Play Seated (or Auto once it has seen you sit): sit down and hold both fists up
    at your face. The guard comes up as it does standing. (Rig, when it was Gun Bonsai VR's, 2026-11-01: headset at
    1.2 m, fists 0.1 m under the eyes: "guard UP" seated; not re-run here.)
20. With RSQ Accessibility: Rumble Strength 0: no knock from punches, the guard, the shove. 2: stronger.
21. Reset All on Tuning and Debug.

## Works with

- **RSQ Gun Bonsai VR** (+ Gun Bonsai 0.10.6): Guard, Hadouken, Wall Splat and Heavy Hands become its upgrades
  (asked by name: `RSQ_MeleeUpgradeService` "level", "plevel", "upgrade.num"); it pays a returned fireball and a
  wall slam to the glove ("claim"); Wall Splat's reel is its stagger (Executioner reads it); Slappers Only and the
  Guard ask its melee inference ("is.melee"). Its glove upgrades read the last punch through `RSQML_Service`.
  Gun Bonsai credits the glove that punched (the glove is the blow's inflictor).
- **RSQ Distance Grab:** a thrown Headlock monster flies through its throw (`headlock.throw`); the off grip press is
  decided between the two (`near.dist` / `headlock.claim`); its catch thud on taking a monster.
- **RSQ SlowMo:** the slow-mo after a shove (`rsm_pulse`), and `slowmo.active` for the F.E.A.R. window.
- **RSQ Score:** the Headlock touches "grab.hold" (its **Headlock** combo, grab.hold > hands); the F.E.A.R. Effect
  award (`RS_ScoreService` "award", 200). Score counts glove blows as "glove" by class name.
- **RSQ Gestures:** none needed. Gestures still names the shove and answers "shove"; it no longer acts on it.
- **RSQ HP Bars:** a held monster shows the padlock (it reads the monster: freezetics held still, borrowed flags).
- **BD22 VR Reloaded:** the shove stands down; its own butt strike (with `rsq_butt` on and a long gun up) starts
  the slow-mo.
- **RSQ Grapple / RSQ Wheel:** the shove is quiet on the rope or with the ring open.
- **RSQ Tactical Rig:** a hand in a holster is the rig's; the Headlock does not take it.
- **RSQ Accessibility** (by name; nothing changes without it): Rumble Strength scales every rumble here; Seated
  Play lowers the Guard's box with your eyes; the Off-Hand Modifier: the off hand's part (the Headlock) is played by
  the controller it names, and the main hand reads no shove while it is held.

Service for other mods: `ServiceIterator.Find("RSQML_Service")` -- "loaded", "punch.glove" / "punch.kind" /
"punch.body" / "punch.counter" / "punch.star" / "punch.chain" / "punch.hand" (GetInt) and "punch.power" /
"punch.speed" (GetDouble), objectArg the blow's inflictor; "guard" (pawn: tics up); "headlock.claim" (pawn);
"headlock.holding" (monster). Events: `rsqml_buttshove`, `rsqml_fear`, `rsqml_hgrip` (applied to `e.Player`).

## Known limits / open

- Nothing is headset-confirmed. The rig's hands are simulated; nothing about rumble could be felt there.
- **What picks 52-55 became** (the picks page had only the names), from the Quest teardown: Heavy Hands = hit-stop
  plus knockback on a landed punch (surveys/01_MELEE.md 3.6, 4.5); Hadouken (named Return Fire until 2026-11-01) =
  punching a missile back at its shooter (01_MELEE 4.11); Wall Splat = the wall bounce (01_MELEE 4.7); Guard = the
  guard pose (01_MELEE 4.4, apply/02_MELEE_BUILD.md 2.2 and 5). If the owner meant something else, say which.
- Guard's box is tighter than the teardown's (each hand within 0.35 m of the head across, 0.25 m below to 0.15 m
  above the eyes). Two hands that close together may light QuestZDoom's two-hand steadying; not checked in the
  headset.
- Hadouken only sees a monster's missiles (not hitscan bullets). Wall Splat counts a line that stops the flight (a
  wall, or a ledge too high to step up), not another monster.
- The butt shove's 3.6 m/s is BD's number at the stock's tip; ours is the hand's average over the swing. Telling
  BD22 VR Reloaded's own strike apart: a `KickAttack` of yours within a quarter second of your main-hand shove, with
  `rsq_butt` on and one of its long guns up; its plain boot kick landing in that quarter second would count too.
  BD's real butt strike was not swung on the rig (a probe fired the `KickAttack`).
- The F.E.A.R. window is the slow motion itself (about 0.6 s with the 300 ms pulse). No SlowMo, no window. The
  doubled blood was counted in the log, not looked at in frames.
- The Headlock's grip press could not be pressed on the rig (a raw key); the probes sent `rsqml_hgrip` directly.
  Human Shield was not tested.
- Without Distance Grab the Headlock toss has no aim assist, and its impact counts walls and bodies only.
- The off-grip key list is shared knowledge with Distance Grab (`rsqml_keys_off` here, `rsqdg_keys_off` there):
  if you change one, change the other.
- A save made mid-headlock with the old Distance Grab: the monster keeps no-gravity after the load (the old hold is
  not released). A save made mid-headlock with this version: released on the first tic after the load.
- Star Punch's star bank lives on the main-hand glove (saved); One-Two's chain and a fireball in flight that a glove
  returned are not kept across a save.
- Loading a save from before 11-01 prints "Cannot find field ..." lines in developer mode (the moved fields); they
  are harmless.
- No netplay in QuestZDoom; hand-driven decisions are the local player's and leave as network events.

## Credits

`CREDITS.txt`:

```
THE BOXING GLOVES AND THE PUNCH (from RSQ Gun Bonsai VR)
  Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa): the glove weapons, the Arcade punch
  reader and ClassifyPunch, Star Punch's banking rule. The glove mesh and its fit are Ermac's (iAmErmac,
  PunchOutVR / Virtual Punch Out); punch and star sounds from Punch Out Doom (DerrickDavison) through
  Virtual Punch Out, as SuperPunchOut ships them. Punch-Out!! is Nintendo's.
  A glove's punch is Brutal Doom's own fist numbers (MeleeStrikeNormal 10, MeleeStrike2 20; brutal22test6
  Melee.dec), parsed, not shipped.
  Guard, Hadouken (Return Fire), Wall Splat and Heavy Hands: the owner's picks 52-55; what each became is from
  the Quest teardown (presidentkoopa's RSQ_QuestEngineSurvey). Their upgrades and numbers stay in RSQ Gun
  Bonsai VR, an addon for Rebecca "ToxicFrog" Kelly's Gun Bonsai (MIT).

THE GUN-BUTT SHOVE, ITS SLOW-MO AND THE F.E.A.R. EFFECT (from RSQ Gestures)
  The gun butt shove is BD22 VR Reloaded's butt shove (the owner's own mod; zscript/rsvr/melee.zs: the swing
  speed, reach, wait and the blow it lands), ported. Numbers taken from Brutal Doom (Sergeant Mark IV;
  brutal22test6.pk3): KickAttack's damage and alert range (Melee.dec) and the monsters' Pain.Kick thrusts
  (actors/Enemies). Sounds played by name, NOT shipped: Brutal Doom's Melee/SwingStrong and Kick/flesh when it
  is loaded, otherwise stock Doom's skeleton/swing and punch (id Software). The F.E.A.R. Effect's blood is
  each monster's own blood type (Brutal Doom's when it is loaded). Slow motion is RSQ_SlowMo's (rsm_pulse);
  the award is RSQ_Score's (RS_ScoreService).

THE HEADLOCK (from RSQ Distance Grab)
  The Headlock, Human Shield and the headlock throw: RSQ Distance Grab's (presidentkoopa; its feel ported from
  his desktop RS_WorldHands).
```

From RSQ Gun Bonsai VR's README (the old README): "Gloves, punch reader and sounds from SuperPunchOut
(presidentkoopa); glove mesh and fit by Ermac (iAmErmac); sounds from Punch Out Doom (DerrickDavison) via Virtual
Punch Out."
