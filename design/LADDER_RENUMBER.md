# The colour ladder renumbered by strength (owner, 2026-11-11)

**Code only, not shown.** Owner's order: "no rig test, code only until i say". Nothing here was run, load-checked or
built into a pk3; the code was reviewed by hand and with the repo's static checks (`Miniboss/tools/check_zs.py`: 0 errors;
`tools/series_check.py static`: nothing new).

The tier number IS the strength now. Measured order (Miniboss commit 7c50d118, `design/rigtest_2026-11-10/evidence/MB_TIER2_strength.py`):

| New | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Colour | Common | Green | Blue | Purple | Cyan | Brown | Yellow | FireBlu | Gray | Red | Abyss | Black (boss, EX) | White (boss) |
| Old (CH order) | 1 | 2 | 3 | 4 | 12 | 13 | 5 | 7 | 8 | 6 | 9 | 10 | 11 |

Only the numbers moved: every colour keeps its classes, health, look, boss status and EX roll.

The re-ordered gem files (TI3R, RSYT, RSQMBG) were staged first and went out inside another agent's commit d2ad1ff9
(eye height), pushed before the code that reads them; from d2ad1ff9 until 76980ec3-2850f20c the gems and the numbers
did not match. They match from 743b3f5b on.

## Changed

**RSQ Monsters**
- `zscript/monsters/RS_Retier.zs`: `RS_TierLadder.ClassFor` / `GateFor` (17 families x 13, re-keyed and re-ordered; every
  entry checked against its class's colour by script); new `IsEXName`, `FamilyOfAny`, `TierOfAny` (an EX form takes its
  gate's family and tier); `RS_Retier.Request` / `TierNowOf` / `Swap` use them, so an **EX body can change tier** (the
  Miniboss agent's flag was right: `FamilyOf` returned -1 for every EX class, so "retier" answered 0 and a life lost did
  nothing); `Swap` does nothing when already on the asked tier (an EX is never swapped to its plain class at the same
  tier); the flash's black-for-White test 11 -> 13; `rs_tierof` prints EX tiers; header and console help.
  **Save migration:** `RS_LadderMark` + `RS_RetierHandler.WorldLoaded`: a level loaded from a save (or a hub level
  re-entered) without the mark moves every `RS_ZomTierToken`, `RS_TierStamp` and running `RS_RetierJob` from the old
  numbers once (`OldToNew`), then marks the level. New maps only get the mark.
- Every colour's `RS_Zom.SetTier(self, N)`: 242 literals in 18 family files, renumbered by script and checked against
  each class's colour (0 mismatches; the tier-0 minions and `RS_PinkDemon` 1 unchanged).
- `RS_Roster.zs` `RS_RosterHandler.TierOf` (the per-family caps, colour word -> tier): new numbers; checked against all
  357 ladder class names (old and new give the same colour).
- `RS_ScoreReadout.zs`: "tier" doc; `TierOfName` / `FamilyOf` / `IsEX` / `FamOfType` use the shared EX helpers;
  `SpawnOdds` gate indices (Brown 6, Cyan 5, Abyss 11, FireBlu 8, Gray 9, White->Black 13->12, Black->Red 12->10);
  `SetClassEX` boss tiers 10/11 -> 12/13 (EX on Black, and on White for the Shotgunner / Lost Soul, as before).
- Tier gems: `sprites/monsters/TierIcons/TI3R?0.png` renamed so A..M = tier 1..13 (colour checked per file); the 13
  `RS_ColorTierIconCH<n>` actors keep Colourful Hell's names (spawned by name ~1,440 times) and each points at its own
  colour's frame now (CH5 Yellow -> G, CH6 Red -> J, CH7 FireBlu -> H, CH8 Gray -> I, CH9 Abyss -> K, CH10 Black -> L,
  CH11 White -> M, CH12 Cyan -> E, CH13 Brown -> F).
- Comments with tier numbers in the family files (255 "TIER N -- Colour" / "Colour (tier N)" / "tier-N colour" lines,
  each checked against its colour) and the 17 family headers' ladder lists.
- `MENUDEF.txt` (the old pages with no entry): Extra Challenge Tiers, Boss & Special Forms, Combat Behaviour labels, the
  Tier Legend (rewritten weakest to strongest), the Starting Roster ladder text.
- `CVARINFO.txt`: the caps' ladder comment; `rs_reserve_tier_min/max` comment; `rs_elite_tier_boss_at` default 10 -> 12
  (Black; no reader).
- `TRNSLATE.txt`: a note that `rs_<family>_tNN` are in CH's old order and read by nothing.
- `README.md`: the ladder table, the feature line, Under the hood (caps, table, EX, gems, save move, service), Status row.

