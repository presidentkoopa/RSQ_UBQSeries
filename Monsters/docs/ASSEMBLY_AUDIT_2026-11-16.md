# Monster Assembly: audit, 2026-11-16

Owner, 2026-11-16 08:36-08:40: "we can get monster assembly done now ... our monsters are designed and done ... we have
ch, bdxmve, and ex tier monsters now." Monster Assembly is the RSQ Monsters rebuild (`Monsters/`, `pk3/RSQ_Monsters.pk3`;
the painted colour art `pk3/RSQ_BDXMTiers_<Colour>.pk3` is built from `MonsterRecolour/` by `tools/build_monster_art.py`).
Its scope is `design/PLANNED_PROJECTS.md` ("RSQ Monsters rebuild = Monster Assembly", "RSQ Monsters pass", "Folded in
2026-11-12") and the root README's "What is left for 2.0", item 4.

This file is the audit made before the work: what was already done, what was not, item by item, read from `origin/main`
at `79e8edf519`. Each item's state after this run is in the last column. Everything shown on the rig is
**rig only, not headset-confirmed**.

## What to load (the owner asked, 11-16)

Load order, after Brutal Doom 22, XMVE, Legion of Bones and Champions (the README's load order):

| File | What it holds | Needed? |
|---|---|---|
| `RSQ_Monsters.pk3` | All of RSQ Monsters' code: the Monster Set (Vanilla, BD22 + XMVE Tiers, ColorfulHell), the colour ladder on Brutal Doom's / XMVE's / plain monsters (tint, health, damage, speed, colour behaviours), the 17 ColorfulHell families and their EX bosses, the tier flash, the tier gems, the menu page, the service RSQ Miniboss / Score / Grenade ask. Also every ColorfulHell sprite and sound. | Yes: this is the mod. Alone it plays: Brutal Doom's monsters on the ladder are drawn with the live **tint** |
| `RSQ_BDXMTiers_Green.pk3` ... `RSQ_BDXMTiers_White.pk3` (12 files: Green, Blue, Purple, Cyan, Brown, Yellow, FireBlu, Gray, Red, Abyss, Black, White) | **Art only, no code.** Each holds the hand-painted copy of every Brutal Doom 22 + XMVE monster frame in one colour (`rsrecolour/<colour>/<LUMP>.png`, about 12,500 frames, 51-54 MB each), the list of painted sprites, and a GLDEFS giving each painted frame its brightmap. There is no Common file: Common is the monster as Brutal Doom ships it. | Optional. With them, a monster at that colour is drawn from the painted frame instead of the tint (RSQ Monsters > Painted Colour Art, on by default). Missing one colour: that colour falls back to the tint |

**Order:** RSQ_Monsters first, then the 12 colour files. **What the order changes (measured on the rig, see the Status
of item 6):** the colour files hold no sprite names (they are drawn through `picnum` by full path) and no code, so loading
them before RSQ_Monsters (the owner's PK3TEST folder sorts them first by name) draws the same art; the only shared lump
is each file's `GLDEFS.txt` (brightmaps), which adds, never replaces. See the report's gate rows for the rig check.

## The items

| # | Item | Before this run (audit) | State after this run |
|---|---|---|---|
| 1 | Stale comments, cvars and menus out; the 29 menu-structure problems; the 256 compile warnings | **Not started** (README "RSQ Monsters pass": "Not started"). Measured: `tools/rsmenu/menutool.py check Monsters` = 29 problems (14 orphan RS pages, 13 pages opening pages, no Reset All, the sub menu named "Monster Diagnostics" not "Test and Debug"); `RS_CH_OffOn` used by 4 rows and never defined. CVARINFO: 150 settings, **101 read by nothing** (elites, reserve squads, health bars, No More Hitscans, spawn bands, missile floor, summons pay ...), its first 515 lines comments only, about RS_Main systems not in the pack. Compile: **256** deprecated-flag warnings (MISSILEMORE / MISSILEEVENMORE in Default blocks, SHORTMISSILERANGE) plus **162** script warnings (VelX/VelY/VelZ 90, bMISSILEMORE / bMISSILEEVENMORE 33, "Bad hex number" from `"none"` railgun colours 39): 418 lines. Dead data: LANGUAGE.en-messages (a byte copy of Gun Bonsai's own), LANGUAGE.rs_ui (420 strings, none read), GLDEFS (2 lights, none read), TEXTURES.txt + graphics/HP_* (health-bar sprites HA/HB/HM/HFRM for a file not loaded), 167 of 196 TRNSLATE entries read by nothing, ELITE_SYSTEMS.txt and EXCLUDED.txt describing files not in the pack. The README's "Which monsters a map gets" table called ColorfulHell "(the default)" and did not list BD22 + XMVE Tiers; the code's default is `rsq_monster_set = 1` (BD22 + XMVE Tiers) | See the report |
| 2 | Menus redone from scratch | Not started | **Proposal only** (`docs/MENU_PROPOSAL.md`), waiting for the owner. Not built |
| 3 | Monster Diagnostics written up | Not done. The page (`RS_MonsterDebugMenu`) listed the Chaingunner family under codes C0001, T0001-T0010, B0001-B0002, X0001; only God Mode worked (14 spawn rows, Spawn All, Remove, DIAG, WAKE sent netevents nothing answered; its "Spawn hostile" setting was read by nothing). The codes come from RS Monsters' per-colour class files (`rs_chaingunner_t0001_green.zs` ...), which were never in this repo | See the report |
| 4 | Brutal Doom's own monsters on the colour ladder (health as Colourful Hell's) | **Built 11-13** (`RS_BDTier.zs`, `RS_BDTierData.zs`; rule `design/BD_XMVE_TIERING.md`), painted art merged 11-14, BD22 + XMVE the default set since 11-13 (kept by the 11-15 revert). Health per colour follows each family's ColorfulHell ratio (zombieman Red = 9.30 x Common: CH's Red ZombieUnman 186 / Zombieman 20), so a Red zombieman has a Red zombieman's health scaled to the Brutal Doom body. Black and White on these monsters are the mild grade (owner 11-13 "Leave them different"), not ColorfulHell's bosses. Not built from the design: the by-kind variants and section 8 | Shown again on the rig with this run's pk3 (report) |
| 5 | The tier icons back (design/icons, style B) | **Done before this run** (11-10 / 11-11): `sprites/monsters/TierIcons/TI3RA0-M0.png` are pixel for pixel `design/icons/B/1_Common.png` ... `13_White_boss.png` (checked 11-16), drawn over ColorfulHell monsters (`RS_ColorTierIconCH*`) and Brutal Doom / XMVE monsters on the ladder (`RS_BDTier.zs`, once a second), behind **Tier Icons Above Monsters** (`rs_ch_colorblind`), off by default | Frame on the rig with this run's pk3 (report); default left Off (question) |
| 6 | Sprite-name clashes between packs (the owner's full load order) | One fixed 11-12 (WICK -> RVWK). Measured 11-16 against the full order: RSQ_Monsters loads after Brutal Doom 22, XMVE, Legion of Bones and Champions, so **every frame it ships under a shared sprite name replaces theirs**. 46 shared names were harmless (the same pictures, or letters nobody else has); **36 names drew a different picture** (among them Brutal Doom's Arch-vile DIAB drawn as a red Colourful Hell Arch-vile, Revenant SKEL, Arachnotron BSPI, Baron BOS2, XMVE's Demon DEMO, Terminator TERM, Cardinal CARD, Legion of Bones' CALI and IMPB, Champions' CBAL / LEF1 / LEF2 / BLUD) and **7 more replaced rotations** of Brutal Doom frames under other lump names (BOSB, BOSC, CYBB, FATF, REVP, TRO3, VILP; the cause of RS_BDArt's 11-14 fallback) | See the report and `docs/SPRITE_CLASHES_2026-11-16.md` |
| 7 | The tier flash matched to Hackfraud's original | Ported 11-09 from `HF_Monster.zs` SetTier/Tick (wait 5-25 tics, every 3 tics flash / own look, black when becoming White); full-bright added 11-12 (owner's complaint); Photosensitive Mode calm flash 11-12. The owner's files were not in the repo; now staged (`outdatedHFmaster/zscript/monsters/HF_Monster.zs`). Compared line by line on 11-16: see the report | See the report |
| 8 | Thrall drops checked on other monster types | Checked 11-12 on RS_CommonZombie thralls only (run `mbthrall2`; RSQ Miniboss README: "Not shown: a thrall of another monster type") | See the report |
| 9 | Inventory the EX tier | Below | Below |
| + | 51 Colourful Hell sprite sets our code names but the pack never carried (owner 09:03, added to this run) | The comparison with Colourful Hell 1.04 (`/tmp/chcmp/absent_sprites.txt`) lists 50 sprite names; 49 are in CH 1.04, 1 (SMT1, `RS_SmithGhost1`) is missing in CH itself | See the report |

## 9. The EX tier: every EX monster class

All ten are **ColorfulHell** monsters (only the ColorfulHell set has EX forms; Brutal Doom's and XMVE's monsters on the
ladder have no EX class: past White each step is +10% health and +5% damage, `RS_BDTier.zs`). Each is `+BOSS`, states
its ladder tier when it spawns (`RS_Zom.SetTier`), and has its gate's family and tier for a tier change
(`RS_TierLadder.IsEXName` / `FamilyOfAny` / `TierOfAny`: an EX body can be asked to change tier).

| EX class | Family | Name (Tag) | Health | Ladder tier | Gate class (where the roll is) | File |
|---|---|---|---|---|---|---|
| `RS_BlackZombieEX` | Zombieman | Player X | 5,000 | 12 Black | `RS_BlackZombie` | `zombieman/RS_Zombieman.zs` |
| `RS_WhiteSGEX` | Shotgunner | BENELLUS,GOD OF SHOTGUNS,ANGRIER | 12,537 | 13 White | `RS_WhiteSG` | `shotgunner/RS_Shotgunner.zs` |
| `RS_BlackCGuyEX` | Chaingunner | LET ME SEE YOUR WARFACE | 8,999 | 12 Black | `RS_BlackCGuy` | `chaingunner/RS_Chaingunner.zs` |
| `RS_BlackImpEX` | Imp | Smoking Black Imp EX | 8,600 | 12 Black | `RS_BlackImp` | `imp/RS_Imp.zs` |
| `RS_BlackCacoEX` | Cacodemon | SHOCKMASTER RETURNS | 10,000 | 12 Black | `RS_BlackCaco` | `cacodemon/RS_Cacodemon.zs` |
| `RS_WhiteLSoulEX` | Lost Soul | The vengeful soul | 12,500 | 13 White | `RS_WhiteLSoul` | `lostsoul/RS_LostSoul.zs` |
| `RS_BlackHKEX` | Hell Knight | Terminator MK II | 11,000 | 12 Black | `RS_BlackHK` | `hellknight/RS_HellKnight.zs` |
| `RS_BlackRevenantEX` | Revenant | The Black Knight unleashed | 7,500 | 12 Black | `RS_BlackRevenant` | `revenant/RS_Revenant.zs` |
| `RS_BlackFatsoEX` | Mancubus | The thing from the bog | 18,000 | 12 Black | `RS_BlackFatso` | `fatso/RS_Fatso.zs` |
| `RS_BlackSPEX` | Arachnotron | Macross Missile Spam EX | 12,000 | 12 Black | `RS_BlackSP1` | `spider/RS_Spider.zs` |

The other seven families (Demon, Spectre, Pain Elemental, Baron, Arch-Vile, Cyberdemon, Spider Mastermind) have **no EX
form**. Health is the class default; the skill's monster health multiplies it as for any monster (Black Metal 0.8). No
"ladder health" applies to an EX body.

**How one is spawned or selected today (three ways):**
1. **The ColorfulHell spawn dial.** A ColorfulHell map spawn rolls its family's colour (`RS_<Family>Colourset`, a
   RandomSpawner). A Black (or White, for the Shotgunner and the Lost Soul) roll lands on the gate class, which rolls
   EX by `rs_ch_exboss`: 1 (default) = 24 in 256, 2 = half, 3 = always, anything else = never; `rs_ch_blackboss` /
   `rs_ch_whiteboss` 1 (default) let the boss spawn at all. **Out of the box this never happens:** the per-family caps
   (`rs_roster_<family>`) default to 1, so ColorfulHell map spawns are Common, and the default Monster Set is BD22 +
   XMVE Tiers anyway.
