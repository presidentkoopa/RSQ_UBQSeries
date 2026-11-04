# RSQ Grenade

A hand grenade you work with your hands. The other hand pulls the ring (or you pull the pin with your teeth), the
trigger is your grip on the spoon, and you throw it with your own arm: it leaves at the speed and in the direction
you swung. Let go without swinging and the spoon flies off and the fuse burns in your hand (cooking); hold it too
long and it goes off. While the fuse burns the grenade flashes red, faster and faster. Grenades lie scattered beside
each map's items. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3 (script only, no engine
changes).

It is Brutal Doom VR Reloaded's grenade handling (the owner's own, from his BD22 VR) brought to plain Doom 2 with a
grenade of its own, plus the teeth and the red fuse from his RS_Grenade. **With Brutal Doom VR Reloaded loaded it
stands down** and BD22 VR's own grenade does everything.

Pk3: `pk3/RSQ_Grenade.pk3` (about 2 MB).

## Load order

```
doom2.wad -> RSQ_Grenade.pk3                                   (plain Doom 2: its own grenade)
doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE -> RSQ_Grenade.pk3
                                                               (Brutal Doom VR: it stands down, nothing of it shows)
```

- **Plain Doom 2 without Brutal Doom:** this is what it is for (rig-tested on doom2.wad, 11-01).
- **Brutal Doom VR Reloaded loaded:** nothing is given, spawned or shown. It recognises BD22 VR by its grenade
  handler (`RSG_Handler`), looked up by name when the game runs. Brutal Doom without the VR Reloaded pack is not
  recognised: then this grenade works beside Brutal Doom's own.
- **Other RSQ pk3s needed:** none. Loads in any order with the rest of the series.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> **RSQ Grenade**. Numbers and Reset All are on its
  **Tuning and Debug** page.
- **Buttons to bind:** none. The grenade is in weapon **slot 9** (or RSQ Tactical Rig's belt buckle). It reads both
  triggers directly.
- It works in either hand: QuestZDoom's own switch-hand puts it in the off hand; then the main hand pulls the ring.

## What to do in VR

1. **Take it:** slot 9, or (with RSQ Tactical Rig) grip at the belt buckle.
2. **Pin out, by the ring:** bring the other hand to the top of the grenade, pull that hand's trigger (you hear and
   feel it take the ring), and pull the hand away (about 8 cm further): the pin is out. The ring disappears from
   the grenade.
   **Pin back in:** bring that hand back to the top and pull its trigger again (before the spoon has gone).
3. **Pin out, with your teeth:** bring the grenade to your mouth and squeeze (its trigger, or grip and trigger
   together) for about a third of a second. "At your mouth" is from your lips to just under your chin, measured from
   your headset; the controller, the grenade or its ring may be there. To pull another pin that way, take it away
   from your mouth first (or let go).
4. **Squeeze:** hold the grenade's trigger. That is your hand on the spoon.
5. **Throw:** swing and let go of the trigger mid-swing. It flies at your arm's speed (faster than 2.5 m/s counts as
   a throw), bounces, rolls, settles and goes off when the fuse runs out (3 s from the spoon flying).
6. **Cook:** let go of the trigger with the hand still. The spoon flies off (a clink) and the fuse burns in your
   hand: the grenade flashes red, faster and faster, ticking each flash. Squeeze and let go again to throw it with
   what is left of the fuse. Hold it too long and it goes off in your hand.
7. Putting the grenade away (another weapon) with the pin out: the pin goes back in. With the fuse already burning,
   it goes off.

## Features

