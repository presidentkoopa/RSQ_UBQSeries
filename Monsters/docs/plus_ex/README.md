# Colourful Hell Plus bosses in RSQ Monsters (2026-11-16)

Owner 2026-11-16 09:21, "get people on the EX bosses". Colourful Hell Plus R3.0.1 (CHP, by Dewzanity, built on Hege
Cactus' Colourful Hell 1.04) adds new boss bodies. They are ported here as ZScript in our naming, each one as CHP's
**Common** subtier (CHP's other 14 subtier copies, its 15x15 grid, spawn system, presets and player-side options are not
ported). Code: `zscript/monsters/plus/` (header: `RS_PlusEX.zs`). Tools: `tools/plus_ex/` (the DECORATE -> ZScript
converter, the hand edits, the rig probes).

**Everything below is rig only, not headset-confirmed.**

## The bodies

| Our class | CHP class | Tag (as CHP names it) | Health | Tier | How it comes |
|---|---|---|---|---|---|
| `RS_BlackSpectreEX` | CommonBlackSpectreEX2 | THE BACKSTABBER UNSILENCED | 7,250 | 12 | EX roll of `RS_BlackSpectre` |
| `RS_WhiteSPEX` | CommonWhiteSpiderEX2 | WHITE HOT SPIDER | 9,500 | 13 | EX roll of `RS_WhiteSP1` |
| `RS_WhiteSPEXSplit` (x3 on its death) | CommonWhiteSpiderEX3 | WHITE HOT SPIDER | 2,200 | 13 | its first split |
| `RS_WhiteSPEXSplit2` (x3 on each death) | CommonWhiteSpiderEX4 | WHITE HOT SPIDER | 500 | 13 | its second split |
| `RS_BlackArchEX` | CommonBlackArchEX2 | AHH HELP!!! | 2,700 | 12 | EX roll of `RS_BlackArch` |
| `RS_BlackArchEXVoid` (x3 on its death) | CommonBlackArchEX3 | Void Strikes back | 4,166 | 12 | rises from AHH HELP!!! |
| `RS_WhiteArchEX` | CommonWhiteArchEX2 | Time to die | 20,800 | 13 | EX roll of `RS_WhiteArch` |
| `RS_WhiteArchEXClone` | CommonWhiteArchEX3 | Time to die | 500 | 13 | its clones |
| `RS_BlackCybieEX` | CommonBlackCybieEX2 | Obsidian Tyrant | 24,000 | 12 | EX roll of `RS_BlackCybie` |
| `RS_WhiteCybieEX` | CommonWhiteCybieEX2 | It crashes doom II | 32,767 | 13 | EX roll of `RS_WhiteCybie` |
| `RS_WhiteCybieEXCore` | CommonWhiteCybieEX3 | The one behind it all | 3,000 | 13 | rises from its death |
| `RS_WhiteMindES` | CommonWhiteMind2 | Everlasting White Spidey | 20,000 | 13 | `RS_WhiteMind`'s White roll (`rs_chp_whitemind`) |
| `RS_WhiteSPFusion` (-> 2 x `..Fusion2` 1,250 -> 2 x `..Fusion3` 500) | CommonWhiteSpider3/4/5 | White Spider | 4,000 | 13 | `rs_chp_whitespider 3` |
| `RS_WhiteSPPlus` | CommonWhiteSpider2 (CHP's "New") | White Spider | 10,000 | 13 | `rs_chp_whitespider 4` |
| `RS_WhiteSP11Old` (1.04, already ported) | WhiteSP11Old | White Spider | 1.04's | 13 | `rs_chp_whitespider 2` |
| `RS_BlackLSoulOld3` (1.04, already ported) | BlackLSoulOld3 | Queen Bee | 1.04's | 12 | `rs_chp_blacksoul 2` |

Health is the class default; the skill multiplies it (Black Metal x0.8), and LegenDoom / Champions act on these as on any
monster (the rig's runs show both doubling health and Champions copying a Fusion split on its death).

**How they spawn.** The six EX bodies are named after their gate (`RS_BlackCybie` -> `RS_BlackCybieEX`, the spider's
`RS_WhiteSP1` -> `RS_WhiteSPEX`), the rule RSQ Monsters already reads, so with no new table:
- the gates (one line each in the family files) roll them with 1.04's own `rs_ch_exboss` (1 = 24 in 256, 2 = half,
  3 = always, other = never). **New EX chances, not changed odds:** the Spectre, Arch-vile and Cyberdemon Black rolls and
  the Arachnotron, Arch-vile and Cyberdemon White rolls had no EX form before; they now take one 24 times in 256 by
  default. The ten older EX forms keep their odds.
- `RSQMN_RosterService` answers `class.tier` 12 / 13 for them and `set.class.ex` picks them (shown below);
- RSQ Miniboss's **Big Boss** pool (every loaded class ending "EX" at a boss colour) lists them: 16 EX bosses (10 + 6).
- `summon` by name works for all of them.

Type choices (console settings for now; RSQ Monsters' menu was just rebuilt, so no row is added here):
`rs_chp_whitespider` 1 = 1.04 (default, unchanged) / 2 = Old / 3 = Fusion / 4 = Plus New; `rs_chp_blacksoul` 1 = 1.04
(default, unchanged) / 2 = Old; `rs_chp_whitemind` 1 = 1.04's Heavily Armed Spidey / 2 = Everlasting / 3 = either, half
and half (**default 3: the White Mastermind roll now gives the Everlasting White Spidey half the time**).

## What was changed from CHP

- **Stubbed** (owner: no Abyss-style effects that reverse the player's movement or darken the screen): the three
  darkness powerups CHP gives the player (`RS_DarknessTokenBlackSpectreEX` from the Spectre EX's dark beams,
  `RS_BVileEXDarknessToken` and `RS_BlackMindDarknessToken` from the Black Arch-vile EX and its Void) are items no one can
  hold. Nothing in these bodies reverses movement.
- **Kept, flagged for VR comfort** (not darkening, not reversal; the owner's call): the White Arch-vile EX's time-up
  freeze (speed 0 on its target, again every few tics until the target dies) and its armour steal (speed x0.25 for 10 s,
  all armour taken, 20 damage, a white flash: CHP's full-white FadeTo is softened to a 60% blend over 1 s); the White
  Arachnotron webs (speed x0.2 for ~1 s, as 1.04's); the Black Arch-vile EX's leaves and tornadoes push (3,000) and pull
  (-1,000) the player.
- **ACS rewritten in ZScript**: WVileEX.acs `WVileEXTimer_C` + `WVileEXTimer2_C` (the 300-second count: the clock sound,
  the lines at 300/200/100/50/20 s and 10..1, the quakes, then invulnerable + TIMESUPMOT) -> `RS_PlusWVileTimer`;
  `WVileEXArmorSteal_C`, `WVileEXTimeStop` -> `RS_PlusEX`. Announcers dropped (standing order); `EXBOSS` -> the same
  "A chill runs down your spine" log line the 1.04 EX bosses print; `CybieSpecialKill_C` dropped (a 1.04 announcer);
  `CallACS("CH_BlackSubtier")` -> CHP's default (2), so the Everlasting Spidey's chaos orb is on.
- CHP's icons -> this series' tier gem (`RS_ColorTierIconCH10` / `CH11`) from each body's Tick, only while Tier Icons is on.
- Tags and obituaries keep CHP's words; CHP's colour codes (`\c[ColorKX]` black, `\c[ColorWX]`, `\c[ColorW]`) are taken
  out (this pack has no such colours; black text is unreadable on the HUD).
- The Everlasting Machine's thralls are our Black bodies in the Mastermind's species (`RS_WhiteSpid<Black body>`); CHP's
  own death states for them are not ported.
- Gore chain (`CHRandom_GibGenerator`) and DRLA / cross-mod drops stripped as in the 1.04 port.
- Warnings: MISSILEMORE / MISSILEEVENMORE -> MissileChanceMult / `RS_MissileChance`, railgun colour "none" -> 0,
  HEXENBOUNCE -> BounceType, DONTHURTSPECIES -> DONTHARMSPECIES: **0 RSQ_Monsters compile warnings**.

## Assets

- **Sprites added: 63 lumps, 52 engine sprite frames** (LETR A-Z 26, the death letters; SBA2 A-H 8, the White Hot
  Spider's fire bomb; RLF1 A-I 9 and RLF2 A-I 9, CHP's leaves: CHP names them LEF1/LEF2, Champions' names with another
  picture, removed from our pack by `SPRITE_CLASHES_2026-11-16.md`, so ours are renamed). Monster Assembly measured 55,287
  after its run: about 55,339 of 65,535 with these. Every other sprite these bodies draw was already in the pack (CHP's
  GKEX, SILE, LMWX, HSMI, MMDG, WSPX, W5PD ... and 1.04's CHA0 via Assembly's import). CHP's own missing frames are left as
  CHP has them (BOS9 I, BRAB L, CHTA X, MISL E, VORX I-P, LEF1 E: those frames draw nothing in CHP too).
- **Sounds added: 74 lumps** (`sounds/plus`, 2.7 MB), defined in `SNDINFO.plusex` under `rsplus/` (CHP's names prefixed, so
  no other mod's `tornado/form` or `wind/away` changes; XMVE defines both). HLWIND / Q2WIND are XMVE lump names with other
  bytes: ours are RSPHLWND / RSPQ2WND. The four NA_* lumps are byte for byte XMVE's. CHP names two sounds nothing defines
  (`hellsmith/miss`, `weapons/onfire`): silent, as in CHP.
- Clashes checked against the owner's full load order (every pk3/wad of `boss_full.sh` and gate_rel4's RSQ pk3s): none
  left for LETR, SBA2, RLF1, RLF2 or the sound lumps (`tools/plus_ex/clash.py`).
- `TRNSLATE.plusex` (BVEX2, BVEX3: the Black Arch-vile EX's phases), `CVARINFO.plusex` (the three type choices).

## Shown on the rig

Frames: `frames/portraits_dormant_288u.jpg` (each body, dormant, 288 units away), `frames/fight_<class>.jpg` (four
frames of each fight). Logs: `rig_logs.txt` (every run's command, its script errors, and the probe's lines).

- Each body: summoned, attacking (its own projectiles logged by class, its hits on the player logged), killed, its death
  spawns logged: the White Hot Spider 1 -> 3 -> 9; AHH HELP!!! -> 3 Void Strikes back; the Fusion 1 -> 2 -> 4; It crashes
  doom II -> The one behind it all; the Time to die clones.
- The White Arch-vile EX's timer (the probe forces its ENDOFTIME attack and moves the clock 10,050 tics on, a test
  harness): "300 seconds left...", "10..." to "1...", "time is up: invulnerable, TIMESUPMOT given", the player frozen
  (RS_TimeSlowMOT3), 270 TimeShock bolts; the armour steal (forced StealofTime) logged.
- The gates with `rs_ch_exboss 3` give the six EX bodies, `rs_chp_whitespider 3` the Fusion, `rs_chp_blacksoul 2` the Old
  Queen Bee, `rs_chp_whitemind 2` the Everlasting Spidey; with `rs_ch_exboss 0` the gates give the 1.04 bodies.
  `set.class.ex` Spectre 12 / Arachnotron 13 / ArchVile 12, 13 / Cyberdemon 12, 13 -> the six; the Big Boss pool: 16.
- Gate: every run, script errors only BD22 VoxelPack's four voxeldef lines, no VM abort.

## Not done / open

- **RSQ VisualRewards' Kill Rewards stalls the game when the 32,767-health White Cyberdemon EX (and, in the rig, the White
  Arch-vile EX) dies**: a boss bursts into spawn health / 10 x 3 bits, 9,830 bits at skill 3 (7,864 at Black Metal), all
  at one spot; the engine then spends minutes per tic (shown: the census jumps to 10,006 actors; the same deaths run on
  with `rsqgb_kr_enabled 0` or without RSQ_VisualRewards.pk3, runs `bisA`-`bisE`). 1.04's White Cyberdemon (21,000) did
  not stall in the same test. A cap belongs in VisualRewards (not this lane). **Do not take these two to the headset with
  Kill Rewards on until then.**
- The White Cyberdemon EX's own death throws up to ~785 `RS_RedThingsHK` sparks (CHP's design); heavy for Quest.
- No menu rows for the three type choices (console only) while the menu is the owner's new one.
- CHP's darkened White Spider (TRIT) and offset White Mastermind (W5PD, 4 px) art are not taken: 1.04's art is drawn.
- The Spectre EX and Queen Bee portraits are dark (a translucent black body in a dark corridor); their fight strips and
  logs show them.
