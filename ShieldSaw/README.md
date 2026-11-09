# RSQ ShieldSaw

A buzzsaw shield for your off hand: block with it, bash with it, rev it into a grinder, then paint targets and hurl it through all of them and catch it on the way back.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (tested on the rig, headset check pending): the hand measured against the frame your headset drew, so walking never swings the shield or saw; Shield on the Rig (the stowed shield drawn on RSQ Tactical Rig).

New on 11-09 (shown flat in the engine at the back and shoulder spots): Back Yaw, Back Pitch and Back Roll were reset
(their settings were renamed), so an old saved tweak no longer tips the stowed shield off your back. Set them again if
you had changed them.

New on 11-06 (rig only, not headset-confirmed): Next/Prev Offhand Weapon (off); grinding throws the monster's own
blood.

New on 11-07 (rig only, not headset-confirmed): with **Take It From** set to Over the Shoulder, RSQ Tactical Rig's
off-shoulder gun holster is the ShieldSaw's (no gun goes in; RSQ Wheel's holster web shows the ShieldSaw there).

RSQ is a series of VR mods for stock QuestZDoom 17.3, built in ZScript alone with no engine changes. ShieldSaw is a full
physical shield: the plate that blocks is measured off the same mesh you see in your hand, every throw is launched from
your real arm speed, and the disc flies a path, ricochets and comes home on its own.
It is the shield saw from *Doom: The Dark Ages*, brought to Doom VR first by Ermac in Rusted Legacy, rebuilt here as a
standalone off-hand mod that loads beside any weapon pack.

## Standout feature: the throw

Hold **Use** with the shield up and sweep your off hand across the room. Rings drop onto monsters one at a time as your
hand passes them, with a click and a tick in the controller, up to five. The biggest ring marks the first stop.

Hold the **off-hand trigger** to rev the saw. The blades open and the whine climbs. Then snap your arm forward and let go.

The disc leaves your hand spinning in the plane your wrist gave it and visits every ringed target in order. Light
monsters are sliced in half and it rips straight through. Medium ones take the blade and get ground for a moment.
Heavies knock it aside. A wall in the way is a bounce, not the end. When the list is done it flies home along the path
it took, never through a wall, and if your off hand is waiting, it snaps back into it. A fully revved throw hits 60%
harder and flies 60% faster.

Nothing ringed? At the moment it leaves it picks up to five targets in a cone along your throw, and with none there it
flies where you threw it. Changed your mind? Press the trigger again mid-flight and it turns for home.

## Features

**Carrying it**
- Everyone spawns with it. It lives on your body, not your head: take it from the **small of your back** (default),
  **behind your neck**, either, or **over your off shoulder**. Stowed, it lies flat along your back, outer face out,
  like a plate on a backpack, at every spot (11-08, rig only, not headset-confirmed).
- The mount turns with your snap and smooth turns. After turning your real body in the room, hold **both hands to your
  chest** for a moment to recenter it, or press the Recenter Torso key.
- Seated? With RSQ Accessibility's Seated Play, the mount drops with you.
- Drawing it sets your off-hand weapon aside. Putting it away hands back your fist (or the weapon you held: your
  choice), and throwing it hands back what the off hand held, so you are never empty-handed.

**Blocking**
- Anything that crosses the face of the plate is stopped: fireballs, rockets, and bullets at the muzzle. A fireball
  that flies under the rim still hits you.
- **Turned shots** go back out, glancing off the face and steered by the way you swung (default), or back at the
  shooter, or where you look (helped onto the enemy nearest your gaze).
- **Returned bullets** fly back out at the damage you would have taken.
- **Blocked melee** stuns the attacker and shoves it back.
- **Perfect block**: meet the attack with the plate moving into it and the turned shot leaves 60% faster, the attacker
  always staggers and is shoved twice as far, and you feel a double knock and hear a higher ring.

**Bashing and grinding**
- **Shield bash**: shove the plate along its face (a quick snap, or a firm lean) into a monster to hit and knock it back.
- **Wall slam**: a body you bash into a wall takes extra damage by how hard it hit, and is stunned for a moment.
- **Grind**: with the saw revved, press the blades into a monster and it is chewed, each body no more than once every
  4 tics. The blades reach 6 cm past the rim. Every grind hit throws the monster's own blood (Brutal Doom's blood on
  Brutal Doom's monsters).
