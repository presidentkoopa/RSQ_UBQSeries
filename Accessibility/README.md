# RSQ Accessibility

One page of comfort and assist settings that the other Radiant Silvergun Quest mods read by name, and the series' gesture reader: it tells other mods when a hand is held in the watch check, when both hands sweep down, are thrown apart or thrust forward. It also has nine keys that stand in for other mods' hand moves when you play with one hand. On its own it changes little you can see: most rows only do something when the mod they speak to is loaded.

<a name="how-to-play"></a>
## How to play

"Main hand" is the hand QuestZDoom's Control Scheme makes the main one; "off hand" is the other. Distances are real metres from your eyes; "ahead" is the way your body faces. A tic is 1/35 of a second. The numbers are the defaults with Gesture Ease at 0 and Fit to Body off.

| Do this | What happens | Needs |
|---|---|---|
| Hold a hand in front of your face (0.12 to 0.81 m ahead of your eyes, from 0.375 m below them to 0.25 m above, within 0.44 m to either side), gun tilted no more than 75 degrees up or down, wrist turned 28 degrees or more so the back of the wrist faces you, hand slower than 1.5 m/s, for 5 tics | The watch check is held for that hand: a light tick in that hand's controller and "watch check (main)" or "watch check (off)" in small grey text low in view for 1.5 seconds. The mod that asked shows its card or does its move | Watch Check: On (default); a loaded mod that asks: RSQ Gun Cards, RSQ Laser Sight, RSQ Tactical Rig or RSQ Boss |
| Turn the wrist back under 16 degrees, or move the hand more than 5 cm out of that space | The watch check drops | |
| Hold the off hand in the same place with the inside of the wrist to your face (22 degrees or more, slower than 1.92 m/s, 4 tics; the space is wider: 0.09 to 1.04 m ahead, 0.48 m below to 0.32 m above, 0.56 m to the side) | The pulse check is held: a tick in that hand and "pulse check (off)" in grey | Watch Check: On (default); RSQ Boss, which asks for it |
| Sweep both hands down past your hips (0.60 m below your eyes) within 120 ms of each other, each at 2.0 m/s or more and mostly downward | "both hands down" in grey, and the event `rsqg_pair 0` is sent for the mod that asked | RSQ Melee with a move that uses it, or Two Hand Always: On (default Off); Both Hands Down: On (default) |
| Throw both hands apart from your chest (each starting within 0.50 m of a point 0.40 m below your eyes), the gap opening at 2.0 m/s or more | "both hands apart", and `rsqg_pair 1` is sent | the same; Both Hands Apart: On (default) |
| Thrust both hands forward together, each at 2.5 m/s or more and mostly forward, above the hips, pointing 20 degrees or more up, 0.25 m or more apart side by side, not braced on a gun | "both palms thrust", and `rsqg_pair 3` is sent | the same; Both Palms Thrust: On (default) |
| Hold both hands still 0.25 m or more ahead of your eyes, above the hips, each pointing 40 degrees or more up, 0.25 m or more apart, no fire or alt fire held, for 400 ms | "both palms out", and `rsqg_pair 2` is sent. No mod in the series hears it | the same; Both Palms Out: On (default) |
| Swing an empty hand forward 15 cm at an average 2.0 m/s or more while the reader is awake (a mod asked it something in the last second) | "jab", "hook" or "uppercut" with the hand's name in grey. Nothing else: no mod asks for punches | Gesture Names: On (default) |
| Swing a hand that holds a gun the same way | "gun-butt shove" with the hand's name in grey. Nothing else here | Gesture Names: On (default) |
| Hang on RSQ Grapple's hook, or open RSQ Wheel | No punch, shove or two-hand gesture is read until 9 tics after it ends | RSQ Grapple or RSQ Wheel |
| Point or aim with a hand | The other mods that point (see Works with) are given a smoothed copy of that hand's place and aim: a still hand is steadied, a fast one passes almost as it is | Steady Hands: On (default) |
| Sit down: eyes 0.25 m or more below your standing height for 2 seconds | You count as seated, and the mods that ask (see Works with) lower their body zones by how far your eyes dropped. Back within 0.15 m for 1 second and you count as standing | Seated Play: Auto (default). Auto calls you standing until it has seen you stand still for a second, or you pressed Measure Height |
| Press a key bound to any of the nine keys below | Nothing | One Handed: Off (default) |
| Hold Off-Hand Modifier (no key is bound until you bind one) | Your main controller plays the off hand's part in the mods that ask: a tick on the main hand as it starts and a lighter one as you let go. Here, the off hand's gestures are read from the main controller and the main hand's own are not read | One Handed: On (default Off) |
| Press Grab Pull | Sends `rsqa_alt 1 1`. RSQ Distance Grab: whatever a hand has locked flies to it | One Handed: On; RSQ Distance Grab |
| Hold Grab Reach | Sends `rsqa_alt 2 1`, and `rsqa_alt 2 0` when let go. RSQ Distance Grab: the main hand reaches as if its palm were out (the off hand's part while Off-Hand Modifier is held) | One Handed: On; RSQ Distance Grab |
| Press Force Push | Sends `rsqa_alt 3 1`. RSQ Saber: a Force push from the Force hand | One Handed: On; RSQ Saber with the Force in the off hand |
| Press Force Pull | Sends `rsqa_alt 4 1`. RSQ Saber: a Force pull | One Handed: On; RSQ Saber with the Force in the off hand |
| Hold Force Grip | Sends `rsqa_alt 5 1`, and `rsqa_alt 5 0` when let go. RSQ Saber: the Force hand is held up and grips what it points at | One Handed: On; RSQ Saber with the Force in the off hand |
| Press Shield Throw | Sends `rsqa_alt 6 1`. RSQ ShieldSaw, with the saw drawn: it is thrown at the ringed targets, or along where you look when none are ringed | One Handed: On; RSQ ShieldSaw |
| Press Flick Reload | Sends `rsqa_alt 7 1`. The main hand's gun reloads, only while a saber, the Force hand or the ShieldSaw is in the off hand | One Handed: On; RSQ Saber or RSQ ShieldSaw |
| Press Wrist Cross | Sends `rsm_toggle` with no number. RSQ SlowMo turns slow motion on or off | One Handed: On; RSQ SlowMo with its Accessibility Button: On (default) |
| Press Off-Hand Modifier, Grab Reach or Force Grip once | It stays on until you press it again; letting go does nothing. RSQ Saber's Force trigger toggles the same way | Hold to Toggle: On (default Off); One Handed: On for the three keys |
| Do any two-hand gesture | The two hands may move 180 ms apart instead of 120. RSQ Wheel's double tap and RSQ Saber's kept marks get half again as long too | Slower Taps: On (default Off) |
| Do any gesture above | Its space is up to twice as wide and its speeds, angles and holds down to half, by the slider. The mods that read Gesture Ease do the same to their own gestures | Gesture Ease above 0 (default 0) |
| Ride RSQ Grapple's hook, or make RSQ Saber's boosted Force jump | The edge of each eye's view darkens (Light 55%, Medium 75%, Strong 92% at the very edge), in over 0.2 s and out over 0.4 s. Never while a menu is open | Comfort Vignette: Light, Medium or Strong (default Off); RSQ Grapple or RSQ Saber |
| Get thrown by a hit (your speed jumps by more than 8 units a tic to over 12, within 2 tics of losing health or armour), or fall faster than 10 units a tic | The same darkening while you fly or fall | Knockback Vignette: On (default Off); Comfort Vignette not Off |
| Take a hit from a monster more than 35 degrees out of view | A red arrow round the middle of the view points to it for 1.2 seconds | Sound Cues: Visual or Both (default Off) |
| Have a monster shoot at you from out of view (its missile within 20 degrees of coming at you from within 2048 units, or its hitscan aimed at you) | An amber open arrow points to it | Sound Cues: Visual or Both |
| Take that hit or shot from more than 40 degrees off the way your body faces | A short buzz in the controller on that side (stronger for a hit) | Sound Cues: Rumble or Both |
| Be in slow motion as it starts or stops | With Visual: "Slow Motion" stays near the top of the view while it lasts; "Normal Speed" fades over a second after. With Rumble: both controllers buzz, longer as it starts, shorter as it stops | Sound Cues not Off (default Off); RSQ SlowMo |
| Have a monster within 1536 units wake up on you or teleport in, out of view | With Visual: a grey double arrow points to it. With Rumble: a light buzz on that side | Wake Cues: On (default Off); Sound Cues not Off |
| Move the Rumble Strength slider | Every rumble this mod plays is multiplied by it, and the mods that ask take the same number. At 0 there is none | Rumble Strength (default 1.0, 0 to 2) |
| Play with QuestZDoom's Quake Haptics at 0 | Each rumble comes as the engine's own shot buzz on that controller instead: this mod's own, and one for each rumble another mod says it started (at most one a controller every 5 tics) | Rumble Backup: On (default Off) |
| Set Handedness to Right or Left | QuestZDoom's Control Scheme is changed to match (the last right-handed or left-handed scheme you used). If you later change the Control Scheme in QuestZDoom's own menu, Handedness goes back to Follow QuestZDoom at the next start | Handedness (default Follow QuestZDoom) |
| Set Two Hand Brace to Off | QuestZDoom's Two Handed Weapons is turned off, so the off hand's gun no longer goes dead when you grip with your hands close. "QuestZDoom's" puts your own value back | Two Hand Brace (default QuestZDoom's) |
| Press the off hand's grip with your hands close, a gun in the off hand, so QuestZDoom's brace latches | A buzz in the off hand, a click, or both | Brace Cue: Rumble, Sound or Both (default Off) |
| Set Colour Blind | The arrows above take that palette's colours. The mods that ask recolour their own cues | Colour Blind (default Off) |
| Raise Cue Size | The arrows above are drawn up to 3 times as big | Cue Size (default 1.0) |
| Raise Text Size | "Slow Motion", "Normal Speed" and the grey gesture names are drawn up to 3 times as big | Text Size (default 1.0) |
| Stand up straight and press Measure Height on the page | Your headset's height is kept as your standing eye height and shown in the middle of the view. Seated Play measures from it | |
| Press Measure Me, close the menu, stand tall with your arms straight out to your sides | After 2 seconds your eye height and reach are measured for 1 second and shown, and Fit to Body is turned on: the watch check's space, the hip line and the chest scale to your body (0.6 to 1.4 times) | |
| Set Seated Play to Seated | You always count as seated | Seated Play: Seated (default Auto) |
| Set Watch Check to Off | The watch check and the pulse check are never held; mods that ask are told it is off and use their own pose | Watch Check: Off (default On) |
| Set Wrist Turn to Palm Up or Either Way | The watch check takes the inside of the wrist, or either side. The pulse check takes the other side from the watch check (with Either Way: the inside) | Wrist Turn (default Watch Side) |
| Set Tick When Ready to Off | No tick when a watch check or pulse check is held | Tick When Ready: Off (default On) |
| Set Gesture Names to Off | No grey gesture names | Gesture Names: Off (default On) |
| Set Menus to Simple | The link to each loaded mod's own Test and Debug page is taken off that mod's page. Full puts them back | Menus: Simple (default Full) |
| Pick Reset All and confirm | Every setting of this mod goes back to its default, except Handedness, Two Hand Brace, your Measure Me body and your Measure Height | |
| Pick Reset Every Mod and confirm | Each loaded series mod's own Reset All is run once. This page is not reset | |
| Pick Forget Height on the Test and Debug page and confirm | Your measured standing height is forgotten; Seated Play learns it again | |

## Keys

<!-- GEN:keys -->
Options > Customize Controls > RSQ Accessibility

| Key | Default bind | Command |
|---|---|---|
| Off-Hand Modifier | none | `+rsqa_mod` |
| Grab Pull | none | `rsqa_pull` |
| Grab Reach | none | `+rsqa_reach` |
| Force Push | none | `rsqa_fpush` |
| Force Pull | none | `rsqa_fpull` |
| Force Grip | none | `+rsqa_fgrip` |
| Shield Throw | none | `rsqa_throw` |
| Flick Reload | none | `rsqa_reload` |
| Wrist Cross | none | `rsqa_slowmo` |
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > Accessibility

| Option | Default | What it does |
|---|---|---|
| **Seeing** | | |
| Colour Blind | Off | Recolours the series' cues and markers for your kind of colour blindness, or high contrast. |
| Photosensitive | Off | Flashes, flickers and pulses from the series at most 2.5 a second, strong flashes at 40% brightness. |
| Cue Size | 1 (0.5 to 3) | Size of the dots, rings, glows and markers from the series. |
| Text Size | 1 (1 to 3) | Size of the series' HUD text and the Gun Bonsai screens. |
| **Hands** | | |
| Handedness | Follow QuestZDoom | Which hand is your main hand; Follow QuestZDoom uses the game's own control scheme. |
| One Handed | Off | Play with one hand: the Off Hand Modifier lets the main hand play the off hand's part, and the gesture buttons act. |
| Steady Hands | On | Smooths shaky hand movement for the series' mods. |
| Slower Taps | Off | Every tap and double tap window in the series is half again as long. |
| Hold to Toggle | Off | Inputs you would hold toggle instead: press once to start, again to stop. |
| Gesture Ease | 0 (0 to 1) | Makes gestures easier: wider tolerances, lower speeds and shorter holds. |
| **Comfort** | | |
| Comfort Vignette | Off | Darkens the edge of view while a hook, rope or Force jump moves you. |
| Knockback Vignette | Off | The comfort vignette also shows on a big knockback and a long fall. |
| Slow Mo Ease (s) | 0 (0 to 2) | The slowest a slow motion may ease in and out, in seconds (0 is SlowMo's own). |
| Seated Play | Auto | Standing, seated, or Auto to tell from how far your eyes drop. |
| Measure Height | (button) | Stand up straight and press to measure your standing height for Seated Play. |
| **Cues and Rumble** | | |
| Sound Cues | Off | Shows or rumbles hits and shots from out of view, and slow motion starting and stopping. |
| Wake Cues | Off | Sound Cues also mark a monster waking or teleporting in out of view. |
| Rumble Strength | 1 (0 to 2) | Strength of every rumble in the series (0 is none). |
| Rumble Backup | Off | When QuestZDoom's Quake Haptics is 0, every series rumble still comes as a short buzz. |
| **Two Hand Brace** | | |
| Two Hand Brace | QuestZDoom's | Off turns QuestZDoom's two handed brace off, so the off hand gun never goes dead when your hands are close. |
| Brace Cue | Off | A rumble or sound when the brace latches and the off hand gun goes dead. |
| **Gestures** | | |
| Watch Check | false | Turning your wrist as if checking a watch shows that hand's card. |
| Fit to Body | Off | Gesture zones scale to your measured eye height and reach. |
| Measure Me | (button) | Stand tall, arms straight out to your sides, and press to measure your eye height and reach. |
| **Menus** | | |
| Menus | Full | Simple takes the Test and Debug links off the series' option pages; Full puts them back. |
| Test and Debug | (page) | Opens the one hand keys, the gesture switches and numbers, and the debug logs. |
| Reset All | (button) | Puts every RSQ Accessibility setting back to its default (Handedness, Two Hand Brace and your measurements are kept). |
| Reset Every Mod |  | Resets every loaded RSQ series mod to its defaults (Accessibility is kept). |

<details><summary>Accessibility: Test And Debug (54 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **One Hand Keys** | | |
| Off Hand Modifier | (key) | Held (or toggled), your main hand plays the off hand's part (with One Handed on). |
| Grab Pull | (key) | A key for Distance Grab's wrist flick pull. |
| Grab Reach | (key) | A key for Distance Grab's palm out reach, held. |
| Force Push | (key) | A key for the Saber's Force push. |
| Force Pull | (key) | A key for the Saber's Force pull. |
| Force Grip | (key) | A key for the Saber's Force grip, held. |
| Shield Throw | (key) | A key for the ShieldSaw's forward flick throw. |
| Flick Reload | (key) | A key for the flick reload. |
| Wrist Cross | (key) | A key for SlowMo's wrist cross toggle. |
| **Seated Play** | | |
| Forget Height | (button) | Forgets your measured standing height, so Seated Play learns it again. |
| **Gesture Switches** | | |
| Wrist Turn | Watch Side | Which way the wrist turns for the watch check: either way, palm up, or the watch side to your face. |
| Tick When Ready | On | A light tick in that hand's controller when the watch check pose is reached. |
| Two Hand Always | Off | Reads the two hand gestures even when no mod asks for them (their names show). |
| Both Hands Down | On | Both hands swept down past the hips counts as a gesture. |
| Both Hands Apart | On | Both hands thrown apart from the chest counts as a gesture. |
| Both Palms Out | On | Both palms held out counts as a gesture. |
| Both Palms Thrust | On | Both palms thrust forward together counts as a gesture. |
| Gesture Names | On | A small grey line low in view names each gesture as it is recognised. |
| **Debug** | | |
| Debug Log | Off | Logs the knockback and wake detections. |
| **Watch Check** | | |
| Twist On (deg) | 35 (20 to 90) | Wrist twist needed to start the watch check. |
| Twist Off (deg) | 20 (10 to 80) | Below this twist the watch check drops. |
| Hold (tics) | 6 (1 to 35) | Tics the pose must be held before it counts. |
| Below Eyes (m) | 0.3 (0 to 0.8) | Lowest the hand may be below your eyes. |
| Above Eyes (m) | 0.2 (0 to 0.5) | Highest the hand may be above your eyes. |
| Nearest (m) | 0.15 (0 to 0.5) | Nearest in front of your eyes the hand may be. |
| Furthest (m) | 0.65 (0.3 to 1) | Furthest in front of your eyes the hand may be. |
| To the Side (m) | 0.35 (0.1 to 0.8) | Furthest to either side of your eyes the hand may be. |
| Gun Tilt Max (deg) | 60 (20 to 90) | The gun may point at most this far up or down. |
| Hand Still (m/s) | 1.2 (0.3 to 3) | The hand must be slower than this to start. |
| Drift Allowed (m) | 0.05 (0 to 0.2) | Once on, the hand may drift this far before the check drops. |
| Tick Strength | 0.35 (0.05 to 1) | Strength of the ready tick. |
| **One Hand** | | |
| Still Under (m/s) | 0.3 (0.05 to 1.5) | Below this speed a hand counts as still. |
| **Both Hands** | | |
| Together (ms) | 120 (20 to 400) | How far apart in time the two hands may move and still be one gesture. |
| Peak Age (ms) | 180 (0 to 250) | Each hand's fastest moment must be this fresh. |
| Refire (ms) | 500 (0 to 2000) | Time before the same two hand gesture may fire again. |
| Down Speed (m/s) | 2 (0.5 to 8) | Down: each hand's downward speed. |
| Down Straightness | 0.5 (0 to 1) | Down: how much of the speed must be downward. |
| Hips Below Eyes (m) | 0.6 (0.2 to 1.2) | The hip line below your eyes. |
| Apart Speed (m/s) | 2 (0.5 to 8) | Apart: how fast the gap between the hands opens. |
| Chest Below Eyes (m) | 0.4 (0.1 to 0.8) | Apart: the chest line below your eyes. |
| Apart From Chest (m) | 0.5 (0.2 to 1) | Apart: the hands must start within this of the chest. |
| Palms Ahead (m) | 0.25 (0 to 0.8) | Palms: each hand at least this far in front of your eyes. |
| Palms Held (ms) | 400 (100 to 2000) | Palms: how long they must be held out. |
| Palms Up (deg) | 40 (0 to 90) | Palms: each hand pointing at least this far up. |
| Palms Apart (m) | 0.25 (0 to 0.8) | Palms: the hands at least this far apart sideways. |
| Thrust Speed (m/s) | 2.5 (0.5 to 8) | Thrust: each hand's forward speed. |
| Thrust Straightness | 0.6 (0 to 1) | Thrust: how much of the speed must be forward. |
| Thrust Palms Up (deg) | 20 (-30 to 90) | Thrust: each hand pointing at least this far up. |
| **Punch and Shove** | | |
| Punch Speed (m/s) | 2 (0.5 to 8) | Average swing speed for a punch. |
| Punch Repeat (tics) | 6 (0 to 35) | Tics before the same hand may punch again. |
| Uppercut Rise | 0.5 (0.2 to 0.9) | The swing's upward share above which a punch is an uppercut. |
| Punch Kept (ms) | 300 (50 to 1000) | How long the last punch is remembered. |
| Shove Share | 0.6 (0.2 to 1) | The other hand moving the same way at this share of the speed makes a shove, not a punch. |
| **Gesture Debug** | | |
| Gesture Debug Log | Off | Logs gesture events, and with more detail the hands' numbers and cost. |

</details>
<!-- /GEN:options -->

## Works with

This mod answers two services that other mods ask by name.

**`RSQG_Service`** (the gesture reader; the hand is 0 main, 1 off): `inspect` (the watch check: 0 not, 1 entering, 2 held, -1 switched off), `inspect.tics`, `inspect.any`, `pulse` (the pulse check, same answers), `pair.ago` (milliseconds since a two-hand gesture: 0 down, 1 apart, 2 palms out, 3 palms thrust; asking keeps them read for a second), `mainleft`, `braced`, `braced.tics`, `punch`, `punch.kind`, `punch.speed`, `shove`, `quiet`, the numbers `hand.x`, `hand.y`, `hand.z`, `hand.roll`, `hand.pitch`, and the text `pose.why` (why a watch or pulse check is not met). It sends the event `rsqg_pair <kind> <hundredths>`.

**`RSQA_Service`**: `swap` (1 while the Off-Hand Modifier is on for that player), `steady` (as a whole number: 1 when Steady Hands is on; as a number with `x`, `y`, `z`, `angle`, `pitch`, `roll`, `dx`, `dy` or `dz`: the smoothed hand), `seated`, `seated.drop`, `seated.eye`, `stand.eye`, `rumble` (Rumble Strength), `taps` (1.5 with Slower Taps), `vignette` (a comfort moment this tic, with its strength), `ready` (a short tick on a hand, with Sound Cues: Rumble), `buzz` (Rumble Backup for a rumble the asker starts). It sends the events `rsqa_mod <0|1>` and `rsqa_alt <code> <0|1>`.

Every setting is also a cvar the other mods read by name (`rsqa_*`), and they read them only while this mod's menu class `RSQA_Menu` exists.

| Mod | What changes |
|---|---|
| RSQ Gun Cards | Asks `inspect` for the hand's card. Its own copy of the reader stands down while this mod is loaded |
| RSQ Laser Sight | Asks `inspect` (a hand in the watch check and not aimed has no laser). Reads `steady` for its aim, Cue Size, Text Size, Colour Blind, Photosensitive |
| RSQ Tactical Rig | Asks `inspect` for both hands. Seated Play (`seated`) hangs the rig from your seated eyes. Handedness sets its body layout. Reads Text Size, Colour Blind, Photosensitive, Rumble Strength, Rumble Backup |
| RSQ Boss | Asks `inspect` for its call-in and `pulse` for its Start Fight card. Reads Text Size, Colour Blind, Photosensitive, Rumble Backup |
| RSQ Melee | Asks `pair.ago` and hears `rsqg_pair` 0 (its ground pound), 3 (its clear out) and 1 (its guard's release, else a taunt). Off-Hand Modifier (`swap`), Seated Play (`seated`, `seated.drop`), Rumble Strength, Rumble Backup |
| RSQ Distance Grab | Hears Grab Pull and Grab Reach. Off-Hand Modifier (`swap`), `steady` for its aim, Gesture Ease, Cue Size, Colour Blind, Photosensitive, Rumble Strength, Rumble Backup |
| RSQ Saber | Hears Force Push, Force Pull, Force Grip and Flick Reload. Off-Hand Modifier (`swap`), Hold to Toggle on its Force trigger, Slower Taps, `steady` for painting targets, `vignette` on its boosted Force jump, `ready` when Force Grip finds a new target, Gesture Ease, Cue Size, Text Size, Colour Blind, Photosensitive, Rumble Strength, Rumble Backup |
| RSQ ShieldSaw | Hears Shield Throw and Flick Reload. `steady` for its aim, Gesture Ease, Cue Size, Colour Blind, Photosensitive, Rumble Strength, Rumble Backup |
| RSQ SlowMo | Hears Wrist Cross as its Accessibility Button. Slow Mo Ease is the shortest its eases may be. Gesture Ease widens its own wrist cross. Reads Text Size, Colour Blind, Photosensitive, Rumble Strength, Rumble Backup. This mod asks it `slowmo.active` for the slow motion cue, and `down` so Seated Play: Auto does not switch while you are down |
| RSQ Whip | Off-Hand Modifier (`swap`), Rumble Strength, Rumble Backup |
| RSQ Wheel | Slower Taps on its double tap, `seated.drop`, `steady` for pointing at cards, Colour Blind, Photosensitive, Rumble Strength, Rumble Backup. This mod asks it `IsOpen` to stop reading gestures while it is open |
| RSQ Grapple | Sends `vignette` while its hook moves you. This mod asks it `g2.mode` and `g2.air` to stop reading gestures on the hook |
| RSQ Score | Text Size, Colour Blind, Photosensitive |
| RSQ VisualRewards | Cue Size, Text Size, Colour Blind, Photosensitive |
| RSQ Gun Bonsai VR | Text Size, Colour Blind, and Handedness for which side its HUD sits |
| RSQ Grenade | Rumble Strength, Rumble Backup. Photosensitive or a Comfort Vignette setting stops its screen kick |
| RSQ FnF | Rumble Strength, Rumble Backup |
| RSQ Monsters | Rumble Backup, Photosensitive |
| RSQ Graveyards | Photosensitive |
| RSQ PlayLog | Asks `inspect`, `pulse` and `pose.why` for its log |
| GNRC Reloaded and WoS Reloaded (weapon sets) | Rumble Strength, Rumble Backup, Photosensitive |
| QuestZDoom | Handedness sets its Control Scheme and Two Hand Brace its Two Handed Weapons. Rumble Backup acts only when its Quake Haptics is 0 |
| Every loaded series mod | Menus: Simple hides its Test and Debug link; Reset Every Mod runs its Reset All |

## Limits

- Nothing is bound by default, and all nine keys do nothing until One Handed is On (default Off).
- Each key only sends its event. With the mod it speaks to not loaded, nothing happens.
- Flick Reload does not reload with a gun in each hand: only RSQ Saber and RSQ ShieldSaw hear it, each only while its own item is in the off hand.
- Wrist Cross is only a key here. The wrist cross move itself is read by RSQ SlowMo, not by this mod's gesture reader.
- The gesture reader acts on nothing. It only names what the hands do and sends `rsqg_pair`; the card, the pound or the release is the asking mod's.
- The reader measures nothing until a mod asks, or Two Hand Always or the Gesture Debug Log is on. With no asking mod loaded, no watch check, punch name or two-hand gesture is read.
- Out of VR no hand is read. The reader answers only for the player on this machine.
- The watch check never starts on a moving hand, and both hands at the same point (a menu just closed) is not a pose.
- Palms out needs the hand pointing up: QuestZDoom reads no fingers.
- No buttons are read by this mod except its nine keys: no fire, grip, Use or stick. Palms out only checks that fire and alt fire are not held.
- Seated Play: Auto is paused while RSQ SlowMo says you are down.
- Comfort Vignette shows only for moments a mod reports (RSQ Grapple's hook, RSQ Saber's Force jump) and for Knockback Vignette. Nothing else darkens the view.
- Sound Cues' arrows and labels are not drawn while a menu is open.
- Rumble Backup's buzz is always the same strength and length, whatever rumble it stands in for.
- Reset All keeps Handedness, Two Hand Brace and both measurements; Forget Height is the only row that clears the standing height.

## Credits

The full list is in **CREDITS.txt**.

- **presidentkoopa:** the project, the design of one shared menu that finds the loaded series mods, the shared setting
  names, and RS_Gestures (written for his UZDXREMA engine), whose one-hand and both-hands detectors, settings and
  event shape the gesture reader is ported from.
- **QuestZDoom** (Emawind and Team Beef): the engine and its option menu classes, which the menu extends.
- **The 1-euro filter:** Casiez, Roussel and Vogel (CHI 2012), behind Steady Hands.
- **Colour checks:** Machado 2009 and Viénot 1999 colour-vision models, CIEDE2000 (`tools/cvd.py`).
- **The code** is new, written for this pack. The gun-butt shove's blow, its slow motion and the F.E.A.R. Effect moved
  to RSQ Melee on 2026-11-01; their credits are in its CREDITS.txt.

---
Written from the code at commit 7bd62b727, 2026-11-27.
