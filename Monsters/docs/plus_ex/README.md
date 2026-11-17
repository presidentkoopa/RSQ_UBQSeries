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
| `RS_WhiteMindES` | CommonWhiteMind2 | Everlasting White Spidey | 20,000 | 13 | `rs_chp_whitemind 2` / `3`; the Big Boss pool (`RSQBIGBS.txt`) |
| `RS_WhiteSPFusion` (-> 2 x `..Fusion2` 1,250 -> 2 x `..Fusion3` 500) | CommonWhiteSpider3/4/5 | White Spider | 4,000 | 13 | `rs_chp_whitespider 3`; the Big Boss pool (`RSQBIGBS.txt`) |
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
- RSQ Miniboss's **Big Boss** pool (every loaded class ending "EX" at a boss colour, plus every class named in an
  `RSQBIGBS` lump) lists them: `Monsters/RSQBIGBS.txt` adds the two that are not named *EX, the Everlasting White Spidey
  and the Fusion White Arachnotron: 18 in all (10 older EX + 6 new EX + 2 registered).
- `summon` by name works for all of them.

Type choices (console settings for now; RSQ Monsters' menu was just rebuilt, so no row is added here):
`rs_chp_whitespider` 1 = 1.04 (default, unchanged) / 2 = Old / 3 = Fusion / 4 = Plus New; `rs_chp_blacksoul` 1 = 1.04
(default, unchanged) / 2 = Old; `rs_chp_whitemind` 1 = 1.04's Heavily Armed Spidey (default, owner 11-16: the White
Mastermind roll is unchanged) / 2 = Everlasting / 3 = either, half and half.

**On the colour ladder (2026-11-17, owner-approved; rig only, not headset-confirmed).** The bodies not named *EX were on no
ladder table, so World Tier changes and One Tier Up did nothing to them. They now stand in the slot of the 1.04 body they
replace (`RS_TierLadder.PlusSlotOf`): the Everlasting White Spidey in the White Mastermind's (tier 13), the Fusion, New
and Old White Arachnotrons in the White Arachnotron's (13), the Old Black Lost Soul in the Black Lost Soul's (12). The
page's switches hold as for every ladder body (Extra Colours, Black Boss, White Boss, World Tier Ladder). A tier change or
the World Tier landing on one of those three slots gives the body its Plus row picks (`RS_PlusEX.LadderBody`, no EX
roll); at the rows' defaults that is 1.04's body, as before. The Fusion's splits and the EX splits, clones and cores stay
off the ladder (a split moved to Black would come back a full-health Black boss). Runs `fps_ladder_*`, `fps_rows_*`,
`fps_rowsdef_*`, `fps_toggles_*` (`/mnt/user-data/outputs/fix_plus_score/`): before, "not on the ladder" and nothing
moved; now What Is It reads family and tier, Whole Map One Tier Up took the Old Black Lost Soul to White, World Tier
5 -> 3 took the White bodies to Black; with the rows at Fusion / Old / Everlasting a Black Arachnotron and a Black
Mastermind tiered up came out the Fusion and the Everlasting White Spidey, and a White Lost Soul lowered came out the Old
Black Lost Soul (at the defaults: 1.04's three, as before).

## What was changed from CHP

- **Stubbed** (owner: no Abyss-style effects that reverse the player's movement or darken the screen): the three
  darkness powerups CHP gives the player (`RS_DarknessTokenBlackSpectreEX` from the Spectre EX's dark beams,
  `RS_BVileEXDarknessToken` and `RS_BlackMindDarknessToken` from the Black Arch-vile EX and its Void) are items no one can
  hold. Nothing in these bodies reverses movement.
- **Kept** (owner 11-16: the slows and the push / pull stay; the time-up is undecided, left as is): the White Arch-vile EX's time-up
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

## Kill Rewards: 100 bits at most a death (fixed 11-16, owner "100 bits at most")

Found here: RSQ VisualRewards' Kill Rewards burst a boss into spawn health / 10 x 3 bits, 9,830 for the White Cyberdemon
EX at skill 3, all at one spot, and the engine then spent minutes a tic (census 10,006 actors; the same deaths ran on with
`rsqgb_kr_enabled 0` or without RSQ_VisualRewards.pk3, runs `bisA`-`bisE`). Fixed in
`VisualRewards/pk3/zscript/rsqvr/killrewards.zs`:
- One death throws at most **100 bit actors**. The Boss Gold Fountain's slots come first (up to 25; its default 20 fits
  whole), then the burst; with the Lucky Kill node the burst leaves the lucky share of what is left (1 / (1 + level) to
  the burst, the rest to the extra burst a tic later), so a lucky kill stays inside the 100 too.
- Over the cap the per-bit rolls are made exactly as before (the chance, the mix, a thrall's no-health rule, the gold and
  steel shares) and counted; each kind that rolled any gets at least one bit, the rest of the 100 by share, and every bit
  carries a **worth** (the bits it stands for): health 25 x worth, armour 10 x worth (up to 250 as before), ammo: each of
  its worth rolls its own gun and Scavenger 3 grenade as separate bits would, gold and steel x worth; the DOWN plate banks
  the same. A bit worth more is drawn a little bigger (up to x2). Battery bits (asked by another mod, 32 at most) are
  outside the cap, as before.
- Under the cap nothing changes: the same rolls in the same order (shown with the RNG seeded at the kill, old and new
  VisualRewards: the same imp, Cacodemon and Baron bits).
- Shown on the owner's full order with Kill Rewards on: the White Cyberdemon EX (7,864 bits of value -> 80 + 20 fountain
  actors, about 30 ms a tic before and after the death, the Core rising on time) and the White Arch-vile EX (4,992 -> 80
  + 20). Logs in `rig_logs.txt` (runs `kr_*`, `kold_` / `knew_`).

## Not done / open
- The White Cyberdemon EX's own death throws up to ~785 `RS_RedThingsHK` sparks (CHP's design); heavy for Quest.
- No menu rows for the three type choices (console only) while the menu is the owner's new one.
- A health or armour bit worth many is picked up at once: what a full player cannot take of it is lost, where many
  small bits could have been taken one by one as health ran down.
- CHP's darkened White Spider (TRIT) and offset White Mastermind (W5PD, 4 px) art are not taken: 1.04's art is drawn.
- The Spectre EX and Queen Bee portraits are dark (a translucent black body in a dark corridor); their fight strips and
  logs show them.
