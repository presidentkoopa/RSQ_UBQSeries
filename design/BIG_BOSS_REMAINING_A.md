# The remaining Big Bosses, part A (PROPOSED 2026-11-25, rewritten to the code-only rule; not locked, not built)

Owner 2026-11-25: "DESIGN IT ACCORDING TO ITS CODE FOR ALL THE BOSSES. YOU SHOULD NOT NEED TO INVENT ANYTHING."

Part A covers five of the Big Boss pool: Player X, the Chaingunner EX, the Cacodemon EX, the White Lost Soul EX and the
Hell Knight EX. Parts B and C cover the rest.

**The rule used here:** every part of a design comes from the monster's own code, and each part cites its state or
function. The only new parts are the series' shared framework:
- weak points placed on one of the monster's own sprite frames;
- the EXPOSED! / BREAK! / GUARD / act structure (telegraph.zs, bigacts.zs);
- the arrival card (bigcard.zs).

Nothing else is added: no new weapon behaviour, no new projectiles, no new shootable parts, no new words beyond the
framework's (EXPOSED!, WEAK!, CANCELLED!, PERFECT!, BREAK!, GUARD). Where the code has nothing for a slot, the slot says
**none**.

All of this was read from source, not run in game. Classes are in `Monsters/zscript/monsters/` (file:line given).
Timings are in tics (35 a second). Weak points are in sprite pixels on the named frame (x right, y down from the PNG's
top-left), with the telegraph.zs layout pair:
- **side** is a share of the half-width as you look at it; minus is your left.
- **up** is a share of the height above the feet.

Sizes follow the existing rule: radius x0.3, clamped to 8-18 units.

## How the framework meets the rule (applies to all five)
- **The opener is the monster's own attack state.** The wind-up enters that state and holds its first frames for the
  window (3 s), as telegraph.zs already holds the pose.
- **BREAK!** (every weak point broken): the framework's CANCELLED! applies. That state's action never runs, and the
  monster is held in its own Pain state (telegraph.zs BREAK!, as built).
