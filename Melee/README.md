# RSQ Melee

Fighting with your body in VR Doom. A hand that holds a fist punches when you swing it: jab, hook and uppercut. A gun in the main hand shoves, the off hand's grip takes a monster in a Headlock that you can punch or throw, and an open palm swats missiles aside. It has no keys of its own: every move is a swing, a grip or a trigger tap.

<a name="how-to-play"></a>
## How to play

"Main hand" is the weapon hand; "off hand" is the other. "Fire" is that hand's trigger (the main hand's fire, the off hand's off-hand fire). A "fist" is a hand that holds Doom's Fist, Brutal Doom's fists, BD22 VR's free off fist, Melee's boxing gloves, or nothing at all. Speeds are the hand's real metres a second against your body, so walking and stairs are not a swing. "Units" are map units.

| Do this | What happens | Needs |
|---|---|---|
| Hold a fist in a hand (either hand) | That hand is read for punches, the palm tap, the swat and the Hadouken. A hand with any other weapon is not | Brutal Doom Fists: On (default) for Brutal Doom's fists and BD22 VR's free off fist |
| Start a swing with a fist: the hand slower than 1.2 m/s, then 0.15 m of travel in at most 14 tics, averaging 2.0 m/s or more | The swing is a punch from that tic. A swing going forward or up plays a whoosh, hit or miss | Min Speed (default 2.0 m/s) |
| Carry that swing into a monster, the fist within 9 cm plus 4 units of its body, driving toward it | It is punched: 10 damage at 2 m/s rising to 20 at 7 m/s, blood, a spark sized by the speed, a buzz in that hand, and a knock the way the fist went (2 to 8 units a tic for a 100-mass monster, less for a heavier one). That hand punches again after 6 tics | Punch Damage (default 10); Full Speed (default 7); Rehit Wait (default 6); Extra Reach (default 4) |
| Punch straight at the monster | A jab: the three jab sounds in turn | |
| Punch across the monster (more than 0.6 of the swing sideways, and more sideways than toward it) | A hook: the same damage and knock, with the right hand's or the left hand's hook sound | |
| Punch upward into a monster (the swing, or its last tic, rising more than half its length: 30 degrees) | An uppercut: the same damage, and it is lifted (5 to 9 units a tic by speed, times 100 over its mass, a boss 0.3 of that), pushed 2 to 5 back, and held in its pain frames while in the air. No launch goes higher than 3 m | Uppercut Rise (default 0.5); Lift Cap (default 3 m) |
| Punch a monster while it is in its attack frames | A counter: a red spark, and with Impact Style: Arcade a red burst and the word COUNTER! (RSQ VisualRewards draws the word). The damage is the same | Impact Words: On (default) |
| Punch at 5.4 m/s or faster, or kill with a punch | A bigger burst and shards, a monster still alive is held 4 or 5 tics before the knock throws it, and a word over it: POW!, BAM!, WHAM!, SMASH!, or FATALITY! on a kill (words need RSQ VisualRewards, one every 14 tics at most) | Impact Style: Arcade (default); Hit Stop: On (default); Impact Words: On (default) |
| Punch while you hold the Berserk pack | The punch does 5 times its damage | |
| Punch a wall line that has a switch or a door on it (no monster in the fist's way) | The line is worked as a Use press would work it, with a buzz in that hand | |
| Uppercut a barrel | No damage: the barrel flies, tumbling, at 28 units a tic to the nearest living monster it can see within 1536 units (with none, the way you hit it) and goes off on the first monster, wall, floor or ceiling, or after 3 seconds. The blast is yours | Barrel Launch: On (default) |
| Tap fire on a hand that holds a fist (pressed and let go within 10 tics, no punch landed meanwhile) | That hand changes between fist and open palm, with a soft click. An open palm does not punch. Only Melee's own bare hand model draws the open hand | |
| Swing an open palm at 1.5 m/s or more, any direction, through a monster's missile | The missile is knocked aside off the palm, keeps its speed, and is yours: it hurts monsters, not you. A slap sound, a spark, a buzz | Palm Swat: On (default) |
| Swing an open palm at 1.5 m/s or more across the line of a monster's bullet, between it and you | The shot is cancelled: it hits nobody | Palm Swat: On (default); Swat Bullets: On (default) |
| With a gun in the main hand, drive that hand 0.15 m at an average of 3.6 m/s or more, any way but back toward you or downward | A gun butt shove: every monster within 60 units along the swing (12 units wide, a clear line from the hand) is pushed away from you (lighter further), and put in its pain frames (not a boss). Doom's zombieman, shotgun guy and imp are thrown further back and up, and some others lifted. No damage. A swing sound, a buzz, monsters within 200 units are alerted. The next shove is taken after 12 tics | Gun Butt Shove: On (default); Shove Speed (default 3.6 m/s) |
| Land that shove on at least one monster | RSQ SlowMo is asked for 1000 ms of slow motion at 35% speed | Shove Slow Mo: On (default); Slow Mo Length (default 1000 ms); RSQ SlowMo |
| Hit a monster with a shotgun while that slow motion lasts | The hit bleeds twice. A kill is the monster's extreme death in a burst of blood mist, "F.E.A.R. Effect" shows low in the view for 1.5 seconds, and RSQ Score is sent the award | Blood Mist: On (default); RSQ SlowMo; RSQ Score for the award |
| Shove the gun at a switch or a door line with no monster in reach | The line is worked as a Use press, with a buzz | Gun Butt Shove: On (default) |
| Swing the gun (0.15 m at 2.0 m/s or more on average) with a barrel within 72 units of the gun hand and within 60 degrees of the swing | The barrel is launched as an uppercut launches it | Barrel Launch: On (default) |
| Launch a barrel either way | RSQ SlowMo slows the world until the barrel goes off, 3 seconds at most | Barrel Slow Mo: On (default); RSQ SlowMo |
| Press the off hand's grip (key code 443, or 436) with the off palm within 0.30 m of a living monster's body | The Headlock: the monster is frozen and carried at the off hand, its face at the hand's height, turned to you, for 3 seconds or until you let go of the grip. Bosses and anything heavier than mass 400 are not taken. A buzz in the off hand | Headlock: On (default); Reach (default 0.30 m); Heaviest (default 400); Hold Time (default 3 s); Off Grip Keys (default "443 436") |
| Let go of the off grip while holding a monster | It is let go where it is | |
| Hold a monster in the off hand | The off hand does not punch, swat or return missiles until it lets go | |
| Punch the held monster with the main hand, three times | The first blow does its own damage, the second 1.5 times, the third 2.5 times. The third lets it go and, after 4 tics, sends it flying away from you (26 units a tic for a 100-mass monster), alive or dead: each monster it meets takes 10 to 150 damage by its speed, is shoved along and staggered 24 tics | Headlock Combo: On (default) |
| Land any blow of your own on the monster you hold | It shows its pain frame for 6 tics with its pain sound, and bleeds extra: 0.3 of the blow on the first, 0.6 on the second, the whole blow again from the third | Extra Blood: On (default) |
| While holding a monster, swing the off hand across the ground within 60 degrees of where you face at 3.0 m/s or more, then slow it | It is thrown the way the hand moved, counted as 30% of its weight, in its pain frames. Without RSQ Distance Grab, whatever it hits at 3 m/s or more (a wall or a body) takes the impact and so does it | Throw At (default 3.0 m/s); Throw Weight (default 30%) |
| With both hands on a long gun of BD22 VR Reloaded (Rifle, Shot_Gun, SSG, AssaultShotgun, MP40, BrutalSMG, Machinegun, MG42), drive the stock forward at 2.4 m/s or more | The butt strike: monsters the stock meets, or within 90 units ahead of it, are shoved as the gun butt shove shoves them (no damage), with the same slow motion once a swing. A switch or door it meets is worked | Butt Strike: On (default); Butt Strike Speed (default 2.4 m/s); Butt Forward Share (default 0.5); BD22 VR Reloaded 2.0.4u or later |
| Swing BD22 VR Reloaded's pistol or revolver, in either hand, so the muzzle moves at 5.0 m/s or more with a quarter of that downward | The pistol whip: Brutal Doom's own punch lands on each monster the gun meets (a second one at twice that speed), with the whip sound. Into a wall it makes Brutal Doom's axe impact | Pistol Whip: On (default); Whip Speed (default 5.0 m/s); Whip Down Share (default 0.25); BD22 VR Reloaded 2.0.4u or later |
| Turn on Boxing Gloves | At the next map start or respawn the two boxing gloves are put in your inventory, not in your hands (the glove asks for weapon slot 1). In a hand they are always fists | Boxing Gloves: On (default Off) |
| Turn on Slappers Only | At once the boxing gloves go on both hands and every weapon but the gloves, Doom's Fist, Brutal Doom's fists and BD22 VR's hands is put away. Weapon pickups vanish and a weapon given later is put away within 8 tics. Turned off, the weapons come back with the ammo you have now | Slappers Only: On (default Off) |
| With the boxing gloves in the main hand (and nothing but a glove in the off hand), hold both hands at your face for 4 tics: within 0.35 m of your head across, from 0.25 m below to 0.15 m above your eyes | The Guard: a blow from within 55 degrees of where you face does 60%, pushes you back a step, with a flash, a tick and a buzz in both hands. A blow of 35 or more breaks it: full damage, and no Guard for 14 tics | Guard: On (default Off); Boxing Gloves or Slappers Only: On |
| Swing a fist at 2.0 m/s or more through a monster's missile | The Hadouken: it flies back at its shooter 1.15 times as fast and hits for 1.5 times its damage | Hadouken: On (default Off) |
| Swing a fist at 2.0 m/s or more across the line of a monster's bullet, between it and you | The shot is cancelled and a round flies from your hand at the shooter for 1.5 times the shot's damage | Hadouken: On (default Off); Swat Bullets: On (default) |
| Land a punch | Heavy Hands: the monster is frozen 2 tics (4 for a punch at 4.5 m/s or more) with chicks and stars over its head, and knocked 1.25 times as far | Heavy Hands: On (default Off) |
| Punch a monster so it meets a wall within 12 tics at 3 units a tic or more | Wall Splat: 10 to 20 damage by its speed, it bounces off, is frozen 5 tics and reels 15 | Wall Splat: On (default Off) |
| With Melee's gloves in both hands, swing both hands down together to 0.60 m or more below your eyes (each 2.0 m/s or more downward, the slower one 3.0 m/s or more, within 120 ms of each other) | Ground Pound: every monster within 2.5 m takes 30 damage, is thrown out and up and staggered 15 tics. A thud, a ring along the floor, a shake, a buzz in both hands | Ground Pound: On (default Off); Boxing Gloves or Slappers Only: On |
| With nothing but Melee's gloves in your hands (at least one), thrust both palms forward together (each 2.5 m/s or more, controllers tilted up 20 degrees or more, hands 0.25 m apart sideways, no lower than 0.60 m below your eyes) | Clear Out: every monster within 2.5 m and 45 degrees of where you face, in sight, takes 15 damage, is shoved back hard (lighter further) and staggered 10 tics | Clear Out: On (default Off); Boxing Gloves or Slappers Only: On |
| Hold a monster in the Headlock | Human Shield: it is turned to face away from you and stays held as long as you grip, a minute at most | Human Shield: On (default Off) |
| Uppercut a barrel | It is lifted up and away from you at the uppercut's speed with no damage, and its blast is yours | Uppercut Barrels: On (default Off) with Barrel Launch: Off |
| Jab forward with BD22 VR's fists (the hand 0.25 m ahead of you, 0.15 m of travel, 2.5 m/s or more, 0.7 of it forward) | Brutal Doom's own punch flies from the hand and deals that swing's damage. Melee's punch still gives the kind of punch, the knock and the lift, with no damage of its own | VR Punch: On (default Off); BD22 VR Reloaded 2.0.4u or later |
| Uppercut with that hand's fire or alt fire held | A Star Punch, spending a banked star: a longer, stronger buzz and the star sound (the harder hit is Gun Bonsai VR's). A star is banked on a counter, on the first punch landed and every second one after, three at most | RSQ Gun Bonsai VR with Star Punch learned on a boxing glove |
| Punch a monster your uppercut launched while it is still in the air, within 70 tics | Juggle: it is lifted again | RSQ Gun Bonsai VR with Juggle learned |
| Hold an open palm nearly still (under 1.5 m/s) where a monster's missile arrives | Catch: the missile is held at the palm. Swing the hand at 2.0 m/s or more to throw it where the hand goes (onto a monster within 12 degrees of that line). Held too long it goes off in your hand | RSQ Gun Bonsai VR with Catch learned |
| With the Guard up, drive both hands forward at 1.0 m/s or more just before a blow lands | Parry: no damage, the attacker is knocked back and staggered | RSQ Gun Bonsai VR with Guard and Parry learned |
| Throw both hands apart | Release: what the Guard has taken goes out as damage to the monsters round you and throws them back. With no charge, a Taunt: monsters in range that see you turn on you and your next punch does double | RSQ Gun Bonsai VR with Absorb and Release, or Taunt, learned |
| While holding a monster, swing the off hand down hard (0.7 or more of the swing downward) | Slam: it is let go, put on the floor and hurt by its weight and the hand's speed; monsters round it stagger | RSQ Gun Bonsai VR with Slam learned on the off glove |
| Uppercut the monster you hold | Headlock Uppercut: the punch hits harder, the monster is let go and launched higher | RSQ Gun Bonsai VR with Headlock Uppercut learned on the off glove |
| Swing a fist | Nothing with Brutal Doom's fists or BD22 VR's free off fist: Brutal Doom punches as it ships | Brutal Doom Fists: Off (default On) |
| Swing an open palm through a missile | Nothing | Palm Swat: Off (default On) |
| Shove with a gun | No shove. With BD22 VR Reloaded loaded the hand is still read while Shove Slow Mo is on | Gun Butt Shove: Off (default On) |
| Press the off grip at a monster | Nothing from this mod | Headlock: Off (default On) |
| Land a punch | The hit spark alone: no bursts, shards, hit stop or words | Impact Style: Classic (default Arcade) |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Melee

