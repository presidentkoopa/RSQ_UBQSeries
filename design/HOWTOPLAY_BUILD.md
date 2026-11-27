# How To Play: the build (2026-11-27)

The owner's asks are in `design/HOWTOPLAY_HANDOFF.md` and `design/README_PASS_STATUS.md` ("How To Play mockups", "The
Rig's ghost hand"). Nothing here has been compiled or run. Look at the pictures in `design/howtoplay_preview/`.

## How it works

- **One page, a tab per loaded mod.** `tools/howtoplay/howto_template.zs` is the page. `gen_howtoplay.py` writes a copy
  into every series mod under its own prefix (`<zs dir>/howto.zs`), as `tools/rsmenu` does for the Options menu, so no
  mod requires another. Each mod also gets `howto_data.zs`: its tab name (its Options menu name without "RSQ " and
  brackets), its rank (the Options order), its colour (its Options group: Body, Hands, Reach, Game, in RSQ Score's
  colours) and its rows, from its README's How to play table.
- **Found by name.** Each copy answers `<P>_HowToService` (`howto.tab`, `howto.rows`, `howto.rank`, `howto.version`).
  The page lists every service whose class name ends in `_HowToService`. A mod not loaded has no service, so no tab.
- **RSQ Score's tab is its Glossary.** Score's data file builds its rows at run time from Score's own
  `glossary_data.zs` (`RSQSC_GlossaryMenu.Build`): its six families are the tab's sections (a second strip under the
  tabs, in the family colours), the entries are its rows, Bonus and Needs its detail. No Glossary entry is copied or
  changed. Score's own "Glossary" row on its options page still opens the Glossary alone.
- **The Body tab** comes first whenever a loaded mod has a row done at a place on the body. A flat figure (boxes, no 3D
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
- **Rows left out of the tabs** (they stay in the READMEs): typed in the console, the rig's test hook, and rows that
  need RSQ Accessibility (being removed). Rows that share a name get " - " and the first setting from their Needs.
- Text is upper case, ASCII 32 to 96 (Score's fonts). Without RSQ Score loaded the page uses the engine's big and small
  fonts and its own colours.

## Who owns ReadThisMenu (F1 / Read This!)

Every series MENUDEF has `ListMenu "ReadThisMenu" { Class "<P>_HowToMenu" }` and `ListMenu "<P>_HowTo"`. A ListMenu
descriptor of that name is found before the engine's ReadThisMenu class; a later definition of a (not protected)
ListMenu replaces an earlier one. **So the last series pk3 loaded owns it, and it does not matter which**: every copy is
the same code and shows every loaded mod's tab. Score no longer claims it with the Glossary. If pk3s from different
builds are mixed, the page that opens hands over on its first tic to the copy with the highest `VERSION` (raise it in
the template when the page changes). With no series mod loaded nothing defines it: the engine's Read This is untouched.

## The tab strip

Twenty mods and the Body tab do not fit one row. The strip keeps the Glossary's look (same boxes, same white underline
on the current tab, names in their colours, dimmed when not current) and shows **six tabs at a time**; it scrolls to
keep the current tab in view. A gold `<` / `>` at its ends says more tabs lie that way (dim when none). Left / Right
walk every section of every tab in order and wrap (Score's six families and the Body's places are sections). A click
on a tab opens it; on an arrow, the next tab that way. With six tabs or fewer they share the whole width, no arrows.

## Where a new player finds it (the first-run choice)

- **"How To Play" is the first row of Radiant Silvergun Options** (a blank line under it). It is reachable with the
  controllers, unlike F1. Each copy's row (`<P>HowToLink`) takes away any earlier one, so there is one row; the shared
  Options menu sorts its rows when it opens, so the row moves itself back to the top on the menu's first tic.
  RSQ PlayLog, which has no row in Radiant Silvergun Options, puts its row in Options and removes it whenever Radiant
  Silvergun Options exists.
- **One line on the first map of a new game, 5 s in**: "HOW TO PLAY: OPTIONS > RADIANT SILVERGUN OPTIONS", as RSQ
  VisualRewards' toast (`RSQVR_Service "toast"`, kind info) when it is loaded, else a plain centre print. Never again
  that game (a later map, a reload, a respawn). Every pk3 has the handler (`<P>_HowToStart`, its own GameInfo block in
  each MAPINFO); only the copy whose service sorts first speaks. Why: the player's eyes are on the view at the start, a
  toast is the series' own way of saying small things, and pointing at the Options path once is enough; nothing
  stays on screen and nothing asks to be dismissed.

## Regenerate

    python3 tools/howtoplay/gen_howtoplay.py            # after a README's How to play table changes, or the template
    python3 tools/howtoplay/gen_howtoplay.py --check    # stale data or a mod not wired: exit 1
    python3 tools/howtoplay/gen_howtoplay.py --report   # each row's name, places, Show Me and key
    python3 tools/howtoplay/preview.py                  # the pictures in design/howtoplay_preview/

Edit the template, never a copy. A new mod: add it to `MODS` in the generator, then the two includes, the MENUDEF block
(copy one) and the GameInfo block; `--check` says what is missing.

## What a headset check must look at first

1. Zero script errors with the full load order, and with each mod alone (the copies are identical; Graveyard compiles
   at ZScript 4.5, Wheel / Saber / Gun Cards at 4.10).
2. F1 on a keyboard and the How To Play row: the row is first in Radiant Silvergun Options, once; the page opens on the
   Body tab; the strip scrolls; Score's tab shows the six families and the Glossary's entries (built with
   `new("RSQSC_GlossaryMenu")` outside a menu: the least certain line of the build).
3. Show Me: the ghost hand's path for holster / draw / grenade / keyring (to the ring), the cigarette (pocket, then the
   lips), recenter (both hands to the chest), and above all **the watch and pulse turns** (`ghost.zs` Demo: off wrist
   yawed 75 degrees across the body and rolled 90 degrees; the roll's sign is a guess). The off hand's mirrored model.
4. Show On My Body: the mirror appears with Mirror set to Off, stands 10 s, the right rings lit; the hand spheres.
5. The first-run toast: 5 s into a new game, once; is ~1.5 s (VisualRewards' toast hold) long enough to read?
6. Text size in the headset: list 1.35, detail 1.6 shrinking to 1.0 only for the longest rows, Body list 1.2.

Owner 2026-11-27 09:44: the page title is "HOW TO RIP AND TEAR" (title only). The Options row, the new-game toast and
the docs keep "How To Play" so players can find it.
