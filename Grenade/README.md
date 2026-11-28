<p align="center"><img src="../design/readme_art/mods/grenade_title.gif" alt="RSQ Grenade"></p>

# RSQ Grenade

A hand grenade you hold, arm and throw with your own hands: pull the ring with the other hand or with your teeth, squeeze, swing and let go. It comes in nine types, can be cooked in the hand, and can be shot out of the air. The same mod gives Doom's barrels a lit blink and new explosions, and draws every grenade and barrel blast.

<a name="how-to-play"></a>
## How to play

"Grenade hand" is the hand that holds the grenade; "other hand" is the one that does not. "Primary fire" is a hand's trigger; "secondary fire" is that hand's alt fire. Distances between hands are real centimetres.

| Do this | What happens | Needs |
|---|---|---|
| Start a new game, or respawn without the grenade | You are given the grenade (weapon slot 9) and 3 grenades. It is not put in your hand | Grenades: On (default); Start With (default 3) |
| Pick the grenade from weapon slot 9 | It comes into the hand, ring in. Its own trigger fires nothing: the buttons and hands below are read instead | |
| Walk over a grenade, or a pack of three, lying in a map | 1 or 3 grenades. You carry 8, or 16 with a backpack | Grenades in Levels: On (default) puts up to 4 singles and 2 packs beside each map's items |
| Press Quick Grenade (no key is bound until you bind one) or the engine's +user1 button (Brutal Doom's Toss Grenade) | One grenade is thrown from your body along where you look, whatever your hands hold: pin sound after 7 tics, toss sound after 15, out after 17 at 45 units a tic. The next press is taken after 22 tics | Quick Grenade: On (default) |
| Press Quick Grenade with no grenades left | "No grenades" is shown. Nothing is thrown | Quick Grenade: On (default) |
| Press Quick Grenade while the grenade in your hand has its pin out | Nothing | |
| Bring the other hand within 12 cm of the ring on the grenade and press the other hand's primary fire | The ring is taken: a short buzz in the other hand | |
| Keep that fire held and pull the other hand more than 20 cm from the ring | The pin is out: a pin sound, a buzz in the other hand, and the ring is no longer drawn. Nothing burns yet | |
| Hold primary fire or secondary fire on the grenade hand with the grenade at your mouth (within 15 cm of the line from your lips to under your chin) for 12 tics | The pin comes out in your teeth: a pin sound and a buzz in the grenade hand | Pin With Your Teeth: On (default) |
| With the pin out, hold primary fire or secondary fire on the grenade hand, swing the arm, and let go of both while the hand moves at 2.2 m/s or more | Thrown. It leaves the hand along the way the hand moved, at twice the hand's fastest speed away from you in the last 7 tics (at most 30 m/s), with your own running speed added. A throw steeper than 40 degrees up is laid down to 40 | Throw Speed (default 2.2 m/s); Throw Strength (default 0.5) |
| With the pin out, hold fire on the grenade hand and let go with the hand slower than 2.2 m/s | The spoon flies off and the fuse burns in your hand (cooking): a clink and a buzz. The fuse is 3 seconds | Throw Speed (default 2.2 m/s); Fuse (default 3 s) |
| Hold a cooking grenade | A tick in the grenade hand at every second of the fuse. The grenade's flash runs amber for the first half of the fuse and red for the rest | |
| While it cooks, press and let go of primary fire or secondary fire on the grenade hand | Thrown, however slowly the hand moves. It keeps what is left of the fuse | |
| Hold a cooking grenade until its fuse ends | It goes off at your body with its full blast and one grenade is used | |
| Watch or listen to a grenade whose fuse burns, in the hand or thrown | It flashes red with a tick: every 16 tics with the whole fuse left, down to every 2 at the end | |
| With the pin out and the spoon still on, bring the other hand within about 7 cm of where the ring was and press its primary fire | The pin goes back in: a pin sound and a buzz. No grenade is used | |
| Switch weapons, or die, while the grenade cooks | The lit grenade drops at your feet and goes off when its fuse ends | |
| Switch weapons with the pin out and the spoon still on | The pin goes back in. No grenade is used | |
| With the pin in and the grenade away from your mouth, press secondary fire on the grenade hand | The next grenade type: Frag, Impact, Incendiary, Freeze, Stun, Smoke, Flash, Charm, Infight, then Frag again. A click, a buzz, and the grenade takes that type's colour | Alt Fire Changes Type: On (default); Grenade Types: All Types (default) |
| Throw a Frag | When the fuse ends: 85 damage over 200 units, then 75 over 255 a tic later. It hurts you too. Until then it bounces off floors, walls and monsters and slides to a stop | Floor Bounce (default 0.5); Wall Bounce (default 0.25); Gravity (default 0.35) |
| Throw an Impact | It bursts with the Frag's blast on the first thing it touches, once it is 2 tics out of the hand | |
| Throw an Incendiary | The Frag's blast, then the ground burns for 4 seconds over 200 units: 1 damage every 7 tics to each monster standing in it | |
| Throw a Freeze | No blast damage. Monsters within 200 units that it can see are frozen for 3 seconds. Bosses are not | |
| Throw a Stun | Half the Frag's damage. Monsters within 200 units are held in their pain frames for 3 seconds. Bosses are not | |
| Throw a Smoke | No damage. A cloud 68 units in radius (2 m) for 12 seconds: a monster in it, or whose line to its target crosses it, loses that target | |
| Throw a Flash | No damage. Monsters within 200 units are staggered for 3 seconds and forget their target | |
| Throw a Charm | No damage. Monsters within 200 units fight on your side for 15 seconds. Bosses are not turned | |
| Throw an Infight | No damage. Monsters within 200 units turn on the nearest other monster for 15 seconds. Bosses are not turned | |
| Shoot a thrown grenade: a bullet from either hand passing within 0.35 m of it, or a player's rocket or other projectile passing as near, 6 tics or more after it left the hand | It goes off where it is. In the air it is a skeet: a gold burst is added. In co-op the shooter gets the kills | Shoot Grenades: On (default); Shot Reach (default 0.35 m); Grenade Explosion: New (default) for the gold burst |
| Throw the last grenade | The main hand picks another weapon; an off hand is left empty | |
| Shoot a barrel, or catch it in a blast | It stands 5 tics, blinks lit and unlit for 10, then goes off with one of five explosions picked at random: 128 damage reaching 192 units | Barrels: On (default); Barrel Explosion: Random (default); Barrel Blast Radius (default 1.5) |
| Set off a row of barrels, each by the blast of the one before | Each barrel down the chain blows bigger and blinks shorter. From the third barrel the blast reaches further (240, 288, then 336 units) and the screen kicks a little | Chain: On (default); Chain Escalation: On (default); Screen Kick on Chains: On (default) |
| Run that chain under open sky to its third barrel or further | Every 3rd barrel plays the mega blast in place of its own, and every 5th the mushroom mega. The damage is still the barrel's | Chain Mega Every (default 3); Chain Mushroom Every (default 5); Big Blasts Outdoors Only: On (default); Mega Explosion Size (default 0.6) |
| Throw with Arc raised | That share of the throw's speed across the ground is added upward | Arc above 0 (default 0) |
| Shoot a thrown grenade while time is not slowed | Nothing: it can be shot only in slow motion | Only in Slow Motion: On (default Off); RSQ SlowMo |
| Throw a grenade in slow motion | It runs half way between the world's speed and real speed, not at the world's | Faster in Slow Motion: On (default Off); Slow Motion Speed (default 0.5); RSQ SlowMo |
| Stand in the fire of your own Incendiary | It burns you too | Your Fire Burns You: Yes (default Auto: only with Brutal Doom loaded) |
| Press secondary fire on the grenade hand with the pin in | Nothing: the type stays | Alt Fire Changes Type: Off (default On) |
| Press secondary fire on the grenade hand with the pin in | Nothing: only the Frag exists | Grenade Types: Frag Only (default All Types) |
| Hold the squeezed grenade at your mouth | Nothing: only the ring pull takes the pin out | Pin With Your Teeth: Off (default On) |
| Press Quick Grenade or +user1 | Nothing | Quick Grenade: Off (default On) |
| Shoot a thrown grenade | Nothing | Shoot Grenades: Off (default On) |
| Start a new game | You are given no grenade and none are scattered. A grenade you already carry still works in the hand | Grenades: Off (default On) |
| Shoot a barrel | Doom's own barrel death, unchanged | Barrels: Off (default On) |

