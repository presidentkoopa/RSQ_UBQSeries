# RSQ Miniboss: cleanup audit (2026-11-12)

The owner asked to "clean up the whole thing", and earlier said we built "three redundant systems that I will never use".
This is an audit only. **Nothing has been deleted.** The owner decides what goes.

Every system, option and code path in `Miniboss/` was read (zscript/rsqmb/*.zs, CVARINFO.txt, MENUDEF.txt, README.md,
docs/). Each one is checked against **the owner's definition** of a miniboss encounter, copied here unchanged:

> The meter fills. The off-hand inner-wrist Start Fight card plus Use calls it in. A HUD bar appears where Be Quick or Be
> Dead is, and grows from a sliver. The thralls (3-5, each a boosted legendary champion, each a different Champion colour)
> land one by one on beams V1-V3 at random, and their bars appear in turn in their Champion colours. The miniboss (a
> boosted legendary champion that takes the thralls' powers, cap five, plus its own) lands on beam V4. The whole arrival
> is 5 seconds, with the LED clock counting down from the bar's first frame to the fight. GUARD shows in grey on the
> greyed bar while thralls live. Nobody can be hurt and nobody attacks during the charge. Then the fight. GUARD shakes when
> the guarded miniboss is hit. Thralls drop nothing. The miniboss drops a legendary weapon (50/30/15/5) and refills
> cigarettes. "RSQ Monsters exists only to fuel miniboss monsters right now." Minibosses and thralls arrive already risen.

Line numbers are for the files as of 2026-11-12 evening (after the tier-swap carry, `carry.zs`).

Each item gets one of these verdicts:
- **DEFINITION**: part of the definition. Keep it.
- **FIGHT**: the fight's own rules ("then the fight"), built with the owner in the 11-09 rework. Not named in the
  definition, but it is the fight. Keep it unless the owner says otherwise.
- **EXTRA**: works and is used, but is not in the definition. The owner asked for most of these at some point. Keeping
  or cutting each one is the owner's call.
- **REDUNDANT**: a second way of doing something the definition already does another way.
- **LEGACY**: from before the rework or the miniboss-fight design, and still in the code.
- **DEAD**: never runs.

---

## 1. Top recommendations (short)

1. **Cut the dead old HUD stack** (`hud.zs` 284-525, `DrawStack` and its helpers). Nothing calls it. No risk.
2. **The "three redundant systems".** This is my reading; the owner said it without naming them. They are the three
   ways a miniboss turns up *other than* the wrist card:
   - (a) **Watch check + Use** call-in, with its own copy of the gesture reader and hand sync.
   - (b) **Arrives By Itself**: the fight comes 60 s after the meter is full, with all its guardrails and the "No
     Miniboss: ..." wait line.
   - (c) **Classic Pick at Level Load**, the original Minibosses! way.

   The definition has one way in, the off-hand card plus Use. Cutting (a), (b) and (c) removes about 900 lines and 17 menu
   rows.
3. **Decide the second drop.** Miniboss drops its own gun or power-up when the miniboss dies (`bossfight.zs` 1328-1389).
   The definition's drop is a legendary weapon at 50/30/15/5, and that is made by BD22 VR's RSLD
   (`rsq_bd_vr_reloaded/src/zscript/rsld/handler.zs` 807-880, which asks RSQMB_Service "bossfight", "tier", "wasboss").
   So two drops fall today. Cut Miniboss's own.
4. **Decide the extras one by one** (section 3): greed and rage, Graves Rise, the room glow and heartbeat, the
   Minibosses! tethers and flames, the "TARGET!/GUARD!" words over the monsters and the grey Xs, the music, the
   "treat it as a boss" rows. None of them is in the definition.
5. **Fix the definition gaps found** (section 5). These are not cuts. The thrall count slider allows 1-8 against the
   definition's 3-5, and nothing here checks that thralls "drop nothing".

---

## 2. What the definition needs (keep)

| System | Where | Verdict |
|---|---|---|
| The meter: fill from kills, chains, Score style, Gun Bonsai XP, movement; Meter Speed; Fills From | `bossfight.zs` 49-68 (RSQMB_Meter), 201-220 (Fill/Ready), 265-282 (BfKill), 283-365 (BfTick fill part), 366-381 (GbStep); CVARINFO `rsqmb_bf_speed`, `rsqmb_bf_from`, `rsqmb_bf_style`, `rsqmb_bf_xp` | DEFINITION ("the meter fills") |
| The meter on the HUD under Score (red, then gold and beating) | `hud.zs` 1-282 (MeterShown, MeterRect, SkullRect, RenderOverlay meter part); `rsqmb_bf_hud`, `rsqmb_bf_hud_size` | DEFINITION (the definition does not say where the meter is drawn; this is the only meter) |
| Off-hand inner-wrist Start Fight card + Use | `bossfight.zs` 418-512 (WristCard, InnerDot, GazeOff), 514-536 (CallIn card branch), 1401-1418 (RSQMB_WQuad), MODELDEF.txt, graphics RSQMBWC0/1; `rsqmb_wristcard` | DEFINITION. Its header comment at 418-430 still says "either wrist"; the code is off-hand only (463, owner 15:54). Fix the comment |
| The card skips the guardrails | `bossfight.zs` 537-558 (TryArrive `m.force`) | DEFINITION |
| Picking types from the map, the spot in view, the landing | `bossfight.zs` 144-186 (BfScan), 624-656 (Tier), 659-893 (PlanArrival, Fits, LooseSpot), 894-944 (StartArrival), 986-1068 (ArrivalStep, ArrivalFailed), 1080-1198 (Land, BeamNow), 1244-1307 (Hold, Reveal, Wake) | DEFINITION |
| Beams: thralls V1-V3 at random, the miniboss V4, in the Champion colour | `bossfight.zs` 1166-1198, the `arrKind` line in Land | DEFINITION |
| Every monster a real Champion (forced roll), every thrall a different colour (reroll) | `bossfight.zs` 1191-1214 (ChampForce, `rsqmb_champ_was`), 1266-1292 (RerollThrall) | DEFINITION |
| Legendary (LegenDoom) and risen | `bossfight.zs` 1216-1236 (Boost), `handler.zs` 274-324 (Bind), `boss.zs` 60-97 (RiseOne/RiseRestore) | DEFINITION |
| Boosted: light, full-bright, 1.25x miniboss, faster and keener | `bossfight.zs` 1216-1243 (Boost, Aggressive) | DEFINITION ("boosted") |
| Inherited powers (cap 5) and losing each with its thrall | `handler.zs` 325-432 (Inherit, PowerCap, LifeBonusPreview), `boss.zs` StripPowers; `rsqmb_inherit`, `rsqmb_inherit_max` | DEFINITION ("absorbing the thralls' powers, cap five"). Note: `rsqmb_inherit` can switch it off, and the definition has no switch |
| The 5-second arrival and the charge (dormant + invulnerable) | `bossfight.zs` 113-120 (ARRIVE_TOTAL), `boss.zs` 32-59, 99-112 (ChargeStart/End) | DEFINITION |
| The miniboss bar where Be Quick or Be Dead is: sliver, thrall bars in Champion colours, GUARD grey, GUARD shake, LED clock | `bossbar.zs` (all), `fight.zs` GuardHit's `guardHitTic` line | DEFINITION |
| A tier swap keeps the boosted legendary champion (new, 2026-11-12) | `carry.zs`, `fight.zs` 260-416, `boss.zs` Reborn | DEFINITION ("RSQ Monsters exists only to fuel miniboss monsters") |
| Service for other mods (BD22 VR's legendary drop reads "bossfight", "tier", "wasboss"; Score, VisualRewards and others read the rest) | `service.zs` | DEFINITION (the definition's drop depends on it) |
| Miniboss From / Thralls From, the colour bonus | `fight.zs` 513-670 (ApplyFrom etc.) | EXTRA, but it is "RSQ Monsters fuels minibosses". Keep |

---

## 3. Every other system: what it is and what cutting it would mean

### 3.1 The three call-in ways that are not the card ("three redundant systems", my reading)

| # | System | Where | Verdict | What cutting removes | Risk |
|---|---|---|---|---|---|
| a | **Watch check + Use** call-in | `bossfight.zs` 382-417 (WatchCheck, CallInput), the `CallInput` line in BfTick (343), `CallIn` non-card branch 529-535; **gestcopy.zs** (all 307 lines: RSQMB_GPose, RSQMB_GCopy, RSQMB_GCopyService); **handsync.zs** (all 160 lines: RSQMB_HandSync, used only by gestcopy.zs 183); MAPINFO's `RSQMB_HandSync`, `RSQMB_GCopy`; `rsqmb_bf_callin` + its row "Call It In: Watch Check + Use" | REDUNDANT (the card is the definition's call-in). README 11-12: "current call in method does not work" (owner 05:06, quoted at `bossfight.zs` 415) | ~500 lines, 2 event handlers, 1 menu row. **Keep** `RSQMB_GPose.IsLeft` (used by the card, `bossfight.zs` 440 and 490): move those 2 lines into bossfight.zs first | Low. RSQ Tactical Rig asks Miniboss "callin" so the watch check's Use press is not taken by the gun (README "Plays well with"). Check that `RSQMB_Service "callin"` still means "the card can call now" after the cut |
| b | **Arrives By Itself** (60 s after full) and its guardrails | `bossfight.zs` 347-364 (due by `rsqmb_bf_auto`), 566-623 (Guard, Waits: Too Early, Map Limit, Cooldown, Low Health, Near Exit, Too Busy), 565 (IgnoreRestrictions); the wait line `hud.zs` 115-150 (MeterBottom's wait part, WaitLine); cvars `rsqmb_bf_auto`, `rsqmb_bf_first`, `rsqmb_bf_cooldown`, `rsqmb_bf_cap`, `rsqmb_bf_minhp`, `rsqmb_bf_busy`, `rsqmb_bf_exit`, `rsqmb_bf_ignore`; 9 menu rows | REDUNDANT with the card. The card already skips every guardrail (`bossfight.zs` 539-546) | ~150 lines, 8 cvars, 9 rows, the README "When it won't come" paragraph. Keep "No Monsters" and "No Room" (the card can still hit them) as debug lines | Low. If the owner wants a full meter to still come by itself one day, it goes. `rsqmb_bf_cap` and the cooldown also limit how often the card can be used: today they do not (the card skips them). No change for the card |
| c | **Classic Pick at Level Load** (Minibosses!' original) | `handler.zs` 5-12 (header), 145-149 (Tick2 pick), 178-272 (Eligible, Choose, Choose2, TooClose, PickThralls), 630-643 (`rsqmb_choose` netevent); `hud.zs` 316-331 (StackBoss classic branch); `RSQMB_Boss.called` false path (`fight.zs` 147, `boss.zs` Rebody `if (called)`); cvars `rsqmb_classic`, `rsqmb_per_map`, `rsqmb_map_chance`, `rsqmb_radius`; 4 menu rows ("Classic" block, "Thrall Range"); README "The classic pick" (316-328) | LEGACY (off by default since 11-05; the definition has only called-in fights) | ~140 lines, 4 cvars, 4 rows, a README section and its picture. `Bind` (`handler.zs` 274-324) **stays**: the miniboss fight binds through it | Low. Score's "Miniboss" row at 1x (a miniboss in the map, `handler.zs` BossDied) only happens through the classic pick. It becomes unused, not broken |

### 3.2 Dead code

| System | Where | Verdict | What cutting removes | Risk |
|---|---|---|---|---|
| **The old fight HUD stack** (thrall row, window bar, skull bar, life bars under Score) | `hud.zs` 284-525: StackParts 343, StackRows 357, StackRect 371, Box, Bar, RGBc, **DrawStack 398** | DEAD: `RenderOverlay` calls `DrawBossBar` instead (`hud.zs` 175); nothing calls DrawStack or StackRect | ~240 lines. Keep `StackBoss` and `StackShown` (used by the bar and MeterBottom) | None. README pictures `classic_pick_hud_stack.jpg` and the 11-10 mockups show this stack: drop or relabel them |
| `arrBeamSet` | `bossfight.zs` 131 | DEAD (the V1/V3 vs V2/V4 sets were replaced by "V4 always, V1-V3 at random") | 1 field | None (a saved field: old saves just drop it) |
| Shared menu pieces not used by this page: presets, Gun Bonsai gates | `rsmenu.zs` 161-388 (OptionMenuItemRSQMBPreset, RSQMBGbLine, RSQMB_GbGate, RSQMBGbOption, RSQMBGbSlider) | DEAD in this pack (MENUDEF has no such rows; owner 11-04: no presets) | ~230 lines. The file is generated by `tools/rsmenu` for every pack: cut it in the generator or leave it | Low. Hand-editing a generated file drifts from the series |
| Removed cvars still named in comments | CVARINFO 33-35 (`rsqmb_shield`, `rsqmb_invuln_bonus`, `rsqmb_revive`, `rsqmb_slow*`) | LEGACY notes (revive and alternate shields already gone in the 11-09 rework) | 3 comment lines | None |

### 3.3 Extras: used, not in the definition (owner's call each)

| System | Where | Verdict | What cutting removes | Risk |
|---|---|---|---|---|
| **Greed / rage** (hit it while guarded, a thrall still stands later: every monster on the map twice as fast) | `handler.zs` 533-618 (NoteGreed, Enrage, RageOne, EndRage, RestoreAll, RageFX), 163-175 (Tick2 greed part), the RageOne calls in WorldThingSpawned/Revived; `items.zs` 123-154 (RSQMB_Rage); `boss.zs` NoteStruck; `rsqmb_greed`, `rsqmb_rage_speed`; 2 rows; README "Greed" | EXTRA (owner's 11-03 rule, before the definition) | ~130 lines, 2 cvars, 2 rows | Medium. RSQ Score reads "enraged"/"greed" for its **Rage Quit** and **Riot Control** rows (README "Plays well with"). Those rows would never fire |
| **Graves Rise** (Legion of Bones tombstones wake) | `bossfight.zs` 945-976 (GySvc, Graves), the Graves call in ArrivalStep (1031), HeartBeat's candle part 977-985; `rsqmb_bf_graves*` (3 cvars, 3 rows); README "Graves Rise" | EXTRA (off by default) | ~45 lines, 3 cvars, 3 rows | Low |
| **The room's glow** (cold grey shield, gold window, red life lost, its colour one-on-one, the red heartbeat while full, the landing in the dark, the death wave and colour re-roll) | `fight.zs` 439-463 (RoomGlow), 129-149 (re-roll in FightTick), 466-472 (FightDeath wave); `bossfight.zs` 221-257 (GdService, Glow), 334-342 (heartbeat), 977-985 (HeartBeat), the dark-landing ask in StartArrival; `rsqmb_bf_dark`; 1 row | EXTRA (RSQ Glow In The Dark) | ~90 lines, 1 cvar, 1 row | Low. Glow In The Dark's own "Miniboss Tint" rows are separate and stay |
| **Minibosses! effects**: tethers (30 beads a thrall), invulnerability flames, breaking bursts, teleport fog when no beams, the particle fallback | `fx.zs` (all 357 lines), `boss.zs` 505-585 (Mid, P, Burst, Shatter, FX particle fallback), `fight.zs` 474-481 (FxLink), the FxBreak/FxLifeLost/FxBossDied/FxInvulEnd calls; `rsqmb_fx`, `rsqmb_fx_density`, `rsqmb_fx_range`; 3 rows | EXTRA (the original mod's look, owner 11-05 "yes, the OG stuff") | ~500 lines, 3 cvars, 3 rows | Medium. The teleport fog is the only landing effect when RSQ VisualRewards is missing. The tethers show which thrall feeds the miniboss: nothing else in the definition does |
| **Words over the monsters** ("TARGET!" over each thrall, "GUARD!" over the miniboss) and the **grey Xs** | `fight.zs` 56-66 (Word helpers), 417-437 (WordsStep), 483-510 (GuardHit's word and X part; **keep** its `guardHitTic` line, which shakes the HUD's GUARD); `items.zs` 82-112 (RSQMB_XFx) | EXTRA. The definition puts GUARD on the HUD bar. Owner 11-12 14:11 found them "way too big, it's all I can see"; they were made smaller | ~90 lines | Low |
| **Miniboss's own drop** (a gun you don't have, else a power-up) | `bossfight.zs` 1328-1389 (BfPayoff's Drop, Drop) | REDUNDANT with the definition's drop (BD22 VR's RSLD legendary weapon, see recommendation 3) | ~45 lines | Low. Check first that RSLD's drop is on (`rsld_bossfight_only`) on the owner's load order |
| **Music** for the fight | `bossfight.zs` 1069-1079 (SceneMusic); `rsqmb_bf_music`; 1 row | EXTRA | ~12 lines, 1 cvar, 1 row | Low |
| **Landing slow motion** (RSQ SlowMo, 4 s at its slowest) and the window's slow motion | StartArrival's SlowMo ask; `handler.zs` Tick2 `rsm_pulse` (150-161); `rsqmb_bf_slow`, `rsqmb_bf_slowest`, `rsqmb_slow_depth`; 3 rows | EXTRA | small | Low. The definition's 5-second LED count was built to match the slow motion bars |
| **"Other Mods Treat It as a Boss"** rows: Boss Kill Rewards, Legendary Boss Health, Can't Be Yanked, Can't Be Headlocked, Can't Be Morphed, Map-wide Roar | `boss.zs` 433-475 (Flags, LogFlags, LDHealthDone), `handler.zs` 433-475 (LDBossHealth); `service.zs` "bossfor"; 6 cvars, 6 rows | EXTRA (owner 11-03). Roar and Morphed are off by default | Roar + Morphed: ~40 lines, 2 rows | Low for Roar and Morphed. The other four are read by other mods (VisualRewards, Grapple, Whip, Melee, Gun Bonsai, ShieldSaw): keep |
| **Tier From** "Set" (half the Gun Bonsai level + Score points per tier + half the fights won) | `bossfight.zs` 624-656 (Tier), `rsqmb_bf_tier_score`, the "Set" choice of `rsqmb_bf_tier_from`; RSQMB_Meter `beaten` | LEGACY (the "old sum", README; default is Whichever Is Larger) | ~10 lines, 1 cvar, 1 row, 1 menu choice | Low |
| **Lives and Tier Up Each Life** | `boss.zs` LoseLife, `rsqmb_lives`, `rsqmb_tier_life`, `rsqmb_invuln` | FIGHT (the definition does not say how many bars it has) | - | Keep |
| **Segments, window, tier-up on a miss, Tier-Up Hits the Whole Map** | `fight.zs` 151-258, `boss.zs` segment fields, `items.zs` RSQMB_Ward; `rsqmb_tier_mapwide` | FIGHT | - | Keep. Note: the map-wide tier-up is why map monsters get swapped at all |
| **Score awards** (Thrall Slow Kill, Miniboss) | `fight.zs` SegBroken, `handler.zs` Award; `rsqmb_score` | EXTRA (Score's rows) | - | Keep (other mods read it) |
| **Champion colour token fallback** (a Yellow/White/DarkGreen/Cyan token by name when Champions would not make one) | `fight.zs` 116-126 (ChampionFallback), its calls in ArrivalStep | LEGACY safety net: with the forced roll and the reroll, every landed monster is a real Champion (README run `force1`) | ~12 lines | Low. It still matters if Champions' cvar cannot be set |
| The particle FX fallback when IWAD sprites are missing | `boss.zs` 505-585 | LEGACY safety net | goes with the effects above | Low |
| `rsqmb_legend_thralls` (Legendary Thralls off: plain +50% health) | `bossfight.zs` 1216-1236, `handler.zs` Bind | Off contradicts the definition ("each a boosted legendary champion") | the off path, 1 row | Low |
| `rsqmb_inherit` off | `handler.zs` Inherit | Off contradicts the definition | 1 row | Low |
| `rsqmb_enabled` ("Minibosses" on/off) | everywhere (BfOn) | Keep: the series' standard master switch | - | - |
| Debug log, `rsqmb_state` / `rsqmb_fill` / `rsqmb_callin` console doors | handler.zs NetworkProcess, PrintState; bossfight.zs BfState | Test tools | - | Keep |

### 3.4 Wording

- The code, CVARINFO comments and the **debug console lines** still say "Bossfight" ("RSQMB BOSSFIGHT ARRIVING",
  "BOSSFIGHT CALLED IN"). With Debug Log on, the owner sees them. Renaming the strings is low-risk. The service request
  names (`"bossfight"`, `"bossfights"`) are read by BD22 VR's RSLD and must stay, or change in both places at once.

---

## 4. Proposed cut list, in order

| Step | Cut | Removes | Risk | Depends on |
|---|---|---|---|---|
| 1 | Old HUD stack (`hud.zs` 284-525 minus StackBoss/StackShown), `arrBeamSet`, dead CVARINFO notes | ~245 lines | None | - |
| 2 | Watch check + Use call-in, gestcopy.zs, handsync.zs, `rsqmb_bf_callin` | ~500 lines, 2 handlers, 1 row | Low (check Tactical Rig's "callin" read) | Move `RSQMB_GPose.IsLeft` into bossfight.zs first |
| 3 | Arrives By Itself and the guardrails, the wait line, Ignore Spawn Restrictions | ~150 lines, 8 cvars, 9 rows | Low | Step 2 (after it, only the card calls a fight in) |
| 4 | Classic Pick at Level Load | ~140 lines, 4 cvars, 4 rows, README section | Low | - |
| 5 | Miniboss's own gun/power-up drop | ~45 lines | Low | Confirm RSLD's legendary drop on the owner's load order |
| 6 | Each extra in 3.3 the owner does not want (greed, Graves Rise, glow, tethers and flames, words and Xs, music, slow motion, Roar, Morphed, Tier From "Set", the off positions of Legendary Thralls and Inherit Powers) | owner's pick | see the table | Greed: Score's Rage Quit / Riot Control rows |

After steps 1-5 the menu would keep: Minibosses, Meter Speed, Fills From, Inner-Wrist Card, Effects (if kept), Thralls,
Lives, Tier From, the Rules block and the boss rows. Test and Debug would keep the numbers that are still used.

Each step needs: build, then a rig run on the owner's load order with no new script errors, before it is called done
(project rule: working means shown working).

---

## 5. Gaps against the definition (not cuts; found while auditing)

- **Thralls "3-5"**: the Thralls slider is 1-8, default 3, and the pick level adds one from level 3
  (`rsqmb_thralls`, MENUDEF "Thralls"). Rig runs bound 3 and 5. Nothing holds it to 3-5.
- **"Thralls drop nothing"**: nothing in Miniboss stops a thrall's drops. Thralls are LegenDoom legendaries, and
  LegenDoom tosses a legendary drop when one dies (LEGENDMON.acs LDMonsterInit). BD22 VR's RSLD tells thralls from the
  miniboss (`deathBoss`, "wasboss"). Whether thralls drop nothing on the owner's load order has not been checked here.
- **"Refills cigarettes"**: done by RSQ Tactical Rig (README "Plays well with"), not by Miniboss. Not checked here.
- **The inner-wrist card's header comment** (`bossfight.zs` 418-430) still says "either wrist"; the code is off-hand only.
- **Tier swaps** now keep the Champion (this session, `carry.zs`). Not shown yet: a hybrid or mutated Champion carried,
  Champions' Dormant option on, and a save loaded in the tick between the old body's end and the new body's spawn.
