# One package, separate mods, or both? (study, 2026-11-08)

Asked by presidentkoopa. Research only: no code was changed. Every number below was measured on the files in this
repo on 2026-11-08 (the built pk3s in `pk3/`, the sources beside them), or read in the QuestZDoom 17.3 engine source
(`emawind84/gzdoom`, tag `qzd17.3`, commit `9afc750`, the build `tools/rig17/README.md` names). Inference is marked
**[inference]**. What I could not check is said.

## 1. Inventory

### Sizes and needs (measured, `pk3/` as built 11-07 / 11-08)

| pk3 | MB | files | ZScript lines | needs |
|---|---:|---:|---:|---|
| RSQ_LaserSight | 25.7 | 14,719 | 3,778 | nothing |
| RSQ_TacticalRig | 17.3 | 152 | 8,481 | nothing |
| RSQ_GunCards | 16.4 | 32,929 | 41,274 | nothing |
| RSQ_Saber | 14.5 | 10,942 | 8,463 | nothing |
| RSQ_Grenade | 5.7 | 219 | 3,166 | nothing |
| RSQ_ShieldSaw | 3.0 | 259 | 6,103 | nothing |
| RSQ_FnF | 1.4 | 140 | 3,357 | nothing |
| RSQ_Melee | 1.3 | 273 | 5,630 | nothing |
| RSQ_SlowMo | 1.2 | 743 | 5,776 | nothing |
| RSQ_Graveyard | 0.8 | 47 | 2,124 | nothing (GPLv3; "not one of the nineteen", README.md) |
| RSQ_VisualRewards | 0.7 | 453 | 4,613 | nothing |
| RSQ_Wheel | 0.6 | 148 | 20,312 | nothing |
| RSQ_Whip | 0.6 | 49 | 7,270 | nothing |
| RSQ_GunBonsaiVR | 0.5 | 63 | 10,758 | **Gun Bonsai 0.10.6, loaded just before it** (GunBonsaiOffhandVR/README.md:90, :191) |
| RSQ_Grapple | 0.5 | 58 | 5,555 | nothing |
| RSQ_Score | 0.4 | 52 | 10,321 | nothing |
| RSQ_DistanceGrab | 0.2 | 88 | 9,698 | nothing |
| RSQ_Miniboss | 0.1 | 21 | 3,962 | nothing |
| RSQ_Accessibility | 0.1 | 18 | 3,130 | nothing |
| RSQ_GlowInTheDark | 0.05 | 17 | 2,397 | nothing |
| **All 20** | **90.9** (86.7 MiB) | **61,390** | ~166,000 | |

