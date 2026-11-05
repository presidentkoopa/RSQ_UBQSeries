# RSQ Grenade

A hand grenade you work like a real one: pull the pin with your other hand or your teeth, squeeze the spoon, cook it,
and throw it with your own arm.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (tested on the rig, headset check pending): shooting thrown grenades and the Shot Grenade Reach slider, the teeth pin pull measured from your real eyes, grenade types without Gun Bonsai.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. On plain Doom 2
it adds its own grenade. With Brutal Doom 22 VR Reloaded loaded it stands down completely and BD22 VR's own grenade
takes over.

## Standout feature: the pin, the spoon and your teeth

Hold the grenade and squeeze its trigger: that is your grip on the spoon. Reach your other hand to the ring at the
top, pull its trigger, and draw it away. The pin is out, with the clink of the pin and a buzz in that hand. Or skip
the other hand entirely: bring the grenade to your mouth, keep squeezing, and hold it there for a moment. You pull
the pin with your teeth.

Now let go. If your arm is swinging, the grenade leaves at the speed and direction of your swing, measured against
your body, so walking and turning never count as a throw. If your hand is still, the spoon flies off and the fuse
lights in your hand. The grenade flashes red with a tick on every flash, faster and faster as the fuse runs down.
Squeeze and let go again to throw it. Hold it too long and it goes off in your hand.

Changed your mind before cooking it? Take the ring again with your other hand and the pin goes back in.

## Features

**Handling**
- Ring pull with the other hand, or the pin pulled with your teeth from your real mouth position (read from the
  headset, lips to just under the chin).
- Squeeze-and-release throwing at your arm's own speed, with a natural arc and your running speed carried into it.
- Cooking: the spoon flies, the fuse burns in your hand, and the red flash and tick speed up to the end.
- Either hand can hold it. The grenade model mirrors correctly in a left hand, ring to the thumb.
- Switch away with the spoon still on and the pin goes back in. Switch away while it cooks and it goes off.

**In the air and on the floor**
- Bounces off floors, walls and monsters, tumbles, then settles on its side and slides to a stop. Only the fuse sets
  it off.
- Shoot thrown grenades: your bullets or projectiles passing within 0.35 m (Shot Grenade Reach: tighten it down to 0.10 m) of a thrown grenade set it off on the spot,
  in the air if you are quick. Punches never do, and a grenade is safe for its first 6 tics out of the hand. Only the
  ray of the hand that fired counts. In co-op anyone can shoot anyone's thrown grenade, and the shooter gets the kill.
- Optional: only while the world is slowed by RSQ SlowMo (off by default).
- Thrown grenades slow down with RSQ SlowMo like everything else. Optional: let them run faster than the slowed world
  (off by default).

**Eight grenade types**
- The holding hand's alt fire cycles the types until the spoon flies. The grenade's colour shows
  which one you hold.
- **Frag**: the full blast. **Impact**: bursts on the first thing it touches. **Incendiary**: a blast, then burning
  ground for a few seconds. **Freeze**: freezes monsters in the blast (bosses are immune). **Stun**: half damage, and
  monsters reel in pain. **Smoke**: a cloud that blinds any monster inside it or looking through it. **Flash**: a
  bright burst that staggers monsters and makes them lose you. **Charm**: monsters in the blast fight for you for a
  while. **Infight**: they turn on each other. Charm and Infight never work on bosses.
- Without Gun Bonsai every type is available from the start (or set Frag Only). With RSQ Gun Bonsai VR you unlock
  them on the grenade's own upgrade tree.

**Supply**
- You start with the grenade and 3 grenades. Carry 8, or 16 with a backpack.
- Single grenades and packs of three are scattered beside each map's items, up to 4 singles and 2 packs a map.

## How To Play

1. Add RSQ_Grenade.pk3 to your load order and play in VR. Skip it if you play with BD22 VR Reloaded: its grenade does
   all of this already.
2. Select the grenade from slot 9 (or grab it from the RSQ Tactical Rig's belt spot).
3. Hold your main trigger. Bring your off hand to the top of the grenade, pull the off-hand trigger, and draw the hand
   away. You feel the pin go.
4. Swing your arm and let go of the trigger in mid-swing. Watch it arc.
5. Next one: pull the pin, then let go with your hand still. The spoon flies and it starts to flash. Count the ticks,
   then throw it with a squeeze and a swing. Cooked right, it bursts as it lands.
6. Try the teeth: grenade to your mouth, squeeze, hold it there half a second.
7. Tap your alt fire while holding it to try the other types.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Squeeze the spoon | Holding hand's trigger, held | |
| Pull the pin (ring) | Other hand's trigger within 12 cm of the ring, then draw the hand 8 cm further away | A buzz in the pulling hand |
| Pull the pin (teeth) | Squeeze (trigger, or alt fire) and hold the grenade at your mouth for 12 tics | Within 0.15 m of your mouth. After a pull, move it clear of your mouth or let go before the next |
| Put the pin back | Other hand's trigger at the ring again, before the spoon flies | |
| Throw | Let go of the trigger while swinging at 2.5 m/s or more | After cooking, any release throws |
| Cook | Let go of the trigger with the hand still | The fuse (3 s) starts in your hand |
| Change type | Holding hand's alt fire | Not at your mouth with the pin in (there it is the teeth's squeeze); not while cooking |
| Shoot a thrown grenade | Shoot it | Your shots and projectiles; never melee |

