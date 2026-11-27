# RSQ FnF (Flash and Flare)

A road flare and a flashlight you take off your own body with the off hand. The flare is lit by a flick or the trigger, held up for light, and thrown; it burns for a minute wherever it lies. The flashlight hangs on a clip, switches with the trigger and runs on a battery that drains while it is on and refills while it is off.

<a name="how-to-play"></a>
## How to play

"Off hand" is the hand that does not hold your main weapon; both the flare and the flashlight are only ever held in it, and the main hand keeps its weapon. "Grip" is the off hand's grip, read by key code (443, or 436 while the main grip is held). "Trigger" is the off hand's fire: the engine's off hand attack button, or any key whose bind text contains `+oh_attack`. Neither press is eaten. Distances are real metres.

| Do this | What happens | Needs |
|---|---|---|
| Start a new game, or come back after dying | You carry 2 flares (topped up to 2 if you have fewer) | Flares: On (default); Start With (default 2) |
| Walk over a box of flares lying in a map | 6 flares. You carry 24 at most | Boxes in Levels: On (default): each item in a map has about a 1 in 21 chance of a box beside it, up to 2 boxes a map |
| Look down at your chest | A flare hangs at the pocket while you carry at least one; the flashlight hangs on its clip while it is not in your hand | Show Flare: On (default); Show Flashlight: On (default) |
| Bring the off hand within 11 cm of the pocket (on the chest toward the main hand's side: 12 cm ahead of, 15 cm to the side of and 28 cm under your eyes) and press the grip | An unlit flare, cap on, is in the off hand and one is taken from your count: a pickup sound and a short buzz in the off hand | Flares: On (default) |
| Press that grip while the engine is steadying your main weapon with both hands | The flare waits and comes up the tic the steadying ends (when you let the grip go). After 6 seconds of waiting the take is dropped with a longer buzz | |
| Press the grip at the pocket with no flares left | "No flares left" is shown. Nothing is taken | |
| With an unlit flare, press the grip at the pocket again | It goes back: your count goes up by one and the off hand gets back what it held before | |
| With an unlit flare, pull the trigger | It lights: a strike sound, a stronger buzz, and 24 tics of sputter and sparks before it burns steadily | Light It By: Either (default) |
| With an unlit flare, more than 8 tics after taking it, flick the off hand down at 1.4 m/s or more (the downward part at least 0.6 of the hand's whole speed) | It lights the same way | Light It By: Either (default); Strike Speed (default 1.4 m/s) |
| Hold a lit flare | A red-orange light of radius 140 map units sits at the burning end and flickers every 4 tics, with flame, sparks and a crackle. It burns 60 seconds in all, in the hand or out of it, and fades over the last 2 | Burn Time (default 60 s); Light Radius (default 140) |
| With a lit flare, hold the trigger (the pull that lit it counts), swing, and let the trigger go while the hand moves at 2.2 m/s or more | Thrown along the hand's own motion at 4 times the hand's fastest speed in the last 7 tics (at most 30 m/s), with 0.35 of its speed across the ground added upward and your own movement added. A buzz. The off hand gets back what it held | Throw Speed (default 2.2 m/s); Throw Strength (default 1.0); Arc (default 0.35) |
| Let the trigger go with the hand slower than 2.2 m/s | Nothing: the lit flare stays in the hand | Throw Speed (default 2.2 m/s) |
| Press the grip with a lit flare, at the pocket or anywhere | Nothing: a lit flare is never put back or dropped by the grip | |
| Watch a thrown flare | It falls at half of Doom's gravity, tumbles, bounces off floors, walls and monsters, slides to a stop and lies burning, its light 12 units above it | |
| Throw a lit or spent flare into a monster | 4 damage, once for each monster in one flight, while the flare still moves faster than 2 map units a tic | |
| Let a flare burn out | In the hand: the spent flare falls and the off hand gets back what it held. A spent flare lies dark for 10 seconds, then is gone | |
| Have more than 3 flares burning | Only 3 give light: the oldest one lying goes dark over 15 tics and burns on as flame and sparks; the one in a hand is the last to go dark. When one burns out, the last to go dark lights again | Most Lit at Once (default 3) |
| Take another weapon into the off hand, or die, with a flare out | Unlit: it goes back to your count. Lit: it falls where the hand was, still burning | |
| Leave the level with a flare in the hand | Unlit: it is back in your count on the next map. Lit: it is used up. Either way the off hand gets back the weapon it held before the flare, if you still carry it | |
| Bring the off hand within 8 cm of the flashlight clip (on the chest toward the off hand's side: 10 cm ahead of, 17 cm to the side of and 22 cm under your eyes) and press the grip | The flashlight is in the off hand and switched on: a pickup sound, a click and a short buzz | Flashlight: On (default) |
| Pull the trigger with the flashlight in the hand | It switches off, or on again: a click and a short buzz | |
| Point the lit flashlight | One spot light shines from the lens along the flashlight for 448 map units (10 degrees bright, 22 to its edge), Warm White, with a see-through cone 4 m long that stops at the first wall or monster | Beam Size: Medium, Beam Colour: Warm White, Beam Quality: Quest, Beam Length: 4 m, Show Cone: On (all defaults) |
| Press the grip at the clip with the flashlight in the hand | It goes back on the clip, switched off: a pickup sound. The off hand gets back what it held before | |
| Take a flare from the pocket while holding the flashlight | The flashlight is put away. When the flare is put back, thrown or burnt out, the flashlight comes back as it was, on or off | |
| Press the grip at the clip while holding a flare | Nothing: the off hand holds one of the two at a time | |
| Leave the flashlight on | Its battery drains: 3 minutes of light from full. A meter of 10 steps on the flashlight's body shows it. At half and under the beam dims, lower still it narrows and flickers; at the last step the meter blinks. Empty, it clicks off by itself | Battery (min) (default 3); Battery Never Drains: Off (default) |
| Leave the flashlight off, in the hand or on its clip | It recharges as fast as it drains. With under one second of light left it will not switch on: the click alone | Battery (min) (default 3) |
| Kill a monster that is inside the lit beam and in your sight | The battery gets back 5% of a full charge | Battery Never Drains: Off (default) |
| Go to the next level with the flashlight | The battery's charge is kept. A flashlight in the hand stays in the hand, switched off. Put back on its clip on the new map, the off hand still gets back the weapon it held before, if you still carry it | |
| Throw a lit flare into a zombieman, shotgunner, chaingunner, SS, imp, or another walking monster of radius 21 or less, height 64 or less and 100 health or less | The hit is Fire damage and the monster burns for 5 seconds: 3 Fire damage every 6 tics (90 in all) with flames on its body. A LegenDoom legendary or a Champions champion burns only under 25% of its health | Brutal Doom (found by its classes BDWeaponSpawner or BrutalPistol); Boosted Ignite (default 25%) |
| Pull the trigger with an unlit flare | Nothing: only the flick lights it | Light It By: Strike (default Either) |
| Flick an unlit flare down | Nothing: only the trigger lights it | Light It By: Trigger (default Either) |
| Shoot or otherwise damage a thrown or dropped flare that still burns | It goes out and lies spent | Shoot Out Flares: On (default Off) |
| Start a new level | Your flares are topped up to 4 | Refill Each Level: On (default Off); Refill To (default 4) |
| Leave the flashlight on | The battery never drains and no meter is drawn | Battery Never Drains: On (default Off), or Battery (min): 0 |
| Switch the flashlight on | The beam takes one of the six colours, never the one it had last | Beam Colour: Random (default Warm White) |
| Point the lit flashlight | The light reaches 640 or 896 map units, the cone has two layers and dust drifts in it | Beam Quality: PCVR or High (default Quest) |
| Point the lit flashlight | A soft spot is drawn where the beam lands, out to 2.5 times the light's reach | Beam Hotspot: On (default Off) |
| Point the lit flashlight | The light takes that DarkDoomZ type's colour, angles and reach; Beam Size and Beam Colour no longer apply. With the spill light on, a second wider light is added | Beam Look: DarkDoomZ (default FnF); DarkDoomZ Beam Type (default Halogen); DarkDoomZ Spill Light (default On) |
| Kill a Legion of Bones monster | 8 times in 100 it drops one battery bit; a legendary or champion always drops 3. Each bit picked up gives 15% of a full charge | Bones Drop Battery Bits: On (default Off); Legion of Bones; RSQ VisualRewards; Battery Never Drains: Off |
| Press the grip at the pocket | Nothing. No flares are given or scattered and none hangs at the pocket; a flare in the hand is put away (unlit: back to your count; lit: it falls burning). The flashlight still works | Flares: Off (default On) |
| Press the grip at the clip | Nothing. A flashlight in the hand is put away | Flashlight: Off (default On) |
| Press another button as the grip | The key codes typed in the row are read as the off hand's grip, for the pocket and the clip both | Off Grip Keys (default "443 436") |
| Reach for the pocket or the clip somewhere else | The pocket and the clip are moved, and how near the hand must come is changed | Pocket: Forward, Toward Main Hand, Height, Reach; Flashlight Clip: Forward, Toward Off Hand, Height, Reach |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ FnF (Flash and Flare)

| Option | Default | What it does |
|---|---|---|
| **Flares** | | |
| Flares | On | Turns the flares on or off (the flashlight has its own switch). |
| Light It By | Either | Light a flare with a sharp flick down, with that hand's trigger, or either. |
| Burn Time (s) | 60 (10 to 180) | Seconds a flare burns. |
| Show Flare | On | A flare you carry hangs at your pocket. |
| Show Hand | On | Draws the hand holding the flare. |
| Start With | 2 (0 to 24) | Flares you start a game with, and after dying. |
| Boxes in Levels | On | Boxes of six flares lie beside a map's items. |
| **Flashlight** | | |
| Flashlight | On | Turns the flashlight on the clip on or off. |
| Show Flashlight | On | The flashlight hangs on its clip while it is not in your hand. |
| Beam Size | Medium | How wide the beam is. |
| Beam Colour | Warm White | The beam's colour, or a random one of the six each time it is switched on. |
| Battery Never Drains | Off | The battery never drains and no meter shows. |
| Test and Debug | (page) | Flare look and supply, beam details, DarkDoomZ beam, hand speeds, pocket and clip places and the debug log. |
| Reset All | (button) | Puts every RSQ FnF setting back to its default. |

<details><summary>RSQ Fnf: Test And Debug (36 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Flares** | | |
| Soft Light | Off | Double the light's radius at half the brightness. |
| Sparks | On | Sparks fly off the burning end. |
| Smoke | Off | A thin smoke trail behind a flare. |
| Sounds | On | Every FnF sound: the strike, the crackle, the burn-out, the bounce, the take and the click. |
| Shoot Out Flares | Off | A dropped or thrown flare is put out by a shot. |
| Boosted Ignite (%) | 25 (0 to 100) | Boosted monsters (legendaries, champions) burn only below this share of their health. |
| **Supply** | | |
| Boxes a Map | 2 (0 to 8) | At most this many flare boxes a map. |
| Refill Each Level | Off | Your pocket is topped up at each new level. |
| Refill To | 4 (1 to 24) | How many flares the pocket is topped up to. |
| **Flashlight** | | |
| Beam Quality | Quest | Quest, PCVR or High: the beam's range, cone layers and dust. |
| Beam Length (m) | 4 (1 to 15) | The visible cone fades out over this length; the light reaches the whole range. |
| Beam Hotspot | Off | A soft spot where the beam lands. |
| Show Cone | On | Shows the visible tapered cone and its dust; off, the light alone. |
| Battery (min) | 3 (0 to 60) | Minutes of light from a full battery (0 never drains). |
| Bones Drop Battery Bits | Off | Legion of Bones kills drop battery bits. |
| Beam Look | FnF | The beam's look: FnF's own, or DarkDoomZ's flashlight types. |
| DarkDoomZ Beam Type | Halogen | Under the DarkDoomZ look, its type sets how far the light reaches; Beam Quality still sets the cone. |
| DarkDoomZ Spill Light | On | Under the DarkDoomZ look, a spill light beside the beam light. |
| **Flare Light** | | |
| Light Radius | 140 (48 to 480) | The flare light's radius in map units. |
| Most Lit at Once | 3 (1 to 12) | At most this many lit flares give light at once; the oldest goes dark. |
| Flicker Step (tics) | 4 (1 to 10) | Tics between flicker steps of the light's size and colour. |
| **Hands** | | |
| Strike Speed (m/s) | 1.4 (0.5 to 4) | Downward speed the flick must reach to strike a flare. |
| Throw Speed (m/s) | 2.2 (0.5 to 6) | Let go faster than this and a lit flare is thrown. |
| Throw Strength | 1 (0.25 to 3) | How hard a flare is thrown. |
| Arc | 0.35 (0 to 1) | This much of the throw's ground speed is added upward. |
| Off Grip Keys | "443 436" | The off-hand grip's key codes. |
| **Pocket** | | |
| Forward (m) | 0.12 (-0.1 to 0.4) | The pocket's place forward of your chest. |
| Toward Main Hand (m) | 0.15 (-0.4 to 0.4) | The pocket's place toward your main hand's side. |
| Height (m) | -0.28 (-0.9 to 0.1) | The pocket's height under your eyes. |
| Reach (m) | 0.11 (0.04 to 0.3) | How near the off hand must be to take or put back a flare. |
| **Flashlight Clip** | | |
| Forward (m) | 0.1 (-0.1 to 0.4) | The clip's place forward of your chest. |
| Toward Off Hand (m) | 0.17 (-0.4 to 0.4) | The clip's place toward your off hand's side. |
| Height (m) | -0.22 (-0.9 to 0.1) | The clip's height under your eyes. |
| Reach (m) | 0.08 (0.04 to 0.3) | How near the off hand must be to take or put back the flashlight. |
| Debug Log | Off | Logs the lights and the hands to the console. |
| Reset All | (button) | Puts every RSQ FnF setting back to its default. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Tactical Rig | While its flare holster holds the flares, the chest pocket is off: no take there, no flare drawn there, and the pocket's rows are greyed. The flare is then taken and put back at the Rig's flare holster (the Rig's own code, which sends this mod's take and put-back events and refuses a lit flare at every place). The flashlight clip hangs where the Rig says and the clip's three place rows are greyed; Reach still applies. The pocket and clip turn with the Rig's body. While the off hand is in one of the Rig's places, a grip there is the Rig's, not the pocket's or the clip's. A strike flick waits 3 tics and is dropped if the hand ends in one of the Rig's places. This mod answers the Rig's questions: the flare's state, the flare count, and where the pocket and clip are |
| RSQ Distance Grab | A flare lying on the floor can be grabbed (its own rule, by this flare's class name). When it throws a flare into a monster it asks this mod to set the monster on fire; this mod adds no hit damage of its own then |
| RSQ Gun Cards | This mod answers its questions for the off hand's card: flare lit or unlit and the flares left; flashlight on or off and the battery |
| RSQ VisualRewards | "No flares left" is shown as its toast. Its battery bits are what Bones Drop Battery Bits drops, and each one picked up asks this mod to add 15% charge |
| RSQ Wheel | A card for the flare or the flashlight shows the Wheel's own icon for it (the Wheel's code, by class name); this mod carries the same two icons |
| RSQ Accessibility | Rumble Strength scales every buzz; Rumble Backup is asked as each buzz starts |
| RSQ SlowMo | A monster's burn runs at the world's slowed speed: its 5 seconds, its damage and its flames |
| BD22 VR Reloaded | When the flare or flashlight leaves the off hand and it held nothing before, the off hand gets that pack's empty hands (RSQ_Hands) back. The hand drawn round the flare and the flashlight is that pack's hand mesh, placed as it places its off hand. The trigger is also read from the command before that pack's off hand can clear it. This mod's code never reads or replaces Brutal Doom's own flashlight or its key |
| Brutal Doom | A thrown flare's hit is Fire damage and sets small monsters burning (see How to play). Without it a flare never burns a monster |
| LegenDoom, Champions | A legendary or a champion burns only under Boosted Ignite (default 25%) of its health, and drops 3 battery bits when it is a Legion of Bones monster |
| Legion of Bones | Its monsters, by class name, can drop battery bits (Bones Drop Battery Bits, default Off) |
| RSQ Grenade, RSQ ShieldSaw | Nothing is asked of either. Each carries its own copy of the same throw numbers (4 times the hand, at most 30 m/s, from 2.2 m/s) |
| RSQ Glow In The Dark, RSQ LaserSight, RSQ Gun Bonsai VR | Nothing: this mod's code looks for none of them. Beam Look: DarkDoomZ is this mod's own rewrite and works without Glow In The Dark; no row on this mod's page is a Gun Bonsai VR upgrade |

## Limits

- The mod has no keys of its own: there is no KEYCONF and nothing to bind.
- Out of VR no hand is read: nothing can be taken, lit, thrown or switched.
- Buttons read: the off hand's grip (by key code) and the off hand's trigger. The main hand's fire, any alt fire, Use and the sticks are not read.
- Neither the grip nor the trigger is eaten: each still does whatever else it does in the game.
- The flare and the flashlight are only ever in the off hand, one at a time.
- A lit flare cannot be put back, put down or dropped. It leaves the hand by a throw, by burning out, or when something else takes the off hand.
- A let-go slower than Throw Speed gives no sign: no buzz, no sound.
- A lit flare does nothing to monsters unless it is thrown into one. The weapon alerts nothing and the lying flare does no damage.
- The trigger switches the flashlight wherever the hand is; only the take and the put-back need the clip.
- The backpack gives no flares and does not raise the 24.
- Only boxes are scattered. Single flares are not placed in maps, and boxes are not scattered again on a saved game or a hub map you come back to.
- A hand further than 96 units from your body throws from your body; a hand pushed through a wall throws from where the wall stops it.
- A thrown flare's upward angle is not capped.
- The beam is placed 35 times a second from the hand, ahead of it by the hand's last move and turn (the cone a whole step, drawn smoothly between steps; the light half a step, and it jumps from step to step). A hand that stops or turns back sharply is overshot for one step.
- The battery refills by itself while the flashlight is off; there is no battery pickup in this mod.
- In slow motion this mod asks RSQ SlowMo for the world's speed only for a monster's burn. A flare's own burn clock counts one tic every tic.
- In a network game the clip of every other player is drawn at your own clip settings.
- One spot light for each flashlight (two under the DarkDoomZ look with the spill light), and one point light for each flare, none with a shadow map.

## Credits

The full list, with every file and licence, is in **CREDITS.txt**.

- **presidentkoopa:** the flare model; the hands, from his Brutal Doom 22 VR Reloaded (the rifle-magazine hold for the
  flare, the shotgun pump hand for the flashlight); the throw, from his RSQ Grenade; RSQ Tactical Rig's body and hand
  geometry.
- **saegiru's Emergency Flare** (UDV Survival Flares, part of the UAC Survival Pack by JohnnyDoom): the box and lying
  flare sprites, the strike, burn and burn-out sounds, the box of 6, carrying 24, the flare's colour and the way boxes
  turn up beside items.
- **BD_VoxelPack:** DooMAD's ammo box voxel, made into the flare box.
- **Ermac's VR-Flashlight** (its base, SuaveSteve's Steve's Flashlight): the idea of a spot light that follows the
  controller, and the battery's model (its drain and recharge, its 10-step meter, its low-battery dim and flicker).
  Read and rewritten; none of its code or art is used.
- **DarkDoomZ** by Caligari87 (Sterling Parker), zlib licence: the DarkDoomZ Beam Look is an altered rewrite of its
  flashlight code (its four types and its beam and spill lights), from this pack's lens. Its licence notice is kept in
  that file. DarkDoomZ's credits also name Kinsie, Gutawer, FishyClockwork, phantombeta, Marisa Kirisame and Accensus
  (code), and Fort of Hard Knox, a1337spy and Orange Bomb (testing).
- **QuestZDoom** (Emawind and Team Beef): the engine and its VR hand API.

---
Written from the code at commit 50f608e63, 2026-11-27.
