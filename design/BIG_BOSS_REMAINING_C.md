# Big Bosses, remaining set C (sections 26-29), PROPOSED, design only (2026-11-25)

Owner's ask (2026-11-25): design the remaining Big Bosses from reading their code. Set C: RS_WhiteArchEX,
RS_WhiteCybieEX, RS_WhiteMindES, RS_WhiteSPFusion, plus every other EX-tier class in `Monsters/` that is on no one's list
(section 30). Same format as the five LOCKED designs (design/BIG_BOSS.md 11-15).

**Owner's hard rule (2026-11-25, during this work): "DESIGN IT ACCORDING TO ITS CODE FOR ALL THE BOSSES. YOU SHOULD NOT NEED
TO INVENT ANYTHING."** Every part below is one of the monster's own states, spawns, phase lines or functions, and each part
names its source (file and state). The only new parts are the series' shared framework: weak points on its own sprite frame,
the EXPOSED! hold, BREAK!, GUARD, lives as acts, the card. Where its code has nothing for a slot (no summons in a phase, no
second phase line), the slot stays empty and says so. Nothing was run. Code read: `Monsters/zscript/monsters/plus/*.zs` and
the family files they call. Sprite pixels measured from the sprite lumps (decoded with doom2.wad's PLAYPAL): x from the
frame's left edge, y from its top row, in the sprite's own pixels before scale.

Two framework notes that apply to all four (these are build notes, not design changes):
- **MISS fires its own attack.** telegraph.zs today fires the Miniboss's own shots (RSQMB_Blob, RSQMB_BigShot ...) when a
  window is missed. Under the owner's rule these four fire nothing new: a missed window lets the monster's own state (named
  in each section) run. BREAK! cancels that state (it never enters it) and staggers, as today.
- **Acts need the RS_Act hook.** Like the Hell Smith (`RSQMN_Act.At` at RS_PlusBlackCybieEX.zs:215), each of these picks its
  phase by health lines that the Big Boss's refilled lives would trip at random. One `RSQMN_Act.At(self, n, line)` per line
  named below; nothing else in the monster changes.

| # | Card | Class | Health (before boosts) | EXPOSED! opens on (its own state) | Signature (its own code) |
|---|---|---|---|---|---|
| 26 | PURIFIER | RS_WhiteArchEX | 20,800 | ScreamofTime (Q frames, planted) | the 300-second clock (ENDOFTIME, RS_PlusWVileTimer) |
| 27 | CYBERTRON | RS_WhiteCybieEX | 32,767 | GlitchLaser's charge (J-K-L screen charge) | The one behind it all (RS_WhiteCybieEXCore on death) |
| 28 | EVERLASTING WHITE SPIDEY | RS_WhiteMindES | 20,000 | Shocker's BFG charge (F to E) | it regenerates (HealThing in See / Flying) |
| 29 | WHITE SPIDER OF TERROR | RS_WhiteSPFusion | 4,000 (8,500 with its splits) | Atk1's hover charge (E-F) | it splits (Death spawns two RS_WhiteSPFusion2) |

---

## 26. PURIFIER (PROPOSED)
`RS_WhiteArchEX` (RS_PlusWhiteArchEX.zs), White Arch-vile EX, tier 13. 20,800 health; radius 20, set to 20 x 80
(Scripted); speed 60 (45 in Approach / Agro); YScale 1.1; pain chance 10; floats, NOCLIP (through walls), additive render,
VISIBILITYPULSE. Sprite LMWX (A-U), a hooded robe with no head: its "head" is the clock face RS_FaceMOT (SCPF) that it keeps
over its collar (A_SpawnItemEx at z 84, warped there every tic).
- **Card:** PURIFIER (its Tag). Kind line: WHITE ARCH-VILE EX, EX-13. Personality: a clerk of time that hides, counts its
  courage (`user_courage`), and screams when it is ready.
- **What opens EXPOSED!:** its ScreamofTime. It plants itself (`bNOPAIN = true`, RS_WVileResist), faces you on frame Q for
  8 + 16 + 24 tics, the RS_SuperEye01 flash and RS_OldTimeyMOT clocks over it (state ScreamofTime, lines 238-251). The
  framework holds that planted Q pose for the EXPOSED! window. It is in Choices1 (you are 1,000+ away) in every phase.
- **Weak points (frame LMWX Q0, 56 x 75, offsets 27,69):** the clock face over the collar (27,-7: RS_FaceMOT, 84 units up =
  7 px above the frame's top row), the left hand (8,21), the right hand (42,20). Missed: the scream runs as its code has it
  (frames R-S-T-U: RS_WVilequake's three quakes, RS_EyeSpawnerMOT, RS_BrightUpVile2 pillars, RS_WhiteVileResser raising
  corpses; lines 256-268). BREAK!: the scream never comes; stagger.
- **Summons during EXPOSED!:** only what the scream itself spawns: RS_WhiteVileResser (9 within 728, 6 within 128) raises any
  corpse near it, a tier up (RS_GrowRaisin). Nothing else in act 1. From act 2, its CloneofTime clones (below).
- **GUARD wave:** its clones, RS_WhiteArchEXClone (500 health, the same kit without CloneofTime / ENDOFTIME), from its own
  CloneofTime (RS_CloneSummonMOT bounces, then spawns one clone; lines 355-364). CloneofTime exists only under its 12,500 line,
  so act 1 has no wave and so no GUARD (the framework's existing rule: no summons standing, no GUARD).
- **Three lives as three acts (its one health line, 12,500, Missile / StealofTime / CloneofTime):**
  1. Above the line: BoltsofTime (E-F-G 8 tics each, then 5 bolts whose RS_BoltEyeMOT eyes fire later), RingsofTime (fades
     out 30 + 12 tics, warps 80 behind you, 4 slow seeking RS_TimeShockMOT rings), EyeofTime (8 eyes that wait; its next
     attack sends them, EyeofTime2), RailofTime (rsplus/wvexactv, E-F-G 10 tics each, two RS_TravelBeam shots), the scream.
  2. Under the line (`RSQMN_Act.At(self, 2, 12500)` at Missile and StealofTime / CloneofTime): ENDOFTIME once (its clock
     starts), StealofTime (Q-Q-Q-Q-R-S-T-U 10 tics, clocks gather on you, then armour taken and slowed 10 s:
     RS_PlusEX.WVileArmorSteal), CloneofTime.
  3. Its code has no third line: act 3 is act 2's kit with the clock already running. If the owner wants a third step
     from its code, the only one is its clock's end (below).
- **Signature: the clock (its own).** ENDOFTIME (lines 369-390) starts RS_PlusWVileTimer: 300 s, a quake every 10 s, the
  count shown at 300/200/100/50/20 and from 10. At zero its code makes it invulnerable and TIMESUP (freezes you, fires until
  you die); the owner decided 2026-11-17 that ours enrages instead (dossier 14; not built). Note for the owner: a Big Boss
  life is sized to about 60 s, so a 300 s clock started in act 2 may never reach zero; its length is its code's, unchanged.
- **Telegraphs (all its own):** every attack above has its wind-up frames or sound named with it; the bolts' eyes and the
  EyeofTime eyes wait visibly before firing; RailofTime is a travelling beam (RS_TravelBeam), no hitscan.

## 27. CYBERTRON (PROPOSED)
`RS_WhiteCybieEX` (RS_PlusWhiteCybieEX.zs), White Cyberdemon EX, tier 13. 32,767 health; radius 40, height 110; speed 24
(18 in See2); scale 1.25; pain chance 0 (never flinches); radius damage x0.33. Sprite MMDG: a walking robot with a CRT
screen for a chest and a rocket launcher for a head.
- **Card:** CYBERTRON (its Tag). Kind line: WHITE CYBERDEMON EX, EX-13. Personality: the game breaking on purpose;
  every attack is a bug.
- **What opens EXPOSED!:** GlitchLaser's charge: rsplus/romeex/atk2, then its screen charges a light (frames J-K-L-K-J at 3,
  then 2, then 1 tic; states GlitchLaser / GlitchLaser2 / GlitchLaser3, lines 805-860). It is in its far set in every phase
  (MissileSet, MissileSet2, MissileSet3) and in Close2 / Med2 / Med3. The framework holds frame J for the window.
- **Weak points (frame MMDG J1, 125 x 126, offsets 62,120):** the charging screen (61,42), the left fist (27,71), the right
  fist (97,71). Missed: its laser runs (RS_ROMEROEXBeamCH stream, 20 a burst in act 1, five bursts in GlitchLaser2; SweepBeam
  if you are within 1,000). BREAK!: no laser; stagger.
- **Summons during EXPOSED!:** its code spawns monsters only from Phase 2: two RS_GlitchBaron (Baron, 1,000 health, NOCLIP)
  at 128 either side (Phase2 / FatalBarons), two more at 218 in phase 3 (BaronMore). Act 1: none.
- **GUARD wave:** its GlitchBarons (acts 2-3). Its own GlitchShields (four reflecting RS_ROMEROEXShield orbiting at 128,
  damage halved for 15 s by RS_RomeroCHProtect2) are an act 2-3 move of its own, not the wave. Act 1: no wave, no GUARD.
- **Three lives as three acts (its lines 24,576 and 8,192, `user_phase`; hook at Missile):**
  1. Phase 1: MissileSeizure (head rockets, frames H-I; E 10 face first), GlitchWinder (it jumps and hovers, 8 seeking glitch
     balls), GlitchLaser, Glitches (glitch-shot volleys, E-E 5 face first), BFGSpam, FourthWall (one homing floor wall, after
     J-K-L-K-J and M-O), Dukie (within 200: rings of RS_ROMEROEXGround bursts outward), Rush (reflective skull charge),
     Reposition (fades out, flies, fades in with a quake).
  2. Phase2 (rsplus/romeex/ph2, frames Z-Y, the two GlitchBarons): adds LaserRain (sky lasers on you after J-K-L-K-J, M-O),
     GlitchMines (marks blink on the floor, then mines), GlitchTrap (E-I-E-G-G-I 7 tics, then a ring of 16 glitch barriers
     round you), CodeLeakage, GlitchShields, FourthWall2 (three walls), GlitchLaser2.
  3. Phase3 (rsplus/romeex/ph3, flicker E-G-I, a quake): walks through walls (See2), FourthWall3 (ten walls in a fan),
     GlitchLaser3, BFGHeck, MissileSeizure3's patterns, OVERDRIVE (up to 16 of its attacks chained).
- **Signature: The one behind it all (its own).** Its Death spawns RS_WhiteCybieEXCore (3,000 health, the ROMR head): it
  warps onto you, then BFG spam (RS_SpamShotsCguy rings) or SuperBFG (RS_ROMEROEXREALBFG). Proposed: the fight is won
  when the core dies (the Black Knight's body swap, framework), so the core is the last thing you kill, not a loose monster.
- **Telegraphs:** every attack has its own wind-up frames or sound (listed above); its lasers and rockets are projectiles
  (RS_ROMEROEXBeamCH, RS_RomeroRocketCH), no hitscan.

## 28. EVERLASTING WHITE SPIDEY (PROPOSED)
`RS_WhiteMindES` (RS_PlusWhiteMind.zs), CHP's White Mastermind, tier 13 (registry RSQBIGBS.txt). 20,000 health; radius 100,
height 100; speed 24 (36 after its roar); scale 1.62; pain chance 0; fire and ice x0.25, plasma x0.75. Sprite W5PD: a
spider machine with a glowing core and twin guns under it.
- **Card:** EVERLASTING WHITE SPIDEY (its Tag). Kind line: WHITE SPIDER MASTERMIND, EX-13. Personality: a machine that heals
  as it walks and roars "I AM EVERLASTING".
- **What opens EXPOSED!:** its Shocker charge: F 4 face, F 5 with weapons/bfgf, F-F-F-E-E 5 face (34 tics; states Shocker /
  Shocker2, lines 389-415). Shocker is in its close set in every phase (CloseJumps) and is its Melee (Shocker2). The
  framework holds frame E, its guns lit, for the window.
- **Weak points (frame W5PD E1, 122 x 78, offsets 61,78):** the core (60,36), the left gun (45,51), the right gun (76,51).
  Missed: the zapper storm runs (RS_ESZapper, 96 in Shocker; 192 in Shocker2 for acts 2-3). BREAK!: no storm; stagger (it
  has no Pain state: its frame is held).
- **Summons during EXPOSED!:** act 1 none (its phase 1 spawns nothing). Act 2: Sentinels, six RS_MiniSentinelSpider (70
  health) out of its body (A_PainAttack, state Sentinels). Act 3: the Orb of Chaos (CHAOSCHAOS: RS_WhiteSpidChaosBall lands
  and becomes RS_OrbOfChaos, 2,000 health, which summons a Black-tier monster, RS_ChaosSummons).
- **GUARD wave:** act 2 its Sentinels; act 3 the Orb of Chaos ("SUMMONER!": the shield drops when the orb is dead). Its own
  SHIELD state (five reflecting RS_WhiteSpidShieldWalk orbiting at 128) is one of its act 2-3 moves. Act 1: no GUARD.
- **Three lives as three acts (its lines 13,000 and 6,000; hook at Missile, FlyingCheck, Charge, CloseJumps):**
  1. Phase 1 on foot: RapidFire (twin plasma, flares at both guns first), SpreadFire (12-shot fans), Rockabye (hops aside,
     plasma rockets), OrbShot (ELECFATT, a crackle orb), EyeBeam far (two harmless cyan sight lines, then RS_TravelBeam),
     Charge (rsplus/spmdash), Shocker; dodges.
  2. Phase 2, it flies (FlightToken, rsplus/wmindfly): RapidFire2 / SpreadFire2 / Rockabye2, FloorCrack (rsplus/spmhop1, it
     jumps, lands: 36 RS_MolochQuake floor rays and 6 winders), SHIELD, Nukes (floor marks RS_WhiteFatMark, then the drops),
     LightningStrike (a mark on you, then zappers from above), Sentinels, Webb (slowing web shots).
  3. Phase 3: IAMEVERLASTING once (quake, rsplus/wmindrag, speed 36), camouflage (fades to 20%: Camoflosh), CHAOSCHAOS.
- **Signature: it regenerates (its own).** HealThing(4, 20000) every walk cycle (See, Flying). Unchanged. Note: in a Big
  Boss life sized by the player's damage it is a small heal; its cap is its spawn health (20,000).
- **Telegraphs:** each attack's flare, sound or mark above is its own; EyeBeam is two zero-damage sight lines then a travelling
  beam, no hitscan.

## 29. WHITE SPIDER OF TERROR (PROPOSED)
`RS_WhiteSPFusion` (RS_PlusWhiteSpiderFusion.zs), CHP's Fusion White Arachnotron, tier 13 (registry). 4,000 health; radius
56, height 64; scale 1.5; speed 28 and pain chance 32 (from RS_WhiteSPPlus). Sprite TRIT: a white spider whose body is a
skull mask. On death it splits: two RS_WhiteSPFusion2 (1,250, scale 1), each splitting into two RS_WhiteSPFusion3 (500,
scale 0.6), each bursting into mini spiders (RS_MiniSP1).
- **Card:** WHITE SPIDER OF TERROR (its obituary; its inherited Tag is "White Spider"). Kind line: FUSION WHITE ARACHNOTRON,
  EX-13. Personality: one spider that is really a colony.
- **What opens EXPOSED!:** Atk1's hover: it rises (ThrustThingZ 40), floats, ignores pain, and charges on E-F 8 tics each
  before its first volley (lines 54-63). Atk1 is in its own sets and its half's (Fusion2), so it is there every act. The
  framework holds it hovering on frame E for the window.
- **Weak points (frame TRIT E1, 93 x 44, offsets 46,40):** the left eye (41,10), the right eye (52,10), the brain cap (47,3).
  At scale 1.5 these are small; the framework's minimum radius applies. Missed: Atk1's two volleys of six RS_WhiteSpiderPBolt
  run. BREAK!: no volleys, it drops; stagger (its Pain state, TRIT F).
- **Summons during EXPOSED!:** act 1 none. Act 2: its Atk3 eggs, RS_WhiteSpidegg (50 health, float, drop webs that slow you).
  Act 3: its twin half (below).
- **GUARD wave:** act 2 its eggs; act 3 its twin half. Act 1: no GUARD.
- **Three lives as three acts (its line 2,500 and its own split):**
  1. The Fusion, Set 1: Atk1, Web (two web shots, E 6 face first), Atk5/6/7 (bolt fans and sweeps, E-F charge first), Atk8
     (RS_SPWHI4 seekers that hatch mini spiders, A 8 charge first).
  2. The Fusion, Set2 (`RSQMN_Act.At(self, 2, 2500)` at Missile): adds Atk2, the red dot (two white sight lines, SHARPST1
     heard map-wide, a third line, then an RS_TravelBeam shot: no hitscan), Atk3 (egg-laying run).
  3. SPLIT: its own death split. The body becomes RS_WhiteSPFusion2 where it stands (the Black Knight's body swap,
     framework) and its twin RS_WhiteSPFusion2 lands beside it, as its Death spawns two. The half's kit: Atk1, Web, Atk5-8.
- **Signature: the split (its own),** used as act 3 above. Its further splits (quarters, then mini spiders) come from its
  own Death states; proposed: when the Boss body dies the fight is won and whatever its death spawns stays as normal monsters
  (owner's call: or bind them, as the Glitch's core).
- **Telegraphs:** every attack above has its own charge frames or sound; the red dot is the clearest telegraph it has.

---

## 30. The other EX-tier classes checked (monster or not, why)

Every class in `Monsters/zscript/monsters/` with EX / Ex in its name was read. None of them is a Big Boss of its own:

| Class | What it is | Big Boss? |
|---|---|---|
| RS_BigHellCybEX (+2, +3) | the Hell Smith's BigHell pentagram (an effect actor, NOBLOCKMAP), its shockwave projectile and homer | No: not a monster; part of the locked Obsidian Tyrant |
| RS_PentaHealCybEX (+2) | Supersmith's heal pentagram: a floor projectile (Projectile, FLOORHUGGER) | No: not a monster; already the Tyrant's CRITICAL TARGET! |
| RS_PlusEX | a static helper class (`class RS_PlusEX play`: icons, EX roll, the White Arch-vile's timer) | No: not an actor |
| RS_WhiteArchEXClone | Time to die's clone, 500 health, -BOSS, no clone / clock states | No: a 500-health minion; used as section 26's GUARD wave |
| RS_WhiteCybieEXCore | "The one behind it all", 3,000, spawned by RS_WhiteCybieEX's death; two frames (ROMR A, B) | No: an epilogue body, off the ladder, not named *EX; used as section 27's signature |
| RS_ROMEROEXShield | the Glitch's orbiting shield (Monster flag, invulnerable, reflective) | No: an invulnerable orbiting prop |
| RS_WhiteSPFusion2 / 3 | the Fusion's halves and quarters (1,250 / 500) | No: its splits; used as section 29's act 3 |
| RS_BlackArchEXVoid | Void Strikes back (4,166), risen from RS_BlackArchEX | Belongs to RS_BlackArchEX's design (another list) |
| RS_WhiteSPEXSplit / Split2 | RS_WhiteSPEX's splits (2,200 / 500) | Belongs to RS_WhiteSPEX's design (another list) |
| RS_BlackRevEx2 / Ex3 | the Black Knight's wraith and shadow | Part of the locked Black Knight |
| RS_RedSpikeCacoEX (100), RS_SkullWSoulEX1 (80) | Black Caco EX's orbiting spikes; White Lost Soul EX's skulls (minions, no tier token) | Belong to those bosses (other lists) |
| RS_HKEXProtect, RS_WVileEXSpeedNerf, RS_DarknessTokenBlackSpectreEX, RS_BVileEXDarknessToken, RS_PowerRevEx(2) | powerups / inventory tokens | No: not actors that fight |
| Projectiles and effects: RS_PlayerEXBFG(2), RS_YellowBombCGUYEX, RS_SpamShotsCguyEX(2), RS_EXPLOSIONSCGuyEX(+Delayd), RS_SpiralLoadGeneEX, RS_CGBigEx, RS_SOULEXSoulCharge, RS_SoulShotWEX, RS_LSoulEXShade, RS_BlackSpideEXShade/Scrap, RS_YellowBombEXSpidie, RS_SpideEXTrail, RS_SpRocket4EX, RS_HadesBallEX2-4, RS_ZapperCacoEX, RS_BlackCacoEXShade, RS_ZapOrbHKEX(2), RS_HKEXslash, RS_SpreadMisBarEX, RS_HKEXFastBeam(+Trail), RS_BruiserMissileEx(2), RS_ShadowBombBigEX, RS_ShadowBeast_BallFireEX / BallEx2 / BallEx3, RS_STracerEX, RS_HellShotEX(2), RS_HellWaverEX, RS_ZapCybEX, RS_HSGhostEX, RS_BVileEX* (clouds, waves, tornado, black holes, shockwave), RS_Shadow*EX* (Spectre EX ghosts, balls, beams, spirals), RS_RainFireRevEX(+Trail), RS_BlackImpEXcharge, RS_BlackImpEXBall1, RS_ROMEROEX* (shots, beams, walls, mines, barriers, code, BFG floors) | missiles, trails and effects of the EX bosses | No: not monsters |

The 1.04 White Mastermind (RS_WhiteMind / RS_WhiteMind2) is not EX-tier and not in the pool.