- Holding hand means whichever hand has the grenade; the other hand pulls the ring. Fire and alt fire are read for
  each hand as the engine maps them (main trigger and off-hand trigger).
- On QuestZDoom's default button mapping, grip plus trigger sends alt fire; the teeth accept that as a squeeze too.

## Menu

Options → Radiant Silvergun Options → RSQ Grenade. One page, and one sub menu, **Test and Debug**. With RSQ Gun Bonsai VR
loaded the page starts with "GunBonsaiOVR detected. Mod features unlocked via upgrades."; Skeet Slow-Mo is greyed until
the Skeet Window upgrade is learned, and Grenade Types is always greyed (the kinds you have learned decide).

| Row | Default | What it does |
|---|---|---|
| **Grenades** | | |
| Grenades | On | The whole mod (it stands down with BD22 VR Reloaded anyway) |
| Start With | 3 | Grenades at a new game, or after dying (0-8) |
| Grenades in Levels | On | Grenades beside each map's items |
| Singles a Map | 4 | Most singles a map |
| Packs of Three a Map | 2 | Most packs a map |
| **Throwing** | | |
| Pin With Your Teeth | On | The mouth pin pull |
| Alt Fire Changes Type | On | Alt fire cycles the grenade types |
| Grenade Types | All Types | All Types or Frag Only (without Gun Bonsai VR) |
| Your Fire Burns You | Auto | Incendiary ground hurts you: Auto (Brutal Doom: yes), Yes, No |
| **Shooting** | | |
| Shoot Thrown Grenades | On | Shots set off thrown grenades |
| Only in Slow-Mo | Off | ...only while RSQ SlowMo has the world slowed |
| Faster in Slow-Mo | Off | Thrown grenades run faster than the slowed world |
| Skeet Slow-Mo (Gun Bonsai VR) | On | Gun Bonsai VR's Skeet Window slow motion (nothing without that upgrade) |
| Reset All | | Every setting on both pages back to default |

**Test and Debug**: Fuse (3.0 s), Throw Speed (2.5 m/s), Throw Strength (1.0), Arc (0.35); Gravity (0.27), Floor Bounce
(0.5), Wall Bounce (0.25), Ground Drag (0.82), Shot Reach (0.35 m: 0.10 to 0.35, it only tightens), Slow-Mo Speed (0.5);
Teeth Mouth Reach (0.15 m), Again Beyond (0.71 m), Hold (12 tics); Debug Log (Off); Reset All.

## Works with

Runs alone on plain Doom 2. It finds the others by name:
- **Brutal Doom 22 VR Reloaded**: RSQ Grenade stands down entirely (no grenade, no scatter, no start grenades);
  BD22 VR's own grenade is the one you use.
- **RSQ Tactical Rig**: without BD22 VR, the Rig's belt-buckle grenade spot hands out this grenade, shows it hanging
  there, and glows in the colour of the type in your hand.
- **RSQ SlowMo**: thrown grenades slow with the world (unless SlowMo is set to leave your own missiles in real time);
  Only in Slow Motion and Faster Grenades in Slow Motion read it.
- **RSQ Weapon Wheel** fans out the types you own; **RSQ Gun Cards** shows the fuse count with the Cook Sense upgrade;
  **RSQ Score** scores teeth pulls, shot grenades and impact bursts.
- **Gun Bonsai + RSQ Gun Bonsai VR**: the grenade levels like a weapon, with its own tree: the types, Short Fuse, Cook
  Sense, Teeth, Strong Arm, Flat Arc, Bounce, Sticky, Skeet, Skeet Window, Big Bang, Cluster, Bandolier and Scavenger.
  Freeze, Stun and Flash then use its freeze and stagger (a frozen monster shatters on the next hard hit); without it,
  this mod freezes and staggers on its own.
- **Brutal Doom** (without BD22 VR): Incendiary's burning ground hurts you too, on Auto.

## Credits and licence

- **UAC Survival Pack** by JohnnyDoom: its hand grenade (original by Froon, Brutal Doom version by Saegiru, sprites by
  Pa1nki113r). Its sounds (blast, distant blast, pin, throw, spoon, bounce, tick), pickup and thrown sprites, explosion
  sprites and the explosion itself, its ammo rules and its random placement beside map items, rewritten in ZScript.
  Lumps renamed so no other mod's are replaced.
- **Gomuz**: the grenade model and skin (its red fuse-flash skin and the type colours are recolours).
- **presidentkoopa** (project owner): the handling, from his BD22 VR Reloaded grenade (ring pull, spoon, swing throw,
  cook, cook-off; its held placement and measured ring point); his RS_Grenade (the teeth, the speeding red flash, the
  flight numbers, the blast damage and its port of the pack's explosion); the upgrade tree's effects and sounds from
  his RS Combat FX and RS Ballistics libraries.
- Generated for this pack: transparent placeholder sprites.
- **QuestZDoom** (Emawind and Team Beef): the engine, and its off-hand weapon and hand-pose API.

Every base sound is the UAC Survival Pack's own recording; nothing is synthesized.

Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors' terms; sharing other
people's work in this pack is the project owner's decision.