Front page (RSQ Grenade). "On" = on by default (CVARINFO); "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Grenades | On | The whole mod. With Brutal Doom VR Reloaded loaded it does nothing anyway. |
| Start With | 3 | Grenades you start with (a new game, or after dying); the grenade itself comes with them. Not with Brutal Doom VR. |
| Scatter Grenades | On | Once per map, beside each item lying in the level, a roll: 5 in 126 drops a single grenade, 3 in 126 a pack of three (the UAC Survival Pack's way). |
| Single Grenades a Map | 4 | At most this many single grenades scattered a map. |
| Packs of Three a Map | 2 | At most this many packs scattered a map. |
| Pin With Your Teeth | On | Squeeze and hold the grenade at your mouth to pull the pin. |
| Alt Fire Cycles Grenade Types | On | The holding hand's alt fire picks the next grenade kind (until the spoon flies). Off: it picks nothing. |
| Grenade Types Without Gun Bonsai | All Types | Without RSQ Gun Bonsai VR: All Types lets the alt fire cycle every kind; Frag Only keeps the frag alone. With Gun Bonsai VR it is always the kinds you have unlocked. |

Always on (no row): carry 8 grenades, a backpack gives 6 and raises the carry to 16; the red flash and its tick;
the blast credited to you (the kill, the obituary, the score). With RSQ Gun Bonsai VR loaded (2026-11-02): the
blast and its kills are also paid to the grenade's own Gun Bonsai record (the thrown grenade names the grenade
weapon as its master and is claimed through the patch's service, by name), so the grenade levels like a weapon.

**With RSQ Gun Bonsai VR (the Grenade tree, GBOVR_TREES.md 4.5; asked by name, `RSQGN_Upg`):** **Bandolier** (carry
10 / 12 / 14 / 16, a backpack doubling it); **Scavenger** (after Bandolier: 6 + 3, 8 + 4, 10 + 5 scattered a map, the
odds rising with them; 3: one Kill Rewards ammo bit in four is a grenade); **Strong Arm** (throw x1.25 / 1.5 / 1.75);
**Flat Arc** (after Strong Arm: less lift and gravity, two levels); **Bounce** (after Strong Arm: wall bounce 0.4 /
0.55 / 0.7); **Cook Sense** (a tick in the hand each second of a cooking fuse; 2: the flash runs amber, then red; 3, with RSQ Gun
Cards: the grenade's card counts the seconds down in those colours);
**Short Fuse** (after Cook Sense: 2.5 / 2.0 s); **Big Bang** (both blast radii +15% a level); **Frag** (after Big
Bang: both damages +15% a level); **Cluster** (after Frag 2: 3 / 4 / 5 bomblets, 30 over 96 each, thrown 2-4 m and
going off a second later); **Sticky** (after Frag: it sticks to the first monster it touches and rides it to the
blast; 2: walls too). The blast that goes off in your hand takes the same numbers. **Teeth** (a pin pulled with your
teeth counts for style; 2-3: the throw after it +15% / +30%); **Skeet** (after Strong Arm 2: shoot your own grenade
in the air and it bursts there, x1.5 / 1.75 / 2.0); **Skeet Window** (after Skeet, needs RSQ SlowMo: eight tics after
a throw time slows for 15 / 20 / 25 tics and the grenade glows; the **Skeet Window Slow-Mo** row turns the slow motion
off); **Slow Burn** (after Cook Sense, needs RSQ SlowMo: a kill by a grenade cooked a second or more while time is
slowed keeps it slowed 0.75 / 1 / 1.25 s more). **The kinds** (each an unlock; the frag is the base): **Impact**
(orange, after Cook Sense: bursts on first contact; 2: +15%), **Incendiary** (amber, after Big Bang: fire over the
blast's radius, 4 / 5 / 6 s), **Freeze** (sky blue, after Frag: no damage, frozen 3 / 4 / 5 s, a hard hit shatters
it for double), **Stun** (violet, after Cook Sense: half damage, staggered 3 / 4 / 5 s), **Smoke** (grey, after Cook
Sense 2: a cloud 4 / 5 / 6 m wide for 12 / 16 / 20 s that blinds whoever is in it or looks through it), **Flash**
(white, after Cook Sense 2: no damage, stunned and blinded 3 / 4 / 5 s), **Charm** (pink, after Flash: they fight
for you 15 / 20 / 25 s) and **Infight** (green, after Flash: they turn on each other 15 / 20 / 25 s; bosses are
immune to both). **The holding hand's alt trigger cycles the kinds you own** (until the spoon flies); the grenade
wears its kind's colour. **Without the patch** (11-03): the alt trigger cycles every kind (Grenade Types Without Gun
Bonsai: All Types), each at its level-1 numbers; Freeze, Stun and Flash then use this mod's own freeze (frozen in ice
3 s, no shatter) and stagger (held in the pain frames 3 s), and bosses are not frozen or staggered. At Frag Only
there is only the frag, as before.

