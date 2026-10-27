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

## Handedness (`rsqa_handed`) -- the left-handed builder, measured on rig D

- **Which controller is the main hand is QuestZDoom's** (`vr_control_scheme`: below 10 right-handed,
  10 / 11 left-handed A / B). It swaps the two pose sets (AttackPos / AttackAngle / AttackPitch /
  AttackRoll = the main hand, Offhand* = the other), the buttons, which drawn weapon is reflected (the
  physical left controller's) and which controller a weapon's rumble goes to. Rig D, controllers posed as
  exact mirror images: scheme 0 and scheme 10 give the same two pose sets with MAIN and OFF traded (body
  frame fwd 10.2 / left -8.5 / yaw 38.8 / pitch 5.8 / roll 34.0 against fwd 10.2 / left +8.5 / yaw -38.8 /
  pitch 5.8 / roll -34.0). A mirrored pose is yaw and roll negated, pitch kept.
- **Choosing Right- or Left-Handed here also sets QuestZDoom's Control Scheme** (menu code may set engine
  cvars), so the engine and the series agree; Follow QuestZDoom leaves it alone. Rig D, driven through
  the menu with the thumbstick: Follow -> Right (scheme stays 0) -> Left (scheme 10) -> Follow (stays 10).
- At start-up, a Right/Left setting that disagrees with the scheme (changed since in QuestZDoom's own
  menu, the newer choice) goes back to Follow QuestZDoom.
- Series mods read `rsqa_handed` only for body layout no hand owns (Tactical Rig's cigarette pocket and
  holstered-gun hang, Gun Bonsai VR's HUD sides); everything a hand owns follows the scheme. Without this
  pk3 they follow the scheme.
- `RSQA_Hand.Left()` / `RSQA_Hand.EngineLeft()` for mods that load after this one.
