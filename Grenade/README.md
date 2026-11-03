# RSQ Grenade

**The one thing:** a grenade you work with your hands: pull the pin with the other hand or your teeth, cook it,
and throw it with your own arm.

A hand grenade you work with your hands. The other hand pulls the ring (or you pull the pin with your teeth), the
trigger is your grip on the spoon, and you throw it with your own arm: it leaves at the speed and in the direction
you swung. Let go without swinging and the spoon flies off and the fuse burns in your hand; hold it too long and
it goes off. Grenades lie scattered beside each map's items. For stock QuestZDoom 17.3, in VR, on plain Doom 2.
Needs no other RSQ mod. With Brutal Doom VR Reloaded loaded it stands down and BD22 VR's own grenade does
everything. Script only, no engine change.

## Features

**The grenade.**
- Weapon slot 9. Either hand can hold it: QuestZDoom's own switch-hand puts it in the off hand, and RSQ Tactical
  Rig's belt buckle hands it out.
- You start with 3 (a new game, or after dying). Carry 8; a backpack gives 6 and raises the carry to 16.
- Grenades scattered through each map, beside the items already lying there: single grenades and green packs of
  three, up to a cap a map.

**The ritual.**
- Pull the pin by the ring with the other hand, or with your teeth. The ring vanishes from the grenade when the
  pin is out. Put the pin back in by taking the ring again.
- The holding hand's trigger is your squeeze on the spoon. Let go mid-swing and it is thrown. Let go still and
  the spoon flies off (a clink) and the fuse burns in your hand: cooking.
- While the fuse burns the grenade flashes red, faster and faster, with a tick each flash.
- Cook too long and it goes off in your hand. Put the grenade away with the pin out and the pin goes back in;
  put it away with the fuse lit and it goes off.

**The throw.**
- It flies at your arm's speed, bounces off floors, walls and monsters, rolls, settles, and goes off when the
  fuse runs out: 3 seconds from the spoon flying.
- The blast is the UAC Survival Pack's full layered explosion. The kill, the obituary and the score are yours.

## How to play

No keys to bind. The grenade reads both triggers. Its menu is Options -> Radiant Silvergun Options -> RSQ
Grenade.

1. **Take it.** Press slot 9, or with RSQ Tactical Rig grip at the belt buckle. A grenade is in your hand, ring
   and spoon on it.
2. **Pin out, by the ring.** Bring the other hand to the top of the grenade and pull that hand's trigger. You
   hear and feel it take the ring. Pull the hand away about 8 cm: the pin is out and the ring is gone.
   To put the pin back in, bring that hand back to the top and pull its trigger again (before the spoon has gone).
3. **Pin out, with your teeth.** Squeeze the grenade's trigger and hold the grenade at your face for about a
   third of a second. To pull another pin that way, take it away from your face first, or let go of the trigger.
4. **Squeeze.** Hold the grenade's trigger. That is your hand on the spoon.
5. **Throw.** Swing your arm and let go of the trigger mid-swing. Faster than 2.5 m/s counts as a throw. It
   flies, bounces, settles, flashes and goes off.
6. **Cook.** Let go of the trigger with the hand still. The spoon flies off and the fuse burns in your hand,
   flashing red faster and faster. Squeeze and let go again mid-swing to throw it with what is left of the fuse.
   Hold it too long and it goes off in your hand.
7. Throw your last grenade and the hand goes back to a gun.

With Gun Bonsai VR loaded, the holding hand's alt trigger cycles the grenade kinds you have learned (until the
spoon flies); the grenade wears its kind's colour.

## Settings

Options -> Radiant Silvergun Options -> RSQ Grenade.

| Menu row | Default | What it does |
|---|---|---|
| Grenades | On | The whole mod. With Brutal Doom VR Reloaded loaded it does nothing anyway. |
| Start With | 3 | Grenades you start with (a new game, or after dying). |
| Scatter Grenades | On | Grenades scattered beside each map's items. |
| Single Grenades a Map | 4 | At most this many single grenades scattered a map. |
| Packs of Three a Map | 2 | At most this many packs of three scattered a map. |
| Pin With Your Teeth | On | Squeeze and hold the grenade at your face to pull the pin. |
| Your Own Fire Burns You | Auto (Brutal Doom: yes) | Whether the Incendiary grenade's burning ground hurts players. Auto: yes with Brutal Doom loaded, no on plain Doom. Yes / No override it. |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Fuse (s) | 3.00 | From the spoon flying off to the blast. |
| Throw Speed (m/s) | 2.50 | Let go faster than this and it is thrown; slower and the spoon flies (cooking). |
| Throw Strength | 1.00 | Times your hand's own speed. |
| Arc | 0.35 | This much of the throw's speed across the ground is added upward. |
| Gravity | 0.27 | The thrown grenade's gravity (1 = Doom's own; 0.37 is earth's). |
| Floor Bounce | 0.50 | Speed kept off a floor. |
| Wall Bounce | 0.25 | Speed kept off a wall. |
| Ground Drag | 0.82 | Per tic on the floor (1 = ice). |
| Teeth: At (m) | 0.47 | How close to your eyes the grenade must be. |
| Teeth: Again Beyond (m) | 0.71 | How far it must have gone before the teeth take another pin. |
| Teeth: Hold (tics) | 12 | How long it must stay there (35 tics = 1 s). |
| Skeet Window Slow-Mo | On | Gun Bonsai VR's Skeet Window: its slow motion after a throw. Nothing without the node. |
| Debug Log | Off | Prints the ring, the pin, the swing, the throw, each flash, the blast and the scatter to the console. |
| Reset All | - | Resets every RSQ Grenade setting. |

