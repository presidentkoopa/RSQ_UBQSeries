# RSQ Distance Grab

Point an open palm at a pickup, a gun or a barrel across the room, flick your wrist, and it flies to your hand. Pickups are used as they land; barrels are carried, swung, held up as a shield and thrown. Up close the grip takes things straight off the floor, lifts doors by hand, and a palm laid on a switch flips it.

<a name="how-to-play"></a>
## How to play

"Main hand" is the hand that holds your gun; "off hand" is the other. Every row works with either hand unless it says so. "Palm out" means the controller rolled a quarter turn onto its side (within 30 degrees of 90) and not pointing more than 30 degrees below level. "Grip" is the grip button, read by key code (446 on the main hand, 443 or 436 on the off hand). 34 map units are one metre across the floor. Fire, alt fire and the sticks are never read.

| Do this | What happens | Needs |
|---|---|---|
| Turn a palm out and point the hand | A blue beam, a dot where it lands and a faint cone are drawn from that palm. The cone is what the grab can take: 12 degrees either side of the hand's line, out to 512 units (about 15 m) | Distance Grab: On (default); Beam, Dot, Reach Cone, Show When Idle: On (default) |
| Point the palm at a pickup, a gun, a barrel or a flare inside the cone, with nothing in the way | It is locked at once: it glows green and breathes, the beam turns green and runs to it, one tick in that hand, then a low hum while it stays locked. The thing nearest the hand's line wins; barrels, guns, keys and flares win ties over ammo, health and armour | Line of Sight: On (default); Target Glow: On (default); Haptics: On (default) |
| Keep the palm out and point or look elsewhere | The lock stays on that thing. It ends when the palm turns back, when the thing is taken or can no longer be grabbed, or when it is more than 640 units (1.25 times Reach) from the palm | |
| With a lock, tip the wrist up sharply (5 degrees in one tic or faster) and roll the palm back within a fifth of a second | The thing flies to that hand on an arc at 22 m/s (at least 6 tics, at most 40), turning end over end once and leaving a faint green trail. A tick in the hand, then a rumble that builds as it comes | Flight Path: Arc (default); Flick Strength (default 5) |
| With a lock, roll the palm back without the flick | The lock is let go. Nothing moves | |
| Turn the palm out again before the pulled thing arrives, and hold it there | Caught when it comes within 24 units of the palm: a thud, a strong tick (two for a heavy thing) and a green bloom at the palm | Catch Distance (default 24); Catch Flash: On (default); Sounds: On (default) |
| Leave the palm turned away as the pulled thing arrives | It waits on the palm for 4 tics, then drops from there | Catch Window (default 4 tics) |
| Catch a pickup: ammo, health, armour, a key, a powerup | It is picked up at once, as if you had walked over it | Use On Catch: On (default) |
| Catch a gun | It is picked up and goes to the hand that caught it: the main hand switches to it, or it is raised in the off hand. A melee weapon, an off-hand-only, two-handed or never-switches weapon, and a gun already in the other hand, stay where the game put them | Use On Catch: On (default) |
| Catch a gun you already have with its ammo full, ammo you are already full of, or a health or armour pickup you cannot use | It is not taken. AMMO FULL, HEALTH FULL or ARMOR FULL is shown, the hand gets a soft buzz, and the thing is put at your feet. Caught by the off hand, the gun you already own is raised in the off hand | Use On Catch: On (default) |
| Catch a barrel, or any other pickup the game would not take (not a gun, ammo, health or armour) | It is carried: it floats about 30 cm ahead of that hand and follows it on a spring, lagging and hanging lower the heavier it is, and it tips with your wrist | Tip With Wrist: On (default); Hold Distance (default 0.30 m) |
| Carry something heavy | You move slower: a 60 kg barrel leaves you at two thirds of your speed | Heavy Slows You: On (default); Half Speed Mass (default 120 kg) |
| Roll the palm back while the carrying hand is still | The thing is set down: it drops where it is | |
| Swing the carrying arm away from you and roll the palm back | Thrown, with a whoosh. The hand holds on until the forward stroke peaks (at most 9 tics), then the thing leaves at the stroke's fastest speed times arm / (arm + its weight) times 2.5: a clip at about 2.5 times your hand's speed, a 60 kg barrel at about 0.8 times | Throw Strength (default 1); Throw Boost (default 2.5); Arm Weight (default 30 kg) |
| Throw within 12 degrees of a monster you can see, up to 1200 units away | The throw bends onto the monster and is lobbed to come down on its middle | Throw Aim Assist (default 12) |
| Hit a monster with a thrown thing | Damage by weight and speed: half its kilograms times its speed squared, one point for every 15 joules, nothing under 3 m/s. 20 damage or more puts the monster in pain and shoves it | Impact Damage (default 15); Min Impact Speed (default 3 m/s); Stagger From (default 20) |
| Throw a barrel at 4 m/s or more | It goes off where it first hits or lands, and the kills are yours | Barrel Blast (default 4 m/s) |
| Put a palm within 30 cm of a pickup, a gun, a barrel or a flare and press that hand's grip | Walk-up grab. A pickup is picked up (a gun into that hand); a barrel is carried and the grip now holds it. A gun, health or armour you cannot use is left where it is, with the same AMMO FULL, HEALTH FULL or ARMOR FULL | Walk Up Grab: On (default); Walk Up Reach (default 0.30 m) |
| Let go of the grip while it holds a carried thing | A still hand sets it down. A moving hand throws it, by the same rule as the palm's throw | |
| Press the grip while the hand carries a thing the palm caught, or keep the grip squeezed as a pulled thing arrives | The grip takes the carry over: the palm no longer matters, and the thing stays in the hand until the grip is let go | |
| Lay the other palm on a carried thing (within its body plus 25 cm), that hand carrying nothing | Both hands carry it: a thud, it sits between the two hands and handles as if half as heavy, so it follows faster, sags less and throws harder | Two Hand Lift (default 2) |
| Swing a carried thing into a monster at 3 m/s or more | It hits, by the same weight and speed rule as a throw: once per swing for each monster, up to 4, with a thud and a tick in the hand | Swing Hits: On (default); Swing Hits From (default 3 m/s) |
| Hold a carried barrel between you and a fireball or other projectile | The projectile stops on the barrel and goes off there. The barrel takes the hit, so it can blow up in your hand | Body Shield: On (default) |
| Walk away from a carried thing that is stuck behind a wall (more than 1.5 m from where the hand wants it for half a second) | The hand rumbles harder the further it is held back, then lets go and the thing is set down there | Break Distance (default 1.5 m); Held Back Rumble: On (default) |
| With a barrel in one hand, or standing within 64 units of a barrel, turn a free palm out at a monster (within 12 degrees, 512 units, in sight) | The monster is locked and glows green. That palm takes no pickup while it is on a monster. The lock holds while a palm stays within 24 degrees of it, and for 3 seconds after | Barrel Lock On: On (default) |
| Throw a barrel while a monster is locked | The barrel flies to the locked monster and is steered onto it all the way, at least as fast as the 45 degree lob that reaches it, and its blow lands when it meets the monster. For half a second after the lock ends it still goes to where the monster last was | Barrel Lock On: On (default) |
| Put a hand within 7 units (about 20 cm) of the front of an ordinary door, then press that hand's grip, press Use, or turn the palm out against it, and raise the hand | You hold the door. It follows your hand up, eased; 22 cm of lift or less brings any door to its commit point. The door's own opening sound plays faster the faster you lift, and the hand ticks faster past half open | Lift Doors: On (default); Grip Takes Door, Use Takes Door, Palm Takes Door: On (default); Door Reach (default 0.22 m) |
| Let go of the door (grip and Use released, palm turned back) with it 40% open or more | The door finishes opening by its own action, waits and closes as it always did. A tick in the hand | Door Commit Point (default 0.40) |
| Let go of the door below 40% open | The door drops shut | |
| Throw the hand upward (1.2 m/s over 3 tics) as you let go | The door finishes opening from 15% open | |
| Take hold of a locked door without its key | Nothing lifts, and the game shows its own locked message | |
| Lay a palm turned out on the front of a switch (within 7 units), the hand carrying nothing | The switch is used once, exactly as a Use press would. The palm must leave it before it can be used again | Palm Flips Switches: On (default) |
| Hold a gun in both hands: the off hand 5 to 70 cm ahead along the barrel and within 20 cm of its line, or the two hands within 16 cm of each other, or QuestZDoom's own two-hand grip | Distance Grab stands down on both hands until half a second after the hands part: locks are let go, no beam, no walk-up grab. A hand already carrying keeps its thing | Two Hand Reach (default 0.2 m) |
| Punch, or move a hand at 2 m/s or more | That hand does not reach for the next 0.75 seconds. A hand with a lock, a pull or a carry is not stood down | Not With Melee: On (default) |
| Hold a palm out for half a second on a hand that holds a melee weapon | No reach. The console line "Distance Grab: the main hand does not reach" (or "the off hand") says why, at most once every 10 seconds for the same reason. Bare fists and Brutal Doom's fists do reach | Not With Melee: On (default) |
| Pull a thing that meets a wall, or that cannot arrive in time | The pull ends and the thing drops where it is | |
| Die, or turn Distance Grab off | Locks end, pulls stop where they are, and carried things are put down | |
| Bind Main Hand Key or Off Hand Key (no key is bound until you bind one), turn that palm out and press the key | The thing the cone has is locked, or a pulled thing within 24 units of that palm is caught. The hand stays armed while the key is held; once the palm turns away, for at most 10 seconds more | Grab Keys: On (default Off); Palm Gate: On (default) |
| Let go of the Main Hand Key or Off Hand Key | A carried thing is thrown or set down. A lock is pulled if the wrist tipped up in the last fifth of a second, and let go if it did not | Grab Keys: On (default Off) |
| With Grab Keys on, turn a palm out and press no key | The palm still locks and still catches. Rolling it back neither pulls nor lets go: the lock ends by itself 10 seconds later, and a carried thing stays until a key press and release, or the grip, lets it go | Grab Keys: On (default Off) |
| With Grab Keys on, point either hand at a thing without turning the palm out | That hand locks whatever it points at, all the time, with no key pressed. A key press and release with a flick pulls it | Grab Keys: On (default Off); Palm Gate: Off (default On) |
| Point a palm at a corpse, or grip one within 30 cm | Corpses lock, pull, carry and throw like barrels. A carried corpse also stops bullets and projectiles | Corpses: On (default Off) |
| Catch or grip a pickup | It is carried in the hand, not used, until you set it down or throw it | Use On Catch: Off (default On) |
| Hold the palm on one thing for the set number of tics | The thing glows amber while you wait, then locks and turns green | Lock Delay above 0 (default 0) |
| Flick to pull | Steer: the thing homes on the palm at up to 12 m/s, slower and lazier the heavier it is. Lob: it is lobbed under gravity, peaking about 1 m up, and the lob follows your hand | Flight Path: Steer or Lob (default Arc) |
| Hit a monster with a thrown thing | The monster also freezes for 3, 4 or 6 tics | Hit Stop: Tap, Beat or Heavy (default Off) |
| Point a palm at a thing behind a wall | It can be locked and pulled; the pull still stops at the wall | Line of Sight: Off (default On) |
| Press the grip with the palm on a pickup | Nothing: the grip only takes doors and takes over carries | Walk Up Grab: Off (default On) |
| Hold RSQ Accessibility's Off-Hand Modifier | The main controller plays the off hand's part (its reach, lock, catch and carry) and the main hand's own part stands down | RSQ Accessibility, One-Handed: On |
| Press RSQ Accessibility's Pull gesture button | Whatever a hand has locked flies to it now, with no wrist flick (the main hand's lock first) | RSQ Accessibility, One-Handed: On |
| Hold RSQ Accessibility's Reach gesture button | The main hand (the off hand's part while the Off-Hand Modifier is held) stays armed as if its palm were held out: it catches and keeps its carry. Letting go is the palm rolled back. A new lock still needs the palm really turned out | RSQ Accessibility, One-Handed: On |

