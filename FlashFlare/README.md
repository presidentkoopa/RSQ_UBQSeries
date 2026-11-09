# RSQ FnF (Flash and Flare)

A road flare you pull from your chest, strike with a flick of the wrist and throw into the dark, and a flashlight
clipped to your chest with a beam you can see in the air.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (tested on the rig, headset check pending): the flashlight, the RSQ Tactical Rig flare holster, the voxel flare box.

New on 11-06 (rig only, not headset-confirmed): the trigger-only grenade-style throw; flares that hurt and burn
monsters; lying flares for RSQ Distance Grab; Shoot Out Flares; and the DarkDoomZ Beam Look.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes.

**Dynamic lights must be on** in the engine's video settings. The flare's and the flashlight's light are real dynamic
lights; with them off you get the flame, sparks and the visible beam, but no light on the walls.

## Standout feature: strike it like the real thing

Reach your off hand across to the pocket on your chest and grip. An unlit flare is in your hand, cap on, and your
main hand still has its gun. Flick the flare hand sharply down, the way you strike a real road flare. It catches with
a burst of sparks, sputters for a moment, then settles into a flickering red-orange burn that lights the
room around you. The light sits on the burning end you see in your hand and follows it as you move.

Throw it the way you throw an RSQ Grenade: hold the off-hand trigger, swing, and let go. The flare leaves your hand
at your arm's own speed and direction, with the grenade's arc. It tumbles, bounces off the floor and walls, slides to a stop, and lies there burning. Light a corridor ahead of you, toss
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
- Thrown like RSQ Grenade: hold the off-hand trigger, swing, let go. Let go with the hand still and it stays in your hand.
  The grip does nothing to a lit flare (trigger only, as the grenade).
- Thrown flares bounce off floors, walls and monsters, then lie burning. A flying flare that hits a monster does a little
  damage (4). With Brutal Doom loaded it also sets the monster on fire with Brutal Doom's own Fire damage (3 every 6 tics
  for 5 s, 90 in all: the burn alone kills an imp, Brutal Doom's 80-health one too, so Brutal Doom plays its own burning pain and death): zombiemen, shotgunners, chaingunners, SS, imps and their
  Brutal Doom / XMVE kin (any walking monster of a zombie's or imp's size, 100 health or less). A LegenDoom legendary or a
  Champions champion only catches fire below "Boosted monsters ignite below N% health" (25 %) of its normal health.
  Without Brutal Doom: the damage only.
- A flare lying on the floor (dropped or thrown, once it has landed) can be pulled, caught, carried and thrown with RSQ
  Distance Grab. Thrown that way into a monster, it sets it on fire the same way.
- Shoot Out Flares (option, off): a dropped or thrown flare can be shot; a hit puts it out.
- A lit flare cannot be dropped by hand: throw it, or let it burn out.
- Unlit flares go back in the pocket by hand. Anything else that takes the off hand (another weapon, death, a new
  level) puts an unlit flare back in the pocket and lets a lit one fall where your hand was, still burning.
- Flame and sparks off the burning end; an optional thin smoke trail.
- saegiru's flare sounds for the strike, the burn and the burnout; a stock Doom knock on landing.
- The hand holding it is Brutal Doom 22 VR Reloaded's hand, drawn in its off-hand place (it can be hidden).

**Light that stays cheap**
- One light per flare, no shadow map, re-set only on a flicker step.
- A cap on how many flares give light at once (3 on the Quest preset, 6 on PCVR). Light one more and the oldest lying
  flare fades dark over half a second and burns on as flame and sparks. The one in your hand goes dark last. When a
  flare burns out, the last one that went dark lights again.
- Soft Light: twice the radius at half the brightness, for a softer look.

**The flashlight**
- On a clip on your chest, on your off hand's own side. Grip there with the off hand: it comes out switched on. That
  hand's trigger turns it off and on. Grip at the clip again to put it back.
- On the clip it is a small pocket light, about 12 cm long, lens up (11-08; not yet seen in-engine).
- Held in Brutal Doom 22 VR Reloaded's shotgun-pump support hand, drawn where your off hand is.
- One real spot light from the lens, plus a beam you can see in the air. The beam stops where it meets a wall or a
  monster, and a soft spot shows where it lands, even past the light's reach. Monsters stay visible through the beam
  (it is drawn see-through in the world, moved a tic ahead so it keeps up with your hand).
