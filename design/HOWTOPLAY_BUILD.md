# How To Play: the build (2026-11-27)

The owner's asks are in `design/HOWTOPLAY_HANDOFF.md` and `design/README_PASS_STATUS.md` ("How To Play mockups", "The
Rig's ghost hand"). **Since 2026-11-27 (owner, 11:3x) the page lives in ONE mod, RSQ Controls** (`Controls/`,
RSQ_Controls.pk3), with RSQoopaControls (the series' controller layout): the Options row and a first-launch screen. The
20 other mods carry none of it. The one-copy build is **not compiled**: the copies before it compiled and booted on the
rig only in RSQ Wheel and RSQ Graveyard ("Use RSQoopaControls" below); the page itself never opened there, nothing ran
in a headset. Look at the pictures in `design/howtoplay_preview/` (`tools/howtoplay/preview.py`).

## How it works

- **One page, in RSQ Controls.** `tools/howtoplay/howto_template.zs` is the page. `gen_howtoplay.py` writes it into
  `Controls/zscript/rsqct/howto.zs` (prefix RSQCT) and every tab into `Controls/zscript/rsqct/howto_data.zs`: per series
  mod its tab name (its Options menu name without "RSQ " and brackets), its colour (its Options group: Body, Hands,
  Reach, Game, in RSQ Score's colours), its rows from its README's How to play table, in the Options order, and the
  class that tells the page the mod is loaded (`PROBE`). It still reads all 20 READMEs; `--check` covers them all, and
  fails while any of the 20 mods still carries its own howto files, includes, menus or handler.
- **A tab per loaded mod, found by class name.** `PROBE` is the mod's first MAPINFO event handler named with its own
  prefix (else its first one; `--check` fails when no file of the mod declares it). The page puts the name in a
  `Class<Object>` from a String, which the engine looks up as the page runs and leaves null when no loaded pk3 declares
  it (gzdoom qzd17.3 `src/common/scripting/backend/codegen.cpp:12370-12392`, `NativeNameToClass`). A mod not loaded:
  no tab.
- **RSQ Score's tab is its Glossary,** baked when the page is generated from Score's own `glossary_data.zs` (each
  `Add(...)` line, read as `RSQSC_GlossaryMenu.Add` / `ShortOf` read it, `Score/zscript/rsscore/glossary.zs:58-75`):
  RSQ Controls loads without Score, so it cannot call Score's code. Its six families are the tab's sections (a second
  strip under the tabs, in the family colours), the entries its rows, Bonus and Needs its detail. A change to the
  Glossary makes `--check` fail until the page is regenerated. Score's own "Glossary" row still opens the Glossary.
- **The CONTROLS tab comes first** (owner 11:33): RSQoopaControls as the front README's table picture
  (`design/readme_art/screens/keys_buttons.png`) draws it. Two panels, LEFT CONTROLLER over RIGHT CONTROLLER, columns
  BUTTON / PRESS / DOUBLE PRESS / RIGHT GRIP + PRESS, a dash where nothing is (never "FREE", owner 11:33), and under
  them "OPTIONS > RADIANT SILVERGUN OPTIONS > USE RSQOOPACONTROLS SETS THESE." and the natural crouch line. The rows
  are generated from the ini in the picture's own words: WORD, LEFT and RIGHT are read from
  `design/readme_art/make_controls_table.py` with `ast` (never run, never edited), so the picture and the game say the
  same thing; the generator stops on a command without words, an ini line on neither panel, or "FREE". Left-handed
  (`vr_control_scheme` 10 or more) QuestZDoom swaps the hands (questzdoom `QzDoom_OpenXR.cpp:397-416` hands
  `HandleInput_Default` the left controller as the dominant one, with X / Y as its buttons; the dominant grip is the
  modifier, `VrInputDefault.cpp:51-55`), so the LEFT CONTROLLER panel then shows the main hand's rows, X / Y stand where
  A / B stood and the last column reads LEFT GRIP + PRESS. Fits the 640 x 400 page at the list's font size 1.0 (the
  preview: `howtoplay_controls_tab.png`, `howtoplay_controls_tab_lefthanded.png`).
- **The Body tab** comes second (after CONTROLS) whenever a loaded mod has a row done at a place on the body. A flat figure (boxes, no 3D
  model) with ten places: mouth, each shoulder, chest, belt, each hip, off hand, main hand, both hands. Left / Right walk
  the places; a click on a place picks it. On the right: the place's moves from every loaded mod (name in the mod's
  colour, the mod's tab name in white), and under them the picked move's DO / GET. Places come from words in each
  row's "Do this" (`RULES` in the generator) and a short override list (`PLACE_FIX`); `--report` prints them.
- **Show Me** (RSQ Tactical Rig loaded, on, alive, in VR, and BD22 VR Reloaded's hand model there, or a move to a ring):
  a gold "SHOW ME" row under each body move of the Rig (holster, draw, off-hand draw, grenade spot, cigarette pocket,
  the lips, recenter, saber, second saber, whip, flare, keyring, watch check, ShieldSaw shoulder; and Gun Cards' watch
  check and Miniboss's pulse check rows), on the Rig's tab, the mod's tab and the Body tab. Select (or a click on the
  picked row) closes every menu and the Rig's ghost hand does that move once on your body.
- **Show On My Body** (the Rig as above): first row of each place on the Body tab. It closes the menu and the Rig's
  mirror (mirror.zs) stands in front of you for 10 s with that place lit: its rings at full strength (both chest
  holsters; grenade spot, keyring and pouch for the belt; the hip with the saber / whip / flare spots on that side), the
  lips and the cigarette pocket as rings in the mirror only, the hands as big spheres. Without the Rig: the figure only.
- **The Rig's request, by name** (`TacticalRig/zscript/rsqtr/hooks.zs`, RSQTR_RigService):
  `GetIntUI("ghost.demo", move)` 1 when it can show it now; `GetStringUI("ghost.demo", move)` the network event that
  plays it (`rsqtr_ghostdemo:<move>`); the same pair for `"mirror.show"` and a place. The Rig owns the ghost: ghost.zs
  `DEMO_NAMES`, `Avail` (every live tic, what can play), `Ask`, `Demo`, `LightPlace`. The menu only reads what the Rig
  cached. The holster tip is untouched; it waits while a Show Me plays.
- **Keys**: a row whose "Do this" presses a key from the mod's Keys table or a MENUDEF Control row shows the key bound
  now (or NOT BOUND) in white, and a KEY line in its detail.
- **Rows left out of the tabs** (they stay in the READMEs): typed in the console and the rig's test hook (the rule for
  rows that needed RSQ Accessibility went with that mod, 2026-11-27). Rows that share a name get " - " and the first setting from their Needs.
- Text is upper case, ASCII 32 to 96 (Score's fonts). Without RSQ Score loaded the page uses the engine's big and small
  fonts and its own colours.

## Who owns ReadThisMenu (F1 / Read This!)

RSQ Controls' MENUDEF has `ListMenu "ReadThisMenu" { Class "RSQCT_HowToMenu" }` and `ListMenu "RSQCT_HowTo"`. A ListMenu
descriptor of that name is found before the engine's ReadThisMenu class. With one copy the old warning "Tried to replace
menu 'Readthismenu' with a menu of different type" (two series MENUDEFs) is gone. Series pk3s built before 2026-11-27
still carry their own older copy: whichever page opens hands over on its first tic to the copy with the highest
`PAGEVERSION` it finds through `*_HowToService` (this one: 3). Without RSQ Controls nothing defines it: the engine's
Read This is untouched, and there is no How To Play.

## The tab strip

CONTROLS, BODY and twenty mods do not fit one row. The strip keeps the Glossary's look (same boxes, same white underline
on the current tab, names in their colours, dimmed when not current) and shows **six tabs at a time**; it scrolls to
keep the current tab in view. A gold `<` / `>` at its ends says more tabs lie that way (dim when none). Left / Right
walk every section of every tab in order and wrap (Score's six families and the Body's places are sections). A click
on a tab opens it; on an arrow, the next tab that way. With six tabs or fewer they share the whole width, no arrows.

## Where a new player finds it (the first-run choice)

- **"How To Play" is the first row of Radiant Silvergun Options** (a blank line under it). It is reachable with the
  controllers, unlike F1. RSQ Controls' row (`RSQCTHowToLink`, `Controls/MENUDEF.txt`) takes away any earlier one (an
  older series pk3's copy), so there is one row; the shared Options menu sorts its rows when it opens, so the row moves
  itself back to the top on the menu's first tic. RSQ Controls always defines Radiant Silvergun Options (tools/rsmenu's
  parent block with its prefix, `Controls/zscript/rsqct/rsmenu.zs`), so it is there even with RSQ Controls alone.