## Keys

<!-- GEN:keys -->
Options > Customize Controls > RSQ Distance Grab

| Key | Default bind | Command |
|---|---|---|
| Grab / pull (main hand) | none | `+rsqdg_main` |
| Grab / pull (off hand) | none | `+rsqdg_off` |
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Distance Grab

| Option | Default | What it does |
|---|---|---|
| Distance Grab | On | Turns the whole distance grab on or off. |
| Reach | 512 (64 to 2048) | How far away you can pull things from. |
| Aim Width | 12 (2 to 45) | How precisely you have to point at a thing to grab it (wider is easier). |
| Corpses | Off | Lets you grab corpses and carry them as props. |
| Lift Doors | On | Take hold of a door and lift it open by hand. |
| **Pull and Throw** | | |
| Flight Path | Arc | How a pulled thing flies to you: Steer homes on your palm, Lob throws it in a lob, Arc follows a smooth arc. |
| Use On Catch | On | A caught pickup is used at once (a gun equipped, a medikit healing you); off carries it instead. |
| Throw Strength | 1 (0.25 to 4) | How hard your throws are. |
| Heavy Slows You | On | Carrying heavy things slows you down. |
| Body Shield | On | A held corpse or barrel stops shots and fireballs (a barrel goes off when hit). |
| Barrel Lock On | On | A free palm locks onto a monster, and barrels you throw or uppercut fly to it. |
| **Show and Feel** | | |
| Beam | On | Draws the grab beam from your palm to what it points at. |
| Haptics | On | The controllers rumble and tick as you lock, pull and catch. |
| Test and Debug | (page) | Opens the tuning numbers, the rarer switches and the debug logs. |
| Reset All | (button) | Puts every RSQ Distance Grab setting on both pages back to its default. |

