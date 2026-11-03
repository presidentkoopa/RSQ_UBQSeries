# RSQ Gestures (RSQ Gestures)

**The one thing:** it reads how your real hands move (a watch check, a thrust, a punch and what kind, a gun-butt
shove, both hands together) and every other mod in the series fights with that.

Reads what your hands are doing and answers the other series mods when they ask: a watch check (gun held up,
the back of the wrist turned to your face), a hand held still, a thrust or pull, a punch (jab, hook,
uppercut), a gun-butt shove, both hands down / apart / palms out / palms thrust, and whether you are braced
(the two-hand grip). It does nothing to the game by itself: it only reads hands and answers. For stock
QuestZDoom 17.3, in VR. It needs no other pk3 and works on plain Doom 2 with or without Brutal Doom. It is a
port of the owner's RS_Gestures.

Pk3: `pk3/RSQ_Gestures.pk3`. The gun-butt shove's blow, the slow motion after a shove and the F.E.A.R. Effect
are RSQ Melee's; Gestures only names the shove.

## Features

- **Watch check.** Hold the gun up in front of your face and turn the back of your wrist to your face: RSQ Gun
  Cards shows its watch card, the Tactical Rig can move the gun to the other hand. A light tick in that
  controller says the pose is held (Watch Check Tick). Inspect Twist Way chooses the side: Back of Wrist,
  Pulse Side, or Either Way.
- **Thrust and pull.** A hand shoved fast along the way it points, or pulled straight back. Thrust and Pull
  Events sends them to other mods.
- **Punch.** A straight punch is a jab, one from the side a hook, a rising one an uppercut. Empty hand or
  fists. Never while braced or with both hands shoving together.
- **Shove.** The same swing with a gun in that hand (or both hands driving one gun, or braced) is a shove, its
  own answer, never a punch.
- **Both hands.** Both hands swept down past the hips, both thrown apart from the chest, both palms held out,
  both palms thrust forward together. Two-Hand Events sends them; each has its own switch under it. With the
  switch off they are still read while a mod asks about them (RSQ Melee does, for Ground Pound and Clear Out).
- **Braced.** One answer for every series mod: whether the engine's two-hand grip latch is on.
- **Quiet.** On a grapple rope (climbing, swinging, reeling) or with the Wheel open, and a quarter second
  after, nothing is read as a thrust, pull, punch, shove or two-hand gesture.
- **Show Gesture Names.** A small grey line low in the view names each gesture as it is read, half
  see-through, gone in 1.5 s.
- **Fit Zones to My Body.** Measure Me scales every zone (the watch check's box, the hips, the chest, palms
  out) from your measured eye height and reach. The defaults assume eyes 1.60 m above the floor and a reach of
  0.70 m.
- **Cheap.** It measures the hands only while a mod has asked something in the last second, or its events,
  Measure Me or the Debug Log are on.

## How to play

There are no buttons to bind. Every gesture is read from the controllers.

- **Watch check:** hold the gun up in front of your face (upper chest to just above the eyes, within an arm's
  length) and turn the back of your wrist to your face, the side a watch sits on, at least 45 degrees. Hold it
  a moment: a light tick in that hand. Either hand. Across the chest, as you would check a watch, is the pose
  RSQ Gun Cards' watch card reads best in. Twist back past 30 degrees and it drops.
- **Thrust / pull:** shove a hand fast (2 m/s) along the way it points, or pull it straight back.
- **Punch:** from a slow hand, throw it 15 cm toward where you face at about 2 m/s. Straight = jab, from the
  side = hook, rising = uppercut. Empty hand or fists.
- **Shove:** the same swing with a gun in that hand.
- **Both hands down:** sweep both hands down past your hips together.
- **Both hands apart:** throw both hands outward from your chest.
- **Both palms out:** both hands in front, pointing up, side by side, still, no trigger, for 0.4 s.
- **Both palms thrust:** both hands driven forward together, where you face, at 2.5 m/s or more, side by side,
  each pointing at least 20 degrees up, not braced on a gun.