**RSQ Miniboss**
- `zscript/rsqmb/fight.zs`: the strength list (`StepOf` / `LadderOf` / `StepText`) removed; the colour bonus adds to
  the ladder numbers (`TOP_TIER` 13, `THRALL_TIER_CAP` 11 Abyss, `FIRST_BOSS_TIER` 12 for the EX roll); `ColourName` /
  `LadderRGB` in the new order; `RetierBy` caps at `TOP_TIER`, so the tier-ups (missed window, life lost, whole map)
  climb in strength. `ApplyFrom`'s start rule ("one above its strongest thrall") now compares strength too.
- `graphics/RSQMBG01-13.png` renamed to the new numbers (the HUD reads `RSQMBG%02d` of the tier).
- `README.md` (the strength table is now the ladder; Status row), `CREDITS.txt` (gem order).

**RSQ Score**
- `zscript/rsscore/rows_roster.zs`: each colour row's `TierNo`; `Rank` (the rarity rank) re-keyed to the new numbers,
  ranks unchanged (checked colour by colour), so Keep the Change, Fresh Paint, Upset and Tier Slayer pay as before;
  header. `README.md`: note and Status row.

**RSQ VisualRewards**
- `pk3/sprites/rsqthp/icons/RSYT?0.png` renamed so A..M = tier 1..13 (the bar shows frame tier-1); `handler.zs` comment;
  `README.md` gem line and Status row.

**RSQ Grenade**
- `zscript/rsqgn/explosions.zs` `RSQGN_Tint.TierRGB`, `TRNSLATE.txt` `RSQGN_T01-13`, `tools/blast_export.py` `TIER_COL`:
  re-ordered to the new numbers, each colour its own tint (Kill Colour now takes the strongest kill's colour).
  `README.md` Status row.

**Series**
- `design/icons/fullset.py` LADDER and `design/icons/B/<n>_<Colour>.png` renamed to the new numbers. Root `README.md`
  pk3 table line.

## Checked and left

- **Gun Bonsai VR** (`GunBonsaiOffhandVR/`): reads no monster tier ("player.level" and "level" are its own). Its Kill
  Rewards live in VisualRewards (`rsqvr/killrewards.zs`): health and the BOSS flag only, no tier.
- **Graveyard**, **SlowMo** (DOWN's top / middle / bottom tiers), **ShieldSaw** (hit tiers by health), **GlowInTheDark**
  (sidedef tiers; colours come from Miniboss's "colour"), **Wheel** (weapon rarity tiers), **QuestSaber**, **FlashFlare**,
  **Whip**, **Grapple**, **Melee**, **TacticalRig**, **DistanceGrab**, **GunCards**, **LaserSight**, **Accessibility**:
  their "tier" is another thing; none reads RSQ Monsters' ladder. Only Score, Miniboss, VisualRewards and Grenade ask
  `RSQMN_RosterService`.
- Miniboss's Bossfight tier (0..4, pick level) and VisualRewards' crown pips: not the ladder.
- Score's MENUDEF roster rows (by colour, no numbers), `Full Spectrum`'s mask (all 13 bits, any order), the colour rows'
  pay; Score's `rs_score_cfgver` (no Score cvar holds a ladder tier).
- **Saved settings:** RSQ Monsters has no cfgver step. `rs_roster_<family>` caps default 1 (Common, same in both orders);
  a cap saved above 1 now caps by strength (README says so). `rs_reserve_tier_min/max` and `rs_elite_tierbump_chance`:
  no reader anywhere. Miniboss, VisualRewards, Grenade: no cvar holds a ladder tier.
- **Inside a save, not migrated:** Miniboss's hub-reset list (`tfOrig`, only used when a hub level is re-entered) and
  Score's per-map Colour Chain / Full Spectrum memory hold the old numbers until the map ends. A Black EX put back by
  the hub reset comes back as the plain Black class (the reset asks for a tier, not a class).
- `RS_MonsterCommands.zs` (not loaded), `RS_MonEvents.zs` (spawns by class name), the CH colour conversions inside the
  monsters (by class name), `EXCLUDED.txt`, `CREDITS.txt`, `LANGUAGE.*`, `TEXTCOLO.txt` (Score ramps, no tier).
- The per-family health list in Monsters' README (by colour name, CH order, no numbers).
- Design mockups keyed to the old numbers on purpose: `VisualRewards/tools/beam_spec/*` (`TIERS`, `tier(n)`),
  `Grenade/tools/barrel_spec/fx_ctx2/*`, `design/icons/icon_set_B.png` (the review sheet). Historical notes and rig
  evidence (`design/rigtest_*`, `design/HANDOFF_ARCADE_2026-11-09.md`, `design/RSMONSTERS_SCORE_GBOVR_STUDY.md`,
  `TestRig/*/evidence*`) record what ran under the old numbers.
- pk3s were not rebuilt.