- Bashes and grinds never reach through walls or doors.

**Throwing**
- Up to 5 targets, painted one at a time as you sweep, kept even when they drift out of the cone (one drops after
  3 seconds out of sight or well off your aim). Let go of Use and your rings stay for 5 seconds, long enough to rev and throw.
- **Hit tiers** by the monster's health, never its name: up to 70 health is bisected, up to 600 is embedded and ground,
  anything tougher takes a glancing hit. **BD22 Monsters** raises these to 250 and 1200 for Brutal Doom's tougher monsters.
- Bounces off up to 3 walls on the way to its targets.
- Catch it with your off hand when it returns, or it lands back on the mount by itself.

**Also**
- **Flick reload**: with the shield in your off hand, flick your main gun down to reload it, the way Brutal Doom VR does
  with a gun in each hand.
- **Saber Over Shield**: with RSQ Saber, rest the lit blade across the front of the plate and the block grows 30% wider.
- Left-handed play follows QuestZDoom's Control Scheme: the held shield is mirrored and the mount moves to the other side.
- Optional, off by default: **Hit-Stop** (a bash or perfect block freezes the monster for a beat), **Perfect Block
  Slow-Mo** (half a second of slow motion through RSQ SlowMo), **Block While Holstered**. On by default: **Show ShieldSaw** (the stowed shield drawn on your back, or on RSQ Tactical Rig's body).

## How To Play

1. Load the pk3. You start with the shield on your back.
2. Reach your off hand behind you to the small of your back, about belt height and a little toward your off side, and
   press **Use**. The shield is in your hand.
3. Raise it into incoming fire. Turn your wrist to aim the turned shots.
4. Snap the plate forward into a monster to bash it. Drive it into a wall for a slam.
5. Hold the **off-hand trigger**: the blades open. Push them into a monster to grind.
6. Hold **Use** away from your back and sweep your off hand over a group. Watch the rings land.
7. Keep the trigger held to rev, snap your arm forward toward them and let go. Hold your off hand out as it returns.
8. Reach behind you and press Use again to put it away.
9. Can't reach your back? Set **Take It From** to Behind the Neck or Over the Off Shoulder, or bind the Draw key.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Draw | Off hand at the mount + **Use** | Small of the back by default: 30 cm behind, 10 cm to the off side, 62 cm below your eyes, 30 cm reach, and at least 14 cm behind your eyes. |
| Put away | Off hand at the mount + **Use** | Off hand returns to its fist (or the weapon it held: On Manual Store). |
| Block | Hold the plate in the way | Turn your wrist to aim the turned shot. |
| Perfect block | Move the plate into the attack | About 0.7 m/s or faster. |
| Bash | Shove the plate along its face | About 1.3 m/s, or a sustained lean. |
| Rev | Hold **off-hand trigger** | 0.6 s to full speed. |
| Grind | Revved blades into a monster | |
| Lock on | Hold **Use** away from the mount, sweep the off hand | Or the Lock key (Lock On With). One target every 3 tics, up to 5. |
| Throw | Release the **off-hand trigger** while snapping the arm forward | About 1.8 m/s, within about 70 degrees of where you look. A slow release keeps it in hand. |
| Recall | Press the **off-hand trigger** while it flies | |
| Catch | Off hand near the returning disc | Within about 70 cm. |
| Reload main gun | Flick the main gun down | 45 degrees in 4 tics, ending 40 degrees below level. Shield in the off hand. |
| Recenter | Both hands to your chest, 0.4 s | 12 cm in front of and 30 cm below your eyes, no buttons held. |
| ShieldSaw: draw / put back / recall | Bindable key | Works without reaching, and without VR. |
| ShieldSaw: throw along aim | Bindable key | Flat throw where you look. |
| ShieldSaw: lock on (hold) | Bindable key | Used when Lock On With is Lock Key. |
| Recenter Torso | Bindable key | Turns the mount to where your head faces. |

Binds are under **RSQ ShieldSaw** in Customize Controls. With RSQ Accessibility's One-Handed mode, the Off-Hand Modifier
lets your main hand reach for the shield, and the Shield Throw and Flick Reload gesture buttons work.

## Menu

**Options → Radiant Silvergun Options → RSQ ShieldSaw.** One page, and one sub menu, **Test and Debug**. With RSQ Gun
Bonsai VR loaded the page starts with "GunBonsaiOVR detected. Mod features unlocked via upgrades." and the rows marked GB
are greyed while the upgrade that unlocks them is not learned (Back Plate, Shield Wall, Strike True). Learning one
turns its row on; the row can still turn it off.

| Row | Default | What it does |
|---|---|---|
| **Shield** | | |
| Start With Shield | On | Every player spawns with it |
| Start in Hand | Off | Spawn with it already drawn |
| Show ShieldSaw | On | The stowed shield is drawn where it hangs: on RSQ Tactical Rig's body, else at its mount on your back |
| Take It From | Small of the Back | Over the Shoulder, Small of the Back, Behind the Neck, Back or Neck |
| Draw With Use | On | Use at the mount draws and puts away (off: only the Draw key) |
| Next/Prev Offhand Weapon | Off | QuestZDoom's next / previous off-hand weapon reach the shield too |
| Mount Marker | When Needed | Never, When Needed, Always: the marker at the grab point |
| Shield Size | 1.0 | Model and block together (1.0-1.5) |
| **Block** | | |
| Shield Blocks | On | The block at all |
| Block While Holstered (GB) | Off | The stowed shield guards your back |
| Double Block Size | Off | The blocking plate twice as wide (the model is unchanged) |
| Blocked Shots | Returned | Cancelled or Returned |
| Turned Shots Go | Off the Face and My Swing | To Shooter, Where I Look, Off the Face, Off the Face and My Swing |
| Turn Shots Early | On | Turn shots that cross the plate before they reach you |
| Muzzle Block | On | Stop bullets whose line crosses the plate |
| Return Bullets | On | A stopped bullet goes back out |
| Perfect Block | On | Meeting a shot with a moving plate: faster turned shot, always staggers |
| Perfect Block Slow-Mo (GB) | Off | Half a second of slow motion (needs RSQ SlowMo) |
| Saber Over Shield | On | RSQ Saber's lit blade across the plate widens the block |
| Blocked Melee | Stun and Shove | Nothing, Stun, Stun and Shove |
| **Bash** | | |
| Shield Bash | On | The bash |
| Bash Needs Sight | On | Bash and grind cannot reach through walls or doors |
| Wall Slam | On | Bashed bodies slam into walls |
| Hit-Stop (GB) | Off | A bash or perfect block freezes the monster briefly |
| **Throw** | | |
| Lock On With | Use | Use (held away from the mount), Lock Key, Throw Button |
| Throw Button | Off Trigger | Off Alt, Either, Off Trigger |
| Max Locks | 5 | Targets one throw visits (0-5) |
| Catch on Return | On | A hand near the returning disc catches it |
| Hit Tiers | On | Bisect, embed or glance by the monster's health |
| BD22 Monsters | Off | Hit tiers for Brutal Doom's tougher monsters |
| **Hands and Body** | | |
| On Manual Store | Fist | Fist or Previously Held Weapon |
| Off-Hand Switch | Keep Shield | Keep Shield, or Allow Switch |
| Recenter: Hands to Chest | On | Both hands to your chest turn the body to your head |
| Turn With the Rig | On | With RSQ Tactical Rig, the shield hangs on the rig's body |
| Body Turns With Hands | Off | Head and both hands turning together turn the body at once |
| Body Catches Up | Off | A head held round eases the body round |
| **Look and Sound** | | |
| Block Feedback | On | Block feedback and haptics |
| Positional Sound | On | Contacts heard where they happen |
| Others See Shield | Netgame Only | Only Me, Everyone, Netgame Only |
| Spin Direction | Normal | Flip if the disc spins the wrong way |
| **Controls** | | Draw / Put Back, Throw Along Aim, Lock On (Hold), Recenter Torso |
| Reset All | | Every setting on both pages back to default |

**Test and Debug** holds every number on one page under short headers: Debug Log and Show Block Area; **Damage** (throw,
bash, grind, wall slam, bullet return); **Shield Fit** (disc position, block radius and depth); **Throw and Disc** (throw
threshold and speed, arm-or-aim blend, aim forward, slowest throw, disc weight, wind-up, top and return speed, return
patience, catch radius, breadcrumbs, hit-tier limits, glance and embed damage and time, rev time, grind gap, rev throw
bonus, revved blade reach, wall bounces); **Lock-On** (cone, range, keep angle, out-of-sight grace, lock gap, rings kept,
ring size); **Block and Bash** (deflect assist, swing steering, guard margin, lookahead, turned shot speed, melee shove,
perfect block speed, bash speed, reach, lean, knockback, lift, wall slam bump and stun, Hit-Stop Tics (GB: the most Strike True may give; learning it raises this to 6 once), brace size
and gap); **Mount** (shoulder, small of back and neck spots, eyes-to-neck, grab reach and zone, stowed yaw, pitch, roll,
size); **In the Hand** (held placement). Reset All. The old Shield Size / Throw Feel / Block Assist / Damage presets are
gone (the owner, 11-04: no presets); each number they set is a row.

## Works with

- **Alone**: everything above, with any weapon pack.
- **Brutal Doom / BD22 VR Reloaded**: the off hand gets Brutal Doom's fist back when the shield leaves it; flick reload
  works on its guns (honouring its flick switch); a shield hit never triggers Brutal Doom's stealth-kill cutscene; BD22
  Monsters adjusts the hit tiers.
- **RSQ Tactical Rig**: with **Turn With the Tactical Rig** on (default), the shield hangs on the rig's body, so shield
  and holsters always turn together, and the Recenter Torso key recenters the rig. A hand inside one of the rig's
  holsters is the rig's press, never the shield's. With **Take It From** set to Over the Shoulder, the rig's off-shoulder
  gun holster is the ShieldSaw's: no gun goes in by hand (a dull tick) or from RSQ Wheel's holster web, whose ring there
  shows the ShieldSaw (11-07, rig only, not headset-confirmed).
- **RSQ Saber**: Saber Over Shield.
- **RSQ SlowMo**: Perfect Block Slow-Mo.
- **RSQ Score**: disc kills, bashes, grinds, turned shots and kills after a block or perfect block earn their own bonuses.
- **RSQ VisualRewards**: HP bars show which monsters carry a lock-on ring.
- **RSQ Miniboss**: true legendary health for minibosses.
- **RSQ Gun Bonsai VR**: adds a ShieldSaw upgrade tree: ricochets, Hunter's Return, Meat Grinder, Cleaver, Shield Dash,
  Charge, a bigger shield and more.
- **RSQ Accessibility**: Gesture Ease, Cue Size, Colour Blind High Contrast rings, Photosensitive Mode, Steady Hands aim,
  Seated Play, Rumble Strength, Hold to Toggle and One-Handed play.

## Credits and licence

- **id Software**: the shield saw itself, the weapon of *Doom: The Dark Ages* (2025): its design, and the mesh Ermac
  ripped from the game.
- **Ermac (iAmErmac)**, [Rusted Legacy](https://github.com/iAmErmac/rusted-legacy): brought the shield saw to Doom VR
  first, and this mod started from his version. His two shield models (one built by him, one a game rip whose parts he
  separated), the hand model and the sounds come from it. His Rusted Legacy code is MIT
  (`models/hand/LICENSE_RustedLegacy_MIT.txt`); that licence does not make id Software's ripped mesh MIT. Which of the
  two shipped shield meshes is which, and where the hand and sounds came from before Rusted Legacy, is not recorded.
- **RS Combat FX** and **RS Ballistics** (the owner's effect libraries): the saw voice and block sparks (chainsaw
  archetype), and Gun Bonsai VR's Shield Dash and Charge effects and sounds.
- **QuestZDoom** (Emawind, Team Beef): the engine and its off-hand weapon and hand-pose support.
- **presidentkoopa**: this standalone version, its design, its headset testing and the direction of every change.
  Code written for this pack.
