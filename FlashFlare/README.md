# RSQ FnF (Flash and Flare)

A road flare you use with your hands. Reach your off hand across to the pocket on your chest and grip: a flare is in
that hand while your gun hand keeps its gun. Flick it down hard to strike it (or pull that hand's trigger), and it
sputters, catches and burns red. Hold it up to see, or throw it with a real swing of your arm: it tumbles, bounces and
lies on the floor burning, lighting the room, until it burns out. A flashlight comes later (see
`docs/FLASHLIGHT_PROPOSAL.md`). Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3 (script only, no
engine changes). Built for the Quest first.

**Rig only, not headset-confirmed.** Everything below was checked on the simulated headset (scripted hand poses), not
yet in a real one.

Pk3: `pk3/RSQ_FnF.pk3` (about 0.3 MB). Source folder: `FlashFlare/`.

## Load order

```
doom2.wad -> RSQ_FnF.pk3                                        (on its own)
doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded -> 04-07 XMVE -> Gun Bonsai -> RSQ pk3s (RSQ_FnF.pk3 among them)
```

- Needs nothing else. Loads in any order with the rest of the series.
- **With RSQ Tactical Rig:** the pocket hangs on the Rig's body, so it turns with your holsters; a grip with the off
  hand inside one of the Rig's places is the Rig's, never the pocket's.
- **With Brutal Doom 22 VR Reloaded:** when the flare leaves your off hand you get BD22's empty hand back, and BD22's
  Hand Skin Tone colours the hand holding the flare.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> **RSQ FnF (Flash and Flare)**. Numbers, the pocket's place and
  Reset All are on its **Tuning and Debug** page.
- **Buttons to bind:** none. It reads the off-hand grip and trigger directly.
- **Dynamic lights must be on** in QuestZDoom's video options (`gl_lights`), or the flare gives no light.

## What to do in VR

1. **Take a flare:** reach your off hand across to the pocket on your chest (the gun hand's side, a palm under your
   collarbone) and press grip. You feel a tick and the flare is in your hand, cap on. If the gun hand is near (the
   engine's two-hand steadying), the flare comes up the moment you let go of the grip.
2. **Put it back:** grip at the pocket again with an unlit flare.
3. **Strike it:** a sharp flick of the flare hand straight down (faster than 1.4 m/s downward), like striking a road
   flare's cap. Or pull that hand's trigger. It catches with a burst of sparks and a strong buzz, sputters for about
   two thirds of a second, then burns.
4. **Hold it** to light the way. The light sits on the burning end you see.
5. **Throw it:** swing your arm and press grip (or the trigger) during the swing (faster than 2 m/s). It leaves at your
   hand's speed and direction. Walking or turning is not a swing: the speed is measured against your body.
6. **Drop it:** press grip with the hand still (away from the pocket): it falls at your feet, burning.
7. It burns 60 seconds (Burn Time), dies away over its last two seconds, and the spent flare lies dark for ten seconds.
   Burnt out in your hand, your hand lets it fall.

Taken away any other way (another weapon or mod takes your off hand, you die, a new level): an unlit flare goes back in
the pocket; a lit one falls where your hand was, still burning.

## Features

Front page. "On" = on by default; "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Flares | On | The whole mod. |
| Light Preset | Quest | **Quest**: radius 140, at most 3 lit at once, flicker every 4 tics. **PCVR**: radius 220, 6 lit, every 3 tics. Shows "Custom" when the Tuning numbers match neither. |
| Subdued Light | Option | Double the radius at half the brightness: a softer, wider glow. |
| Burn Time (s) | 60 | How long a flare burns (10-180). |
| Light It By | Strike or Trigger | Strike (flick down) only, the trigger only, or either. |
| Show Hand | On | Draws the hand holding the flare (Brutal Doom 22 VR's FBX hand, its magazine hold). Off: the flare alone. |
| Sparks | On | Sparks off the burning end (a burst when struck). |
| Smoke | Option | A thin smoke trail. |
| Sounds | On | The strike and a quiet burning crackle (stock Doom sounds). |
| Start With | 4 | Flares in the pocket at a new game and after dying. |
| Boxes in Levels | On | Boxes of 6 lie beside some of a map's items (saegiru's / the UAC Survival Pack's way). |
| Boxes a Map | 2 | At most this many boxes a map. |
| Pocket Refills Each Level | Option | Tops the pocket up at each new level. |
| Pocket Refills To | 4 | ...to this many. |

Always on (no row): carry 24 flares; a box gives 6.

**Tuning and Debug:** Light Radius, Most Lit at Once, Flicker Step; Strike Speed Down, Throw Speed, Throw Strength,
Arc; the pocket's place (Forward, Toward Main Hand, Height, Reach); Debug Log; Reset All.

## The light budget (why it is cheap)

- **One light per flare.** A plain point light with no shadow map, attached to the flare itself (never a spot light).
- **The flicker is a step, not a pulse.** The size and colour change every 4 tics (Quest) or 3 (PCVR) by a few percent;
  only the strike's sputter changes every 2 tics. Each step re-sets the one light; nothing is re-made every frame.
- **A hard cap.** At most 3 (Quest) / 6 (PCVR) flares give light at once, a flare in your hand counted. Light one more
  and the oldest flare on the floor goes dark over half a second and burns on as flame and sparks only. When one burns
  out, the one that went dark last lights again.
- **Flame, sparks and smoke are particles,** not actors.
- On the rig, with 5 flares burning (4 on the floor, 1 in the hand) on the Quest preset, never more than 3 lights were
  on (`docs/rig/light_log.txt`).

## Proof (rig only, not headset-confirmed)

Frames in `docs/rig/` (doom2 MAP01, the map darkened by a test probe): `01_taken_unlit`, `02_struck_sputter`,
`03_burning_held`, `04_head_turned`, `05_thrown_arc`, `06_lying_lit`, `07_cap3_three_lights_plus_held`,
`08_pcvr_preset`, `09_pcvr_subdued`, `10_burning_out_in_hand`. The log of the same run: `docs/rig/light_log.txt`.

Script errors from our packs: 0 with doom2 + RSQ_FnF alone; 0 with doom2 + Gun Bonsai + every RSQ pk3; 0 in the full
order (only BD_VoxelPack's own 4 voxeldef lines).

## Not yet known / open

- Nothing about the headset is known yet: the strike's feel (1.4 m/s down), the pocket's place on a real body, the
  throw's strength, the haptics (nothing can be felt on the rig).
- In two of six full-order rig runs, one frame showed the lit flare's flame and light in the hand but not the hand and
  flare model (the psprite was there, frame B); not seen again in four runs since. Watch for a held flare that
  vanishes in the headset.
- A grip at the pocket with the gun hand within 0.5 m makes the engine steady the gun for that press (its two-hand
  hold); the flare waits for the grip to let go. Other mods that act on the off-hand grip (Distance Grab's aim) may also
  see that press.