## Keys

<!-- GEN:keys -->
Options > Customize Controls > RSQ Grenade

| Key | Default bind | Command |
|---|---|---|
| Quick Grenade | none | `rsqgn_quickthrow` |
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Grenade

| Option | Default | What it does |
|---|---|---|
| **Grenades** | | |
| Grenades | On | Turns the whole grenade on or off (the barrels have their own switch). |
| Start With | 3 (0 to 8) | How many grenades you start with in a new game or after dying. |
| Grenades in Levels | On | Scatters grenades beside each map's items. |
| **Throwing** | | |
| Quick Grenade | On | The Toss Grenade key or the Quick Grenade key throws one, as Brutal Doom throws. |
| Quick Grenade Key | (key) | The key or button that throws a quick grenade. |
| Pin With Your Teeth | On | Pull the pin by bringing the grenade to your mouth. |
| Grenade Types | All Types | All Types lets the alt fire cycle every grenade kind; Frag Only keeps the frag alone. |
| Shoot Grenades | On | A player's shot sets off a thrown grenade on the spot (in the air, a skeet). |
| **Explosions** | | |
| Barrels | On | Our barrels, with a blink and one of the new explosions; off leaves the stock barrel. |
| Grenade Explosion | New | The grenade's blast art: the new pixel-art blast or the original; the damage is the same. |
| Explosion Colour | Normal | The colour of barrel and grenade blasts. |
| Explosion Lights | Full | The light each blast casts: none, one flash, or stepped. |
| Test and Debug | (page) | Brutal Doom tie-ins, grenade kinds, barrels, blast contexts, throw numbers and the debug log. |
| Reset All | (button) | Puts every RSQ Grenade setting back to its default. |