| Option | Default | What it does |
|---|---|---|
|  |  |  |
| **Hands** | | |
| Brutal Doom Fists | On | Brutal Doom's fists punch with Melee's punch reader (jab, hook, uppercut); off leaves them as Brutal Doom ships them. |
| Boxing Gloves | Off | Your hands are SuperPunchOut's boxing gloves (always fists, no open palm). |
| Slappers Only | Off | Boxing gloves on both hands and your guns put away (gun pickups vanish); off gives them back. |
| Palm Swat | On | An open hand swung through a monster's missile knocks it aside. |
| Barrel Launch | On | An uppercut or a gun butt shove into a barrel sends it tumbling at the nearest monster. |
| Impact Style | Arcade | Classic shows the hit spark alone; Arcade adds bursts, shards, hit stop and words. |
| **Moves** | | |
| Gun Butt Shove | On | A shove with a gun in your main hand hits like a butt strike. |
| Headlock | On | Your off hand's grip holds a living monster. |
| Human Shield | Off | A held monster stays held as long as you grip, turned away from you as a shield (a Gun Bonsai upgrade when it is loaded). |
| Guard | Off | Both fists up at your face soak a blow from in front (a Gun Bonsai upgrade when it is loaded). |
| Hadouken | Off | A punch knocks a monster's missile back at its shooter. |
| Wall Splat | Off | A monster punched into a wall slams into it (a Gun Bonsai upgrade when it is loaded). |
| Heavy Hands | Off | A landed punch freezes the monster for a beat and knocks it further. |
| Ground Pound | Off | Both fists swung down together send a shockwave round you (a Gun Bonsai upgrade when it is loaded). |
| Clear Out | Off | Both palms thrust forward together shove back everything in front (a Gun Bonsai upgrade when it is loaded). |
| Test and Debug | (page) | Opens the tuning numbers, rarer switches and the debug log. |
| Reset All | (button) | Puts every RSQ Melee setting on both pages back to its default. |