2. **RSQ Miniboss's fight.** The Boss comes from ColorfulHell by default (`rsq_mon_bf_boss` 1). At the arrival its
   colour is world tier + 2 (`Miniboss/zscript/rsqmb/fight.zs`); at 12 or above it asks RSQ Monsters
   `"set.class.ex"` (`RS_ScoreReadout.zs` `SetClassEX`), which rolls the same `rs_ch_exboss` odds and answers the EX
   class when its family has one at that colour. So with the world tier at 10 or more (`rsq_mon_worldtier`, the test
   row) a Boss of an EX family can arrive as its EX form; White-gate families (Shotgunner, Lost Soul) need world tier
   11 or more. Its thralls are world tier + 1 and never EX.
3. **A tier change never makes an EX.** `RS_Retier.Swap` uses `RS_TierLadder.ClassFor` (the plain Black / White class:
   `RS_BlackImp1` ...); an EX body asked one step up becomes the family's White.

**On demand:** `summon RS_BlackImpEX` (any of the ten) spawns one, alone, at its default health (sv_cheats in
multiplayer). Since 11-16 the Test and Debug page's X0001 row spawns the Chaingunner's (`netevent rs_cg_spawn 13`).
**With thralls, on demand: not today.** The only path is a Miniboss call-in (`netevent rsqmb_fill 1000`, then
`netevent rsqmb_callin`) with `rs_ch_exboss 3` and `rsq_mon_worldtier` 10 (11 for White gates), and the Boss's family
is the one the fight picks from the map's monsters, not one you choose. Nothing spawns a chosen EX class with
thralls. RSQ Monsters gives the Big Boss builder what is needed by name: `"set.class.ex"` (family + colour -> the EX
class, after the roll), `"set.class"` (any monster type + set + tier -> that family's class at that colour, for thralls),
`"retier"`, `"tier"`, `"ex"` (`RSQMN_RosterService`, `RS_ScoreReadout.zs`).