For scale: `brutal22test6.pk3` is 159.5 MB (`/home/claude/gamedata`). The owner's "under 100 MB" is right.
Three pk3s carry 64% of the bytes and 95% of the files (LaserSight's 7,344 halo + 7,344 beam models; GunCards' ~16k
sprites; Saber's ~10.7k sprites).

"No mod requires another: each only gains features when another is loaded" (WHO_OWNS_WHAT.md:9-10; README.md:74).
The one hard dependency is Gun Bonsai VR on ToxicFrog's Gun Bonsai: its classes derive from Gun Bonsai's
(`rsq/zscript/up_gloves.zs:7`, `class RSQ_Upgrade_Base : TFLV_Upgrade_BaseUpgrade`) and it replaces Gun Bonsai files
by path (`GunBonsaiOffhandVR/zscript.txt:3-5`).

### Who talks to whom

The mods only know each other by name strings. Counted in the shipped sources (tools/, docs/, tests excluded):
247 `ServiceIterator.Find`, 140 `SendNetworkEvent`, 530 `CVar.FindCVar`, 156 `FindInventory("...")`,
147 `EventHandler.Find`/`StaticEventHandler.Find`.

I matched every string literal in each pk3's ZScript/MENUDEF/KEYCONF against the classes and cvars the OTHER pk3s
declare. Result: **146 directed links among the 20 pk3s** (out of 380 possible). Heuristic, not a compiler: it counts
names, not call sites that run.

| mod | reads this many other mods | is read by this many |
|---|---:|---:|
| Gun Bonsai VR | 15 | 19 |
| Accessibility | 4 | 16 (its cvars and `RSQA_Service`, via each mod's `a11y.zs` copy) |
| Score | 13 | 14 |
| SlowMo | 9 | 12 |
| Tactical Rig | 12 | 10 |
| Saber | 4 | 10 |
| Miniboss | 7 | 10 |
| Wheel | 13 | 3 |
| Melee | 11 | 6 |
| VisualRewards | 10 | 3 |
| Whip, DistanceGrab | 8 each | 4, 5 |
| ShieldSaw, Grapple | 6 each | 7, 5 |
| FnF, Grenade, LaserSight, GunCards, GlowInTheDark, Graveyard | 3-4 each | 1-7 |

Network events that cross a mod line (11): `rsm_pulse` is sent by 9 mods and heard by SlowMo; `bonsai-level-up`
(GBOVR to GlowInTheDark and VisualRewards); `rsqa_alt` (Accessibility to DistanceGrab, Saber, ShieldSaw); Rig to FnF
(`rsqff_take`, `rsqff_back`), Saber (`ubqs_dual_in`), SlowMo (`rsqtr_cigslowmo`); Wheel to SlowMo (`rsm_on/off`) and
ShieldSaw (`ssq-draw`); Melee to SlowMo (`rsqml_fear`).

Outside the series: Champions and LegenDoom names (`champion_Token`, `LDLegendaryMonsterToken`, ...) are read in 11
files across Score, VisualRewards, ShieldSaw, SlowMo, GBOVR, Miniboss and FnF. BD22 VR's own grenade and shove make
Grenade and Melee stand down (README.md, WHO_OWNS_WHAT.md). Bundling the series changes none of these.

The owner's "best features are when mods play off each other" is visible in the code: DOWN alone draws on six
series mods plus Champions and LegenDoom (README.md, "DOWN").

## 2. What is already unified, and what is not

The series is already one family at run time, built by copying shared code into every pk3 under its own prefix:

| shared piece | copies | lines in all copies | template |
|---|---:|---:|---|
| Radiant Silvergun Options menu (`*_RSMenu`, `*RSLink`) | 20 | 10,140 | `tools/rsmenu/rsmenu_template.zs` (507 lines) |
| Accessibility reader (`*_A11y`) | 15 | 2,213 | `Accessibility/tools/a11y_template.zs` |
| HandSync (frame-to-tic hand fix) | 9 | 1,430 | `tools/handsync/handsync_template.zs` |
| Gesture fallback (`gestcopy`) | 4 | 1,295 | `tools/gestcopy/gestcopy_template.zs` |

Ten of the `a11y.zs` copies are byte-identical once the prefix is removed (md5 measured). The one menu already
works: every MENUDEF defines an empty protected `RSQ_RSOptions` and adds one row (rsmenu_template.zs:6-18).
The one rumble scale (`rsqa_rumble_scale`) and one Reset already live in Accessibility.

What a unified package would add:

- **One download, no mixed versions.** Today a player can hold Score from 11-07 and SlowMo from 11-03. The names
  the mods ask each other for are not checked at compile time (tools/series_check.py:9-12 says so), so a stale pk3
  silently loses features. One file removes that case.
- **No load-order mistakes inside the series.** The series already loads "in any order" (README.md:89), so this gain
  is small. The order that matters (after the BD stack, after XMVE, Gun Bonsai before GBOVR) stays the same.
- **No stale files.** The Gestures fold-in already produced a fatal duplicate-class trap for players with an old
  `RSQ_Gestures.pk3` (Accessibility/README.md:117). One file per release makes "delete the old one" simple.
- **Netplay.** In-repo statements disagree: "QZD has no netplay" (Score/ideas/B_grenade_grapple_grab_laser_gestures.md:155)
  and "netplay ... not a concern on Quest" (DistanceGrab/docs/PORT_SCOPE.md:113), yet co-op bugs were fixed
  (BUGS_0.99a_STATUS.md:56). I could not check QZD netplay. REMA's goal is "four-player online co-op ... with a fixed,
  versioned mod set" (uzdxrema/CLAUDE.md:29); one versioned file is what that needs **[inference]**.
- **Bytes saved: almost none.** Identical files in two pk3s: 5 (one 360,810-byte sound in Melee and GBOVR; four
  small PNGs shared by Wheel with Saber and FnF). Total under 0.4 MB. The duplicated code above compresses to little.
- **Quest install.** I found no Quest install guide in the repo and could not check how QZD on Quest picks files.
  One file to copy instead of 18-20 is less friction **[inference]**.

## 3. The case for keeping them separate

- **Players outside Brutal Doom.** ShieldSaw is "a standalone off-hand mod that loads beside any weapon pack"
  (ShieldSaw/README.md:19); the README promises "Plain Doom 2 with RSQ mods and nothing else works too". Someone who
  wants only the Whip downloads 0.6 MB, not 91 MB; only the Grapple, 0.5 MB.
- **Failure isolation.** One ZScript error aborts the whole game: "Abort if the compiler produced any errors"
  (engine `src/scripting/thingdef.cpp:432-436`). A player with three mods is safe from a bug in the other sixteen. In
  one pk3, every player gets every mod's errors **[inference: true for anyone who today loads them all anyway]**.
- **The series rule.** Each mod stands alone and gains features from partners (WHO_OWNS_WHAT.md:9-10). Separate
  files keep that rule honest: a hidden hard link shows up the moment someone loads one mod alone. I found no tool
  that tests each mod alone: `series_check.py` gates the owner's full load order (lines 19-23), `rig17/runall17.sh`
  runs four packs. So today "loads alone" rests on design, not on a gate (checked by reading those tools).
- **Hard dependencies.** GBOVR cannot go into a package without Gun Bonsai: its parent classes would be missing, a
  fatal compile error. Graveyard is GPLv3 and already kept apart.
- **Credits and licences per mod.** 18 CREDITS files, GBOVR's COPYING.md, Graveyard's GPLv3, Ermac's MIT, id rips.
  A combined file must carry all of them (fine, but it must be built, not forgotten).
- **Contributors.** One folder, one pk3 is easy to hand to a helper. A combined build does not change that if
  sources stay per mod.
- **Git size.** pk3s are committed (`.gitignore`: `!pk3/*.pk3`); `.git` is 965 MB, pack 667 MiB. A second 87 MB file
  per release about doubles the binary growth **[inference]**.

## 4. Options in between

### A. Status quo plus an "All" zip (no code change)
A zip of the separate pk3s, attached to a GitHub release. One download, no new failure mode. Still 18-20 files to
copy and load, and mixed versions are still possible later.

### B. Same sources, the build also makes one `RSQ_Series.pk3` (recommended to test)
`tools/build_all.py` gains one more output: every mod except GBOVR and Graveyard in one archive.

What has to change, checked against the engine:

| lump | today | in one pk3 | engine evidence |
|---|---|---|---|
| ZSCRIPT | one `zscript.txt` per pk3 | rename per mod: `ZSCRIPT.rsqsm`, `ZSCRIPT.ubqs` ... | `thingdef.cpp:425`: every `ZSCRIPT` lump is found and compiled on its own, each with its own `version` (`zcc_parser.cpp:441-477`). So Saber, Wheel and GunCards keep `version "4.10"`, LaserSight `"4.12"`, the rest `"4.14"`. |
| CVARINFO, MENUDEF, KEYCONF | one per pk3 | same rename | all loop over every lump: `d_main.cpp:1676`, `menudef.cpp:1555`, `keysections.cpp:170` |
| MAPINFO (AddEventHandlers) | one per pk3 | same rename | all read (`g_mapinfo.cpp:2716`), **unless the same archive has a ZMAPINFO**, then every MAPINFO in it is skipped (2721-2726). No mod ships ZMAPINFO today; the build must refuse one. |
| SNDINFO, MODELDEF, GLDEFS, TEXTURES, LANGUAGE, VOXELDEF, TRNSLATE, TEXTCOLO | one per pk3 | same rename | loops: `models.cpp:717`, `voxeldef.cpp:272`, `r_translate.cpp:745`, `v_font.cpp:378`, `stringtable.cpp:63`. brutal22test6 already ships 9 MODELDEF.* and 9 SNDINFO.* in one pk3; the series already ships `VOXELDEF.halo`, `MODELDEF.torch`. |
| README / CREDITS | root | `credits/<mod>/` | not lumps the engine reads |

Name clashes, measured across all 20 pk3s: **0** shared top-level classes, **0** shared cvars, **0** shared SNDINFO
names, **0** shared OptionMenu/OptionValue names apart from the intended `RSQ_RSOptions`, **0** TRNSLATE or TEXTURES
names. Same path in two pk3s: `graphics/WRIFORCE.png`, `graphics/WRISABER.png` (Saber and Wheel), byte-identical, so
the build keeps one. Same short name: `WRIFLARE`/`WRITORCH` (FnF, Wheel) and `HITTHE` (Melee, GBOVR), all
byte-identical. Six enum names (`ERole`, `EKind`, ...) repeat, but all sit inside classes, so they do not clash.

Duplicate event handlers: none. Each mod's handlers keep their prefixes, so all 99 handlers named in the 17 MAPINFOs register as today. The order
between mods becomes the archive's name order instead of the load order; the series claims any order works.
The shared menu needs no change: each MENUDEF lump still adds its own row, and the link row still removes the
earlier copies (rsmenu_template.zs:15-18).

File count: 61,280 entries without GBOVR and Graveyard, above the 65,535 limit of a plain zip only if it grows by
~4,300. The engine reads Zip64 (`file_zip.cpp:58-95`) and Python's zipfile writes it, but a Zip64 pk3 has not been
run on a Quest **[not checked]**.

**The trap: combined plus a single.** If a player loads `RSQ_Series.pk3` and also `RSQ_Saber.pk3`, the game will not
start. The second CVARINFO hits "cvar '%s' already exists" (`d_main.cpp:1776-1778`), and the second class hits "Class
name %s already exists" (`zcc_compile.cpp:907`), which aborts (`thingdef.cpp:432`). This is the Gestures trap again
(Accessibility/README.md:117). ZScript cannot catch it: it fails before any script runs. Only naming and the README
can prevent it.

Nested pk3s do not help: the engine only opens `.wad` files embedded at an archive's root, or names the game lists
(`resourcefile.cpp:116-131`). A "pk3 of pk3s" will not load.

### C. A core library pk3 plus feature pk3s
Move the menu, the Accessibility reader, HandSync and gestcopy into `RSQ_Core.pk3`, once. This saves ~15,000 lines
of copies, and nine HandSync handlers running every tic would become one (a Quest gain only if measured
**[inference]**). But every mod would then need Core: it breaks "No mod requires another" (WHO_OWNS_WHAT.md:9) and
every prefixed call (`RSSC_A11y`, `RSQTR_HandSync`, ...) must be renamed in every mod. Mixed Core and mod versions
come back as a new failure. I do not recommend it.

### D. One pk3, each mod switched on in a menu
Option B plus a master switch per mod. Many mods already have one (e.g. `rsqgr_on` in Grapple/KEYCONF.txt:25). Every
mod's handlers would still load and tick when switched off, and each "off" must be shown truly off (no events, no
spawns, no menu row). That is 17 new test cases. **[inference]**: worth it only if players ask.

## 5. RS Monsters and the owner's load order

RS Monsters' README says it "needs the UZDXREMA engine fork" (rs_monsters/README.md:10-11); its source folder is
142 MB. Folded in before a QZD port, it would break both the stock-QZD rule and "under 100 MB" **[inference: source
size, not a built pk3]**. The planned re-tiering with Score and GBOVR crosses a pk3 line in every option, because GBOVR
stays separate. It works by names today, so it can keep working by names.

The owner's own order (BD stack, BD22 VR Weapons, Champions, LegenDoom, then the series) is unchanged by any option:
the series pk3s go last in every case.

## 6. Recommendation (opinion)

**Both, with the separate pk3s as the source of truth.** Keep the per-mod folders and the 20 pk3s. Add option B as
one extra release file, `RSQ_Series.pk3`: the 17 stand-alone mods (everything except Gun Bonsai VR and Graveyard),
built by `build_all.py` from the same folders in the same run, so it can never drift from the singles. Gun Bonsai VR
and Graveyard stay separate downloads. Put the combined file on GitHub Releases rather than in git.

Why: the series already behaves as one family at run time, so the combined file adds the one thing separation lacks
(one download, one version) at almost no code cost. And the singles keep what the owner asked to keep: one mod beside
any other pack, a small download, and the stand-alone rule kept honest.

Before it is offered, by the series' own rules: the combined pk3 runs on the owner's load order with no script error
(the `series_check.py gate`, with the combined pk3 in place of the singles), and the menu shows one Radiant Silvergun
row with every page. Until then it is "not yet". It is rig only, not headset-confirmed, until the owner says so.

Top risks:
1. **Combined plus single = the game does not start** (the CVARINFO and class errors above). Name it plainly. Put
   "Use RSQ_Series.pk3 OR the single pk3s, never both" at the top of the README and the release notes.
2. **Not yet shown working.** The rename trick is confirmed in the engine code and in brutal22test6 for MODELDEF and
   SNDINFO. More than one ZSCRIPT/CVARINFO/MENUDEF lump in one archive has not been run on the rig.
3. **One bug stops every mod.** A script error in any of the 17 stops all 17 for players of the combined file.
4. **Quest unknowns:** a 61k-entry, 90 MB archive (load time, memory, Zip64) was not measured on a Quest.
5. **Stand-alone drift.** If most players use the combined file, a hidden hard link between two mods goes unnoticed.
   A solo-load pass per mod (which does not exist today) would catch it.
