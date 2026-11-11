# The owner's five HUD decisions of 11-11: RSQ Gun Bonsai VR and RSQ Score (HUD11)

**Code only, not shown.** The owner ordered at 15:07 "no rig test, code only until i say". One launch (HUD11A) had
started just before the order reached this lane; it was stopped by hand before it got to the checks, and nothing
from it is counted (no frame, no log line cited). The load check (`/tmp/lc.sh GunBonsaiOffhandVR Score Miniboss`,
the owner's order, built from this code) ran before the order: zero script errors or warnings from our pk3s
(the 4 errors are BD_VoxelPack's voxeldef.txt; the warnings are brutal22test6, LOB, BD_VoxelPack and RSQ_Monsters,
untouched here). That proves it compiles, not that it works.

| # | Decision | What the code does now | Files | Shown? |
|---|---|---|---|---|
| 1 | Score's line centred, below the gauges | Score's Across default 85 -> 50 (centred); a saved 85 is moved to 50 once (`rs_score_cfgver`). Gun Bonsai VR's `RSQ_HudService` now answers `gauges.bottom` (permille of the screen's height: the bottom of the lowest hand gauge drawn, Dual HUD or single HUD, same test and anchors the gauges draw with; -1 when none). Score moves its whole display down until the line's top is 1% of the screen under that bottom; Down still works below it. The old ShieldSaw-band shift is gone | `Score/zscript/rsscore/hud.zs` (Layout, GaugeShift, Migrate), `Score/CVARINFO.txt`, `GunBonsaiOffhandVR/rsq/zscript/hudservice.zs` (was shieldgauge.zs), `ca.ancilla.bonsai/EventHandler.zsc` (GaugesBottom), `HUD.zsc` (GaugeBottom) | code only, not shown |
| 2 | ShieldSaw bar removed | Drawing (DrawShield, ShieldScale, ShieldBand), GetShieldStats, ShieldGaugeShown, the menu row, `rsq_hud_shield` (no migration system covers it; a value left in an ini is ignored), the language string, the service band, README text. It used Gun Bonsai's own gauge art, so no graphics to remove | `HUD.zsc`, `EventHandler.zsc`, `PerPlayerStats.zsc`, `menudef.rsq`, `cvarinfo.txt`, `language.rsq`, READMEs | code only, not shown |
| 3 | No HUD while a menu is open | `menuactive != Menu.Off` hides: Gun Bonsai VR's gauges (ShouldDrawHUD), the skin's HUD / Ammo and Health Row (RSQUI_Handler), the Berserk gauges; Score's line, bar, pips and breakdown; **RSQ Miniboss's meter and stack** (changed). Score's wrist digits are world actors, so the frame sends `rs_score_wristmenu` when the menu state changes and the playsim hides that player's digits | `GunBonsaiOffhandVR/ca.ancilla.bonsai/EventHandler.zsc`, `rsq/ui/dispatch.zs`, `rsq/ui/gauges.zs`, `Score/zscript/rsscore/hud.zs`, `Score/zscript/rsscore/wrist.zs`, `Miniboss/zscript/rsqmb/hud.zs` | code only, not shown |
| 4 | Whip and bare-fist pictures | A blank picture (1x1 or TNT1: the whip's WHPWA0 is a 1x1 clear pixel) counts as none. Whip: `graphics/rsqui/guns/RSQWP_WhipWeapon.png` (a copy of RSQ Wheel's WRIWHIP, our own art), then WRIWHIP. Bare fist (BD22 VR's `RSQ_Hands`, BD's `Melee_Attacks`: TNT1 frames, no icon anywhere in BD or BD22 VR): BD's own fist sprite FISTD0, then RMICA0 / RMICB0 for that hand, then WRIFIST. Gloves keep their own icons, RMICA0/RMICB0 by name if blank | `GunBonsaiOffhandVR/rsq/ui/skin_a_menus.zs` (RSQUI_GunPic), `graphics/rsqui/guns/` | code only, not shown |
| 5 | Display Info opens on the main hand | menuHand started at 0 and was stepped before opening, so the first press went to the off hand (the comment said it started at -1; nothing set it). The first browse now sets -1 before the step (`menuBrowsed`), landing on the main hand (the off hand if the main is empty); later presses step as before | `ca.ancilla.bonsai/EventHandler.zsc` (ShowInfo), `PerPlayerStats.zsc` | code only, not shown |

## Other series HUDs checked for drawing over menus

- **Changed (11-11, first pass):** RSQ Miniboss (meter and stack, one early return in `RSQMB_Hud.RenderOverlay`).
- **Changed (11-11, the owner's "yes, hide them too"), the same test (`menuactive != Menu.Off`), code only, not
  shown, not load-checked (the owner's order also stops lc.sh):**
  - RSQ SlowMo: the countdown bar (`countdown.zs`), the edge arrows (`arrows.zs`), DOWN's panel and edge marks
    (`downhud.zs` Draw).
  - RSQ Accessibility: the vignette (a post-process pass, switched off through its own off path while a menu is open,
    `rsqa_core.zs` DrawVignette), the threat and slow-motion cues (`rsqa_core.zs` RenderOverlay), the gesture names
    (`rsqg/gestures.zs`).
  - RSQ Melee: the gesture-name line (`shove.zs`).
  - Found on the way, debug only: RSQ ShieldSaw's `ssq_debug` lines (`state.zs`), RSQ Saber's `ubqs_diag 2` lines
    (`QuestSaber/zscript.txt`).
- **Not changed, not HUD:** RSQ VisualRewards' bars and damage numbers (world actors over monsters); RSQ SlowMo's
  colour drain (a post-process pass on the world during slow motion, not a HUD piece); the Wheel (a menu itself);
  SlowMo's breathing menu title (it is a menu row). No other `Screen.Draw` in the series' code.

## To show when the owner allows the rig

The launch is written (`/home/claude/scratch/rig1110/HUD11A/script.txt`, probe `HUD11_probe/`, not committed): the
whip in the main hand and the bare fist in the off hand (gloves off), Dual HUD then single HUD frames for the Score
line under the gauges with its numbers logged (`gauges.bottom`, the line's top and centre, Across and cfgver after
the migration from a saved 85), Display Info twice (focus hand logged), the options page open with its rows dumped
(no ShieldSaw Gauge row) and no HUD over it, and the wrist digits' visible count logged as the menu opens and closes. Added (owner's "hide them too"): slow motion
toggled on and the options menu opened inside it (frames: no Accessibility slow-motion cue, Score or Miniboss over
it; SlowMo's countdown bar shows only for an automatic trigger, so this launch does not cover it), and a Comfort
Vignette held by the probe (`gbp_vig`, Accessibility's own request fields) with the menu opened over it (the probe
logs `vignette shown` with `menuactive`). The scratch probe and script are updated, not run, not committed.