<details><summary>RSQ Melee: Test And Debug (38 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Hands** | | |
| Hand Model | Auto | Which hand model Melee uses; Auto picks BD22 VR's FBX hand when that weapons mod is loaded, else Ermac's. |
| VR Punch | Off | A forward jab with BD22's fists lands BD22 VR's own punch (BD22 VR Reloaded only). |
| Melee Opens Switches | On | The pistol whip, the butt strike and the VR punch work a switch or door they hit. |
| Swat Bullets | On | A monster's bullet met by your hand: the palm swat knocks it away, the Hadouken sends it back. |
| Barrel Slow Mo | On | RSQ SlowMo slows the world until a launched barrel goes off, 3 seconds at most. |
| Uppercut Barrels | Off | An uppercut into a barrel lifts it up and away like Brutal Doom's kick. |
| Hit Spark Size | 1 (0.25 to 3) | Size of the hit and guard sparks (1 is about a monster's head). |
| Impact Words | On | Words such as POW and SMASH appear over a hard blow. |
| Hit Stop | On | A hard blow holds the monster for a few tics before the knock throws it. |
| Start With Guard | Off | With Gun Bonsai VR loaded, Guard works at level 1 before it is learned. |
| **Punch** | | |
| Punch Damage | 10 (2 to 40) | Damage of a punch at full speed is double this. |
| Min Speed (m/s) | 2 (0.5 to 5) | The slowest swing that counts as a punch. |
| Full Speed (m/s) | 7 (3 to 12) | The swing speed that gives a punch its full power. |
| Rehit Wait (tics) | 6 (1 to 20) | Tics before the same hand may punch again. |
| Uppercut Rise | 0.5 (0.1 to 0.95) | How much of a swing must go upward to count as an uppercut. |
| Lift Cap (m) | 3 (0 to 10) | No launch sends a monster higher than this (0 is no cap). |
| Extra Reach | 4 (0 to 16) | Extra punch reach past the glove, in map units. |
| **Gun Butt Shove** | | |
| Butt Strike | On | Both hands on a long gun, drive the stock forward to strike (BD22 VR Reloaded only). |
| Pistol Whip | On | Swing a pistol or revolver into something to hit it, either hand (BD22 VR Reloaded only). |
| Shove Slow Mo | On | A landed butt shove always slows time for a moment. |
| Blood Mist | On | A shotgun kill in the shove's slow motion bursts the monster into blood mist. |
| Shove Speed (m/s) | 3.6 (1 to 8) | The speed a shove must average to hit. |
| Slow Mo Length (ms) | 1000 (100 to 2000) | How long the shove's slow motion lasts. |
| Club Swing Strength | 1 (0.2 to 3) | Scales the swing both the pistol whip and the butt strike need. |
| Butt Strike Speed (m/s) | 2.4 (1 to 6) | The speed at the stock a butt strike needs. |
| Butt Forward Share | 0.5 (0 to 1) | How much of the stock's speed must point forward. |
| Whip Speed (m/s) | 5 (2 to 10) | The speed at the muzzle a pistol whip needs. |
| Whip Down Share | 0.25 (0 to 0.9) | How much of the muzzle's speed must point down for a whip. |
| **Headlock** | | |
| Headlock Combo | On | Three blows on the monster you hold build up; the third sends it flying. |
| Extra Blood | On | A held monster that is punched bleeds more with each blow. |
| Reach (m) | 0.3 (0.1 to 0.6) | How far from your palm a monster's body may be to grab it. |
| Heaviest | 400 (50 to 1000) | The heaviest monster you can hold (imp 100, demon 400, baron 1000). |
| Hold Time (s) | 3 (1 to 10) | How long a monster stays held before it breaks free. |
| Throw At (m/s) | 3 (0 to 8) | Swinging the off hand past this speed throws the held monster (0 is never). |
| Throw Weight (%) | 30 (10 to 100) | A thrown monster counts as this share of its weight. |
| Off Grip Keys | "443 436" | The off grip's key codes, as Distance Grab and the Tactical Rig read them. |
| **Debug** | | |
| Debug Log | Off | Prints each melee decision to the console. |
| Reset All | (button) | Puts every RSQ Melee setting back to its default. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Gun Bonsai VR | Its upgrade service gives the levels and numbers for Melee's moves. The Uppercut on a boxing glove must be learned (any other fist always uppercuts). Guard, Ground Pound, Clear Out and Human Shield then need both their upgrade and their Melee row; Hadouken, Heavy Hands and Wall Splat need both on a boxing glove, and any other fist plays the row alone. The Guard, Wall Splat, Ground Pound, Clear Out and Human Shield rows are greyed on the menu until learned (Start With Guard gives Guard at level 1 first). The numbers in the table above are the ones used without it. Its other glove and player upgrades act through Melee: Launcher, Meteor, Dempsey, Rage, Swat Back, Bullet Time Fists (on RSQ SlowMo's slowed rounds), Reflect Guard, Knockdown, Heavier Headlock, Chokehold, Throw Into, Pistol Whip, Rifle Butt. A boxing glove's blows are credited to that glove |
| RSQ Distance Grab | It is asked which mod takes an off grip press: the Headlock takes it only when a holdable monster is nearer the palm than anything Distance Grab would grab, and not when that hand is already Distance Grab's. A monster thrown from the Headlock flies through Distance Grab's throw. Its thud is used for the catch. With its Barrel Lock-On holding a lock, an uppercut sends the barrel to the locked monster, and Barrel Lock-On turns the uppercut's barrel kick on |
| RSQ SlowMo | Asked for the slow motion after a landed shove or butt strike (`rsm_pulse`) and for a launched barrel (`start.barrel`, `stop`). The F.E.A.R. window stays open only while SlowMo says it is slowing. The Ground Pound's and Clear Out's rings and the Headlock combo's flying monster read the world's speed from it |
| RSQ Score | Told which move touched a monster (the Headlock's "grab.hold" every 2 seconds, "shove", "hadouken", "wall", "pound" and the others) and sent the "F.E.A.R. Effect" award. Score can ask RSQML_Service which punch a blow was |
| RSQ VisualRewards | Draws the impact words (POW!, COUNTER!, FATALITY!) over a monster. Without it there are no words |
| RSQ Accessibility | Rumble Strength scales every buzz and Rumble Backup is asked as a buzz starts. The Off-Hand Modifier lets the main controller play the off hand (the gun butt shove is not read while it is held). Seated Play lowers the Guard's box by the measured seat drop. With its two-hand reader loaded (`RSQG_Service`) that reader sends Ground Pound, Clear Out and "both hands apart"; without it Melee's own copy of that reader does, with the numbers in the table above |
| RSQ Tactical Rig | An off grip press with the off hand in a rig holster region is never the Headlock's |
| RSQ Grapple | No gun butt shove, and no two-hand move from Melee's own reader, while you climb, swing or reel on the rope, and for 9 tics after |
| RSQ Wheel | No gun butt shove, and no two-hand move from Melee's own reader, while the Wheel is open, and for 9 tics after |
| RSQ Miniboss | A miniboss with its "Can't Be Headlocked" on is refused by the Headlock as a boss is |
| BD22 VR Reloaded 2.0.4u or later (found by its class RSVR_MeleeYield, with Brutal Doom) | Melee does that pack's butt strike, pistol whip and VR punch (it asks `owns` and stands its own down), measured on its gun models, and Melee's own gun butt shove leaves those guns alone. On the first map with both loaded that pack's swing settings are copied into Melee's once. Hand Model: Auto uses its FBX hand and its Hand Skin Tone |
| BD22 VR Reloaded before 2.0.4u (no RSVR_MeleeYield) | Melee's gun butt shove stands down and that pack keeps its own strike. Melee only watches for its strike to ask for the slow motion |
| Brutal Doom | Its fists and anything made from them punch with Melee's reader (Brutal Doom Fists). Its barrels are launched like Doom's. The blood mist is Brutal Doom's own mist in the monster's blood colour. The shove's swing sound is Brutal Doom's |
| SuperPunchOut | Its boxing gloves (SPO_Glove) count as gloves here |
| Any mod, by name | `RSQML_Service` answers: `loaded`, `owns`, the last punch (`punch.kind`, `punch.power`, `punch.speed` and the rest), `guard`, `guarded`, `headlock.claim`, `headlock.holding`, `headlock.by`, `headlock.shield`, `returned.by`, `launch.age`, `barrel.kicked`, `fear`, `autopunch`, `dizzy`, and the menu's `menu.locked`. `RSQML_GCopyService` answers `reader`, `pair.reader` and `pair.ago` |

## Limits

- Out of VR no hand is read: nothing here happens.
- There are no keys and no weapon slot commands. The buttons read are fire and off-hand fire (the palm tap), fire and alt fire of a hand (the Star Punch squeeze) and the off grip by its raw key code. Use, jump, crouch and the sticks are not read.
- There is no backhand, no kick and no shove with an empty or open hand: an open palm only swats, and only a gun in the main hand shoves.
- Jab and hook differ in sound and name only. The damage and the knock are the same.
- The gun butt shove and the butt strike do no damage.
- A gun in the off hand does nothing here, except BD22 VR Reloaded's pistol or revolver, which whips.
- The gun butt shove does not happen with Doom's Fist, Brutal Doom's fists, BD22 VR's hands or any weapon flagged as melee in the main hand, and never lands while BD22 VR Reloaded is loaded with Brutal Doom.
- A fist on the far side of a wall from the monster does not land, and a hand pulled back out of a body is not a punch.
- A turn of more than 15 degrees in one tic (a snap turn) drops that tic of a punch; 8 degrees clears the shove's swing.
- An open palm never punches and never does the Hadouken. With the boxing gloves on, a hand cannot open.
- The swat and the Hadouken take only a monster's own damaging missiles within 256 units of you.
- The Guard works only with the boxing gloves in the main hand and with Boxing Gloves or Slappers Only on. It does not stop a hazard with no attacker (slime, a crusher).
- Ground Pound and Clear Out need Melee's own gloves in the hands.
- The Headlock does not take a boss, a player, or a monster heavier than Heaviest. A wall at your hand with no room for the monster ends the hold.
- The Headlock's grip, its throw, the gun butt shove and the two-hand moves are read only for the player at this machine.
- Without RSQ SlowMo the shove slows nothing and the F.E.A.R. window closes after 4 tics. It is never open longer than 5 seconds.
- With Slappers Only turned off, weapon pickups it removed from the current map do not come back.

## Credits

The full list, with every file and its source, is in **CREDITS.txt**.

- **presidentkoopa:** SuperPunchOut (the glove weapons, the Arcade punch reader, Star Punch's banking), BD22 VR
  Reloaded's butt strike (ported twice: the shove read at the hand, and since 2026-11-13 the butt strike, the pistol
  whip and the VR punch line for line, `zscript/rsqml/club.zs`), RSQ Distance Grab's Headlock and throw, RS Gestures' swing reader, and the sounds
  from his RS Combat FX and RS Ballistics. The FBX hand is Brutal Doom VR's free hand.
- **Ermac** (iAmErmac): the hand model (Rusted Legacy / Doom Force Unleashed, MIT; licence in
  `credits/Ermac_RustedLegacy_LICENSE.txt`) and the boxing glove mesh and fit (PunchOutVR / Virtual Punch Out).
- **The punch sounds** (the jab, hooks, uppercut, pistol whip, butt shove and the swing's whoosh, 2026-11-16): the
  owner's punch1-punch11, from **Streets of Rage 2** (Sega, 1992; owner 2026-11-17).
- **DerrickDavison** (Punch Out Doom): the star sound and the punch sound the Hadouken and the guard still use, through
  Virtual Punch Out. Punch-Out!! is Nintendo's.
- **Sergeant Mark IV** (Brutal Doom): the punch, kick and knock numbers, parsed, not shipped; its mist and sounds are
  played by name when it is loaded.
- **shezzor:** the community sprite sheet the hit sparks, dust and dizzy chicks are cut from (non-commercial).
- **kiddolink:** "VFX Hit Impact", the impact bursts (a paid pack, bought for this series).
- **Rebecca "ToxicFrog" Kelly:** Gun Bonsai (MIT), which RSQ Gun Bonsai VR extends.
- **id Software:** stock Doom's sounds played by name (the revenant's slap, the chat tick, the swing, the punch).
- **QuestZDoom** (Emawind and Team Beef): the engine and its VR hand API.

---
Written from the code at commit 50f608e63, 2026-11-27.
