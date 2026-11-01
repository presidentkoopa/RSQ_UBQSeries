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
3. **Pin out, with your teeth:** squeeze the grenade's trigger and hold the grenade at your face for about a third of
   a second. To pull another pin that way, take it away from your face first (or let go of the trigger).
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
| Pin With Your Teeth | On | Squeeze and hold the grenade at your face to pull the pin. |

Always on (no row): carry 8 grenades, a backpack gives 6 and raises the carry to 16; the red flash and its tick;
the blast credited to you (the kill, the obituary, the score).

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
| Teeth: At (m) | 0.47 | How close to your eyes the grenade must be. |
| Teeth: Again Beyond (m) | 0.71 | How far it must have gone before the teeth take another pin. |
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
8. Squeeze the trigger and hold the grenade at your mouth for a moment: the pin comes out (teeth).
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
