# RSQ FnF (Flash and Flare)

A road flare you pull from your chest, strike with a flick of the wrist, and throw into the dark.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. The flare is
built; a flashlight is planned.

**Dynamic lights must be on** in the engine's video settings. The flare's light is a real dynamic light; with them off
you get the flame and sparks but no light.

## Standout feature: strike it like the real thing

Reach your off hand across to the pocket on your chest and grip. An unlit flare is in your hand, cap on, and your
main hand still has its gun. Flick the flare hand sharply down, the way you strike a real road flare. It catches with
a burst of sparks, sputters for a moment, then settles into a flickering red-orange burn that lights the
room around you. The light sits on the burning end you see in your hand and follows it as you move.

Swing your arm and press, and the flare leaves your hand at your arm's own speed and direction. It tumbles end over
end, bounces off the floor and walls, slides to a stop, and lies there burning. Light a corridor ahead of you, toss
one into a dark room before you go in, or leave a trail behind you.

All of it is ZScript on a stock engine: the pocket hangs on your body, the strike is read from your hand's motion,
and the throw is measured against your body, so walking and turning never count as a swing.

## Features

**The flare**
- Taken from a chest pocket by the off hand. The main hand keeps its gun the whole time.
- Lit by a downward flick, by the off-hand trigger, or either (your choice).
- A sputter on the strike, then a flickering burn: the light's size and colour shift a little every few tics.
- Burns 60 seconds by default, in your hand or on the floor, and dies away over its last two seconds.
- Burnt out in your hand, the spent flare drops. A spent flare lies dark for 10 seconds, then is gone.
- Thrown flares bounce off floors, walls and monsters, then lie burning. They hurt nothing.
- Drop one at your feet: grip with the hand still.
- Unlit flares go back in the pocket by hand. Anything else that takes the off hand (another weapon, death, a new
  level) puts an unlit flare back in the pocket and lets a lit one fall where your hand was, still burning.
- Flame and sparks off the burning end; an optional thin smoke trail.
- Stock Doom sounds: the arch-vile's flame catching for the strike, its crackle for the burn, a dull knock on landing.
- The hand holding it is Brutal Doom 22 VR Reloaded's hand, drawn in its off-hand place (it can be hidden).

**Light that stays cheap**
- One light per flare, no shadow map, re-set only on a flicker step.
- A cap on how many flares give light at once (3 on the Quest preset, 6 on PCVR). Light one more and the oldest lying
  flare fades dark over half a second and burns on as flame and sparks. The one in your hand goes dark last. When a
  flare burns out, the last one that went dark lights again.
- Subdued Light: twice the radius at half the brightness, for a softer look.

**Supply**
- You start a new game with 4 flares. You carry up to 24.
- Boxes of 6 turn up beside a map's items, up to 2 a map.
- Optional: the pocket tops up at each new level (off by default).

## How To Play

1. Add RSQ_FnF.pk3 to your load order. Make sure dynamic lights are on. Play in VR: the flare is taken by hand only.
2. Bring your off hand across your chest toward your main-hand side, on your upper chest, and grip.
   You hear the pickup sound and feel a tick. The pocket has no marker: if nothing happens, move a little and grip
   again, or move the pocket under Tuning and Debug.
3. Flick the flare hand down hard. Too gentle? Pull the off-hand trigger instead, or lower Strike Speed Down.
4. Hold it up and walk. Then swing and grip to throw it ahead of you.
5. Out of flares, the game tells you "No flares left". Look for boxes beside the map's items.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Take a flare | Off hand at the chest pocket, grip | Pocket: 0.12 m forward, 0.15 m toward your main hand, 0.28 m under your eyes; reach 0.11 m |
| Put it back | Off hand at the pocket with an unlit flare, grip | |
| Strike it | Flick the flare hand down at 1.4 m/s or more | With Light It By on Strike or Strike or Trigger |
| Light by trigger | Off-hand trigger | With Light It By on Trigger or Strike or Trigger |
| Throw | Swing the off hand faster than 2 m/s, then grip or off-hand trigger | Leaves at 1.25x your hand's speed, with a little arc and your walking speed added |
| Drop | Grip with the hand still, away from the pocket | Lies at your feet, burning |