- Beam size, colour and quality are menu rows. One light per flashlight; Quest quality keeps the range short.
- One thing in the off hand at a time: take a flare and the flashlight goes away. Put the flare back and the
  flashlight comes back, on or off as it was.
- No battery: it stays on as long as you like. On a new level it stays in your hand, switched off.
- With DarkDoomz loaded, its own flashlight switches off while yours is on.

**Supply**
- You start a new game with 2 flares, and get them back after dying. You carry up to 24.
- Boxes of 6 turn up beside a map's items, up to 2 a map: saegiru's flare box (with voxels on, a voxel box with
  "FLARE" on its sides; his box sprite with voxels off). A single flare lying about is his lying-flare sprite (with models on, three flares in a bundle).
- Optional: the pocket tops up at each new level (off by default).

### New on 11-06 (rig only, not headset-confirmed)
- **Battery** (Ermac's VR-Flashlight model): the flashlight drains while on and recharges while off (in the hand or on its
  clip), at the same rate. **Battery (min)** sets the capacity (3, Ermac's default; 0 = never drains). Empty, it clicks
  off by itself; with under a second of light left it won't switch on. Below 50% it dims and flickers like Ermac's (the
  cone fades with it).
- **The meter is on the flashlight**: 10 segments and a round LED on top of the body, behind the head. Green, yellow,
  orange, red as it empties; the LED blinks at the last step. Hidden when the battery is off (0 or Never Drains).
  Rig frames: docs/rig/11_battery_meter.jpg.
- **Kills in the beam** refill it: a monster you kill while it is inside your lit beam gives back **5%** of a full battery.
- **Battery Never Drains** (off): no drain, no meter.
- **Bones Drop Battery Bits** (off): with Legion of Bones loaded, each Legion of Bones monster you kill drops a yellow
  battery bit 8% of the time (a LegenDoom legendary or Champions champion always drops 3). They are RSQ VisualRewards'
  Kill Rewards bits (need VisualRewards), fly to you like the others, and each refills **15%**.
- **Beam Colour: six** (was 18): Warm White, White, and the four Bossfight colours (Pink, Cyan, Amber, Violet, RSQ
  Miniboss's own), plus Random of the six. No special powers. A saved colour from the old list moves to the nearest of the
  six once (Silver -> Warm White; Yellow, Gold, Orange, Red, Lime -> Amber; Crimson, Pink, Magenta -> Pink; Lavender,
  Purple, Blue -> Violet; Sky, Cyan, Teal, Green -> Cyan).

## How To Play

1. Add RSQ_FnF.pk3 to your load order. Make sure dynamic lights are on. Play in VR: the flare is taken by hand only.
2. Bring your off hand across your chest toward your main-hand side, on your upper chest, and grip.
   You hear the pickup sound and feel a tick. A flare you carry hangs at the pocket (Show Flare), so you can see where to
   reach; if nothing happens, move a little and grip again, or move the pocket under Test and Debug.
   The flashlight is the mirror: your off hand on its own side of your chest, grip, and it comes out on.
3. Flick the flare hand down hard. Too gentle? Pull the off-hand trigger instead, or lower Strike Speed Down.
4. Hold it up and walk. To throw it, hold the off-hand trigger, swing, and let go mid-swing, as with RSQ Grenade.
5. Out of flares, the game tells you "No flares left". Look for boxes beside the map's items.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Take a flare | Off hand at the chest pocket, grip | Pocket: 0.12 m forward, 0.15 m toward your main hand, 0.28 m under your eyes; reach 0.11 m |
| Put it back | Off hand at the pocket with an unlit flare, grip | |
| Strike it | Flick the flare hand down at 1.4 m/s or more | With Light It By on Strike or Strike or Trigger |
| Light by trigger | Off-hand trigger | With Light It By on Trigger or Strike or Trigger |
| Throw | Hold the off-hand trigger, swing, and let go while the hand moves faster than 2 m/s (RSQ Grenade's throw). The grip does nothing to a lit flare | Leaves at your hand's own speed (Throw Strength 1.0), with the grenade's arc (0.35) and your walking speed added. Let go of the trigger with the hand still: it stays in your hand. A lit flare is never put away |
| Take the flashlight | Off hand at the clip (your off hand's side of your chest), grip | Clip: 0.10 m forward, 0.17 m toward your off hand, 0.22 m under your eyes; reach 0.12 m. Comes out on |
| Flashlight on / off | The flashlight hand's trigger | A click |
| Put the flashlight back | Off hand at the clip, grip | |
| Flare holster (with RSQ Tactical Rig) | Off hand at the Rig's flare holster on your off-hand hip, grip | Takes or puts back an unlit flare, the same flares as the pocket. A lit one cannot go back: it stays in your hand. Shown there while you carry one |

- The flare is always in the off hand. With QuestZDoom's left-handed setting the pocket moves to the other side of
  your chest, still toward your main hand.
- The off-hand grip is read from the keys the engine sends for it (443, or 436 while the main grip is held).
- If the engine is steadying a gun with both hands when you grip at the pocket, the flare comes up the moment you
  let go of the grip.

## Menu

Options → Radiant Silvergun Options → RSQ FnF (Flash and Flare). One page, and one sub menu, **Test and Debug**. Nothing
here is a Gun Bonsai VR upgrade.

| Row | Default | What it does |
|---|---|---|
| **Flares** | | |
| Flares | On | The whole mod |
| Show Flare | On | A flare you carry hangs at the chest pocket; with RSQ Tactical Rig's flare holster, at that holster |
| Show Hand | On | Draw the hand holding the flare |
| Light It By | Either | Strike (flick down), Trigger, or Either |
| Soft Light | Off | Double radius, half brightness |
| Burn Time (s) | 60 | How long a flare burns (10-180) |
| Sparks | On | Sparks off the burning end |
| Smoke | Off | A thin smoke trail |
| Sounds | On | Strike, burning, burnout and landing sounds |
| Shoot Out Flares | Off | A dropped or thrown flare can be shot; a hit puts it out |
| Boosted monsters ignite below N% health | 25 | With Brutal Doom: a LegenDoom legendary or Champions champion catches fire from a flare only below this share of its normal health |
| **Supply** | | |
| Start With | 2 | Flares at a new game (0-24) |
| Boxes in Levels | On | Boxes of 6 beside a map's items |
| Boxes a Map | 2 | Most boxes in one map (0-8) |
| Refill Each Level | Off | Tops the pocket up at each new level |
| Refill To | 4 | ...to this many (1-24) |
| **Flashlight** | | |
| Flashlight | On | The flashlight on its clip |
| Show Flashlight | On | The flashlight hangs on its chest clip while it is not in the hand |
| Beam Size | Medium | Narrow (6/14 degrees), Medium (10/22), Wide (16/32) |
| Beam Colour | Warm White | Warm White, the series' 17 colours, or Random (a new one each time you switch it on) |
| Beam Quality | Quest | Quest: range 448, one-layer beam, trace every 2nd tic. PCVR: 640, two layers, a little dust. High: 896, more dust |
| Beam Length (m) | 4 | How far the visible cone reaches before it fades out (1-15). The light itself still reaches the whole range. |
| Beam Hotspot | Off | A soft glow sprite where the beam lands. Off: the spot light alone shows it. |
| Show Cone | On | The visible tapered cone (and its dust); off, the light alone |
| Beam Look | FnF | FnF: the rows above. DarkDoomZ: DarkDoomZ's flashlight light, rewritten to come from our flashlight's lens (its types and spill light; Beam Size and Beam Colour grey out) |
| DarkDoomZ Type | Halogen | Incandescent, Halogen, LED or Red Filter: DarkDoomZ's own colours, angles and reach (greyed on FnF) |
| DarkDoomZ Spill Light | On | On: DarkDoomZ's Fancy (a beam light plus a wider, dimmer spill light). Off: its Simple (one light) (greyed on FnF) |
| Reset All | | Every setting on both pages back to default |

**Test and Debug**: Light Radius (140; the old Quest preset, PCVR was 220), Most Lit at Once (3; PCVR 6), Flicker Step (4
tics; PCVR 3); Strike Speed (1.4 m/s), Throw Speed (2.0 m/s), Throw Strength (1.0), Arc (0.35), Off Grip Keys (443 436);
Pocket Forward / Toward Main Hand / Height / Reach (0.12 / 0.15 / -0.28 / 0.11 m); Flashlight Clip Forward / Toward Off
Hand / Height / Reach (0.10 / 0.17 / -0.22 / 0.12 m); Debug Log (Off); Reset All.

## Works with

Runs alone. It finds the others by name:
- **RSQ Tactical Rig**: the pocket hangs on the Rig's torso and turns with its holsters (stick turns, followed room
  turns, recenters). The pocket and the flashlight clip show the Rig's fading holster sphere, like its own holsters. The Rig adds a flare holster on your off-hand hip that holds the same flares as the pocket, with
  a flare model hanging there while you carry one. While your off hand is in one of the Rig's holsters, the grip
  belongs to the Rig, never the pocket, and a fast reach down to a holster is never read as a strike. Drawing a gun
  into the off hand from a holster puts an unlit flare back; with a lit flare in the off hand the Rig's holsters do nothing for that hand (the flare stays in it). The Rig never throws the
  flare. The two pockets sit on opposite sides: the Rig's cigarettes on your off-hand side, flares on your main-hand
  side. Without the Rig, the pocket follows snap and stick turns and eases under your head while you look ahead.
- **Brutal Doom 22 VR Reloaded**: when the flare leaves your hand, the off hand gets BD22 VR's empty hands back (on
  plain Doom the off hand is simply empty). Its Hand Skin Tone tones the hand holding the flare or the flashlight.
- **RSQ Wheel, RSQ Gun Bonsai VR**: the flare and the flashlight each have their own icon (a burning road flare, a
  torch with its beam), shown wherever those mods picture the item in your hand (Gun Bonsai VR's status screen; the
  Wheel's card, when a mod puts them in a weapon slot). Seen on the status screen on the rig only, not
  headset-confirmed; the Wheel card not seen.
- **DarkDoomZ** (built into RSQ Glow In The Dark since 11-09) no longer has a flashlight of its own: this is the only
  flashlight. Its darkness is left alone. Beam Look can borrow DarkDoomZ's beam types and spill light.
- **RSQ Distance Grab**: lying flares are things it can pull, catch, carry and throw (its "Flares" switch).
- **Brutal Doom, LegenDoom, Champions**: found by name for the flare's burn (above). The flashlight clip also hangs on RSQ Tactical Rig's body, and a Rig holster can take it by name.

## Credits and licence

- **presidentkoopa** (project owner): the flare model (Flare.blend with its FlareTexture and FlareTip textures),
  read from the .blend and turned into the in-hand, lying and box models, scaled to a 22.5 cm road flare. The code.
- **Brutal Doom 22 VR Reloaded** (the owner's mod): the FBX hand, its off-hand magazine hold and skin, drawn in BD22
  VR's own off-hand placement; its shotgun-pump support hand holds the flashlight.
- This pack: the flare and flashlight icons (graphics/rsqff/WRIFLARE.png, WRITORCH.png), original pixel art drawn by
  RSQ Wheel's sources/icons/gen_item_icons.py.
- **Ermac** (VR-Flashlight, base code by SuaveSteve): ideas for the flashlight.
- **DarkDoomZ** by **Caligari87** (Sterling Parker), zlib licence (github.com/caligari87/darkdoomz): the "DarkDoomZ"
  Light Style is an altered rewrite of its flashlight (`zscript/rsqff/ddzlight.zs`, which carries its licence notice):
  its four types and their numbers and its beam + spill lights, moved onto our flashlight's lens. Not carried: its
  spring-follow and mounts, toggle key and click sound. DarkDoomZ's own credits: code by Kinsie, Gutawer,
  FishyClockwork, phantombeta, Marisa Kirisame, Accensus; testing by Fort of Hard Knox, a1337spy, Orange Bomb; its click
  sound by mshahen (CC BY 3.0, not used here).
- **saegiru's Emergency Flare** (UDV Survival Flares, part of the UAC Survival Pack by JohnnyDoom, forum.zdoom.org t=47229):
  the box and lying-flare sprites and the strike, burning and burnout sounds (renamed), and the numbers: a box of 6,
  carry 24, the red-orange colour, the raised light, boxes rolled beside a map's items, a thrown flare that bounces and
  lies burning with sparks.
- **BD_VoxelPack**: DooMAD's "Ammo Box" voxel, made into the flare box voxel (lid closed, recoloured to saegiru's box,
  "FLARE" and a latch added). The pack's voxel authors, as its credits name them: Ghostpilot, DooMAD, Monfriez,
  DooMGoaT, Exl, Scott_AW, ReaperMan, 4mer, phi108, Conrad RDW, Voxelbro, zedas.
- **id Software**: the stock Doom sounds played by name.
- Generated for this pack: the glowing end, flame, spark and smoke pictures, the clear skin and placeholder sprites,
  the flashlight model, its beam cones and the hotspot.
- **QuestZDoom** (Emawind and Team Beef): the engine, and its off-hand weapon and hand-pose API.

Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors' terms; sharing other
people's work in this pack is the project owner's decision.
