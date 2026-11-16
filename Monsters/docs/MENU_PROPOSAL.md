# RSQ Monsters: the menu, proposed from scratch (2026-11-16)

**Built 2026-11-16** (owner 09:58: "Build it as proposed"), in `MENUDEF.txt`, `RSQ_MonsterMenu.zs` (the RSQMNGroup and
RSQMNDiagRow rows), `RS_Diagnostics.zs` and `RS_Retier.zs` (`rs_retier_all_up`). Shown on the rig, rig only, not
headset-confirmed: `rig_2026-11-16_menu/`. Where the build differs from the tables below, it says so in "As built" at the
end. A place is kept on page 1, after the ColorfulHell rows, for the coming **Second Colour** section
(design/SECOND_COLOUR.md, its own build).

It follows the series' menu pattern (MENU_PASS_BRIEF.md, owner 11-04 19:36): one page with every option, most important
first, plain short labels, On/Off rows first, small groups under short headers, no description lines, no presets; at its
foot the one sub page **Test and Debug** and **Reset All**. Player-facing words: "Boss" is RSQ Miniboss's boss; nothing
says Bossfight, MeatGrinder or any Hackfraud term.

Every setting already exists unless marked **NEW**. Defaults are today's code defaults. **OWNER** marks a call for him.

## Page 1: Radiant Silvergun Options > RSQ Monsters (`RSQMN_Options`)

