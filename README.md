# RSQ_Accessibility (UBQ / RSQ suite)

One shared Accessibility menu for the whole UBQ series (owner, 10-27: "one shared menu detecting what mods from the series we load").

- This pk3 defines the shared settings (cvars, prefix `rsqa_`) and one Options entry, **Accessibility**.
- The menu shows a mod's rows only when that mod is loaded (detected at run time by class/service name; no hard links).
- Every series mod reads these settings with CVar.FindCVar and falls back to its own defaults when this pk3 is absent, so every mod still loads and works alone.
- Shared settings (names fixed; add more only as `rsqa_*`):
  - `rsqa_colorblind`  0 Off, 1 Protanopia, 2 Deuteranopia, 3 Tritanopia, 4 High Contrast
  - `rsqa_handed`      0 Follow QuestZDoom, 1 Right-Handed, 2 Left-Handed
  - more (photosensitivity, one-handed, comfort, text size) as the audit decides
- Owners: the colourblind builder creates this skeleton (menu with mod detection) and commits it first; the left-handed builder merges it and adds its rows.

## Files
- `CVARINFO.txt`, `MENUDEF.txt`, `zscript/rsqa_menu.zs`: the settings and the menu. `RSQASection "Label", "Class1|Class2"`
  starts a mod's rows; `RSQA_Menu` drops a section (and its rows) when none of its classes exists.
- `tools/cvd.py`: colour-vision simulation (Machado 2009, Vienot 1999) and CIEDE2000 / luminance ratio, for palettes and rendered frames.
- `tools/cb_template.zs`, `tools/gen_cb.sh <PREFIX> <out.zs>`: the palette class each series mod carries under its own prefix.

## The colour-blind palette (rsqa_colorblind)
Roles, not colours, so a cue means the same thing across the series:

| role | 1-2 protan/deutan | 3 tritan | 4 high contrast |
|---|---|---|---|
| IDLE (searching) | D0D0D0 | D0D0D0 | 8C8C8C |
| COULD (noticed, would take it; off hand) | FFB000 | FF4040 | FFFF00 |
| HAVE (taken, locked, yours; main hand) | 3090FF | 00E0E0 | FF40FF |

Mods with more than two categories (holster profiles, Score families) carry their own per-vision sets, picked by
farthest-point search on simulated colours. Every cue that means something also differs by brightness, size, pulse or a letter.
