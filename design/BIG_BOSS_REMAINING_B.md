# The remaining Big Bosses, set B (2026-11-25; design only, PROPOSED, nothing built). Revision 2

**The owner's hard rule (2026-11-25): "DESIGN IT ACCORDING TO ITS CODE FOR ALL THE BOSSES. YOU SHOULD NOT NEED TO INVENT
ANYTHING."** Every part below comes from the monster's own code, and each one names the state or function it comes from:
- the EXPOSED! opener: one of its own states;
- the miss: that state allowed to run;
- the summons and the GUARD wave: only classes its own code spawns;
- the acts: its own phase lines and attacks;
- a signature: only if its code already has one.

**The only new parts are our shared framework** (already built in `Miniboss/zscript/rsqmb/`):
- weak points on one of its own sprite frames, held for the 3-second wind-up;
- EXPOSED! / CRITICAL! / GUARD / lives as acts, and the words those already use (WEAK!, CRITICAL!);
- the arrival card;
- hooks that drive its own states: the act-by-life phase hook (`RS_Act.zs` RSQMN_Act.At), starting a state of its own
  when the window is due, and releasing the held pose into that state on a miss.

What revision 1 invented, now dropped:
- shooting its rockets in mid-air;
- the Spectre's heartbeat;
- WEBBED! torn off by hand;
- drawing the raise rings on the floor;
- the "dizzy, HELP!" moment;
- the Spectre going solid in the window;
- the floor arcs before the stab;
- the slow lava fan;
- every per-boss word (JAMMED!, BEHIND!, DISARMED!, SHADOWS!, DOUSED!, HATCHLINGS!, CALM!, MR BONES!);
- the invented card names (each card now uses the monster's own Tag);
- every summon class its own code does not spawn (the red spiders, the spectres, the revenant in the Arch-vile's
  first form).

**Notation.** **[V]** means read from the code. Timings are in tics (35 a second). Weak points are given as sprite
pixels on the named lump (x,y from its top-left), and as the telegraph layout `(side, up)` that `telegraph.zs`
MakeWeakPoints and `bigcard.zs` CardLayout use. side is a share of the radius, positive to the monster's own right
(your left); up is a share of its height.

**No summons means no GUARD.** Two of these four spawn no monsters at all. Under the built rule (`bigacts.zs`
GuardStart: "has no summons standing: no GUARD") they get no summons in EXPOSED! and no GUARD. That is what their code
gives.

| # | Class (card = its Tag) | EXPOSED! opener (its own state) | Weak points (frame) | Summons / GUARD wave (its own spawns) | Signature (its own) |
|---|---|---|---|---|---|
| 22 | RS_BlackSPEX, MACROSS MISSILE SPAM EX | Miss2 rocket salvo (act 1), Miss8 sight-lines (acts 2-3) | brain dome, two gun pods (BSP2 Q1) | none in its code: no GUARD | none beyond its kit |
| 23 | RS_BlackSpectreEX, THE BACKSTABBER UNSILENCED | GETTO shriek, then BACKSTABBUU behind you | head, both claws (GKEX F1) | none in its code: no GUARD | its hidden count `user_hm` and the backstab |
| 24 | RS_WhiteSPEX, WHITE HOT SPIDER | Basic (act 1, act 3), KRAKATOA (act 2) | two eyes, crown (WSPX C1) | RS_MiniSpiderL9 / RS_WhiteSPEXSplit2 | the split on death (its act 3) |
| 25 | RS_BlackArchEX, AHH HELP!!! | the G-H arms-up wind-up of Leaves / Shadowing (Void: Summon) | head, both hands (SILE H1; Void SILE G1) | RS_MrBones; the Void: its revenants | its trail clouds raise the dead (RS_ArchRingHelp) |

---

## 22. Big Boss: MACROSS MISSILE SPAM EX (PROPOSED, rev 2)
`RS_BlackSPEX` (`Monsters/zscript/monsters/spider/RS_Spider.zs:1863`), 12,000 health before boosts, Black 12. BSP2,
radius 64, height 64, scale 1.15, speed 21, pain chance 24, +SEEINVISIBLE, `MissileChanceMult 0.0625`.
- **Card:** its Tag, MACROSS MISSILE SPAM EX; kind line BLACK ARACHNOTRON (`bigcard.zs` CK as built).
- **Personality (dossier 8):** everything is a missile.
- **Its kit [V]:** `Missile` picks Miss1-4, or Miss5-9 under `A_JumpIfHealthLower(7000,"ChoicesMore")`.
  - Miss1: twin bouncing lasers, `RS_ExSpideLaser1`.
  - Miss2: 11 `RS_SpRocket4` then 6 `RS_SpRocket4EX`, all fired from **frame Q**.
  - Miss3: `ThrustThingZ(0,100)`, FLOAT/NOPAIN, then about 40 `RS_SPMM1-5` seekers.
  - Miss4: three `RS_YellowBombEXSpidie`.
  - Miss5: an airborne laser storm; 64/256 it goes on into Miss3 by Miss33.
  - Miss6: weaving rocket pods.
  - Miss7: `RS_BlackSpideSpiralShot`.
  - **Miss8:** frames R/H/Q at 6 tics each, `A_CustomRailgun(0,...)`: six **0-damage** blue sight-lines, then
    `BSP2 GGGGGG 10` six yellow bombs.
  - Miss9: a rocket trio.
  - `Pain`: 128/256 straight into Miss4 or Miss3.
  - Its rockets hang 12 tics before they launch (`RS_SpRocket4` Spawn `MSLH A 12`, then `A_ScaleVelocity`).

**What opens EXPOSED!:** both openers are its own states, so the window always comes from its own move. The framework
starts the state when the window is due and holds its first Q frame for the 3 s.
- **Act 1:** its own **Miss2** (set 1). It goes to frame Q, the pod lights red.
- **Acts 2-3:** its own **Miss8** (set 2), the six blue sight-lines, also on frame Q.
- **Weak points (BSP2 Q1, 96 x 53, offset 48,49):** brain dome (45,8), layout (+0.05, 0.74); left pod (your left)
  (41,32), layout (+0.13, 0.30); right pod (50,32), layout (-0.04, 0.30). The pods are about 10 world units apart on
  its art, so they need small cores.
- **All broken:** CRITICAL! (framework); the state is cancelled.
- **Miss:** the held state runs on as its code has it. In act 1 that is the Miss2 salvo: rockets hang 12 tics, then
  fly. In acts 2-3 it is the Miss8 lines, then the six slithering bombs.
- **Summons in EXPOSED! / GUARD wave:** none. Its code spawns no monster (only missiles and its tier icon,
  `RS_ColorTierIconCH10`), so it has no GUARD.
- **Acts (its own phase line, 7,000, driven by life with the RSQMN_Act hook):**
  - 1: set 1 (Miss1-4).
  - 2: set 2 (Miss5-9, `ChoicesMore`).
  - 3: its code has no third set, so set 2 again; only the framework's act rules apply (wind-up sooner, harder).
- **Signature:** none added. Its kit already has its own character: the hanging rockets and the Miss5 -> Miss3 chain.
- **Build:** add `RSQMN_Act.At(self, 2, 7000)` in `Missile`; a pose per act (Q of Miss2 / Miss8); the miss releases
  the pin into that state, not a Miniboss shot.

## 23. Big Boss: THE BACKSTABBER UNSILENCED (PROPOSED, rev 2)
`RS_BlackSpectreEX` (`Monsters/zscript/monsters/plus/RS_PlusSpectreEX.zs`), 7,250 health before boosts, Black 12. GKEX,
radius 20, height 56, scale 1.2 x 0.85, pain chance 30.
- **Card:** its Tag, THE BACKSTABBER UNSILENCED; kind line BLACK SPECTRE.
- **Personality (dossier 11):** a shadow that wants you to know it's behind you.
- **Its kit [V]:**
  - `SeeMode1`: 45 percent visible, speed 20, afterimages `RS_ShadowGhostEXB-E`.
  - `SeeMode2`: 12 percent visible, speed 12, NOCLIP, `Charge` lunge (`A_Recoil(-48)`, then `Melee` 40-99).
  - Modes swap by `A_Jump(3/6,"Switch")`.
  - `Standard`: 8 weaving `RS_ShadowBallEX1`.
  - `BigOne`: the slow spiral `RS_ShadowSpiralEX`, which bursts into 72 `RS_ShadowBallEX3`.
  - `DarkBeam`: 32 `RS_ShadowDarkBeamEX`.
  - `Pain`: 88/256 into `Warp`.
  - **The count:** `user_hm` goes +2 in `HMM` when you are not within 1,000, +3 per `Warp`, +6 per backstab. At 10 or
    more, `GETTO`: `GKEX A 20` with the shriek (`Shadow/pain`, ATTN_NONE). Then `A_Warp` to 38 behind you (blocked:
    your right, then your left). Then `BACKSTABBUU`: red sparks, **`GKEX F 15 Bright`**, two
    `A_CustomMeleeAttack(40-99)`, then `GetBackhere`.

**What opens EXPOSED!:** its own **GETTO -> BACKSTABBUU**. When the window is due, the framework sets its own `user_hm`
to 10, so its own shriek and warp happen; then it holds **GKEX F** for the 3 s in place of the 15 tics.
- **Weak points (GKEX F1, 51 x 47, offset 25,43):** head (26,8), layout (-0.06, 0.53); left claw (your left) (3,12),
  layout (+1.30, 0.47); right claw (46,21), layout (-1.26, 0.33).
- **All broken:** CRITICAL!; the stab is cancelled.
- **Miss:** BACKSTABBUU runs on: its two strikes, then `GetBackhere`.
- **Summons in EXPOSED! / GUARD wave:** none. Its code spawns no monster (its ghosts are NOINTERACTION afterimages;
  the death spawn is `RS_RandomLetterSpawner`), so it has no GUARD.
- **Acts:** its code has **no phase lines**, so each life is its whole kit as written (both modes, all four attacks,
  the backstab). Only the framework's act rules apply.
- **Signature (its own):** the hidden count and the backstab it leads to: keep your distance and the count climbs
  (`HMM`) until it comes for your back. It is used as it is, with nothing shown or added.
- **Build:** the hook sets `user_hm` and sends it to `GETTO` when the window is due; the pose is F; the miss releases
  into `BACKSTABBUU`.

## 24. Big Boss: WHITE HOT SPIDER (PROPOSED, rev 2)
`RS_WhiteSPEX` (`Monsters/zscript/monsters/plus/RS_PlusWhiteSpiderEX.zs`), 9,500 health before boosts, White 13. WSPX,
radius 56, height 64, scale 1.35 x 1.62, speed 22, pain chance 32. Fire x0.1, Ice x1.4, Plasma x0.85.
- **Card:** its Tag, WHITE HOT SPIDER; kind line WHITE ARACHNOTRON.
- **Personality (dossier 17):** a volcano that learned to walk.
- **Its kit [V]:**
  - Fire trail `RS_FlaminFireAL9`; hops (`Dodger`, `Jumpy`).
  - **`Basic`**: `C 2`, lifts off (FLOAT, NOPAIN, `ThrustThingZ 40`), **`CF 8 Bright A_FaceTarget`** (16 tics), then
    `RS_BoilBoltL9` fans and sweeps (Basic1-5).
  - `Flares`, `FireBombs`, `FlameBlast`.
  - `Spiders`: `RS_SPWHIL9`, each one's Death spawns **2 `RS_MiniSpiderL9`**.
  - `Webs`: `RS_WHITESPIDERWEBSHOT`, which slows you x0.2 for 30 tics (`RS_WHITESPSlowdownNew`).
  - **`KRAKATOA`** (`A_JumpIfHealthLower(5000, 1)`, else `Basic`): `C 10` facing you, `RS_SuperEye02` lit at its two
    eyes (+4 forward, 28 up, 0 and 8 to its right), **`CCCF 10`** (40 tics), then 20 `RS_KrakatoaL9` (40-80, 300-radius
    blasts).
  - `Death`: `WSPX OOO 0 A_SpawnItemEx("RS_WhiteSPEXSplit")` (3 thirds, 2,200). Each third's Death spawns 3
    `RS_WhiteSPEXSplit2` (ninths, 500), which `A_Burst("RS_MiniSpiderL9")`.

**What opens EXPOSED!:** its own lift-and-charge states, held on **frame C** for the 3 s.
- **Acts 1 and 3:** `Basic` (lifted, `C`/`F` 8 Bright, facing you).
- **Act 2:** `KRAKATOA` (its own eyes lit, `CCCF 10`).
- **Weak points (WSPX C1, 100 x 45, offset 50,41):** eye (50,24), layout (0, 0.44); eye (44,24), layout (+0.14, 0.44)
  (where `KRAKATOA` lights `RS_SuperEye02`); crown (52,8), layout (-0.05, 0.83).
- **All broken:** CRITICAL!; the state is cancelled.
- **Miss:** the held state runs on: Basic's bolts, or KRAKATOA's 20 lava shots. Those are its own projectiles
  (FastProjectile speed 80, not hitscan), warned by the charge.
- **Summons in EXPOSED!:** `RS_MiniSpiderL9`, which its `Spiders` attack already spawns.
- **GUARD wave:** `RS_WhiteSPEXSplit2`, the ninths its own split spawns. Their own deaths burst into tiny spiders,
  which are not the wave.
- **Acts (its own line and its own death):**
  - 1: its kit above 5,000 (no KRAKATOA).
  - 2: KRAKATOA, by `RSQMN_Act.At(self, 2, 5000)`.
  - 3: its own `Death` split. At the act change it plays its death frames and splits. The Big Boss goes on as one
    `RS_WhiteSPEXSplit` (a body swap, as the Black Knight's bodies are; the third's own kit: Basic, Spiders,
    FireBombs, Webs). The other two thirds are its summons, tethered.
- **Signature (its own):** the split on death, used as act 3. Its webs (x0.2 speed for 30 tics) stay exactly as
  written.
- **Build:** the act hook on KRAKATOA's health line; the body swap; the final third's own Death spawns 3 ninths after
  the win (its code). They must die with its summons, or they outlive the fight.

## 25. Big Boss: AHH HELP!!! (PROPOSED, rev 2)
`RS_BlackArchEX` (`Monsters/zscript/monsters/plus/RS_PlusBlackArchEX.zs`), 2,700 health before boosts (every Big Boss
life is sized by `bigfix.zs`), Black 12. SILE, radius 20, height 56, alpha 0.75, speed 20/24/30, pain chance 8,
+CANTSEEK.
- **Card:** its Tag, AHH HELP!!!; kind line BLACK ARCH-VILE.
- **Personality (dossier 12):** a panicking wind spirit.
- **Its kit [V]:**
  - **Phase lines:** `See2` and `Missile` check `A_JumpIfHealthLower(1800,"Phase2")` (translation BVEX2, speed 24)
    and `(900,"Phase3")` (BVEX3, speed 30).
  - **Phase 1 `Missile`:** 192/256 `Leaves`, else `Woahoahoahoah`.
  - **Phase 2:** `Shadowing` or `KABAM`.
  - **Phase 3:** 32/256 `Woahoahoahoah`, else `Shadowing`, `KABAM`, `Leaves` or `Wooosh`.
  - **`Leaves` and `Shadowing` both open on `SILE GH 4`** (arms raised), then IJK and LMN.
    - `Leaves` then releases four `A_RadiusThrust(3000,400)` pushes with leaf swarms.
    - `Shadowing` (ATTN_NONE gust) fires 12 `RS_BVileEXWAVE3`.
  - `KABAM`: a seeking `RS_BVileEXMindWave`.
  - `Wooosh`: 5 floor `RS_BVileEXTornado`.
  - `Woahoahoahoah`: the spin that pulls you in (`A_RadiusThrust(-1000,400)`, up to 40 cycles).
  - **`Pain`:** spawns `RS_MrBones`, and 156/256 `Wee` (dash, then `RS_MrBones`).
  - **Its trail:** every `RS_BVileEXCloud` ends with `A_SpawnItemEx("RS_ArchRingHelp",...,224)`: 1 in 8 leaves an
    invisible ring that runs `A_VileChase` (raises corpses).
  - **`Death`:** `SILE AAA 0` spawns **three `RS_BlackArchEXVoid`** (4,166 each). Each Void counts hits in
    `user_myeyes`; at 8 it runs `Summon`: `SILE G 12`, GHI flicker, `SILE J 15`, `VILE [\] 15`, then
    `RS_CommonRevenant` x2, `RS_RedRevenant`, `RS_PurpleRevenant` and 4 `RS_MrBones`.

**What opens EXPOSED!:** its own arms-up wind-up, **SILE H** of `Leaves` (phase 1) or `Shadowing` (phases 2-3), held
for the 3 s. The Void (act 3) has no body except in `Summon`, so its window is its own **`Summon`**: the framework sets
`user_myeyes` to 8 when the window is due, and holds `SILE G`.
- **Weak points (SILE H1, 79 x 96, offset 39,92):** head (38,29), layout (+0.05, 1.13); left hand (your left) (8,7),
  layout (+1.55, 1.52); right hand (73,10), layout (-1.70, 1.46). Its art is far bigger than its 20 x 56 box, so the
  layout runs past 1.
- **The Void's weak points (SILE G1, 73 x 93, offset 35,89):** head (33,27), layout (+0.10, 1.11); left hand (3,4),
  layout (+1.60, 1.52); right hand (70,8), layout (-1.75, 1.45).
- **All broken:** CRITICAL!; the state is cancelled (for the Void: no revenants).
- **Miss:** the held state runs on: Leaves' pushes and leaves, or Shadowing's 12 waves, or the Void's Summon raising
  its revenants.
- **Summons in EXPOSED! / GUARD wave:**
  - acts 1-2: `RS_MrBones` (its own `Pain` spawn);
  - act 3: the Void's own `Summon` classes (`RS_CommonRevenant`, `RS_RedRevenant`, `RS_PurpleRevenant`,
    `RS_MrBones`).