- **The first-launch screen** (`RSQCT_FirstRun`): the first time RSQ_Controls.pk3 loads it offers RSQoopaControls
  (below).
- **One line on the first map of a new game, 5 s in**: "HOW TO PLAY: OPTIONS > RADIANT SILVERGUN OPTIONS", as RSQ
  VisualRewards' toast (`RSQVR_Service "toast"`, kind info) when it is loaded, else a plain centre print. Never again
  that game (a later map, a reload, a respawn). RSQ Controls has the handler (`RSQCT_HowToStart`, `Controls/MAPINFO.txt`);
  with an older series pk3's copy loaded too, only the copy whose service sorts first speaks. Why: the player's eyes are on the view at the start, a
  toast is the series' own way of saying small things, and pointing at the Options path once is enough; nothing
  stays on screen and nothing asks to be dismissed.

## Controls: RSQoopaControls / My Own (the row under How To Play)

Owner 2026-11-27 15:50: "i want this mod loaded and the ability to swap to and from my control scheme" (from the menu,
in VR; no console). **One row, not two**: "Controls", drawn as an Option row (the label, then in the value colour the set
that is on now: "RSQoopaControls" or "My Own"), because the series' own pages are Option rows that show their value
(e.g. RSQ SlowMo's "Adrenaline  On"), and one row can never show a stale or contradictory pair. One press, the engine's
yes / no ("Switch to My Own Controls" / "Switch to RSQoopaControls", then "Do you really want to do this?"), Yes switches.
- **Saving his own** (`SaveOwn`): before RSQoopaControls is written (this row or the first-launch Yes, both `UseOurs`),
  the current bind of every key the ini names (normal and double, empty as empty) and the current value of every
  `[CVars]` CVar go into `rsqct_own_controls` (`Controls/CVARINFO.txt`, `nosave` string: CVAR_CONFIG_ONLY, kept in the
  engine's ini, never in a savegame). Only when the set on now is not already RSQoopaControls (`IsOurs`: every ini line
  in force), so switching twice never writes ours over his. Format `v1|B:Key=cmd|D:Key=cmd|C:name=value|`, with `%`,
  `|`, CR, LF in a value as `%25`, `%7C`, `%0D`, `%0A`; the engine's config writer and reader keep such a value as it is
  (`src/common/utility/configfile.cpp:654-730`, `:820-830`).
- **My Own** (`UseOwn` / `RestoreOwn`): every saved line written back with the same `SetBind` / CVar calls (an empty one
  unbinds). With RSQoopaControls on and nothing saved, the press shows a notice ("Nothing of your own is saved yet")
  and changes nothing.
- The row is refreshed every 10 tics while the menu is open (`IsOurs`), so a bind changed in Customize Controls shows.
- **Shown on the rig (2026-11-27, `/home/claude/rigdata/rig2`, QuestZDoom 17.3, freedoom2 MAP01, controller presses
  `qz_rbuttons` / `qz_rstick`, RSQ Controls alone and with BD22 test6 + VoxelPack + VR-Reloaded 3.0rc):** own binds set
  first (Pad_X, Pad_A, double Pad_Y / Pad_A, Home and double Space empty); the first-launch Yes saved them (log
  "RSQoopaControls: your own controls saved: v1|...") and wrote the layout; Controls to My Own, to RSQoopaControls, to My
  Own: the full `bind` / `doublebind` dumps after each My Own equal the ones before the first switch (78 / 3 lines alone,
  88 / 3 with the stack), the ones after each RSQoopaControls equal each other; `rsqct_own_controls` never changed after
  the first save; the first-launch Yes with RSQoopaControls already on saved nothing. With `-config` kept across two
  runs: after a restart the row switched back to My Own and the dumps matched. Frames looked at: the first-launch text,
  "Controls  RSQoopaControls", "Controls  My Own", both prompts, the "Nothing of your own is saved yet" notice. Not in a
  headset.

The rest of this section is how RSQoopaControls itself is written (the class keeps its name, `StdControls`).

The control set's name is **RSQoopaControls** (owner 11:23; it was "RSQ Standard Controls"). The ini keeps its path.

- **Where:** Options > Radiant Silvergun Options, the row right under How To Play. The How To Play row's Ticker puts it
  there once (`OptionMenuItem<P>StdControls`, in the template; the class keeps that name), so no MENUDEF carries it.
- **What it does:** one press, then the engine's own yes / no prompt, worded as `OptionMenuItemSafeCommand` words it
  (the row's name, then "Do you really want to do this?", `$SAFEMESSAGE`; gzdoom qzd17.3
  `wadsrc/static/zscript/engine/ui/menu/optionmenuitems.zs:287-297`, `wadsrc/static/language.0:60`). Yes writes every
  line of `design/controls/rsq_standard_controls.ini`: `[Doom.Bindings]` as normal binds, `[Doom.DoubleBindings]` as
  double binds (a line with nothing after `=` empties that button), and `[CVars]` as settings, each by its own type
  (`vr_crouch_use_button=false`: natural crouch on). No other key or setting is touched.
- **The engine call:** `KeyBindings.SetBind(key, command)` (`wadsrc/static/zscript/engine/ui/menu/menu.zs:36-47`) on the
  globals `Bindings` and `DoubleBindings` (`wadsrc/static/zscript/engine/base.zs:199-201`), as the engine's own
  Customize Controls rows bind. The native (`src/common/scripting/interface/vmnatives.cpp:1083-1098`) is a fatal error
  outside menu code; the yes arrives as `MKEY_MBYes` from the prompt (`ui/menu/messagebox.zs:184`) through the option
  menu to its selected row (`ui/menu/optionmenu.zs:376-378`) inside the menu's event call, which counts as menu code
  (`src/common/menu/menu.cpp:316-326`). An empty command is an empty bind (`src/common/console/c_bind.h:64-68`).
  Key names become codes by the engine's own table: `KeyBindings.NameKeys(k, 0)` is `KeyNames[k]`
  (`src/common/console/c_bind.cpp:228-237`, `:268-282`), the table the ini's names are read with (`GetKeyFromName`,
  `c_bind.cpp:172-191`), for every key below `NUM_KEYS` (`src/common/console/keydef.h:138`). The console's `bind` /
  `doublebind` (`c_bind.cpp:610-618`) would do the same, but a mod's menu may run a console command only through
  `OptionMenuItemCommand`, whose `DoCommand` is private to it (`optionmenuitems.zs:233`).