- The flare is always in the off hand. With QuestZDoom's left-handed setting the pocket moves to the other side of
  your chest, still toward your main hand.
- The off-hand grip is read from the keys the engine sends for it (443, or 436 while the main grip is held).
- If the engine is steadying a gun with both hands when you grip at the pocket, the flare comes up the moment you
  let go of the grip.

## Menu

Options → Radiant Silvergun Options → RSQ FnF (Flash and Flare)

| Row | Default | What it does |
|---|---|---|
| Flares | On | The whole mod |
| Light Preset | Quest | Quest: radius 140, 3 lit at once, flicker every 4 tics. PCVR: 220, 6, 3 |
| Subdued Light | Off | Double radius, half brightness |
| Burn Time (s) | 60 | How long a flare burns (10-180) |
| Light It By | Strike or Trigger | Strike (flick down), Trigger, or Strike or Trigger |
| Show Hand | On | Draw the hand holding the flare |
| Sparks | On | Sparks off the burning end |
| Smoke | Off | A thin smoke trail |
| Sounds | On | Strike, crackle and landing sounds |
| Start With | 4 | Flares at a new game (0-24) |
| Boxes in Levels | On | Boxes of 6 beside a map's items |
| Boxes a Map | 2 | Most boxes in one map (0-8) |
| Pocket Refills Each Level | Off | Tops the pocket up at each new level |
| Pocket Refills To | 4 | ...to this many (1-24) |

**Tuning and Debug**

| Row | Default | What it does |
|---|---|---|
| Light Radius | 140 | The light's radius, map units |
| Most Lit at Once | 3 | Flares giving light at the same time |
| Flicker Step (tics) | 4 | How often the light's size and colour change |
| Strike Speed Down (m/s) | 1.4 | How hard the downward flick must be |
| Throw Speed (m/s) | 2.0 | How fast the hand must move for a press to throw |
| Throw Strength | 1.25 | Throw speed as a multiple of the hand's |
| Arc | 0.25 | Share of the throw's speed added upward |
| Pocket Forward (m) | 0.12 | The pocket, forward of the chest line |
| Pocket Toward Main Hand (m) | 0.15 | ...toward your main hand's side |
| Pocket Height (m) | -0.28 | ...under the eyes |
| Pocket Reach (m) | 0.11 | How near the hand must be |
| Debug Log | Off | Flare lines in the console |
| Reset All | | Every setting back to default |

## Works with

Runs alone. It finds the others by name:
- **RSQ Tactical Rig**: the pocket hangs on the Rig's torso and turns with its holsters (stick turns, followed room
  turns, recenters). While your off hand is in one of the Rig's holsters, the grip belongs to the Rig, never the
  pocket. The Rig never holsters or throws the flare. The two pockets sit on opposite sides: the Rig's cigarettes on
  your off-hand side, flares on your main-hand side. Without the Rig, the pocket follows snap and stick turns and eases
  under your head while you look ahead.
- **Brutal Doom 22 VR Reloaded**: when the flare leaves your hand, the off hand gets BD22 VR's empty hands back (on
  plain Doom the off hand is simply empty). Its Hand Skin Tone tones the hand holding the flare.

## Credits and licence

- **presidentkoopa** (project owner): the flare model (Flare.blend with its FlareTexture and FlareTip textures),
  read from the .blend and turned into the in-hand, lying and box models, scaled to a 22.5 cm road flare. The code.
- **Brutal Doom 22 VR Reloaded** (the owner's mod): the FBX hand, its off-hand magazine hold and skin, drawn in BD22
  VR's own off-hand placement.
- **saegiru's Emergency Flare** (UDV Survival Flares, part of JohnnyDoom's UAC Survival Pack): ideas and numbers only.
  A box of 6, carry 24, the red-orange colour, the raised light, boxes rolled beside a map's items, a thrown flare that
  bounces and lies burning with sparks. His sprites and sounds are not used: the copy supplied carries no licence for
  reuse.
- **id Software**: the stock Doom sounds played by name (no sound files shipped).
- Generated for this pack: the glowing end, flame, spark and smoke pictures, the clear skin and placeholder sprites.
- **QuestZDoom** (Emawind and Team Beef): the engine, and its off-hand weapon and hand-pose API.

Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors' terms.
