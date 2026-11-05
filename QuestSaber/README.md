# RSQ Saber

A lightsaber that cuts what your real swing passes through, turns blaster bolts with the blade, flies from your hand
to each enemy you marked and comes home, with the Force in your other hand.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

New since the headset pass (tested on the rig, headset check pending): Hand on the Hilt; the blade and the Force hand measured against the frame your headset drew, so walking and strafing never swing them.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. It works on
plain Doom, and replaces the sabers of Wardust's Lightsaber and Xim's Star Wars Doom when loaded after them.

## Standout feature: the blade is real

There is no swing button. The blade is where your hand puts it, and it cuts whatever your swing drags it through.
Hold it up in front of an imp's fireball and the bolt glances off. Swing into the bolt as it arrives and it is a
parry: the shot goes back, a white starburst blooms where it met the blade, and both hands feel it. A zombie's
rifle round is stopped at the blade, not in your chest, because the blade is tested against the bullet's own path
before the engine traces it. Cross your two blades in front of you and nothing from in front gets through.

Then hold the trigger and sweep your hand across the room: each enemy along your hand's line gets a gold diamond.
Let go with a throw and the saber leaves your hand, spinning, lighting its second blade, and flies to each marked
enemy in turn, cutting as it goes, before it comes back to your hand. Press the trigger again and it comes home at
once, like a Force pull.

## Features

**The blade**
- Cuts by your real swing (about 8 map units a tic of blade travel), through monsters, never through walls.
- Deflects missiles that cross the blade, tested along the blade's whole sweep so fast bolts cannot slip through.
- Blocks hitscan shots: always with a blade swung in the last third of a second, 70% of the time held still.
- Parry by driving the blade into the shot: it goes back, with a bright burst. Optional slow motion on a perfect
  parry with RSQ SlowMo (off by default).
- A blade pushed into a wall or the floor sparks and scorches it.
- The hum follows the blade and swells on a hard swing; the swing is heard from the blade.
- Eight colours and five lengths (54 to 99 cm) per blade, with dynamic light on each blade.
- Optional hit-stop: a cut monster freezes for a beat (off by default).

**Two sabers**
- A second saber in the off hand, on by default. With RSQ Tactical Rig it can start put away in its holster and be
  drawn by hand.
- Cross the blades for a blade lock: a crack of light, a snarling electric loop, sparks, and a cross guard that
  stops everything from in front of you.
- A second blade on the far end of the hilt (a key, or the alt fire when Force Push is off). With it lit, the staff
  twirls in your hand: a spinning disc of blade that cuts what it touches and turns every shot that crosses it.
- Douse or light the blade with a key.
- Hand on the Hilt: Brutal Doom 22 VR Reloaded's hand wraps each hilt, sized to the blade, mirrored for a left hand,
  hidden while the saber is thrown. It takes BD22 VR's hand skin tone.

**The throw**
- Hold the trigger to mark up to 5 enemies along your hand's line; let go with a throw and it flies to each in turn.
- With nothing marked, a forward snap as you let go throws it straight out along your swing.
- It cuts what it passes, turns shots it crosses, burns a trail where its blades touch, then comes back.
- The trigger (or alt fire) while it is out calls it home.

