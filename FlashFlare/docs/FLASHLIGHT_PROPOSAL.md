# RSQ FnF: the flashlight (proposal, nothing built yet)

For the owner to pick from. Everything below about the engine is read from QuestZDoom 17.3's source
(`/home/claude/g9/src/qzd`, tag qzd17.3) and named file by file. Ermac's flashlight was read in full from his repo
(`github.com/iAmErmac/VR-Flashlight`, last commit 9536729, 2022-06-17). Nothing here was measured on a Quest: the costs
below are reasoned from the renderer's code, and the first build would measure them on the rig and then in your headset.

## In short

**My recommendation is B+**: one real spot light from the hand, a cheap see-through cone so you can see the beam, and a
small hotspot where it lands. It is held in BD22 VR's shotgun-pump hand, is ON / OFF on the flashlight hand's trigger,
DarkDoomz's flashlight stands down while ours is on, and an optional battery comes with battery bits from Kill Rewards.
That is about the cost of one flare on the Quest: one light, one extra model, one sprite.

## 1. What Ermac's flashlight does (and what it costs)

How it works (zscript/flashlight.txt, 732 lines; base code by SuaveSteve, "Steve's Flashlight"):

- **It is a weapon**, a `Fist` in slot 0 (`S_FlashLight`), held in the MAIN hand. Its fire button turns it on and off.
  A quick-toggle key swaps between your gun and the light. Option: "Weapon Mounted Flashlight" puts the light on every
  gun instead.
- **One real spot light** (`TrackedSpotLight : Spotlight`) moved every tic to the controller: position `AttackPos` plus
  20 units forward, yaw `AttackAngle + 90`, pitch `-AttackPitch` (QuestZDoom's `AttackAngle` is the controller's yaw
  minus 90; `hw_openxrdevice.cpp:590`). White, intensity (range) 256, inner 8 degrees, outer 16. It is the controller's
  light, not the head's: that was the point of the mod.
- **A "bounce light" every tic:** two `LineAttack`s 92 units ahead; on a wall within reach it spawns a fresh point light
  actor (`FlashLightSpot`, radius 25, lives 3 tics). So 3 short-lived lights are made and destroyed all the time.
- **Monster alarm every tic:** a 960-unit `LineAttack` spawning an actor that calls `A_AlertMonsters` (option).
- **Melee:** three more `LineAttack`s a tic in a 60-degree fan looking for something to bonk (option).
- **Battery:** minutes of charge (3 by default), drains while on, recharges while off; below half it dims and flickers
  (random intensity and cone every 5-35 tics); a battery readout is drawn on the model (a 10-step bar, its own md3).
  Auto-flip when the hand is rolled past 120 degrees (Harris hold).
- **Models:** a Sketchfab tactical flashlight (shaded, PBR and voxel versions) with Cherno's SimSun shader.
- **Known issues** (its README): the light jumps near walls, it can vanish when the model clips a wall, the bounce light
  can separate from the spot.

What it costs: the spot light itself is fine. The rest is a steady drip of per-tic work: up to 6 `LineAttack`s and up to
2 actor spawns a tic, and lights being created and destroyed every tic (each is a light re-linked into the level's
sector lists: `a_dynlight.cpp` collects up to `gl_light_max_collected_subsectors` subsectors per light). On a Quest
that is the kind of churn the series avoids.