- **The CVars:** `CVar.FindCVar(name)`, then `SetBool` / `SetInt` / `SetFloat` / `SetString` by its `GetRealType()`
  (`wadsrc/static/zscript/engine/base.zs:685-712`); the natives refuse an engine CVar outside menu code by the same
  `DMenu::InMenu` test (`vmnatives.cpp:947-958`), which the yes passes. The template's comment carries the rest.
- **Generated, never typed:** the template's line `// @STDCONTROLS@` becomes three lists, `BINDS`, `DOUBLEBINDS` and
  `CVARS`, each line as the ini has it (`Key=command`, `name=value`), and `LAYOUT_ID` (below), written by
  `gen_howtoplay.py` (`standard_controls_block`). The generator stops on a section other than the three, a line without
  `=`, a key twice in one section, a quote, or a `[CVars]` line other than `vr_crouch_use_button=false` (the CONTROLS
  tab and the first-launch screen say "natural crouch on"). Change the ini, re-run the generator; `--check` fails while
  the copy is stale.
- **Shown on the rig (2026-11-27, `/home/claude/rigdata/rig` scratch copy of the qzd17.3 rig, freedoom2 MAP01, a
  test-only probe pk3 outside the repo):** RSQ Wheel alone, RSQ Graveyard alone, and the two together compile and boot;
  with Radiant Silvergun Options open the rows read How To Play, Use RSQ Standard Controls (its name then), a blank
  line, then the mods' rows (one such row with two copies loaded); every key name in the ini resolved to the code
  CONTROLS.md gives (Shift 42 ... Pad_Y 451). NOT shown: the prompt and the binds being written (the rig cannot press a
  menu button), and anything in a headset. That was the per-mod build; RSQ Controls' one copy is not compiled.

