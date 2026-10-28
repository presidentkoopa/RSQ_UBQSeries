# RSQ_Accessibility (Radiant Silvergun Quest suite)

One shared Accessibility menu for the whole Radiant Silvergun Quest series (owner, 10-27: "one shared menu detecting what mods from the series we load").

- This pk3 defines the shared settings (cvars, prefix `rsqa_`) and one page, **Accessibility**, under
  **Options → Radiant Silvergun Options** (the series' parent page, tools/rsmenu in the hub), which lists
  every loaded series mod beside it. (Until 2026-10-28 this page carried a link to each loaded mod's
  options; those links are the parent page's rows now.)
- Every series mod reads these settings with CVar.FindCVar and falls back to its own defaults when this pk3 is absent, so every mod still loads and works alone.
- Shared settings (names fixed; add more only as `rsqa_*`):
  - `rsqa_colorblind`  0 Off, 1 Protanopia, 2 Deuteranopia, 3 Tritanopia, 4 High Contrast
  - `rsqa_handed`      0 Follow QuestZDoom, 1 Right-Handed, 2 Left-Handed
  - more (photosensitivity, one-handed, comfort, text size) as the audit decides
- Owners: the colourblind builder creates this skeleton (menu with mod detection) and commits it first; the left-handed builder merges it and adds its rows.

## Series sections in the menu
Gone (2026-10-28): the per-mod sections (a header and a link to each loaded mod's page) moved to the
series' parent page, **Radiant Silvergun Options**, where every loaded mod's page sits beside this
one. `RSQASection` / `RSQA_Menu` stay in `zscript/rsqa_menu.zs` for any row that should show only
when a given mod is loaded.

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
- **The left-handed scheme in use is remembered** (`rsqa_left_scheme`, 10 or 11, kept whenever the
  engine is on one: at start-up and before every change made here), and Left-Handed puts it back. Rig B
  (polish, 10-27), driven with the thumbstick from scheme 11 (B): Right -> Left -> Right -> Left gave
  0, **11**, 0, **11** (before: 0, **10**, 0, 10 -- B was lost); from 10 (A): 0, 10, 0, 10.
- At start-up, a Right/Left setting that disagrees with the scheme (changed since in QuestZDoom's own
  menu, the newer choice) goes back to Follow QuestZDoom.
- Series mods read `rsqa_handed` only for body layout no hand owns (Tactical Rig's cigarette pocket and
  holstered-gun hang, Gun Bonsai VR's HUD sides); everything a hand owns follows the scheme. Without this
  pk3 they follow the scheme.
- `RSQA_Hand.Left()` / `RSQA_Hand.EngineLeft()` for mods that load after this one.

## Round two (`agent-a11y2`) -- the settings, what each mod does with them, and what was measured

Every setting is off (or 1.0) by default, and a series mod reads none of them unless this pk3 is
loaded (the class-name guard in `tools/a11y_template.zs`; each mod carries a copy as `<PREFIX>_A11y`,
written by `tools/gen_a11y.sh <PREFIX> <out.zs>`). Rig B, doom2 and the owner's load order: with all
of them off the measured numbers below are exactly the mods' own.

| Row | cvar | What it does |
|---|---|---|
| Photosensitive Mode | `rsqa_photosafe` | strong flashes at 40%; flash / flicker / pulse at most 2.5 a second (14 tics apart) |
| One-Handed | `rsqa_onehand` | the Off-Hand Modifier and the Gesture Buttons work |
| Off-Hand Modifier | `+rsqa_mod` | held (or toggled), the main controller plays the off hand's part |
| Gesture Buttons | `rsqa_*` binds | Grab Pull, Grab Reach, Force Push / Pull / Grip, Shield Throw, Flick Reload, Wrist Cross |
| Gesture Ease | `rsqa_gesture_ease` 0..1 | tolerances x1..x2, speed thresholds and holds x1..x0.5 |
| Hold to Toggle | `rsqa_hold_toggle` | the Force trigger, the grapple hook binds, the shield's lock key, the modifier and the held gesture buttons latch |
| Comfort Vignette | `rsqa_vignette` | Light / Medium / Strong dark edge while a grapple swings, reels, climbs or yanks and through a boosted Force jump |
| Min SlowMo Ease | `rsqa_slowmo_ramp` s | no slow-motion ease shorter than this |
| Cue Size | `rsqa_cue_scale` | grab beam, dot, catch bloom, glow rim; Force outline rim, hand flare, saber lock diamonds; shield lock rings; laser dot, glow, arc; HP-bar markers |
| Text Size | `rsqa_text_scale` | the slow-motion label, the rig's and the training remote's prints (big font at 1.5+), the laser range readout, RS Score's display, the Gun Bonsai screens' text (rsq/ui) |
| Sound Cues | `rsqa_sound_cues` | Visual: arrows round the view for hits and incoming shots from off-view, a "Slow Motion" label; Rumble: the controller on that side, slow-mo start / stop, Force grip-ready |
| Menus | `rsqa_menus` | Simple hides the links to the series' niche sub-pages from their front pages (rows are kept and come back on Full) |

How mods reach this pk3: `RSQA_Service` -- `GetIntData("swap", "", player)`, `GetInt("vignette", src, player, strength)`,
`GetInt("ready", "", player, hand)`; gesture buttons arrive as `netevent rsqa_alt <code> <down>` (codes in KEYCONF.txt).
The vignette is a post-process shader (GLDEFS, `shaders/pp/rsqa_vignette.fp`): QuestZDoom runs it per eye on the scene,
so the dark edge follows the head with no lag.

Measured on rig B (scratch probe, 10 s windows):
- Photosensitive Mode, off -> on: saber clash starbursts 3.9 -> 2.0 /s; saber flash light (a blade lock's 2-tic flicker)
  15.3 -> 2.2 brightness changes /s; grab catch blooms 8.8 -> 2.2 /s; shield block stars 8.8 -> 2.2 /s; RS Score flashes
  (a kill every 3 tics) 11.6 -> 2.3 /s. Laser head pulse 4.0 -> 2.5 Hz (lock pulse 2.2 stays). Choke crackle every 5 -> 14 tics.
- Comfort Vignette, eye corner luminance 26.1 at rest: Light 9.1, Medium 6.1, Strong 0.7 at full strength; the centre unchanged
  (67.3-68.0); off it is 26.1 again. On a reel to the ceiling it eased 0 -> 0.61 in 10 tics at 12 u/tic, 0.35-0.41 hanging.
- Min SlowMo Ease 1.0 s: full speed to 0.25 in 26 tics (0.74 s) against 3 tics as set.
- Gesture Ease 1: Distance Grab palm roll accepted 90.5 / 104.3 and refused 120.2 at 0; accepted 120.2 and 146.9 at 1.
  SlowMo wrist cross with the wrists 0.22 m apart: nothing at 0, slow motion at 1 (0.12 m toggles at 0).
- Off-Hand Modifier: Distance Grab's off part reads the main controller while held, the off one when let go; Hold to Toggle
  latches it on a press and clears it on the next. With the off saber out, holding it arms the Force from the main hand
  (a still hand gripped a zombieman within 10 tics); the Force Push button threw one (0 -> 9.9 u/tic).
- Hold to Toggle, grapple: a press and release keeps the reel held; the next press lets go of the reel (the rope stays).
- Simple menus: RSQGR_Options 24 -> 22 rows (Reset All stays), RSQSM_Options 17 -> 11, UBQS_Options 39 -> 27; Full restores them.