- **Measure Me:** turn on Fit Zones to My Body, stand tall, arms straight out to your sides, pick Measure Me,
  close the menu. A message tells you to stand; two seconds later you are measured for one second.

Left-handed (QuestZDoom's Left-Handed scheme, which RSQ Accessibility's Handedness sets): "main" is always the
gun hand.

## Settings

Options -> Radiant Silvergun Options -> **RSQ Gestures**.

| Menu row | Default | What it does |
|---|---|---|
| Inspect Twist Way | Back of Wrist (watch) | Either Way / Pulse Side (palm up) / Back of Wrist (watch): which way the wrist turns for the watch check. Mirrored for the left hand. |
| Inspect Twist (degrees) | 45 | Twist needed to start. |
| Inspect Hold (tics) | 6 | How long the pose is held before it counts (35 tics = 1 s). |
| Watch Check Off | Off | Turns the watch check off; RSQ Gun Cards then uses its own watch pose. |
| Watch Check Tick | On | A light tick in that hand's controller when the watch check is held. |
| Show Gesture Names | On | The small grey line naming each gesture as it is read. |
| Thrust and Pull Events | Off | Sends thrust, pull, punch and shove events to other mods. |
| Two-Hand Events | Off | Sends the both-hands events. |
| Both Hands Down | On | Under Two-Hand Events: this one fires. |
| Both Hands Apart | On | Under Two-Hand Events: this one fires. |
| Both Palms Out | On | Under Two-Hand Events: this one fires. |
| Both Palms Thrust | On | Under Two-Hand Events: this one fires. |
| Fit Zones to My Body | Off | Scales every zone from your measured eye height and reach. |
| Measure Me | row | Two seconds after you close the menu, measures you for one second. |
| Tuning and Debug | page | See below. |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Twist To Drop (degrees) | 30 | Below this twist the watch check drops. |
| Lowest (below eyes) | 0.30 | The watch check's box, metres from your eyes. |
| Highest (above eyes) | 0.20 | |
| Nearest (in front) | 0.15 | |
| Furthest (in front) | 0.65 | |
| To The Side | 0.35 | |
| Gun Points Up/Down At Most | 60 | Degrees. |
| Hand Still Under (m/s) | 1.2 | The hand must be slower than this to start the watch check. |
| Drift Allowed Once On (m) | 0.05 | Once on, the hand may drift this far before it drops. |
| Thrust Speed (m/s) | 2.0 | Speed along the hand for a thrust or pull. |
| Thrust Fresher Than (ms) | 150 | The fastest instant must be this fresh. |
| Thrust Repeat (tics) | 12 | Before the same hand may thrust again. |
| Still Under (m/s) | 0.30 | Below this a hand counts as still. |
| Together Within (ms) | 120 | How far apart in time the two hands may move and still be one gesture. |
| Peak Fresher Than (ms) | 180 | Each hand's fastest instant must be this fresh. |
| Refire After (ms) | 500 | Before the same two-hand gesture fires again. |
| Down: Speed (m/s) | 2.0 | Each hand's downward speed. |
| Down: How Straight | 0.50 | How much of the speed must be downward. |
| Hips Below Eyes (m) | 0.60 | The hip line. |
| Apart: Speed (m/s) | 2.0 | How fast the gap between the hands opens. |
| Chest Below Eyes (m) | 0.40 | The chest. |
| Thrown From Within (m) | 0.50 | Apart: thrown from within this of the chest. |
| Palms: In Front (m) | 0.25 | Each hand at least this far in front of your eyes. |
| Palms: Held (ms) | 400 | Held this long. |
| Palms: Pointing Up (degrees) | 40 | Each hand pointing at least this far up. |
| Palms: Apart Sideways (m) | 0.25 | The hands at least this far apart (thrust too). |
| Thrust: Speed (m/s) | 2.5 | Both palms thrust: each hand's speed forward. |
| Thrust: How Straight | 0.60 | How much of the speed must be forward. |
| Thrust: Pointing Up (degrees) | 20 | Each hand pointing at least this far up. |
| Punch Speed (m/s) | 2.0 | Average speed over the swing for a punch. |
| Punch Repeat (tics) | 6 | Before the same hand may punch again. |
| Uppercut Rise | 0.50 | The swing's upward share above this is an uppercut. |
| Punch Answered For (ms) | 300 | "punch" and "shove" answer the last one for this long. |
| Two-Hand Shove Share | 0.60 | The other hand moving the same way at this share of the speed = a two-hand shove, not a punch. |
| Watch Check Tick Strength | 0.35 | The tick's strength (QuestZDoom's quake haptics level scales it). |
| Debug Log | Off | Off / Changes and Events / Also the Hands, Every Second / Also the Cost. |
| Reset All | row | Resets the Gestures settings. Asks first. |

