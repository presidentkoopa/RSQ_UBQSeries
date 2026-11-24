# The series' menu standard (owner 2026-11-24 16:42)

> "the bd22 options menu used to be the standard but it got filled with all sorts of 'if rsq is detected' bullshit. and
> tons of menus have too wordy choices instead of the on / off standard bd22 had, simplicity. the test and debug can be
> for other things if people need more advanced options"

Brutal Doom 22's own options menu is the model: short rows, On / Off, nothing to read.

## The front page: what a player changes

- **A row is a real choice a player would make.** On/off for a feature, which hand, how strong or how big in a few
  steps. Tuning numbers, thresholds, timings, internal switches and anything only a tester changes go to Test and Debug.
- **Labels are short:** 1 to 4 words, Title Case, no punctuation, no units in prose (a unit in brackets is fine:
  "Reach (m)").
- **On / Off for every two-way choice** (`OptionValue "OnOff"`). A choice with more values only when there are really
  more than two, each value one or two words ("Main Hand", "Off Hand", "Both").
- **No prose.** No StaticText that explains, warns or says what another mod does. Allowed: a section header of 1 to 3
  words (`StaticText "Throwing", 1`) and a blank line between sections.
- **No "if RSQ X is detected / needs RSQ X / with RSQ X loaded" text, anywhere.** A row about another mod either works
  (the mod is loaded) or does nothing; it does not say so in the menu. If a row only matters with another mod and is not
  a common choice, it goes to Test and Debug.
- **Few sections, few rows.** Aim for under 15 rows on the front page of a mod. Order: the master switch, then the
  most-used choices, then the rest.
- **Sliders on the front page** only for something a player tunes by feel (a size, a volume, a strength); every other
  slider goes to Test and Debug.

## Test and Debug: everything else

- The front page's one sub menu stays **"Test and Debug"** (tools/rsmenu/menutool.py checks this). Every row that leaves
  the front page goes there, grouped under short headers. Nothing is lost: every cvar that had a row keeps one.
- The same rules for labels apply there (short, On / Off), but it may be long.

## Tooltips (later)

Above every row, keep or write ONE comment line `// tip: <what it does, one plain sentence>`. A later pass shows these in
a tooltip window (Gun Bonsai's), so no explanation is lost when prose comes off the page.

## What a menu pass does not do

- No cvar renamed, no default changed, no code changed. MENUDEF (and the LANGUAGE strings its rows use) only.
- No row removed outright. It moves to Test and Debug. Only a row that duplicates another row exactly (the same cvar
  twice) may go.
- `python3 tools/rsmenu/menutool.py check <Mod>` passes before and after. `python3 tools/build_all.py <Mod>` builds.