Tuning and Debug page:

| Row | Default | What it does |
|---|---|---|
| Fuse (s) | 3.00 | From the spoon flying off to the blast. |
| Throw Speed (m/s) | 2.50 | Let go faster than this and it is thrown; slower and the spoon flies (cooking). |
| Throw Strength | 1.00 | x your hand's own speed. |
| Arc | 0.35 | This much of the throw's speed across the ground is added upward. |
| Gravity | 0.27 | The thrown grenade's (1 = Doom's own, about 2.7 times real; 0.37 is earth's). |
| Floor Bounce | 0.50 | Speed kept off a floor. |
| Wall Bounce | 0.25 | Speed kept off a wall. |
| Ground Drag | 0.82 | Per tic on the floor (1 = ice). |
| Teeth: Mouth Reach (m) | 0.15 | How close to your mouth (lips to under the chin) the controller, the grenade or its ring must be. |
| Teeth: Again Beyond (m) | 0.71 | How far from your mouth it must have gone before the teeth take another pin. |
| Teeth: Hold (tics) | 12 | How long it must stay there (35 tics = 1 s). |
| Debug Log | Off | Prints the ring, the pin, the swing, the throw, each flash, the blast and the scatter to the console. |
| Reset All | - | Resets every RSQ Grenade setting. |

## Test it

Everything here is new on 2026-11-01 and ran on the simulated rig only: **not yet headset-confirmed**. Nothing
about rumble or sound could be checked there.

1. Load plain Doom 2 and the pack. Options -> Radiant Silvergun Options shows *RSQ Grenade*. No script error.
2. Press 9: a grenade is in your hand, ring and spoon on it.
3. Off hand to the top of the grenade, off trigger, pull the hand away: the pin sound, a rumble in the off hand, the
   ring is gone from the grenade.
4. Off hand back to the top, off trigger: the pin goes back in (the sound again). Pull it out again.
5. Squeeze the main trigger, swing at an imp and let go mid-swing: it flies, bounces, settles, flashes red faster
   and faster, and after 3 s goes off. The imp is hurt or killed; the kill is yours.
6. Next grenade: pin out, squeeze, let go with the hand still: a clink, the spoon is gone, it flashes red in your
   hand. Squeeze and let go mid-swing: thrown with the rest of the fuse.
7. Next grenade: pin out, let go still, keep holding: about 3 s later it goes off in your hand.
8. Bring the grenade to your mouth and squeeze for a moment: the pin comes out (teeth). Grip and trigger together
   work too. Squeezing with the grenade at your chest does nothing.
9. Walk round a map: grenades (a single, a green pack of three) lie beside other items; never more than 4 singles
   and 2 packs. Walk over one: "You got a Type J Hand Grenade!" / "Picked up a pack of Type J Hand grenades!".
10. Throw your last grenade: the hand goes back to your best gun.
11. With RSQ Tactical Rig: grip at the belt buckle; the grenade comes to your main hand; grip there again: your gun
    is back. With RSQ Gun Cards: the watch card's GRENADES count is this grenade's.
12. Load the Brutal Doom VR order with this pack: no slot 9 grenade of ours, no grenades of ours on the floor; BD22
    VR's grenade works as before (the rig's buckle hands out BD's HandGrenades).

What the rig showed (11-01, plain doom2.wad MAP01, logs `gren_plain`, `gren_offhand`, `gren_scatter`,
`gren_pickup3`, `gren_rig_b`, `gren_gc_b`, `gren_load_c2`): the ring pulled 24.9 cm (pin out at t66); a 7.2 m/s swing
thrown, gone off 105 tics later, an imp and two zombiemen killed by `DoomPlayer` via `RSQGN_Thrown`; pin back in;
cooked and gone off in the hand 105 tics after the spoon (85 + 75 damage to the player, credited to him); teeth at
0.18 m after 12 tics; a cooked throw left with 67 of 105 tics; the flash period 16, 14, 12, 10, 9, 8, 7, 6, 5, 4, 4,
3, 3, 3, 2 tics down the fuse; held in the off hand and thrown from it; scattered 0-4 singles and 0-2 packs on
MAP01-13 (caps 1/1 on MAP15-17, none with the scatter off); a pack +3 and a single +1 walked over; backpack 3 -> 9, cap
16; switched away with the pin out: kept, pin back in; switched away cooking: gone off (`gren_switch`). Frames looked at: the held grenade with the ring, without it, without the spoon, red; in the off hand (mirrored);
thrown and flashing in the air, lying on its side, the blast; the two pickup sprites.