**The Force** (off hand: the off-hand saber's alt fire held, or with no off-hand saber, the bare Force hand)
- **Push**: thrust the hand out. Everything in a cone is thrown back, lighter things farther, and shots in the cone
  (fireballs, Cacodemon balls, rockets) are turned round: onto the enemy you look at, or the way you pushed. A shot
  you turn is yours, kill and score. The main hand's alt fire also pushes.
- **Pull**: yank the hand back. Enemies stagger toward you, pickups fly to your hand, a thrown saber comes home.
- **Grip**: hold the hand still on an enemy. It rises, choking, and hangs where your hand points. Move your hand and
  it moves. Let go mid-swing and it is flung, and hurts when it lands.
- **Force Jump**: hold jump with a saber or the Force hand out. You jump higher and float down while jump is held.
- Force Only With the Saber: the Force hand appears only while the saber is in your main hand.

**The training remote**
- A little drone that circles in front of you and stings you with bolts. Deflect them. It keeps score on screen.

**Comfort and play**
- With a saber or the Force in the off hand, a flick of the main gun still reloads it on Brutal Doom 22 VR.

## How To Play

1. Add RSQ_Saber.pk3 to your load order (after Wardust's or Xim's sabers if you use them). You start holding it.
2. Swing through an imp. Watch the fireball when it comes and put the blade in its way; then swing into the next
   one for a parry.
3. Cross your two sabers in front of you when a crowd opens fire.
4. Hold the trigger and sweep your hand across three enemies until each has a gold diamond, then throw. Catch it
   coming back, or pull the trigger to call it.
5. Your off hand: thrust to push, yank to pull, hold still on a zombie to grip it. Then fling it into its friends.
6. Bind Second Blade under Controls, light it, and hold your hand still to watch the staff twirl.
7. Bind Training Remote and practise deflecting.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Cut | Swing the blade through a monster | Swing to Cut sets how hard (8 by default) |
| Block / deflect | Hold the blade in a shot's path | Hitscan: swung always blocks, still blocks 70% |
| Parry | Swing the blade into the shot as it arrives | The shot goes back |
| Cross guard / blade lock | Cross your two blades in front of you | Nothing from in front gets through |
| Mark targets | Hold the saber hand's trigger and sweep across enemies | Up to Lock-On Targets |
| Throw | Let go of the trigger with marks, or with a forward snap | The off-hand saber throws with its own trigger |
| Call it back | Trigger or alt fire while it is thrown | |
| Force Push (main hand) | Main saber's alt fire | Force Push on Alt on |
| Force Push / Pull / Grip | Off-hand saber's alt fire held (or the bare Force hand's trigger or alt), then thrust / yank / hold still on an enemy | |
| Force Jump | Hold jump with a saber or the Force hand out | |
| Second blade on / off | Bindable key; or the alt fire when Force Push on Alt is off | Lit, the staff twirls |
| Blade on / off | Bindable key (douse it) | |
| Training remote | Bindable key | Summon or dismiss |

- Keys: Options → Radiant Silvergun Options → RSQ Saber → Controls, or Customize Controls → RSQ Saber.
- Left-handed: the engine's left-handed setting moves the main saber, the mirrored hilt hand and the rumble to your
  left hand.
- The saber sits in slot 1.

## Menu

Options → Radiant Silvergun Options → RSQ Saber. One page, and one sub menu, **Test and Debug**. With RSQ Gun Bonsai VR
loaded the page starts with "GunBonsaiOVR detected. Mod features unlocked via upgrades." and the rows marked GB below are
greyed while their upgrade is not learned. Learned, the row still decides: Off is off (learning a switch's upgrade turns
it on), and Hit-Stop and Lock-On Targets cap what Strike True and Battle Meditation give.

| Row | Default | What it does |
|---|---|---|
| **Sabers** | | |
| Sabers | On | The whole mod |
| Start With Saber | On | Begin holding one (off: pick it up) |
| Dual Sabers | On | A second saber, the off hand's weapon |
| Second Saber Starts | Put Away | In its Tactical Rig holster (without the Rig, in the off hand, blade off), or In Hand |
| Show Sabers | On | Each saber you own and don't hold hangs at the hip: in its RSQ Tactical Rig holster, or without the Rig at the same spot, drawn by this mod |
| Hand on the Hilt | On | The hand round each hilt |
| Sword Becomes Saber | On | Brutal Doom's sword turns into this saber |
| **Blades** | | |
| Main Colour / Off Colour | Blue / Red | Eight colours |
| Main Length / Off Length | 76 cm / Same as Main | 54, 65, 76, 88 or 99 cm |
| Blade Light | Low | Lights per blade: Off, Low (Quest), Medium, High |
| Off Blade Light | On | The off blade's own light |
| Saber Sound | Graflex | Graflex, Vader, Rogue Rebel |
| **Fighting** | | |
| Damage | 30 | The cut's damage (15-60) |
| Swing to Cut | 8.0 | How hard a swing must be to cut (3-20) |
| Turned Shots Go | Where I Look | Where I Look, At the Shooter, Mirrored |
| Hit-Stop (GB) | Off | Off, Light, Medium, Heavy |
| Perfect Parry Slow-Mo | Off | Half a second of RSQ SlowMo on a perfect parry |
| Lock-On Targets (GB) | 5 | Enemies one throw can mark (1-5) |
| Rumble | On | Controller buzz |
| **The Force** | | |
| The Force | On | Push, pull, grip, jump |
| Force Push on Alt (GB) | On | The main saber's alt fire pushes (off: it toggles the second blade) |
| Force Jump (GB) | On | Hold jump with a saber or the Force hand out |
| Force Only With Saber | On | The Force hand only while the saber is in the main hand |
| Force Hand | Our Hand | BD22 VR's hand, or Original (Ermac's) |
| Lightning Beam (Gun Bonsai VR) (GB) | On | Force Lightning drawn as a beam; Force Lightning exists only as a Gun Bonsai VR upgrade |
| **Controls** | | Second Blade, Blade On / Off, Training Remote |
| Reset All | | Every setting on both pages back to default |