## Works with

- **Brutal Doom VR Reloaded:** stands down completely. Recognised by its grenade handler (RSG_Handler) at run
  time. Brutal Doom without the VR Reloaded pack is not recognised: then this grenade works beside Brutal Doom's
  own.
- **RSQ Tactical Rig:** the belt buckle hands out this grenade (grip at the buckle: the grenade to the main
  hand; grip again: your gun back), and its grenade-spot light takes the colour of the kind in your hand.
- **RSQ Gun Cards:** the grenade's card counts a cooking fuse down (Cook Sense 3).
- **RSQ Wheel:** its grenade card offers the kinds you own.
- **RSQ SlowMo:** Skeet Window pulses slow motion after a throw; Slow Burn re-pulses it on a kill by a cooked
  grenade.
- **RSQ Score:** the throw's facts (teeth, skeet, impact, a monster turned by Charm or Infight) are answered for
  the scorer, and the nodes' touches are paid to it.
- All asked by name, so each mod still loads alone. RSQ Accessibility is not read.

**Gun Bonsai VR (RSQ_GunBonsaiVR):** the grenade levels like a weapon on its own record, and its tree is:
**Bandolier** (carry 10 / 12 / 14 / 16, a backpack doubling it); **Scavenger** (more scattered a map; 3: a Kill
Rewards ammo bit may be a grenade); **Strong Arm** (throw x1.25 / 1.5 / 1.75); **Flat Arc** (less lift and
gravity); **Bounce** (wall bounce 0.4 / 0.55 / 0.7); **Cook Sense** (a tick in the hand each second of a cooking
fuse; 2: the flash runs amber, then red; 3, with RSQ Gun Cards: the card counts the seconds down); **Short Fuse**
(2.5 / 2.0 s); **Big Bang** (both blast radii +15% a level); **Frag** (both damages +15% a level); **Cluster**
(3 / 4 / 5 bomblets thrown out of the blast, going off a second later); **Sticky** (sticks to the first monster
it touches; 2: walls too); **Teeth** (a pin pulled with the teeth counts for style; 2-3: the throw after it +15% /
+30%); **Skeet** (shoot your own grenade in the air and it bursts there, harder); **Skeet Window** (needs RSQ
SlowMo: a moment after a throw time slows and the grenade glows, a window to line up the shot); **Slow Burn**
(needs RSQ SlowMo: a kill by a grenade cooked a second or more while time is slowed keeps it slowed). **The
kinds**, each an unlock, the frag the base: **Impact** (orange: bursts on first contact), **Incendiary** (amber:
fire over the blast's radius), **Freeze** (sky blue: no damage, frozen solid; a hard hit shatters it for double),
**Stun** (violet: half damage, staggered), **Smoke** (grey: a cloud that makes whoever is in it or looks through
it lose their target), **Flash** (white: no damage, stunned and blinded), **Charm** (pink: they fight for you)
and **Infight** (green: they turn on each other; bosses are immune to both). The blast that goes off in your hand
takes the same numbers and the held kind. Without the patch nothing changes.

## Load order

After Brutal Doom and the monster packs (it stands down for BD22 VR Reloaded), after Gun Bonsai and
RSQ_GunBonsaiVR, beside the other RSQ pk3s in any order.

## Known limits

- A throw is read from the fastest moment of the last seven tics: letting go still just after a fast move can
  still throw.
- It goes off in your hand at your body, not exactly at the hand (every machine in a netgame has to agree where).
- A new map puts a pulled pin back in quietly; a grenade cooking across a level change does not carry over.
- Outside VR the grenade does nothing (the gestures need the controllers).
- The explosion is about 120 short-lived effect actors. Watch frame time on the Quest when several go off at once.

## For other mods

`RSQGN_Service` (by name; absent is -1 / 0 / ""):
- `cooked` (objectArg a thrown grenade): tics it cooked in the hand before the throw; -1 for anything else.
- `teeth`, `skeet`, `impact` (objectArg a thrown grenade): 1 / 0; -1 if not a grenade.
- `turned.by` (objectArg a monster): the player whose Charm or Infight grenade turned it; -1.
- `kinds.owned` (intArg player): a bit per kind owned. `kind` (intArg player): the kind in hand. `kind.set`
  (intArg player, doubleArg the kind): 1 when taken. `kind.colour` (intArg player), `kind.colour.of` (intArg a
  kind): 0xRRGGBB, -1 the frag. GetString `kind.name` (intArg a kind): "Freeze Grenade".
- `fuse.count` / `fuse.amber` (intArg player): whole seconds left on a cooking fuse / 1 in its first half; only
  at Cook Sense 3, else -1.

It asks by name: `RSQ_MeleeUpgradeService` ("level", "upgrade.num", "claim"), `RS_ScoreService` ("touch"), and
sends the network event `rsm_pulse` to RSQ SlowMo.

## Credits

See `CREDITS.txt` (shipped). In short:

- **UAC Survival Pack** by **JohnnyDoom** (forum.zdoom.org, t=47229): its hand grenade (original by **Froon**, Brutal
  Doom version by **Saegiru**, sprites by **Pa1nki113r**), its sounds, its pickup sprites, its explosion, its ammo
  rules and its random placement.
- **Gomuz**: the grenade model.
- **The project owner**: the handling (his BD22 VR Reloaded grenade) and his RS_Grenade (the teeth, the red fuse,
  the flight, the blast's damage).
- The Gun Bonsai VR tree's effects and sounds: the owner's RS Combat FX and RS Ballistics libraries.
- QuestZDoom: Emawind and Team Beef.