## The first-launch screen (RSQ Controls)

- **What:** the first time RSQ_Controls.pk3 loads, about a second after the title is up and with no menu open, the
  OptionMenu `RSQCT_FirstRun` (`Controls/MENUDEF.txt`) opens: what RSQoopaControls does, where to see it (How To Play,
  CONTROLS tab) and where to set it later, then two rows. "Yes: use RSQoopaControls" runs the Options row's own
  `ApplyAll` (every bind, double bind and CVar line); "No: keep my buttons" changes nothing. Both close the screen; Back
  counts as No.
- **Once per layout:** the CVar `rsqct_layout_asked` (`Controls/CVARINFO.txt`, a saved user CVar) takes `LAYOUT_ID`
  as the screen opens. `LAYOUT_ID` is a CRC-32 of the ini's lines (not its comments), written by the generator
  (`layout_id`), so any change to a bind, a double bind or a CVar line asks once more; a comment does not.
- **Why a menu:** `KeyBindings.SetBind` is a fatal error unless `DMenu::InMenu` is raised
  (`src/common/scripting/interface/vmnatives.cpp:1083-1098`), and only a menu's input and event calls raise it
  (`src/common/menu/menu.cpp:277-326`, `CallResponder` and `CallMenuEvent`). A row's `Activate` runs inside them (Enter
  through `OptionMenu.MenuEvent`, a click through the menu's input call). `rsqct_layout_asked` is a mod CVar, which ui
  code may set anywhere (`vmnatives.cpp:947-958` checks only engine CVars).