## Works with

Gestures is a shared service: other mods ask it, it does not change them.

- **RSQ Gun Cards:** asks "inspect" (the watch check) to show the watch card. With Watch Check Off, Gun Cards
  uses its own watch pose.
- **RSQ Tactical Rig:** asks "inspect" for its Move Gun at Watch (Use) option: Use during the watch check
  moves that hand's gun to the other hand. Without Gestures that option does nothing.
- **RSQ Melee:** asks "pair.ago" for Ground Pound (both hands down) and Clear Out (both palms thrust), so those
  work with Two-Hand Events off. Melee reads its own swings for the gun-butt shove, so a shove is never acted on
  twice.
- **RSQ Gun Bonsai VR:** its fists nodes that need the two-hand reads are offered only while RSQ Melee and
  Gestures are both loaded.
- **RSQ Grapple** and **RSQ Wheel:** asked whether you are on the rope or the ring is open, to stay quiet.
- **RSQ Accessibility:** Handedness is followed through QuestZDoom's scheme. Off-Hand Modifier (One-Handed):
  while it is held the main controller plays the off hand, so the off hand's thrust, pull, punch and watch
  check come from it; the main hand names nothing meanwhile. Seated Play: Measure Me while seated adds back how
  far your eyes are below standing. Slower Taps: the two hands' "together" window x1.5. Rumble Strength scales
  the watch-check tick (0 = none).

Gun Bonsai VR has no nodes that change Gestures: it has no progression of its own.

## Load order

After Brutal Doom, the monster packs and Gun Bonsai, with the other RSQ pk3s, in any order among them.

## Known limits

- QuestZDoom gives no finger, grip or trigger travel. "Palms out" is read from the hands pointing up, side by
  side, no fire button.
- Gesture Ease and Accessibility's gesture buttons do not reach Gestures.
- The drawn-shape matcher from RS_Gestures (shapes drawn in the air) is not ported.
- Every answer is about the local player; anyone else gets 0.

## For other mods

Service class **RSQG_Service**, asked by name:

```
let it = ServiceIterator.Find("RSQG_Service");
Service s = it.Next();
int state = s ? s.GetInt("inspect", "", 0) : 0;   // 0 main hand, 1 off hand
```

Ask from play code at least once a second: asking is what keeps it measuring. `intArg` is the hand (0 main, 1
off) unless said otherwise. `objectArg` may be the asking PlayerPawn: anyone but the local player gets 0.