- **Acts (its own phase lines and its own death):**
  - 1: Phase 1.
  - 2: Phase 3, its fullest kit (it holds everything of Phase 2 plus Leaves, the spin and Wooosh), by the act hook.
    Phase 2 alone is a subset; the owner may prefer act 2 = Phase 2, act 3 = Phase 3 and leave the Voids out.
  - 3: its own `Death`, three Voids. The Big Boss goes on as one `RS_BlackArchEXVoid` (a body swap); the other two
    are its summons. Its other Void attacks (BlackHole, KABAM, Shockwave, Shadowing by `RS_VoidMode`) stay as
    written. `eNO`'s darkness is stubbed in our port.
- **Signature (its own):** its trail raises the dead (`RS_ArchRingHelp` by `A_VileChase`). Mr Bones killed near its
  path can stand again. It is used as it is; nothing is drawn or added. +CANTSEEK (homing shots miss it) stays.
- **Build:** the act hook on both phase lines; the body swap to a Void; the hook on `user_myeyes`; Mr Bones raised by
  a ring are not in the summon list, so they do not hold GUARD.

---

## For the owner to pick from (one screen)
Rev 2 follows the owner's hard rule: every opener, summon, act and signature below is a state or spawn in the monster's
own code. The only new parts are the shared framework: weak points on its own frame, EXPOSED!/CRITICAL!/GUARD/acts,
the card, and hooks that start its own states.

- **22 MACROSS MISSILE SPAM EX:** EXPOSED! on its own Miss2 salvo (act 1) / Miss8 blue sight-lines (acts 2-3), frame
  Q. Weak points: brain dome, two gun pods. It summons nothing, so it has no GUARD. Acts: its 7,000 line (set 1 / set
  2 / set 2).
- **23 THE BACKSTABBER UNSILENCED:** EXPOSED! on its own shriek and backstab (GETTO -> BACKSTABBUU), frame F. Weak
  points: head, both claws. It summons nothing, so it has no GUARD. It has no phases: the whole kit each life.
  Signature: its hidden count.
- **24 WHITE HOT SPIDER:** EXPOSED! on its own Basic lift (acts 1, 3) / KRAKATOA charge (act 2), frame C. Weak points:
  two eyes, crown. Its own tiny spiders in EXPOSED!, its own ninths as the wave. Act 3 is its own death split into
  thirds.
- **25 AHH HELP!!!:** EXPOSED! on its own arms-up wind-up (Leaves / Shadowing), frame H. Weak points: head, both
  hands. Its own Mr Bones as the wave. Acts: its own Phase 1 / Phase 3 / its death's Void (EXPOSED! on the Void's
  Summon). Signature: its trail raises the dead.