<details><summary>RSQ Distance Grab: Test And Debug (98 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Controls** | | |
| Grab Keys | Off | Grab with a key as well as the palm gesture. |
| Main Hand Key |  | The key that grabs and pulls with your main hand (read only with Grab Keys on). |
| Off Hand Key |  | The key that grabs and pulls with your off hand (read only with Grab Keys on). |
| Palm Gate | On | With Grab Keys on, the key only grabs while your palm is turned out. |
| Not With Melee | On | A hand holding a melee weapon or another mod's hand does not reach. |
| Line of Sight | On | Only things you can see can be grabbed, not things through a wall. |
| **What You Can Grab** | | |
| Barrels | On | Barrels can be grabbed. |
| Flares | On | Flares lying on the floor can be grabbed. |
| Weapons | On | Guns can be pulled to you. |
| Powerups | On | Spheres, berserk, the suit and the map can be pulled. |
| Ammo | On | Ammunition can be pulled. |
| Health | On | Medikits and stimpacks can be pulled. |
| Armor | On | Armour can be pulled. |
| Keys | On | Keys can be pulled. |
| Bonuses | On | The small health and armour bonuses can be pulled. |
| Walk Up Grab | On | Gripping a thing with your palm up close takes or carries it. |
| **Doors and Switches** | | |
| Grip Takes Door | On | The grab's grip takes hold of a door. |
| Use Takes Door | On | Pressing Use takes hold of a door. |
| Palm Takes Door | On | A palm turned out against a door takes hold of it. |
| Palm Flips Switches | On | A palm laid on a switch flips it. |
| **Pull and Carry** | | |
| Pull Gravity | Off | A pulled thing sags under gravity on its way to you. |
| Duck Under Doors | On | A pulled thing dips under a low ceiling ahead, such as a doorway. |
| Pull Trail | On | A faint trail behind a pulled thing. |
| Tip With Wrist | On | A held thing tips with your wrist. |
| Swing Hits | On | A held thing swung into a monster hits it. |
| Hit Stop | Off | A monster hit by a thrown thing freezes for a moment. |
| Sounds | On | Whoosh on a throw and a thud on a catch or landing. |
| Landing Dust | On | A hard landing kicks up dust. |
| **Beam and Feel** | | |
| Dot | On | A glow where the grab line lands. |
| Reach Cone | On | Shows the cone the grab reaches through. |
| Show When Idle | On | Draws the beam even when it has found nothing. |
| Yield to Laser | Off | Hides the grab beam on a hand the Laser Sight is already lighting. |
| Target Glow | On | The target lights up in its own silhouette. |
| Voxel Flash | On | A voxel target flashes its colour instead of the glow. |
| Recolour Target | Off | Recolours the target itself. |
| Catch Flash | On | A green bloom at your palm on a catch. |
| Rumble | On | Uses the rumble route for haptics; off uses the fixed buzz (turn off if Quake Haptics is 0). |
| Approach Ping | On | A ping that speeds up as a pulled thing closes in. |
| Held Back Rumble | On | Rumbles when a carried thing is held back by a wall. |
| **Gesture** | | |
| Palm Roll | 90 (0 to 180) | The palm-out wrist roll that arms the reach. |
| Roll Tolerance | 30 (5 to 90) | How far off the palm roll may be and still count. |
| Min Hand Pitch | -30 (-90 to 60) | The hand must point above this pitch to reach. |
| Flick Strength | 5 (1 to 20) | How sharp a wrist flick must be to pull. |
| Lock Delay (tics) | 0 (0 to 35) | Tics the cone must hold the same target before it locks. |
| Two Hand Reach (m) | 0.2 (0 to 0.4) | An off hand this close to the gun's barrel counts as two-handing, and the grab stands down. |
| Hand Lead (tics) | 1 (0 to 2) | Draws the beam's hand end ahead of the hand to cancel the render lag. |
| Pose Jump Cutoff (m) | 1 (0.25 to 3) | Hand travel in one tic above this is treated as a tracking glitch. |
| Walk Up Reach (m) | 0.3 (0.1 to 0.6) | How close your palm must be to a thing for the walk up grab. |
| Main Grip Key Codes | "446" | The main grip's key codes, as the Tactical Rig reads them. |
| Off Grip Key Codes | "443 436" | The off grip's key codes. |
| **Pull** | | |
| Arc Speed | 22 (4 to 40) | Speed of the Arc pull. |
| Arc Height | 0.25 (0 to 0.5) | Height of the Arc pull as a share of its distance. |
| Arc Pull In | 1.6 (1 to 3) | Above 1 the Arc pull starts slower and speeds up. |
| Shortest Flight (tics) | 6 (1 to 35) | The shortest an Arc pull may take. |
| Longest Flight (tics) | 40 (10 to 140) | The longest an Arc pull may take. |
| Pull Smoothness | 0.6 (0 to 1) | How much of the flight settles softly into the hand. |
| Pull Spin (turns) | 1 (0 to 3) | Turns a pulled thing makes about its own up. |
| Tumble | 1 (-2 to 2) | End over end turns across the whole pull. |
| Lob Height (m) | 1 (0.25 to 3) | How high the Lob pull peaks. |
| Pull Speed | 12 (2 to 40) | The speed the Steer pull aims for. |
| Steering | 40 (5 to 150) | How hard the Steer pull can turn. |
| Pull Strength | 10 (1 to 100) | The mass the pull moves almost effortlessly; higher makes heavy things come easier. |
| Flight Width | 2 (1 to 16) | The width a pulled thing flies with. |
| Give Up After (tics) | 140 (35 to 350) | The least time before a pull that cannot arrive is dropped. |
| **Catch and Carry** | | |
| Catch Distance | 24 (8 to 64) | How close a pulled thing must come to your hand to be caught. |
| Catch Window (tics) | 4 (1 to 16) | How long the catch window stays open. |
| Hold Distance (m) | 0.3 (0 to 1.5) | How far ahead of your hand a held thing sits. |
| Hold Stiffness | 0.6 (0.1 to 0.95) | How stiffly a held thing follows your hand. |
| Max Hold Speed | 40 (10 to 80) | The fastest a held thing may move. |
| Break Distance (m) | 1.5 (0 to 4) | Held back this far for half a second and you let go (0 is never). |
| Half Speed Mass (kg) | 120 (20 to 400) | Carrying this much halves your speed. |
| Heavy Sag | 1 (0 to 2) | How low heavy things hang and dip when swung (0 is off). |
| Two Hand Lift | 2 (1 to 4) | Your other palm on a held thing makes it handle this many times lighter. |
| **Throw** | | |
| Throw Boost | 2.5 (1 to 5) | Multiplies the speed of a throw. |
| Throw Aim Assist (deg) | 12 (0 to 30) | A throw within this angle of a monster bends to hit it (0 is off). |
| Throw Spin | 1 (0 to 3) | How fast a thrown thing turns in the air. |
| Throw Gravity | 0.27 (0.1 to 1) | Share of Doom's gravity a thrown thing falls at. |
| Flutter | 0.35 (0 to 2) | Sideways wobble of light fluttering things in the air. |
| Air Time Limit (tics) | 1400 (140 to 4200) | How long the air holds something that never lands. |
| Arm Weight (kg) | 30 (5 to 100) | Your arm's weight; heavier things leave your hand slower. |
| Impact Damage | 15 (2 to 60) | Energy of a thrown thing per point of damage it does. |
| Min Impact Speed (m/s) | 3 (0 to 10) | Below this speed nothing counts as an impact. |
| Stagger From (damage) | 20 (5 to 100) | Damage from a thrown thing that staggers a monster. |
| Barrel Blast (m/s) | 4 (0 to 15) | A barrel thrown this fast goes off where it lands (0 is never). |
| Swing Hits From (m/s) | 3 (1 to 8) | A held thing swung slower than this does not hit. |
| **Beam and Feel** | | |
| Beam Width | 1 (0.25 to 4) | Width of the grab beam. |
| Beam Brightness | 0.8 (0.1 to 1) | Brightness of the grab beam. |
| Dot Size | 1 (0.25 to 4) | Size of the dot. |
| Cone Brightness | 0.45 (0.05 to 1) | Brightness of the reach cone. |
| Glow Brightness | 1 (0.25 to 2) | Brightness of the target glow. |
| Pulse Period (tics) | 24 (6 to 70) | Tics per full pulse of the target glow. |
| Rumble Strength | 1 (0 to 2) | Strength of the grab's rumble. |
| Locked Rumble | 0.15 (0 to 0.6) | The steady rumble while something is locked. |
| Door Commit Point | 0.4 (0.1 to 0.9) | Let go of a door past this much open and it finishes opening. |
| Door Lift Gain | 2.5 (1 to 5) | Door travel per unit of hand travel. |
| Door Reach (m) | 0.22 (0.08 to 0.6) | Hand lift that brings any door to its commit point. |
| **Debug** | | |
| Report Actions | Off | Logs what the grab did. |
| Report Refusals | Off | Logs why the grab refused something. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Melee | A living monster is never Distance Grab's: the off hand's Headlock is Melee's. Distance Grab asks Melee whether its Headlock takes the off grip and leaves the press to it if so; Melee asks back how near Distance Grab's nearest thing is. A monster thrown out of the Headlock flies through Distance Grab's throw (strength, weight, boost, aim assist, impact). Melee's uppercut sends a barrel to the Barrel Lock-On's monster. An idle hand in Melee's Boxing Gloves or Slappers Only never reaches, and the punch speed that stands a hand down is Melee's Punch Min Speed |
| RSQ Tactical Rig | A hand the Rig says is busy ("rig.busy") does not reach. A hand inside one of the Rig's regions ("rig.region") does not walk-up grab, start a door hold or flip a switch. The Rig can ask RSQDG_DoorService whether a hand holds a door |
| RSQ Accessibility | Gesture Ease widens the palm's roll tolerance (up to double), lowers its pitch floor (up to 30 degrees more) and lowers the flick needed (down to half). Steady Hands smooths where the cone and the idle beam point. One-Handed adds the Off-Hand Modifier and the Pull (1) and Reach (2) gesture buttons; buttons 3 to 5 are not Distance Grab's. Rumble Strength scales every rumble, and Rumble Backup is asked each time a rumble starts. Photosensitive Mode spaces and dims the catch bloom and slows the pulses. Colour blind modes recolour the beam, cone, glow and trail. Cue Size scales the beam, dot, bloom and the glow's rim |
| RSQ Saber | A saber's hand reaches, lit or not; a swing stands it down for 0.75 seconds like a punch. Its other hand weapons (class names starting UBQS_ that are not the saber) do not reach. A caught saber is not moved between hands. A saber in the main hand does not count as two-handing by where the off hand is |
| RSQ ShieldSaw | A hand holding the ShieldSaw does not reach (Not With Melee). A caught ShieldSaw is not moved between hands |
| RSQ LaserSight | With Yield to Laser on (default off), the grab's beam is hidden on a hand LaserSight is already drawing a beam on; the dot and cone stay |
| RSQ VisualRewards | AMMO FULL, HEALTH FULL and ARMOR FULL are shown as its HUD toast (or its word over the thing); without it, a short centre print. Its Kill Rewards bits are never locked, pulled or gripped |
| RSQ Score | A monster hit by a swung carried thing is reported to Score as "grab.swing" before the blow. Score can ask RSQDG_ThrowService who threw a thing, how long ago, how hard it landed, its weight, whether the throw set it off and how many times it was caught back out of the air |
| RSQ SlowMo | It can ask RSQDG_ThrowService ("lockon.met") whether a barrel's steering ended on its locked monster |
| RSQ FnF | Its flares lying on the floor can be locked, pulled and gripped (Flares, default on). A thrown flare that hits a living monster is reported to FnF ("flare.hit") |
| RSQ Whip | Whip's own code hears the two Grab Keys and grips its rope with them (its Grab Keys Grip Rope row), whatever Distance Grab's Grab Keys row says |
| RSQ Gun Bonsai VR | Nothing. The grab has no upgrade tree and no row is greyed |
| BD22 VR Reloaded | Its two-hand holds (RSQ_TwoHandAimed, RSQ_TwoHandRifle, RSVR_MeleeTwo) count as two-handing. A hand holding its axe (BrutalAxe, RSQ_Off_BrutalAxe) reaches. Its empty hand (RSQ_Hands) is never moved between hands |
| Brutal Doom | Its floor guns (BDWeaponSpawner) count as weapons, its barrels count as barrels by what they replace, its invisible spawner leftovers are never locked, its fists reach, its head hitboxes are not hit twice or aimed at, and its burning barrel is set off by a hard throw |
| Voxel packs (VOXELDEF, voxels/) | A thing drawn as a voxel flashes its colour and gets no glow twin, tumbles in a pull, and turns all three ways in the hand |
| Any pk3 with a MASSDEF lump | Its weights are read; a later line for the same class wins. A weapons pack with RS_WeaponWeightService gives measured gun weights |
| Any mod with a GrabEventService | It is told every lock, pull, catch, drop, throw, hit and block ("grab.event"). It is also asked about each pickup before the game is ("pickup.first": 1 it gave the thing itself, -1 it refuses it as AMMO FULL) and after a refusal ("pickup.claim") |
| An engine that offers RSLaserService | The beam and dot are drawn by the engine's laser; stock QuestZDoom draws the model beam and sprite dot |

**Services this mod answers** (asked by name):

| Service | Request | Answer |
|---|---|---|
| RSQDG_ThrowService | GetInt "hold.full" (hand; pawn) | 1 while that hand of this machine's player carries something |
| RSQDG_ThrowService | GetInt "near.dist" (hand; pawn) | -2 while that hand is Distance Grab's already; else map units from the palm to the nearest walk-up thing; -1 none |
| RSQDG_ThrowService | GetInt "headlock.throw" (player number, weight %; monster) | Throws that monster as a carried thing is thrown and watches it land. 1 done |
| RSQDG_ThrowService | GetInt "headlock.caught" (player number; monster) | Plays the catch's thud and tick in the off hand. 1 done |
| RSQDG_ThrowService | GetInt "lockon.on" (player number) | 1 while that player's Distance Grab and Barrel Lock On are both on |
| RSQDG_ThrowService | GetInt "lockon.kick" (player number, forward speed; barrel) | 1 when the barrel was sent to the locked monster; 0 when the caller should kick it itself |
| RSQDG_ThrowService | GetInt "lockon.met" (barrel) | 1 once that barrel's steering ended on its locked monster |
| RSQDG_ThrowService | GetInt "throw.by", "throw.age", "throw.cms", "throw.kg", "throw.blast", "throw.juggle" (thing) | Thrower's player number; tics since release; landing speed in cm/s (-1 in flight); kilograms; 1 if the throw set it off; mid-air re-catches. -1 for a thing not thrown in the last 10 seconds |
| RSQDG_MassService | GetDouble "mass.kg", "mass.drag" (thing) | Its weight in kilograms; its MASSDEF drag |
| RSQDG_MassService | GetInt "mass.hello", "mass.flags", "mass.stated", "mass.grams" (thing) | 1; its MASSDEF flags (1 flutter, 2 impact explode); 1 if its weight was stated, 0 if guessed; its weight in grams |
| RSQDG_GrabRuleService | GetInt "grab.hello", "grab.rule", "grab.deny", "grab.weight", "grab.forget" (class name) | 1; makes that class grabbable; refuses it; sets how hard it competes in the cone; removes its rule |
| RSQDG_DoorService | GetInt "door.holding" (hand) | 1 while that hand of this machine's player holds a door, else -1 |

## Limits

- Every hand is read from the controller pose of this machine's player. Another player's hands are never read.
- Buttons read: each hand's grip (by key code), Use (for doors only), and the two optional Grab Keys. Fire, alt fire and the sticks are never read, and no key is found by its bind.
- A living monster, a player, a projectile in flight, an invisible thing, a thing already in someone's inventory, and a barrel that is already going off are never locked, pulled or gripped. Lamps, columns, trees and other decorations are not grabbable; of solid props only the two barrels are.
- Corpses are off by default.
- One thing per hand. A hand that is pulling or carrying takes no new lock, and the two hands cannot lock, pull or hold the same thing.
- A thing you have just thrown cannot be locked again until it has landed.
- The beam, dot and cone are hidden while a hand is pulling or carrying.
- A pull that is blocked by a wall drops there. A pull gives up after at least 140 tics.
- A caught barrel is not solid in your hand: it passes through monsters and through you. A released thing stays pass-through until it is clear, for at most 2 seconds.
- A thrown thing hits each monster once, and its first hard stop is its one impact (up to 4 monsters in reach); its bounces after that do nothing.
- A menu or a save cannot throw what you hold: while the hand pose jumps or collapses, a carried thing stops where it is and nothing is read as a flick or a throw. Turning your head sharply blinds the throw reading for 2 tics.
- Only ordinary doors can be lifted: a door action with tag 0, taken from its front side, not one that is already moving (a door a Use press started in the last few tics is taken over). One held door per player.
- A hand in a Tactical Rig holster never starts a door hold and never flips a switch.
- Use at a door is still a Use to the game.
- Lift Doors and Palm Flips Switches are not turned off by the Distance Grab row: with Distance Grab off, Use and the palm still take doors and the palm still flips switches. The grip does not.
- The Barrel Lock-On only picks a monster while a barrel is in your other hand or within 64 units of you. Only barrels are steered; anything else gets the aim assist.
- With cl_capfps on, the fixed buzz is used in place of the rumble.
- There are two keys, both unbound, and they do nothing in Distance Grab until Grab Keys is on.

## Credits

The full list is in **CREDITS.txt**.

- **presidentkoopa:** his desktop RS_WorldHands, whose designs and numbers are re-written here for stock QuestZDoom: the
  pull's path and its tumble, the gravity, drag and flutter of everything that leaves a hand, a held thing tipping with
  the wrist and sagging by its weight, and the strain rumble.
- **Generated for this pack** (procedural, original): the beam and the reach cone models, and the cone's placeholder
  sprites, by `tools/gen_cone.py`. The aim dot's glow has no outside source recorded.
- **Ideas, no code or art taken:** the dot from QuestZDoom's bundled laser sight; the cone's look from DXR's debug wire
  cone; the beam from the lightsaber blade's crossed planes.
- **id Software's Doom:** the whoosh and the thud are Doom's own revenant swing and punch, pitched by speed and weight.
  This pack ships no sounds.
- **QuestZDoom** (Emawind and Team Beef): the engine and its hand-pose API.

---
Written from the code at commit 0252337bd, 2026-11-27.