<details><summary>RSQ Grenade: Test And Debug (48 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Grenades** | | |
| Replace BD Grenade | On | On, this grenade runs with Brutal Doom VR loaded and its own grenade stands down. |
| Singles a Map | 4 (0 to 16) | At most this many single grenades scattered a map. |
| Packs a Map | 2 (0 to 16) | At most this many packs of three scattered a map. |
| Your Fire Burns You | Auto | Whether the Incendiary's burning ground hurts players (Auto: yes with Brutal Doom). |
| Alt Fire Changes Type | On | The holding hand's alt fire cycles the grenade kinds. |
| **Throw** | | |
| Fuse (s) | 3 (0.5 to 10) | Seconds from the spoon flying off to the blast. |
| Throw Speed (m/s) | 2.2 (1 to 6) | Let go faster than this and it is thrown; slower and only the spoon flies. |
| Throw Strength | 0.5 (0.25 to 4) | How much of the hand's speed the grenade leaves with. |
| Arc | 0 (0 to 1.5) | This much of the throw's ground speed is added upward. |
| **Flight** | | |
| Gravity | 0.35 (0.05 to 1) | The thrown grenade's gravity (1 is Doom's). |
| Floor Bounce | 0.5 (0 to 0.9) | Speed kept off a floor. |
| Wall Bounce | 0.25 (0 to 0.9) | Speed kept off a wall. |
| Ground Drag | 0.82 (0.3 to 1) | Drag per tic on the floor (1 is ice). |
| **Shooting** | | |
| Shot Reach (m) | 0.35 (0.1 to 0.35) | How near a shot must pass a thrown grenade to set it off. |
| Only in Slow Motion | Off | Thrown grenades can be shot only while the world is slowed. |
| Faster in Slow Motion | Off | In slow motion a thrown grenade runs faster than the world. |
| Slow Motion Speed | 0.5 (0 to 1) | How far from the world's speed up to real speed a thrown grenade runs in slow motion. |
| Skeet Slow Motion | On | Gun Bonsai VR's Skeet Window: its slow motion after a throw. |
| **Teeth** | | |
| Mouth Reach (m) | 0.15 (0.05 to 0.3) | How close to your mouth the grenade must come to count as at your mouth. |
| Again Beyond (m) | 0.71 (0.3 to 1.5) | How far from your mouth it must have been before pulling another pin. |
| Hold (tics) | 12 (2 to 40) | Tics it must stay at your face. |
| **Barrels** | | |
| Barrel Explosion | Random | Which explosion a barrel plays, or a random one each time. |
| Barrel Sound | Kinetic | The barrel blast's sound set. |
| Replace BD Barrels | On | Our barrels replace Brutal Doom's barrels too. |
| Barrel Explosion Size | 2 (0.5 to 4) | The size of the barrel blast's art (the look only). |
| Barrel Blast Radius | 1.5 (1 to 3) | The barrel blast's reach. |
| Debris | 1 (0 to 1) | How much of each blast's debris is thrown. |
| **Chains** | | |
| Chain Escalation | On | Each barrel down a chain blows bigger and blinks shorter. |
| Chain Mega Every | 3 (0 to 10) | Every Nth barrel down a chain is the mega blast (0 never). |
| Mega Explosion Size | 0.6 (0.25 to 1.5) | Size of the mega blast; the mushroom mega is half again as big. |
| Chain Mushroom Every | 5 (0 to 10) | Every Nth barrel down a chain is the mushroom mega (0 never). |
| Screen Kick on Chains | On | A small short quake from the third link of a chain up. |
| Big Blasts Outdoors Only | On | With no sky above, a barrel never plays the big explosions. |
| **Explosions** | | |
| Grenade Sound | Kinetic | The grenade blast's sound set. |
| Ceiling Fit | All Mods | Keeps explosion art from poking through the ceiling, for this mod or every mod. |
| BD Launchers | On | Brutal Doom's rocket and grenade launcher shots go off with our blast. |
| Neon Room Colour | On | The Neon Crescent takes the room's Glow In The Dark colour; off keeps it pink. |
| Effects Cap | 600 (100 to 2000) | Most explosion effects alive at once; past it a blast shows its first tic only. |
| **Contexts** | | |
| Contexts | On | The room changes a blast (the rows below); off, every blast is as in the open. |
| Wall | On | Near a wall the blast fans along it and leaves a scorch. |
| Low Ceiling | On | Under a low ceiling fire and smoke roll along it. |
| Open Sky | On | Under open sky a taller column and standing smoke. |
| Water | On | Fully under water: a white flash, bubbles and silt, no fire. |
| Liquid Floors | On | On nukage, lava or blood: a crown of drops, waves and a stain. |
| Chain | On | A barrel set off by another barrel's blast is a link in a chain. |
| Crowd | On | A blast that kills 3 or more bursts each of them (its slow motion is RSQ SlowMo's). |
| Debug Log | Off | Logs the pin, fuse, flashes, throw and scatter to the console. |
| Reset All | (button) | Puts every RSQ Grenade setting back to its default. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ SlowMo | A thrown grenade, its fuse and every blast effect run at the world's slowed speed (a thrown grenade at real speed when SlowMo's own-missiles setting is off). Eight tics after a Quick Grenade leaves, this mod asks SlowMo for 1.5 seconds of slow motion and sends `rsqgn_quickslowmo` so SlowMo's own Quick Grenade row decides. With Gun Bonsai VR's Skeet Window learned it asks the same way after a hand throw and sends `rsqgn_skeetslowmo`. Getting up from SlowMo's DOWN gives one grenade |
| RSQ Gun Bonsai VR | The grenade levels like a gun: thrown grenades, bomblets and type blasts are credited to it (`claim`). It answers `loaded` with 0, so every grenade type is yours and Freeze, Stun and Flash use this mod's own freeze and stagger. Its grenade upgrades went with its upgrade trees on 2026-11-25 |
| RSQ Score | Sticky, Freeze, Stun, Flash, Smoke, Charm, Infight and fire touches are reported to Score. Score can ask a thrown grenade whether its pin was pulled by teeth, whether it was shot in the air, whether an Impact burst on touch, how long it cooked, and which player turned a monster |
| RSQ VisualRewards | "No grenades" is shown as its toast. When the type changes, the new type's name pops on the grenade in the hand |
| RSQ Gun Cards | The grenade carries the small off hand card's models. This mod answers the seconds left on a cooking grenade for the card (`fuse.count`, `fuse.amber`) |
| RSQ Wheel | This mod answers the Wheel's questions for its fan of grenade types: which types you own, which is in hand, each one's name and colour, and sets the type the Wheel picks (not while a grenade cooks). While the Wheel is open it eats the Quick Grenade key and +user1 (the Wheel's own code) |
| RSQ Tactical Rig | The Rig's grenade spot hands out this grenade (the Rig's own code, by class name). This mod answers the colour of the type in your hand, which the Rig asks for that spot. A grenade in the off hand is handled like one in the main hand |
| RSQ Glow In The Dark | Explosion Colour: Room Complement tints blasts opposite the room's glow. The Neon Crescent takes the room's glow colour |
| RSQ Monsters | Explosion Colour: Kill Colour tints a blast with the tier colour of the strongest monster it kills |
| RSQ Grapple | Its air spike asks this mod for the Neon Crescent barrel blast at the impact (128 damage, the barrel's reach), credited to the player |
| BD22 VR Reloaded | With Replace BD Grenade on (default) this grenade runs and that pack stands its own down; off, this mod hands out and scatters nothing and Quick Grenade does nothing, but a grenade already in your hand still works. Its "Use RSQ Grenade Instead" setting counts as on too. Its under-barrel launcher asks this mod to cycle the type, for the type's damage share and name, and to burst the round as a grenade of that type. A revive gives Brutal Doom's GrenadeAmmo while that pack's grenade is in charge |
| Brutal Doom | The grenade is added to slot 9 behind Brutal Doom's own five. Our barrels replace its barrels too (Replace BD Barrels, default On). Its rocket and grenade launcher shots go off with this mod's blast art (BD Launchers, default On). Your own Incendiary fire burns you (Your Fire Burns You: Auto) |
| Any mod with explosions | Ceiling Fit: All Mods (default) keeps other mods' explosion art under the ceiling, found by words in the class name (explo, boom, blast, nuke, mushroom, fireball, flame, flare, smoke, burst, kaboom) |

## Limits

- Out of VR no hand is read: the pin cannot be pulled and the grenade in the hand cannot be thrown. Quick Grenade still works.
- Buttons read: primary and secondary fire on the grenade hand, primary fire on the other hand, the Quick Grenade key and +user1. No grip, Use button or stick is read.
- The other hand's primary fire is still that hand's own trigger: a gun in it fires when you take the ring.
- With the pin out and no fire held, nothing happens: the spoon only flies when fire on the grenade hand is let go.
- Nothing catches or bats a thrown grenade back: with no grenade in a hand, the hands are not read at all.
- There is no separate underhand roll: a low or level release leaves as the hand moved. Only the upward angle is capped.
- A thrown grenade cannot be shot in its first 6 tics, a punch or other melee attack never sets one off, and a grenade in a hand cannot be shot.
- The blast hurts the player who threw it.
- A Quick Grenade flies with Brutal Doom's numbers (gravity 0.7, floor bounce 0.6, wall bounce 0.3), not the Flight rows.
- A hand further than 96 units from your body throws from your body; a hand pushed through a wall throws from where the wall stops it.
- A new map starts with the pin back in and nothing used. The grenade type you picked is kept. Grenades are not scattered again on a saved game or a hub map you come back to.
- Only the classes ExplosiveBarrel and ExplosiveBarrel1 are replaced; the Barrels rows apply to barrels that spawn after the change.
- The mega blast and the mushroom mega play only on barrel chains. No grenade plays them.
- At most 8 explosion lights at once. Past the Effects Cap (default 600) a blast shows only its first tic.
- There is one key, Quick Grenade.

## Credits

The full list, with every file and licence, is in **CREDITS.txt**.

- **presidentkoopa:** the handling, from his Brutal Doom 22 VR Reloaded grenade and his RS_Grenade (the teeth, the
  flight); RS Combat FX.
- **UAC Survival Pack** by JohnnyDoom (its grenade by Froon, Saegiru and Pa1nki113r): the sounds, the pickups, the
  original explosion, the ammo rules and the scatter.
- **Gomuz:** the grenade model.
- **Reactorcore** (Explosion Spriteanim Sheet Minipack), **Magma MK-II** (Rufaswan's sheet), **Sergeant Mark IV**
  (Meatgrinder's blood, via RSQ Monsters): explosion art.
- **QuestZDoom** (Emawind and Team Beef): the engine and its VR hand API.
- End of Starchild: the barrel death's timing, as a reference only (none of its art, sound or code).

---
Written from the code at commit 0252337bd, 2026-11-27.
