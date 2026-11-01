# RSQ Gestures

Reads what your hands are doing and answers the other series mods when they ask: a watch check (gun held
up, wrist twisted), a hand held still, a thrust or pull, a punch (jab, hook, uppercut), a gun-butt shove,
both hands down / apart / palms out, and whether you are braced (two-hand grip). It does nothing to the
game by itself: nothing here hurts, pushes or fires. It is a port of the owner's RS_Gestures (written for
his REMA engine).

Pk3: `pk3/RSQ_Gestures.pk3`.

## Load order

doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3 ->
BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> **RSQ_Gestures.pk3**

- Works on plain Doom 2 without Brutal Doom.
- Needs no other RSQ pk3 to load. Alone, you only see it if you turn on **Thrust and Pull Events** or
  **Two-Hand Events** (then the gesture names line shows what it reads). Today the only mod that asks it
  something is **RSQ_GunCards** (the watch check).
- With nothing asking and both event switches off, it stops measuring (costs nothing).

## Setup

- No buttons to bind.
- Menu: Options -> Radiant Silvergun Options -> **RSQ Gestures**. Fine numbers and Reset All are on its
  **Tuning and Debug** page.

## What to do in VR

- **Watch check**: hold the gun up in front of your face (upper chest to just above the eyes, within an
  arm's length), twist your wrist knuckles-up past 45 degrees, hold a moment. Either hand.
- **Thrust / pull**: shove a hand fast along the way it points, or pull it straight back.
- **Punch**: from a slow hand, throw it 15 cm toward where you face at about 2 m/s. Straight = jab, from
  the side = hook, rising = uppercut. Empty hand or fists.
- **Shove**: the same swing with a gun in that hand (or both hands driving one gun, or braced).
- **Both hands down**: sweep both hands down past your hips together.
- **Both hands apart**: throw both hands outward from your chest.
- **Both palms out**: both hands in front, pointing up, side by side, still, no trigger.
- **Measure Me**: stand tall, arms straight out to your sides, press the row, close the menu.

## Features

| Row | Default | What it does |
|---|---|---|
| Inspect Twist Way | Knuckles Up (watch) | Which way the wrist twists for the watch check: Either Way, Palm Up (pulse side), Knuckles Up (watch). Mirrored for the left hand. |
| Inspect Twist (degrees) | 45 | Twist needed to start. |
| Inspect Hold (tics) | 6 | How long the pose is held before it counts (35 tics = 1 s). |
| Watch Check Off | Option (off) | Turns the watch check off; RSQ Gun Cards then uses its own watch pose. |
| Watch Check Tick | On | A light tick in that hand's controller when the watch check is held. |
| Show Gesture Names | On | A small grey line low in the view names each gesture as it is read (half see-through, gone in 1.5 s). |
| Thrust and Pull Events | Option (off) | Sends thrust, pull, punch and shove events to other mods. |
| Two-Hand Events | Option (off) | Sends the both-hands events. |
| Both Hands Down | On | (Under Two-Hand Events) this one fires. |
| Both Hands Apart | On | (Under Two-Hand Events) this one fires. |
| Both Palms Out | On | (Under Two-Hand Events) this one fires. |
| Fit Zones to My Body | Option (off) | Scales every zone from your measured eye height and reach (defaults assume eyes 1.60 m, reach 0.70 m). |
| Measure Me | row | Two seconds after you close the menu, measures you for one second. |

Always answered when a mod asks (no row): punch kind, shove, braced (the engine's two-hand grip latch),
hand still, hand position. On a grapple rope (climbing, swinging, reeling) or with the Wheel open, and a
quarter second after, nothing is read as a thrust, pull, punch, shove or two-hand gesture.

Tuning and Debug: where the gun must be for the watch check, thrust and two-hand speeds and zones, punch
speed / repeat / uppercut rise, two-hand shove share, Watch Check Tick Strength, Debug Log, Reset All.

## Test it

Load the order above plus RSQ_Gestures.pk3. The whole mod was built 2026-10-31: every step is not yet
headset-confirmed.

1. Options -> Radiant Silvergun Options -> RSQ Gestures. Turn on **Thrust and Pull Events**.
2. Hold a gun up in front of your face and twist knuckles-up. Hold it. You feel a light tick in that hand
   and see "watch check (main)" low in the view. Try the off hand: "watch check (off)".
3. Turn on **Watch Check Off**. Repeat step 2: no tick, no name. Turn it off again.
4. Turn off **Watch Check Tick**. Repeat step 2: name, no tick.
5. Put the guns away (fists). Throw a straight punch: "jab (main)". A punch from the side: "hook". A rising
   punch: "uppercut".
6. With a gun in hand, the same swing: "shove (main)". Both hands driving one gun: "two-hand shove".
   Brutal Doom's own pistol whip / butt strike still does the hitting; Gestures only names it.
7. Shove a hand fast along where it points: "thrust (main)". Pull it straight back: "pull (main)".
8. Turn on **Two-Hand Events**. Sweep both hands down past your hips: "both hands down". Throw them apart
   from the chest: "both hands apart". Hold both palms out, pointing up, side by side: "both palms out".
9. Turn off **Both Hands Apart**. Throw them apart again: nothing.
10. Turn off **Show Gesture Names**. The line no longer appears.
11. Turn on **Fit Zones to My Body**, stand tall, arms out, pick **Measure Me**, close the menu. A message
    tells you to stand; two seconds later you are measured. The watch check now fits your height.
12. With RSQ_Grapple: while climbing or swinging on a rope, thrusts and punches are not named.
    With RSQ_Wheel: while the ring is open, the same.
13. With RSQ_GunCards (Show Cards: Inspect Gesture, or the watch card): the watch check from step 2 shows
    the cards.
14. Reset All on Tuning and Debug.

## Works with

Gestures is a shared service: other mods ask it, it does not change them.

- **Read by RSQ_GunCards**: "inspect" (the watch check) shows the watch card and, on Inspect Gesture, the
  small card. With Watch Check Off, Gun Cards uses its own watch pose.
- **Nothing reads "braced", "punch", "shove", "still" or the events yet.** They are ready for other mods.
- **Reads RSQ_Grapple** (on the rope?) and **RSQ_Wheel** (ring open?) to stay quiet.
- Left-handed (QuestZDoom's Left-Handed scheme, which RSQ_Accessibility's Handedness sets): "main" is
  always the gun hand.
- Does not read RSQ_Accessibility (Gesture Ease does not reach it yet).

## Known limits / open

- All rig only (simulated hands), not yet headset-confirmed: braced, punch, shove, quiet on the rope /
  Wheel, watch-check tick, gesture names, Fit to My Body, Watch Check Off, per-event two-hand switches.
- QuestZDoom gives no finger, grip or trigger travel. "Palms out" is read from the hands pointing up, side
  by side, no fire button.
- The drawn-shape matcher from RS_Gestures (shapes drawn in the air) is not ported.
- Brutal Doom VR's long-gun butt strike is off in BD itself (`rsq_butt`, its own setting); only the pistol
  whip is on. The owner asked for it on (handoff section 9). Gestures reports the shove either way.
- No netplay in QuestZDoom; every answer is about the local player.

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
```

From the old README: the punch reader is Gun Bonsai's gloves' reader and SuperPunchOut's ClassifyPunch,
copied (no link to Gun Bonsai).

---

## Appendix: for mod makers: asking by name (no compile dependency)

```
let it = ServiceIterator.Find("RSQG_Service");
Service s = it.Next();
int state = s ? s.GetInt("inspect", "", 0) : 0;   // 0 main hand, 1 off hand
```

Ask from play code (a weapon, an item, a WorldTick) at least once a second: asking is what keeps it
measuring. `intArg` is the hand (0 main, 1 off) unless said otherwise. `objectArg` may be the asking
PlayerPawn: anyone but the local player gets 0 (the hands are this machine's hardware).

| Request | Returns |
|---|---|
| `GetInt "inspect"` | 0 not, 1 starting (pose met, being held), 2 held; -1 when Watch Check Off |
| `GetInt "inspect.tics"` | tics since the pose was met (counts through 1 and 2), 0 when not |
| `GetInt "inspect.any"` | the larger of the two hands' states |
| `GetInt "still"` | tics the hand has been still |
| `GetInt "thrust"` | speed along the hand's pointing, hundredths of m/s (negative = pulling back), its fastest instant in the last quarter second |
| `GetInt "pair.ago"` | `intArg` = 0 down, 1 apart, 2 palms: ms since it last fired, -1 never (needs Two-Hand Events) |
| `GetInt "palms"` | ms both palms have been out (needs Two-Hand Events) |
| `GetInt "mainleft"` | 1 when the main hand is the left controller |
| `GetInt "braced"` | 1 while the two-hand grip latch is on (`objectArg` = the pawn; any player). Also from `GetIntUI` / `GetIntData` |
| `GetInt "braced.tics"` | tics it has been on, 0 when not |
| `GetInt "punch"` | the hand's last punch within `rsqg_punch_window` (300 ms): 1 jab, 2 hook, 3 uppercut; 0 none |
| `GetInt "shove"` | the hand's last gun shove within `rsqg_punch_window`: 1 one hand, 2 two hands on the gun; 0 none |
| `GetInt "shove.ago"` / `"shove.speed"` | ms since it (-1 never) / its average, hundredths of m/s |
| `GetInt "quiet"` | 1 on the rope, 2 the Wheel open (or just closed): nothing is read as a gesture; 0 |
| `GetInt "punch.kind"` / `"punch.ago"` / `"punch.speed"` | the last punch: 0 jab 1 hook 2 uppercut (-1 never) / ms since (-1 never) / average hundredths of m/s |
| `GetDouble "hand.x"`, `"hand.y"`, `"hand.z"` | the hand from your eyes, metres: forward, left, up |
| `GetDouble "hand.roll"`, `"hand.pitch"` | the hand's twist and pitch, degrees |
| `GetDouble "thrust"`, `"palms"` | as above, in m/s and seconds |
| `GetIntUI` / `GetIntData` `"inspect"`, `"inspect.tics"`, `"inspect.any"`, `"mainleft"` | the last answer, from any scope, read only (does not keep it measuring) |

Unknown requests return -1. A mod loaded after this one may instead call the static `RSQG.Inspect(hand)`,
`RSQG.InspectTics(hand)`, `RSQG.StillTics(hand)`, `RSQG.Thrust(hand)`, `RSQG.PalmsOutSeconds()`,
`RSQG.Braced(pmo)`, `RSQG.Punch(hand)`.

**Events** (when switched on) have RS_Gestures' shape: `rsqg_thrust` / `rsqg_pull` arg0 hand, arg1 speed
in hundredths of m/s; `rsqg_punch` arg0 hand, arg1 kind (0 jab, 1 hook, 2 uppercut), arg2 hundredths of m/s; `rsqg_shove` arg0 hand, arg1 two hands (0/1), arg2 hundredths of m/s; `rsqg_pair` arg0 which (0 down, 1 apart, 2 palms), arg1 hundredths of its own unit
(the slower hand's downward m/s, the gap's opening m/s, seconds out). They say what the hands did, not
what it means. Apply them to `e.Player`.