| Request | Returns |
|---|---|
| `GetInt "inspect"` | 0 not, 1 starting (pose met, being held), 2 held; -1 when Watch Check Off |
| `GetInt "inspect.tics"` | tics since the pose was met, 0 when not |
| `GetInt "inspect.any"` | the larger of the two hands' states |
| `GetInt "still"` | tics the hand has been still |
| `GetInt "thrust"` | speed along the hand's pointing, hundredths of m/s (negative = pulling back), its fastest instant in the last quarter second |
| `GetInt "pair.ago"` | `intArg` = 0 down, 1 apart, 2 palms, 3 palms thrust: ms since it last fired, -1 never. Asking keeps the two-hand events read for a second, with Two-Hand Events off |
| `GetInt "palms"` | ms both palms have been out (needs Two-Hand Events) |
| `GetInt "mainleft"` | 1 when the main hand is the left controller |
| `GetInt "braced"` | 1 while the two-hand grip latch is on (`objectArg` = the pawn; any player). Also from `GetIntUI` / `GetIntData` |
| `GetInt "braced.tics"` | tics it has been on, 0 when not |
| `GetInt "punch"` | the hand's last punch within Punch Answered For (300 ms): 1 jab, 2 hook, 3 uppercut; 0 none |
| `GetInt "shove"` | the hand's last gun shove within the same window: 1 one hand, 2 two hands on the gun; 0 none |
| `GetInt "shove.ago"` / `"shove.speed"` | ms since it (-1 never) / its average, hundredths of m/s |
| `GetInt "quiet"` | 1 on the rope, 2 the Wheel open (or just closed): nothing is read as a gesture; 0 |
| `GetInt "punch.kind"` / `"punch.ago"` / `"punch.speed"` | the last punch: 0 jab 1 hook 2 uppercut (-1 never) / ms since (-1 never) / average, hundredths of m/s |
| `GetDouble "hand.x"`, `"hand.y"`, `"hand.z"` | the hand from your eyes, metres: forward, left, up |
| `GetDouble "hand.roll"`, `"hand.pitch"` | the hand's twist and pitch, degrees |
| `GetDouble "thrust"`, `"palms"`, `"punch.speed"`, `"shove.speed"` | as above, in m/s and seconds |
| `GetIntUI` / `GetIntData` `"inspect"`, `"inspect.tics"`, `"inspect.any"`, `"mainleft"`, `"braced"` | the last answer, from any scope, read only (does not keep it measuring) |

Unknown requests return -1. A mod loaded after this one may instead call the static `RSQG.Inspect(hand)`,
`RSQG.InspectTics(hand)`, `RSQG.StillTics(hand)`, `RSQG.Thrust(hand)`, `RSQG.PalmsOutSeconds()`,
`RSQG.Braced(pmo)`, `RSQG.Punch(hand)`.

**Events** (when switched on) have RS_Gestures' shape: `rsqg_thrust` / `rsqg_pull` arg0 hand, arg1 speed in
hundredths of m/s; `rsqg_punch` arg0 hand, arg1 kind (0 jab, 1 hook, 2 uppercut), arg2 hundredths of m/s;
`rsqg_shove` arg0 hand, arg1 two hands (0/1), arg2 hundredths of m/s; `rsqg_pair` arg0 which (0 down, 1 apart,
2 palms, 3 palms thrust), arg1 hundredths of its own unit (the slower hand's downward m/s, the gap's opening
m/s, seconds out). They say what the hands did, not what it means. Apply them to `e.Player`.

## Credits

`CREDITS.txt`, unchanged:

```
RSQ_Gestures -- credits
=======================

Code: ZScript for the Radiant Silvergun Quest series (presidentkoopa), for stock QuestZDoom 17.3 by
Emawind84 and Team Beef. No engine change.

Ported from presidentkoopa's RS_Gestures (written for his REMA engine, UZDXREMA): the one-hand pose and
impulse detectors (rsg_signals.zs: still, thrust, pull) and the both-hands detectors (rsg_pair.zs: both
down, both apart, both palms out), their settings and their event shape. The inspect pose is new here,
for the RSQ Wheel's weapon cards.

The hand reading follows RSQ_Grapple's (AttackPos / OffhandPos and the engine's angle conventions), and
the shared Radiant Silvergun Options menu is the series' tools/rsmenu.

(The gun butt shove -- BD22 VR Reloaded's, with Brutal Doom's numbers and sounds -- its slow motion and the
F.E.A.R. Effect live in RSQ Melee; their credits are in its CREDITS.txt.)
```

The punch reader is the boxing gloves' reader (RSQ Melee's) and SuperPunchOut's ClassifyPunch, copied (no link
to either).