- **The hook:** `RSQCT_FirstRun`, a StaticEventHandler (`Controls/MAPINFO.txt`), in `UiTick`, which the engine calls
  every tic in every game state, the title screen included (`src/g_game.cpp:1429` in `G_Ticker`:
  `primaryLevel->localEventManager->UiTick()`, which calls the static handlers first, `src/events.cpp:640`,
  `:675-678`). After 35 tics, in the title, a title level or a level, with no menu open, it opens the screen with
  `Menu.SetMenu` (`wadsrc/static/zscript/engine/ui/menu/menu.zs:144`).
- Not compiled, not run.

## Regenerate

    python3 tools/howtoplay/gen_howtoplay.py            # after a README's How to play table, the ini, Score's Glossary,
                                                        # the picture's WORD / LEFT / RIGHT or the template changes
    python3 tools/howtoplay/gen_howtoplay.py --check    # stale files, Controls/ not wired, or a mod with its own copy: exit 1
    python3 tools/howtoplay/gen_howtoplay.py --report   # each row's name, places, Show Me and key; each tab's PROBE
    python3 tools/howtoplay/preview.py                  # the pictures in design/howtoplay_preview/

It writes `Controls/zscript/rsqct/howto.zs`, `Controls/zscript/rsqct/howto_data.zs` and `Controls/RSQoopaControls.cfg`.
Edit the template, never the copy. A new series mod: add it to `MODS` in the generator (its README, MENUDEF and
MAPINFO); nothing goes into the mod itself. `--check` says what is missing.

## What a headset check must look at first

1. Zero script errors with the full load order, and with RSQ Controls alone (ZScript 4.10). The least certain lines:
   the String-to-`Class<Object>` probe in `Build`, and the ui-scope `RSQCT_HowToData` arrays read from the handler.
2. The first-launch screen: opens once on the first start, Yes writes the binds (check Customize Controls and the
   ini's `[Doom.DoubleBindings]`), it does not open on the next start; No / Back leave every bind as it was.
3. F1 on a keyboard and the How To Play row: the row is first in Radiant Silvergun Options, once, with Use
   RSQoopaControls under it; the page opens on the CONTROLS tab; a tab only for each loaded mod; the strip scrolls;
   Score's tab shows the six families and the Glossary's entries; the CONTROLS tab left-handed.
4. Show Me: the ghost hand's path for holster / draw / grenade / keyring (to the ring), the cigarette (pocket, then the
   lips), recenter (both hands to the chest), and above all **the watch and pulse turns** (`ghost.zs` Demo: off wrist
   yawed 75 degrees across the body and rolled 90 degrees; the roll's sign is a guess). The off hand's mirrored model.
5. Show On My Body: the mirror appears with Mirror set to Off, stands 10 s, the right rings lit; the hand spheres.
6. The first-run toast: 5 s into a new game, once; is ~1.5 s (VisualRewards' toast hold) long enough to read?
7. Text size in the headset: list 1.35, detail 1.6 shrinking to 1.0 only for the longest rows, Body list 1.2, the
   CONTROLS panels 1.0.

Compile fixes (2026-11-27, found on the rig above; the page had never compiled): ZScript names ignore case, so
`const VERSION` (a keyword) became `PAGEVERSION`, the array `sTop` ("stop", a keyword) `sTopRow`, the local `out` (a
keyword) `res`, the function `RowH()` (the constant `ROWH`) `RowHeight()`, and `AtPlace`'s parameter `places` (the table
`PLACES`) `plist`. Still seen on the rig, not part of this page's code: two series pk3s together log "Tried to replace
menu 'Readthismenu' with a menu of different type" (the second MENUDEF's `ListMenu "ReadThisMenu"`; the first one's
page stays), and RSQ Tactical Rig does not compile (`ghost.zs:194`, `:199`, `:271`: unknown `DEMO_NAMES`, `PLACES`).

Owner 2026-11-27 09:44: the page title is "HOW TO RIP AND TEAR" (title only). The Options row, the new-game toast and
the docs keep "How To Play" so players can find it.
Owner 2026-11-27 09:45 ("use the god damn Doom marine"): the Body tab draws the Doom marine sprite PLAYA1 (flipped: your left on
the left), the place chips stand round him in two columns, each joined by a line to its spot on him. Grey boxes only
when no PLAYA1 sprite exists at all.