| # | Row (label) | Kind | Setting | Values (shown text = stored value) | Default |
|---|---|---|---|---|---|
| 1 | Monster Set | Option | `rsq_monster_set` | Vanilla = 0, BD22 + XMVE Tiers = 1, ColorfulHell = 3 | **BD22 + XMVE Tiers** |
| 2 | Painted Colour Art | Option | `rsq_mon_art` | Off = 0, On = 1 | **On** |
| 3 | Tier Icons | Option | `rs_ch_colorblind` | Off = 0, On = 1 | **Off** (OWNER: On?) |
| 4 | Colour Ladder On BD Monsters | Option | `rsq_mon_bdtier` | Off = 0, On = 1 | **On** |
| 5 | On Tier Change | Option | `rsq_mon_retier_health` | Keep Health Share = 0, Full Health If Instant = 1, Always Full Health = 2 | **Full Health If Instant** |
| | *Boss* | header | | | |
| 6 | Boss From | Option | `rsq_mon_bf_boss` | Same As Monster Set = 0, ColorfulHell = 1 | **ColorfulHell** |
| 7 | Thralls From | Option | `rsq_mon_bf_thralls` | Same As Boss = 0, ColorfulHell = 1, Map's Own Monsters = 4 | **Same As Boss** |
| | *ColorfulHell* | header | | (OWNER: these rows on the page, on Test and Debug, or not in the menu at all) | |
| 8 | Extra Colours | Option | **NEW** `rsq_mon_ch_extras` (one row standing for the five gates below; the code would set `rs_ch_cyan`, `rs_ch_brown`, `rs_ch_abyss`, `rs_ch_fireblu`, `rs_ch_gray` from it) | Off = 0, On = 1, Half = 2 | **Off** (Colourful Hell's default) |
| 9 | Black Boss | Option | `rs_ch_blackboss` | Off = 0, On = 1 | **On** |
| 10 | White Boss | Option | `rs_ch_whiteboss` | Off = 0, On = 1 | **On** |
| 11 | EX Bosses | Option | `rs_ch_exboss` | Never = 4, Rare = 1 (24 in 256), Half = 2, Always = 3 | **Rare** |
| 12 | Drops | Option | **NEW** `rsq_mon_ch_drops` (one row for the seven drop settings: Standard sets each to Colourful Hell's 1, Scarce / Generous / None their CH values) | Standard = 0, Scarce = 1, Generous = 2, None = 3 | **Standard** |
| | | spacer | | | |
| 13 | Test and Debug | Submenu | `RSQMN_Test` | | |
| 14 | Reset All | RSQMNResetAll | every setting a row names on both pages | "Reset all RSQ Monsters settings?" | |

Gone from the page (moved to Test and Debug): **World Tier (test)** (it stands in for the gun turn-ins; a test row,
not a player option) and its two description lines; the three description lines under Painted Colour Art.

## Page 2: RSQ Monsters: Test and Debug (`RSQMN_Test`)

| # | Row (label) | Kind | Setting / command | Values | Default |
|---|---|---|---|---|---|
| | *World* | header | | | |
| 1 | World Tier | Slider | `rsq_mon_worldtier` | 1 to 20, step 1 | **1** |
| 2 | God Mode | Command | `god` | | |
| | *Monster Diagnostics* | header | (`docs/MONSTER_DIAGNOSTICS.md`) | | |
| 3 | Family | Option | **NEW** `rsq_mon_dbg_family` | the 17 families: Zombieman = 0 ... Spider Mastermind = 16 (the ladder table's order, or the owner's) | **Chaingunner** |
| 4 | Spawn Hostile | Option | `rs_mon_dbg_hostile` | Off = 0, On = 1 | **Off** |
| 5-18 | C0001 ... X0001 | Command x 14 | `netevent rs_diag_spawn <row>` (**NEW** name for `rs_cg_spawn`, any family) | the family's Common, ten colours, two bosses and EX, labelled with their Colourful Hell names and codes; a family with no EX shows 13 rows | |
| 19 | Spawn All | Command | `netevent rs_diag_line` | | |
| 20 | Remove Them All | Command | `netevent rs_diag_clear` | | |
| 21 | DIAG | Command | `netevent rs_diag_diag` (console: live class, name, health, tier, code) | | |
| 22 | WAKE | Command | `netevent rs_diag_wake` | | |
| | *Aimed Monster* | header | | | |
| 23 | What Is It | Command | `netevent rs_tierof` | | |
| 24 | One Tier Up | Command | `netevent rs_retier_up` | | |
| 25 | Whole Map One Tier Up | Command | **NEW** `netevent rs_retier_all_up` | | |
| | *ColorfulHell Spawn Caps* | header | | 1 Common .. 13 White, by strength | |
| 26 | Caps On | Option | `rs_roster_enable` | Off = 0, On = 1 | **On** |
| 27-43 | Zombieman ... Spider Mastermind | Slider x 17 | `rs_roster_zombieman` ... `rs_roster_mastermind` | 1 to 13 | **1** each |
| | *ColorfulHell Switches* | header | (Colourful Hell's own, its values) | | |
| 44 | Abyss Shot Markers | Option | `rs_ch_abyssmark` | Off = 0, On = 1 | **Off** |
| 45 | Cyan Shotgunner Dodges | Option | `rs_ch_cyanbounce` | On = 0, Off = 1 | **On** |
| 46 | Green Knight Leads Shots | Option | `rs_ch_intercept` | On = 0, Off = 1 | **On** |
| 47 | Red Baron Form | Option | `rs_ch_nerfredboss` | Power Baron = 1, the other form = 0 | **Power Baron** |
| 48 | Orange Revenant Variant | Option | `rs_ch_yellowrev` | 0, 1, 2 | **0** |
| 49 | Cyberdemon Rocket Normal Damage | Option | `rs_ch_rawket` | Off = 0, On = 1 | **On** |
| 50-56 | Health / Backpack / Ammo / Extra / Weapon / Powerup / Armour Drops | Option x 7 | `rs_ch_healthdrops` ... `rs_ch_armordrops` | each its Colourful Hell values (CVARINFO) | **1** each |
| | *Logs* | header | | | |
| 57 | Tier Log | Option | `rsq_mon_bdtier_debug` | Off = 0, On = 1 | **Off** |
| 58 | Painted Art Log | Option | `rsq_mon_art_debug` | Off = 0, On = 1 | **Off** |

## What it would cost to build

New settings: `rsq_mon_ch_extras`, `rsq_mon_ch_drops` (page 1, only if the owner wants one row each instead of the
raw gates), `rsq_mon_dbg_family`; new netevents `rs_diag_*` (generalising RS_Diagnostics.zs from the Chaingunner to any
family through `RS_TierLadder`) and `rs_retier_all_up`. Everything else exists. No setting changes its default.

## As built (2026-11-16)

- **X0001 on a family with no EX** is greyed and cannot be picked, with "(none in this family)": QuestZDoom 17.3's menus
  cannot hide a row.
- **Reset All** also resets the five extra-colour gates (`rs_ch_cyan` ... `rs_ch_gray`), which have no row of their own,
  so a reset leaves them matching Extra Colours.
- **Extra Colours: Half** puts Cyan, Brown and Abyss on half; FireBlu and Gray have no half in Colourful Hell, so Half
  leaves them on. **Drops: Generous** leaves the four drop settings that have no generous value at standard.
- **Red Baron Form** reads Power Baron (1) / Red Rage Baron (0), the two classes' own names.
- **Old saved values**: a Monster Set, Boss From or Thralls From saved by an older version as 2 or 3 (MeatGrinder,
  Mixed; already played as ColorfulHell) is written as ColorfulHell when a map loads, so its row shows a name, not
  "Unknown" (the owner's saved Thralls From was 2). Nothing plays differently.
- Family order: RS_TierLadder's (Chaingunner first); the owner did not ask otherwise.

## Questions in it (OWNER, answered 11-16 09:58: build it; Tier Icons stay Off)

1. Tier Icons: on by default now that the icons are back?
2. ColorfulHell's switches on the main page (rows 8-12), or all on Test and Debug, or not in the menu?
3. Diagnostics family order: the ladder table's (Chaingunner first, as `RS_TierLadder` numbers them) or Doom's
   (Zombieman first)?