Licence and credits: the repo has no licence file. Its credits name SuaveSteve (code), mshahen's clicks (freesound
271109, CC BY 3.0), Cherno (shader), and a Sketchfab model. We would reuse **ideas** (controller-following spot, battery
dim, auto-flip, the alarm option) and credit Ermac and SuaveSteve for them, write our own code, and ship his model or
clicks only if you say so (his assets ship in the series by your rule; the Sketchfab model's own licence is not stated).

## 2. What QuestZDoom 17.3 can do

- **Spot lights exist and follow an actor's angle and pitch.** A light's direction is its owner's yaw and pitch
  (`hw_dynlightdata.cpp:129-141`: `Angles.Yaw`, `-Pitch`), inner/outer angles from `SpotInnerAngle` /
  `SpotOuterAngle`. Two ways to make one: a `SpotLight` actor we move every tic (Ermac's way), or
  `A_AttachLight(name, PointLight, colour, range, 0, LF_SPOT | LF_NOSHADOWMAP, ofs, 0, inner, outer, pitch)` on an
  actor whose angle and pitch we set to the hand's (`a_dynlight.cpp:888`). Either is one light.
- **The Quest's GLES renderer draws spot lights.** `shaders_gles/glsl/material_normal.fp` has the cone test, and only
  compiles it into the shader variant of a surface that has a spot light on it (`DEF_HAS_SPOTLIGHT`,
  `gles_shader.cpp:724`). The old GLSL-100 path stops at 8 lights a surface.
- **The catch: a spot light costs like a point light of its full range.** Which surfaces a light touches is decided by
  its range as a sphere, not by its cone (`GetLight`, `hw_dynlightdata.cpp:55`). A 1024-range beam adds itself to every
  wall and floor within 1024 units, behind you too; the cone only zeroes the pixels outside it after the work is done.
  So the range is the real price: about 400-512 on the Quest, not 1024.
- **Other knobs in QZD:** `gl_light_wall_max_lights` / `gl_light_flat_max_lights` (lights a surface takes),
  `gl_light_distance_cull` (2000: lights further from the eye are dropped), `gl_light_range_limit` (64, a shader loop
  cap). No shadow maps on the Quest: a beam goes through monsters and lights the wall behind them. `gl_lights` must be
  on.
- **Hands:** `AttackPos` / `OffhandPos` and their angles are the real controller poses for the console player
  (`hw_openxrdevice.cpp:590-603`). The flashlight can sit in either hand as an off-hand weapon, like the flare.

## 3. The look: options

| | What you see | Quest cost (estimate) | Notes |
|---|---|---|---|
| **A. Spot light only** | A lit circle on walls where you point. No beam in the air. | 1 light, range 448. Like one flare. | What Ermac and DarkDoomz do (DarkDoomz adds a second wide "spill" spot). |
| **B. A + visible cone** | The beam itself: a soft additive cone from the lens, fading with distance and toward the edges, cut short where it hits a wall. | 1 light + 1 small model (about 64 triangles, additive, unlit). One trace a tic (or every 2nd tic). | The "near volumetric" look. See 4. |
| **B+. B + hotspot** (recommended) | B, plus a soft bright spot sprite where the beam lands, so the beam looks like it hits something even beyond the light's range. | B + 1 sprite actor (no light). | The hotspot fakes reach: the real light can stay short (400) while the spot shows far away. |
| **C. B+ + dust** | B+, plus a few motes drifting through the beam. | B+ + about 6-10 particles alive, only inside the cone. | Pretty in dark rooms; skip on the Quest preset if frames dip. |

**What the cone is made of (B):** a cone model (MODELDEF) on one actor at the lens, pointing where the hand points
(the actor's angle and pitch from the controller, like the flare's held light). Its texture is a radial gradient times a
little noise, bright on the axis and at the lens, fading to nothing at the rim and at the far end; drawn additive and
full bright, so it costs no lighting and never darkens anything. Each tic (or every second tic on the Quest) one trace
along the beam finds the first wall or monster, and the cone's length is scaled to it (one `LineTrace`, no actors
spawned), so it never pokes through a wall. Seen from inside (pointing it at your face) an additive cone just gets a
little brighter. The lens itself gets a small glow (a full-bright surface on the flashlight model, like the flare's
burning end).

**Hotspot (B+):** where the trace lands, one additive sprite, sized by distance, faded by the angle to the wall.
On a wall beyond the light's range it is the only thing lit, which reads as a long throw for no light cost.

**Dust (C):** particles spawned only inside the cone, slow, full bright, short-lived. Cheap but not free on a Quest.

## 4. How you hold it (the owner's plan, 11-03 19:25)

A flashlight points forward, so it is a horizontal cylinder in the hand. **Use BD22 VR's shotgun pump / forend
support-hand pose**, not the magazine hold turned 90 degrees: BD22 VR Reloaded's `fbx_s192_L.md3` frame 1 (RQWS B, the
pump-action Shot_Gun's support hand; frame 0 is the SSG, 2 the AssaultShotgun). Measured with `tools/fit_grip.py`
(NEAR=x): the hand wraps a cylinder of radius 2.49 cm along (0.933, -0.250, 0.259) in its mesh space, which is a
flashlight's barrel. Preview (a flat-shaded picture of that hand frame with a 2.3 cm cylinder, not an in-engine frame):
`docs/flashlight_pump_hold_preview.png`. As with the flare, our own one-frame copy in model slot 7 with Skin 7
"fbx_hand.png", so BD22 VR's Hand Skin Tone tones it.

In the off hand by default (your gun stays in the main hand), on the same holster plan as the flare: **your planned
left-hip holster** for the flare and the flashlight (a mirror of the planned whip holster on the right hip, a bit behind
and outside the saber holster, same height). Spec only: until that holster exists, it would come out of the chest pocket
spot like the flare, or a menu row.

Controls (proposal): the flashlight hand's trigger toggles it (click sound); a hand rolled past 120 degrees flips the beam
(Ermac's Harris-hold flip, option); "Mount on Gun" option later.

## 5. DarkDoomz (you load it; it has its own flashlight)

DarkDoomz's flashlight is an inventory item, `DarkDoomZ_Flashlight` (toggled by its own key, default F) that spawns one
or two `DarkDoomZ_Spotlight` actors (attenuated spot lights: beam 384-512 range plus a 128-384 spill). It has **no
setting that turns it off**; its menu only picks quality, type and where it is mounted. Its licence is zlib
(Caligari87).

You said (19:21) that DarkDoomz's flashlight stands down in favour of ours, or you will turn it off yourself. Safest way
to do it from our side, with a row **"DarkDoomz Flashlight Stands Down"** (on): while our flashlight is ON, if live
`DarkDoomZ_Spotlight` actors (found by class name, so nothing breaks without DarkDoomz) follow you, we use its own item
once (`UseInventory` on `DarkDoomZ_Flashlight`, its own toggle and sound), which switches it off the way its key does.
We never delete its lights or its item. The fallback, if you prefer zero contact: don't press its key (or unbind
"Toggle Flashlight" under DarkDoomZ in Customize Controls). Its darkening of the map is untouched either way; that is
what makes the flare and the flashlight worth having.

## 6. Battery (optional gameplay, off by default)

Your idea (19:21), as a proposal:

- **Drain:** while on, the battery runs down (default 4 minutes of light, slider). Off, it does not recharge (or a
  "Slow Recharge" option, Ermac's way).
- **Low battery:** under 25 % the beam dims and flickers in steps (Ermac's dimming, done as our flare's flicker: a
  step every few tics, never a pulse every frame); at 0 it goes out with a click.
- **Battery bits:** a FOURTH bit type in RSQ VisualRewards' Kill Rewards (next to its existing three), asked for by
  name from our side, OFF by default, only offered when our battery is on. A bit tops the battery up a little
  (e.g. 10 %).
- **Battery pickups:** a battery lying beside a map's items (the flare boxes' roll), a full charge each.
- **Readout:** the light itself flickering is the first readout. Optional: a small battery bar on the flashlight model
  (Ermac had one), and/or a line on RSQ Gun Cards' wrist card (asked by name).

## 7. What I would build first, if you pick B+

1. The flashlight in the off hand (pump hold), ON / OFF on its trigger, one spot light (Quest range 448, inner 10,
   outer 22; PCVR 640), no shadow map; the presets and Reset All like the flare.
2. The cone and the hotspot; the trace every tic (PCVR) / every 2nd tic (Quest).
3. DarkDoomz standing down; then the battery, if you want it.
4. Rig frames of each, a light-count log, and Quest vs PCVR frames, then your headset.