**Test and Debug**: Block Width (1.5), Shot Lookahead (3 tics), Throw Needs (1.5), Swing Hum Boost (1.1), Gesture
Sharpness (2.0), Gesture Straightness (0.55), Remote Start Level (2), Rumble Hand (Auto), Debug View (Off: Blade Line,
Glow Readout), Reset All.

## Works with

Runs alone. It finds the others by name:
- **Wardust's Lightsaber, Xim's Star Wars Doom, the earlier SW QuestSaber**: their saber becomes this one, on the map
  and in your hands (load RSQ Saber after them).
- **Brutal Doom**: its sword becomes the saber (a menu row).
- **Brutal Doom 22 VR Reloaded**: the hilt hand and Force hand are its hand, in its skin tone; a flick of the main
  gun reloads while the saber holds the off hand.
- **RSQ Tactical Rig**: two saber holsters below your hips, each saber on its own hand's side. The second saber is
  put away and drawn only there.
- **RSQ SlowMo**: Perfect Parry Slow-Mo.
- **RSQ Score**: cuts, parries, returned shots and the training remote pay into it.
- **RSQ Accessibility**: Steady Hands smooths marking and gripping; Gesture Ease, Slower Taps, Photosensitive Mode
  and rumble strength apply.
- **Gun Bonsai + RSQ Gun Bonsai VR**: the sabers level like weapons, with the Dual tree and the Force tree (Force
  Sensitive, Force Speed, Force Lightning, stronger Push, Pull and Choke, Battle Meditation for more marks,
  Precognition for easier parries, the Saber Barrage and Returning Blade throws). Under it, Force powers start
  weaker and grow as they are learned. The Force hand earns XP for its own blows plus half of the main saber's, and a
  level-up on either offers blade and Force nodes from one shared pool.

## Credits and licence

- **presidentkoopa** (project owner) and this pack: the saber itself, the blade and glow shapes and the generated
  sounds; Force Lightning's crackle from his RS Ballistics library.
- **Ermac** (DXR, Rusted Legacy; RS_Main): combat effect sprites for the Force and the blade's impacts (the choke
  lightning, the blast smoke, the hand flare), the Force choke loop, and the Original Force hand. Much of Ermac's work
  is MIT-licensed; sharing it here is the project owner's decision.
- **BD22 VR Reloaded** (the owner's mod): the Force hand and the hilt hand (its FBX hand in the magazine hold), and
  its skin. The FBX's original author and licence are not recorded.
- **li-gnrcwpn**: the training remote's ready beep.
- The saber model is believed to come from *Star Wars Jedi Outcast* (Raven Software / LucasArts), and the saber sounds
  from a lightsaber soundfont library. Their individual authors, and the path they took into this mod, are not recorded.
- **QuestZDoom** (Emawind): the engine, and the off-hand weapon and hand-pose API the whole mod is built on.

Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors' terms.