What the rig showed on 11-03 (the teeth and the kinds; logs in `docs/rig_2026-11-03/`; rig only, not
headset-confirmed). The teeth used to measure from `player.viewz`, the pawn's fixed eye 1.45 m up, not from the
headset: on the rig with the owner's poses (headset 1.65-1.75 m, the controller 12 cm under and 10 cm in front of the
eyes) the old code pulled the pin with the trigger alone, but **not** with grip and trigger squeezed together under
QuestZDoom's default button layout (`vr_secondary_button_mappings` on: the main grip is a shift key, so the pair sends
alt fire and never fire), **not** for a 1.75 m player with `vr_height_adjust` 0.3 (0.48 m from the pawn's eye), and it
**did** pull it with the grenade held at the chest (0.37 m). Now: the pin came out at the mouth in every pose (standing
1.65 / 1.70 m, the chin, an upright hold, grip and trigger, 1.75 m + 0.3 height adjust, seated 1.20 m), in the main
hand and the off hand, and not at the chest (0.33 m from the mouth). The alt fire without Gun Bonsai cycled Impact,
Incendiary, Freeze, Stun, Smoke, Flash, Charm, Infight, Frag; with the row off and at Frag Only it cycled nothing; a
Freeze grenade froze three monsters in ice for 105 tics, then thawed them.

## Works with

- **RSQ Tactical Rig:** its grenade spot on the belt buckle hands out this grenade when Brutal Doom's isn't there
  (grip at the buckle: the grenade to the main hand; grip again: your gun back), and its light counts these
  grenades.
- **RSQ Gun Cards:** the watch card's GRENADES count is this grenade's when Brutal Doom's isn't there.
- **Brutal Doom VR Reloaded:** stands down completely (see Load order).
- Both are asked by name, so each mod still loads alone. Does not read RSQ Accessibility (Handedness, Steady Hands
  and the off-hand modifier do not change the grenade; QuestZDoom's own left-handed schemes do, as for every gun).

## Known limits

- **Not yet headset-confirmed** (all of it). Sounds and rumble were not heard or felt on the rig.
- With the grenade in the off hand, the main trigger that takes the ring also fires the main hand's gun. Pull the pin
  with your teeth, or hold it in the main hand.
- With Brutal Doom VR Reloaded loaded this mod stands down, so in that load order the teeth are BD22 VR's own (its
  2.0.3r has the same mouth fix).
- A throw is read from the fastest moment of the last fifth of a second: letting go still just after a fast move can
  still throw.
- It goes off in your hand at your body, not exactly at the hand (every machine in a netgame has to agree where).
- A new map puts a pulled pin back in quietly; a grenade cooking across a level change does not carry over.
- Outside VR the grenade does nothing (the gestures need the controllers).
- Brutal Doom 22 without BD22 VR Reloaded is not recognised as Brutal Doom VR: both grenades are then in the game.
- The explosion is the UAC pack's full layered blast (about 120 short-lived effect actors). Watch frame time on the
  Quest when several go off at once.
- The scatter does not skip items at map height 0 the way the pack's ACS did (that was a test for "no position").

## Credits

See `CREDITS.txt` (shipped). In short:

- **UAC Survival Pack** by **JohnnyDoom** (forum.zdoom.org, t=47229): its hand grenade (original by **Froon**, Brutal
  Doom version by **Saegiru**, sprites by **Pa1nki113r**), its sounds, its pickup sprites, its explosion, its ammo
  rules and its random placement.
- **Gomuz**: the grenade model.
- **The project owner**: the handling (his BD22 VR Reloaded grenade) and his RS_Grenade (the teeth, the red fuse,
  the flight, the blast's damage).
- QuestZDoom: Emawind and Team Beef.