- **MISS** (a weak point standing): the state is released and runs its own actions as written. That is the monster's
  own attack, not one of ours.
  - This differs from the locked five: for those, telegraph.zs fires attacks it makes itself (the Tyrant's rings, the
    Warlord's travelling beam). For these five, MISS has no attack of ours.
- **Summons during EXPOSED! and the GUARD wave** come only from monsters the boss's code already spawns. Three of the
  five spawn no monsters at all (Player X, the Chaingunner EX, the Hell Knight EX).
  - bigacts.zs GuardStart already skips GUARD when a Big Boss has no summons ("no GUARD"). For those three: no
    summons and no GUARD; the next window comes the framework's interval after the BREAK! or MISS.
  - Whether GUARD should run on its time cap alone for them is a framework question for the owner, not a part of
    these designs.
- **Acts are the monster's own phase lines.** Phase n comes from act n, by the act hook already used for the Hell Smith
  (`RS_Act.zs` RSQMN_Act.At in place of the `A_JumpIfHealthLower` line).
  - A monster with one phase line gets it in acts 2 and 3, as the bog does (bigacts.zs ActMark comment).
  - A monster with no phase line keeps its whole kit in all three acts. Only the framework's per-act "sooner and
    harder" (telegraph.zs Interval / Damage) changes.
- **Card:** the name is the monster's own Tag, which bigcard.zs CardWho already uses. The type line is its colour and
  family, as CardWho has it. The circled weak points are the ones below.

| # | Class | Card (its Tag) | EXPOSED! opener (its state) | Weak points (frame) | Summons / GUARD (its spawns) | Acts (its phase lines) | Signature (in its code) |
|---|---|---|---|---|---|---|---|
| 17 | RS_BlackZombieEX | PLAYER X | Jammed | gun, head, chest (PLAY E1) | none / none | none: full kit x3 | the jam itself (every 2nd blast) |
| 18 | RS_BlackCGuyEX | WARFACE | BigBomb | chaingun, belt, head (HCPO E1) | none / none | Phase2 (<5000): acts 2-3 | none |
| 19 | RS_BlackCacoEX | SHOCKMASTER | Electro3 | eye, two cheek gems (HELE D1) | red spikes / red spikes | Phase2Jumps (<6500): act 2; BonusDucks (<5000): act 3 | the orbiting red spikes |
| 20 | RS_WhiteLSoulEX | The vengeful soul | Transformers | skull, two flames (ETHS F1) | its two skulls / its two skulls | RollOut (<6000): acts 2-3 | the skulls that hatch |
| 21 | RS_BlackHKEX | Terminator MK II | Homing | cannon, eye, chest core (BRUC E1) | none / none | Phase2 rage (<5000): acts 2-3 | Resistance (40% less for 7 s) |

---

## 17. Big Boss: PLAYER X (PROPOSED)
`RS_BlackZombieEX` (`zombieman/RS_Zombieman.zs:1824`; Health 5000, Radius 16, Height 56, Speed 28, PainChance 16; sprite
PLAY, translated black). Card: **PLAYER X** (Tag "Player X"), type line BLACK ZOMBIEMAN.
Personality: the deathmatch tryhard. This is his code's own Obituary and HitObituary ("lmao owned rekt gg ez"), his
Taunt state and his See2 FastChase.

- **His kit:**
  - **Missile** chooses by range:
    - under 300, **Shotttgun** / **Shootmydude**: a hop in (ThrustThingZ 64), then the super shotgun (8 pellets of
      6-18). Each blast gives `RS_ShotgunWhere`.
    - under 840, **PlasmaSpammer**: 4 `RS_PlasmaBallSP3` in a widening spread, then CellEject.
    - further, **Rawkets**: chaingun taps that can turn into **ActualRawk** (a Rocket).
  - **RBarrage / AltBar:** a hop up and back or sideways, then 3 Rockets. It comes after a jam (84/256), from
    PlasmaSpammer (84/256) and on Pain (84/256).
  - **BFGBoi:** the `weapons/bfgf` hum, 24 bright tics of aiming, then `RS_PlayerEXBFG` (speed 25, 100-200, a 156 blast
    and a spray).
  - **Melee:** a punch for 60-120.
  - **Taunt:** if his target is a corpse (A_CheckFlag CORPSE), he alternates PLAY A and G with his laugh.
- **EXPOSED! opener: Jammed.** The shotgun blast after a blast that gave `RS_ShotgunWhere` jumps to Jammed. Its frames:
  E 8 bright, A 2 with the reload sound, A 8, E 2 with the shell ejected.
  - The wind-up holds Jammed's first frame (PLAY E, bright).
  - **BREAK!**: Jammed never runs, and he is held in his Pain (PLAY G).
  - **MISS**: Jammed runs as written. Its own exits follow: RBarrage (84/256), BFGBoi (64/256), else Missile.
  - The window comes when his code jams, not on the framework's clock, so the framework's timer would wait for his
    next jam. That is a framework choice for the owner: either the timer waits for the jam, or it is used as the
    fallback, as the Tyrant's 45 s fallback is.
- **Weak points (PLAY E1, 26 x 56, offsets 12,51; the IWAD's frame, and BD22's PLAYE1 is the same size):**

  | Point | Pixel | side | up |
  |---|---|---|---|
  | the super shotgun | (4,24) | -0.6 | 0.53 |
  | head | (12,5) | 0 | 0.90 |
  | chest | (15,17) | +0.25 | 0.67 |

  Radius 16 puts all three at the minimum size (8).
- **Summons during EXPOSED!: none.** His code spawns no monsters (Shell, Cell, Rocket, the BFG ball and the tier icon only).
- **GUARD: none** (no summons; GuardStart skips).
- **Acts:** his code has no phase line, so all three acts are his full kit. Only the framework's per-act sooner and
  harder changes.
- **Signature:** the jam, `RS_ShotgunWhere`: every second shotgun blast jams. It is his own rhythm, and here it is also
  the opener. Nothing else is added.

## 18. Big Boss: WARFACE (PROPOSED)
`RS_BlackCGuyEX` (`chaingunner/RS_Chaingunner.zs:1616`; Health 8999, Radius 20, Height 56, Speed 20, PainChance 12;
HCPO). Card: **WARFACE** (its Tag), type line BLACK CHAINGUNNER. The Boss bar calls him CHAINGUNNER
WARLORD (bossbar.zs, as built).
Personality: a drill sergeant with a doomsday arsenal. This is his Obituary ("made to peel potatoes for eternity") and
his own arsenal.

- **His kit:**
  - **Missile** picks at random from RedSpam, YellowBomb, BigBomb and RapidFire.
  - **RapidFire:** 20 tics of aiming, `prox/beep`, then bursts with the `RS_DetoPuffCG` puff, refiring.
  - **YellowBomb / YE** (within 1,200): sparks at the gun, then `RS_YellowBombCGUYEX`. The bomb lands, shrinks for 54
    tics, then grows through eight blasts up to a 312 radius.
  - **RedSpam:** two 15-tic `RS_SpiralLoadGeneEX` charges, then 14 red `RS_SpamShotsCguyEX` / `EX2` shots.
  - **BigBomb:** `RS_RedRevLoad`, 20 tics, `RS_SpiralLoadGeneEX`, 20 tics, a quake, then `RS_CGBigEx`. That is a seeker
    (speed 21, 30-80, a 164 blast) that bursts into delayed explosions.
  - **Pain:** HCPO G, and FastChase (See2) 128/256.
  - **Death:** HKRedDeath bursts.
- **EXPOSED! opener: BigBomb.** It is his own 40-tic charge, the load and then the spiral at the muzzle (HCPO E).
  - The wind-up holds HCPO E.
  - **BREAK!**: `RS_CGBigEx` is never fired, and he is held in Pain (HCPO G).
  - **MISS**: BigBomb runs as written.
- **Weak points (HCPO E1, 43 x 63, grAb 21,57):**

  | Point | Pixel | side | up |
  |---|---|---|---|
  | the chaingun, where the load turns | (10,27) | -0.5 | 0.53 |
  | ammo belt | (28,21) | +0.35 | 0.63 |
  | head | (21,9) | 0 | 0.84 |

- **Summons during EXPOSED!: none.** His code spawns no monsters (loads, shots, bombs and death bursts only).
- **GUARD: none.**
- **Acts:**
  1. His kit as written.
  2. **Phase2**, from the `A_JumpIfHealthLower(5000,"Phase2")` line in Missile, by the act: `RS_MissileChance.SetEvenMore`
     and ALWAYSFAST.
  3. Phase2, as act 2 (his code has one phase line).
- **Signature: none** beyond his kit. His YellowBomb is not shootable in his code, so nothing is added to it.

## 19. Big Boss: SHOCKMASTER (PROPOSED)
`RS_BlackCacoEX` (`cacodemon/RS_Cacodemon.zs:1747`; Health 10000, Radius 31, Height 54, Scale 1.25, floats, Speed 21,
PainChance 32; HELE). Card: **SHOCKMASTER** (its Tag), type line BLACK CACODEMON.
Personality: a storm cloud with a grudge. It is all electricity (Electro1-5), with afterimage shades
(`RS_BlackCacoEXShade`) and the Phase vanish.

- **Its kit:**
  - **Missile:** Electro1, Electro5 or Electro3. After Phase2Jumps, Nah picks Electro2-5.
  - **Electro1:** a 13-ball `RS_HadesBall` fan.
  - **Electro5:** an `RS_HadeLoad1` charge, then 3 `RS_HadesBallEX3`.
  - **Electro4:** 3 `RS_HadesBallEX4`, then Electro1.
  - **Electro3:** B C 8, an `RS_HadeLoad1` charge, D 8, a second charge, D 8, then `RS_EyeBeamCaco`, an RS_TravelBeam
    (20-80) and the `RS_HadeAra` puff.
  - **Electro2:** a charge, then 6 `RS_RedSpikeCacoEX` (spawned at 12,128,32 with SETMASTER), then 3 `RS_HadesBolt`.
  - **Phase** (from See 128/256, and from Pain 88/256): it fades to 10% over 10 tics, wanders 37 steps, then fades
    back in over 10 tics.
  - **Phase2Jumps** (below 6500, once, `user_DO2`): NOPAIN, 7 red spikes, SetEvenMore, speed 42.
  - **BonusDucks** (below 5000): one `RS_HadesBallEX2` after Electro1, 2, 3 and 5.
- **EXPOSED! opener: Electro3**, its two-charge eye lance.
  - The wind-up holds HELE B/C, then D, with the load spiral at the mouth.
  - **BREAK!**: the lance never fires, and it is held in Pain (HELE H).
  - **MISS**: Electro3 runs as written.
- **Weak points (HELE D1, 90 x 79; it floats, so up is from the sprite's bottom):**

  | Point | Pixel | side | up |
  |---|---|---|---|
  | eye | (45,36) | 0 | 0.54 |
  | left cheek gem | (7,28) | -0.84 | 0.65 |
  | right cheek gem | (82,28) | +0.82 | 0.65 |

- **Summons during EXPOSED!: its red spikes.** `RS_RedSpikeCacoEX` (Monster, Health 100) is spawned by its own Electro2
  and Phase2Jumps. Electro2's count is 3 (one of its two DDD rows); the framework's act scaling applies.
  - Their own behaviour as written: they orbit at 176 units (Fly, `user_angle` to 720), then Strike / dash (Missile,
    A_SkullAttack) and burst into HKRedDeath and CacoNails on Death.
- **GUARD: the red spikes are the wave.** The count is Electro2's 6. In act 2 it is Phase2Jumps' 7.
- **Acts:**
  1. Electro1, Electro5, Electro3, Phase.
  2. **Phase2Jumps**, from `A_JumpIfHealthLower(6500,"Phase2Jumps")`, by the act: once 7 spikes, more attacks, speed
     42. From then on Missile picks Nah (Electro2-5).
  3. **BonusDucks**, from `A_JumpIfHealthLower(5000,"BonusDucks")` in Electro1, 2, 3 and 5, by the act: the extra
     `RS_HadesBallEX2` after each.
- **Signature: the orbiting red spikes** (Electro2 / Phase2Jumps), as written above. Phase stays its own vanish, with
  nothing added to it.

## 20. Big Boss: THE VENGEFUL SOUL (PROPOSED)
`RS_WhiteLSoulEX` (`lostsoul/RS_LostSoul.zs:1893`; Health 12500, Radius 16, Height 32, floats, NOCLIP, ice x0.2; ETHS;
White, tier 13). Card: **The vengeful soul** (its Tag), type line WHITE LOST SOUL.
Personality: a grief that wears every face that killed you. This is its own shapeshift into six monsters.

- **Its kit:**
  - **Scripted / AddOns:** it spawns its two skulls, `RS_SkullWSoulEX1` and `RS_SkullWSoulEX2` (Monster, Health 80,
    INVULNERABLE, orbiting by A_Warp to its master). AddOns respawns them when they are not within 512.
  - **Missile:** WSSmore smoke, then (128/256) **A1 / A2 / A3**, which give its skulls `RS_WhiteSoulAdsOff2` / `3` / `4`
    within 700. Then **Miss2**: SoulShot, Beam or Transformers.
  - **Beam:** 27 tics of gathering smoke, then the `RS_SoulexBeam` ice beam (speed 69).
  - **SoulShot:** it swells, then the `RS_SOULEXSoulCharge` seeker.
  - **Transformers:** F stretched over 18 tics (0.85x1.2 to 0.55x1.6), smoke, then:
    - above 6000: **HK / REV / CACO**;
    - below 6000 (**RollOut**): **Baron / Vile / Mancu**.

    Each form is a long, fixed volley of that monster's attacks.
  - **Pain:** ETHS G, and **Reset** (64/256): it gives `RS_WhiteSoulAdsOff` within 700 (the old skulls turn to See: they
    hunt you, shootable, and fire `RS_SoulShotWEX`), wanders 70 steps, and spawns two fresh skulls.
  - **The skulls' A2 / A3 / A4:** they lose INVULNERABLE, wander, dash (ThrustThing 13), stop, and swell (D frames, scale
    to 1.5, about 165 tics in all). Then they hatch:
    - A2: a Revenant (`RS_CommonRevenant`; 64/256 Green, Purple or Red);
    - A3: a Hell Knight (`RS_CommonHK`; or Green, Blue or Yellow);
    - A4: a Cacodemon (`RS_CommonCaco`; or Blue or Yellow).

    Every one of these classes exists.
- **EXPOSED! opener: Transformers.** The wind-up holds its stretch (ETHS F).
  - **BREAK!**: the shift never happens, and it is held in Pain (ETHS G).
  - **MISS**: Transformers runs as written, and the soul becomes that form.
- **Weak points (ETHS F1, 36 x 50, grAb 19,46):**

  | Point | Pixel | side | up |
  |---|---|---|---|
  | skull, the face in the fire | (18,32) | 0 | 0.36 |
  | left flame | (5,20) | -0.78 | 0.6 |
  | right flame | (31,20) | +0.67 | 0.6 |

  Radius 16: minimum-size points.
- **Summons during EXPOSED!: its own skulls breaking off.** Its Missile gives A1 / A2 / A3 before Miss2, so in its
  code the skulls break off on the attack that leads to Transformers (128/256). The framework gives the token on every
  opener instead of half of them, and the skulls then do A2-A4 as written.
- **GUARD: its skulls are the wave.** If two are not orbiting, its own AddOns brings two fresh ones, and they are given
  A2 / A3 / A4. They are shootable (80 HP) once released. Shot in time, nothing hatches; left alone, each hatches its
  monster as written. A hatched monster is spawned by its code, so it joins the wave.
- **Acts:**
  1. Soul form, and the HK / REV / CACO shapes.
  2. **RollOut**, from `A_JumpIfHealthLower(6000,"RollOut")`, by the act: the Baron / Vile / Mancu shapes.
  3. RollOut, as act 2 (its code has one phase line).
- **Signature: the skulls that hatch** (RS_SkullWSoulEX A2-A4), exactly as written: released on its attacks, shootable,
  hatching if left. Nothing is added: no bar, no timer.

## 21. Big Boss: TERMINATOR MK II (PROPOSED)
`RS_BlackHKEX` (`hellknight/RS_HellKnight.zs:1865`; Health 11000, Radius 24, Height 64, drawn 1.25 x 1.5, Speed 14,
PainChance 30; DamageFactor None 0.7, Plasma 1.25, Melee 0.75; BRUC). Card: **Terminator MK II** (its Tag), type line
BLACK HELL KNIGHT.
Personality: a relentless cyborg that beeps before it kills. This is its `prox/beep` before every big shot, and its
Obituary ("terminated by T-800 Baron MK II").

- **Its kit:**
  - **See:** a first-sight boot-up, once (`user_ready`): BRUC J zapping with `RS_ZapDecHKex`.
  - **Missile:** E 8 facing you, then by range:
    - under 500, **Mode2**: BigSlash, MisBar, FastBeam or NadeToss;
    - under 1,500, **Mode1**: BigMis, MisBar, NadeToss, DeathBeam or FastBeam;
    - further: Homing or DeathBeam ("BigMiss" is a dead label in CH: it falls back to See2).
  - **BigSlash:** 3 `RS_HKexSlash`.
  - **MisBar:** spreads of `RS_SpreadMisBarEX`.
  - **NadeToss:** `RS_BaronHellNade`.
  - **BigMis:** 3 `RS_BruiserMissileEx`, each after a beep.
  - **FastBeam:** a beep, then `RS_HKEXFastBeam`; sometimes **AccurateBeam** (an RS_TravelBeam).
  - **DeathBeam:** 18 tics of facing you, a beep, `RS_RedRevLoad`, then `RS_MegaRedRev` (speed 90).
  - **Homing:** E 9 bright with a beep, E 9 facing you, E 9 bright with a beep, E 9, then F 9: `RS_BruiserMissileEx2`
    (a seeker, speed 29, 80-125).
  - **Warp** (from See2 24/256, and from Pain 128/256): it squashes flat and wanders at speed 99, then **Resistance**
    (64/256).
  - **Resistance:** a zap halo, `RS_HKEXProtect` (DamageFactor 0.6 for 7 s), and `RS_ZapOrbHKEX`, a visual orb (NOINTERACTION).
  - **Phase2** (below 5000, once, `user_rage`): speed 18, SetEvenMore, and then Warp2 and Res2 (3 ripping
    `RS_ZapOrbHKEX2`).
- **EXPOSED! opener: Homing**, the two beeps.
  - The wind-up holds BRUC E (bright on its own beep frames).
  - **BREAK!**: the seeker never launches, and it is held in Pain (BRUC J).
  - **MISS**: Homing runs as written.
  - Homing is only reachable from Missile over 1,500 units, so the framework enters it directly at any range, as it
    does for every opener. That is the framework's wind-up, not a change to the monster.
- **Weak points (BRUC E1, 49 x 71, grAb 25,66):**

  | Point | Pixel | side | up |
  |---|---|---|---|
  | arm cannon | (6,30) | -0.78 | 0.55 |
  | eye | (28,9) | +0.12 | 0.86 |
  | chest core, the red vent | (33,21) | +0.33 | 0.68 |

- **Summons during EXPOSED!: none.** Its code spawns no monsters (projectiles, zap decorations, the orb, ammo items).
- **GUARD: none.**
- **Acts:**
  1. Its kit as written.
  2. **Phase2**, from `A_JumpIfHealthLower(5000,"Phase2")`, by the act: speed 18, more attacks, Warp2, Res2.
  3. Phase2, as act 2.

  Its first-sight boot-up plays once, as written.
- **Signature: Resistance** (`RS_HKEXProtect`, 40% less damage for 7 s, with the zap halo and orb), as written. The orb
  is not shootable in its code, so nothing is added.

---

## For the owner (one screen)

| # | Big Boss (its Tag) | EXPOSED! = its own state | Weak points | Waves (its own spawns) | Acts (its phase lines) |
|---|---|---|---|---|---|
| 17 | PLAYER X | Jammed (every 2nd shotgun blast) | gun, head, chest | none | none: full kit all 3 |
| 18 | WARFACE | BigBomb (40-tic charge) | chaingun, belt, head | none | Phase2 in acts 2-3 |
| 19 | SHOCKMASTER | Electro3 (eye-lance charge) | eye, two cheek gems | its red spikes (EXPOSED! and GUARD) | Phase2Jumps act 2, BonusDucks act 3 |
| 20 | The vengeful soul | Transformers (the shapeshift) | skull, two flames | its two skulls, which hatch if not shot | RollOut in acts 2-3 |
| 21 | Terminator MK II | Homing (two beeps) | cannon, eye, chest core | none | Phase2 in acts 2-3 |

- **Break all three:** CANCELLED!, it holds in its own Pain, then BREAK!.
- **Miss:** its own state runs as written. We add no attack.
- **Signatures, only what the code has:** the jam (Player X), the red spikes (Caco), the hatching skulls (Soul),
  Resistance (Hell Knight). The Chaingunner EX has none.
- **Dropped as invented:** AIRSHOT!, DEFUSE!, CAUGHT!, the shootable Resistance orb, the skulls' HP bars, the
  shapeshift's preview face, and the red-tier and extra-family summons (RS_RedZombie, RS_RedCGuy, RS_RedCaco,
  RS_RedLSoul, RS_RedHK, Player 9, RS_BlackCGuy2, RS_BlackHK2).
- **Your calls (framework only):**
  1. Three of these have no spawns, so no GUARD. Should GUARD then run on its time cap alone?
  2. Player X's window comes when his code jams. Should the timer wait for the jam, or force it as a fallback?
