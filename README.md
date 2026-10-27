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
