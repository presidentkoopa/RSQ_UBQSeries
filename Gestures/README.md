# RSQ Gestures

Reads what your hands are doing and answers the other series mods when they ask: a watch check (gun held
up, the back of the wrist turned to your face), a hand held still, a thrust or pull, a punch (jab, hook, uppercut), a gun-butt shove,
both hands down / apart / palms out, and whether you are braced (two-hand grip). It does nothing to the
game by itself: it only reads hands and answers. It is a port of the owner's RS_Gestures (written for his
REMA engine).

**Moved to RSQ Melee (2026-11-01):** the gun-butt shove's blow (BD22 VR Reloaded's butt strike), the slow
motion after a shove and the **F.E.A.R. Effect** live in [RSQ_Melee](../Melee/) now, with their settings
(`rsqml_shove*`). Melee reads the swing itself, so it needs no Gestures; Gestures still names the shove and
answers "shove" to any mod that asks.

Pk3: `pk3/RSQ_Gestures.pk3`.

## Load order

doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3 ->
BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> **RSQ_Gestures.pk3**

- Works on plain Doom 2 without Brutal Doom.
- Works on plain Doom 2 and with Brutal Doom alike: it changes nothing in the game.
- Needs no other RSQ pk3. The mods that ask it something are **RSQ_GunCards** and **RSQ_TacticalRig** (both
  the watch check).
- It measures the hands only while a mod has asked something in the last second, or its events, Measure Me or
  debug are on.

## Setup

- No buttons to bind.
- Menu: Options -> Radiant Silvergun Options -> **RSQ Gestures**. Fine numbers and Reset All are on its
  **Tuning and Debug** page.

## What to do in VR

- **Watch check**: hold the gun up in front of your face (upper chest to just above the eyes, within an
  arm's length) and turn the back of your wrist to your face, the side a watch sits on (not the pulse side),
  at least 45 degrees, hold a moment. Either hand. Across the chest, as you would check a watch, is the pose
  RSQ Gun Cards' watch card reads best in.
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
| Inspect Twist Way | Back of Wrist (watch) | Which way the wrist turns for the watch check: Either Way, Pulse Side (palm up), Back of Wrist (watch). Mirrored for the left hand. (Renamed 2026-11-02 from Palm Up / Knuckles Up; same settings.) |
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
speed / repeat / uppercut rise, two-hand shove share, Watch Check Tick Strength, Debug Log, Reset All. (Gun Butt
Shove, Slow-Mo After a Shove, Butt Shove Speed and Shove Slow-Mo Length are RSQ Melee's rows now.)

(The gun butt shove's numbers and where each comes from: RSQ_Melee's README.)

## Test it

Load the order above plus RSQ_Gestures.pk3. The whole mod was built 2026-10-31: every step is not yet
headset-confirmed.

1. Options -> Radiant Silvergun Options -> RSQ Gestures. Turn on **Thrust and Pull Events**.
2. Hold a gun up in front of your face and turn the back of your wrist to your face. Hold it. You feel a light
   tick in that hand and see "watch check (main)" low in the view. Try the off hand: "watch check (off)".
2a. Turn the wrist the other way, the pulse side to your face: no tick, no name, no watch card. **(not yet
   headset-confirmed; rig 2026-11-02 below)**
3. Turn on **Watch Check Off**. Repeat step 2: no tick, no name. Turn it off again.
4. Turn off **Watch Check Tick**. Repeat step 2: name, no tick.
5. Put the guns away (fists). Throw a straight punch: "jab (main)". A punch from the side: "hook". A rising
   punch: "uppercut".
6. With a gun in hand, the same swing: "shove (main)". Both hands driving one gun: "two-hand shove".
6a. With RSQ_Melee loaded too, the same swing also hits (its gun-butt shove, tested in its README); Gestures only
   names it.
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
15. With RSQ Accessibility, One-Handed On and the Off-Hand Modifier bound: hold the modifier and thrust your
    main hand along where it points: "thrust (off)". Let go: "thrust (main)" again. While it is held the main
    hand names nothing of its own. **(not yet headset-confirmed; rig: logged "thrust, off hand" with the
    modifier held)**
16. With RSQ Accessibility, Seated Play Seated (or Auto, sitting down): Fit Zones to My Body, Measure Me while
    seated. The eyes it reports are about your standing height, not the chair's. **(not yet headset-confirmed)**
17. With RSQ Accessibility, Slower Taps On, Two-Hand Events On: both hands down past the hips can be a little
    less together and still count (180 ms apart instead of 120). **(not yet headset-confirmed)**
18. With RSQ Accessibility: Rumble Strength 0, hold the watch check: no tick. 2: stronger.
    **(not yet headset-confirmed)**

## Works with

Gestures is a shared service: other mods ask it, it does not change them.

- **Read by RSQ_GunCards**: "inspect" (the watch check) shows the watch card and, on Inspect Gesture, the
  small card. With Watch Check Off, Gun Cards uses its own watch pose.
- **Read by RSQ_TacticalRig**: "inspect", for its *Move Gun at Watch (Use)* option (off by default): Use
  during the watch check moves that hand's gun to the other hand. Without Gestures that option does nothing.
- **Nothing reads "braced", "punch", "still", "shove" or the events from outside yet.** They are ready for
  other mods. (RSQ_Melee reads its own swings, so Melee works without Gestures and a shove is never acted on
  twice.)
- **Reads RSQ_Grapple** (on the rope?) and **RSQ_Wheel** (ring open?) to stay quiet.
- Left-handed (QuestZDoom's Left-Handed scheme, which RSQ_Accessibility's Handedness sets): "main" is
  always the gun hand.
- **Reads RSQ_Accessibility** by name (RSQA_Service and its settings; nothing changes without it). New
  2026-11-01, not yet headset-confirmed:
  - Handedness: followed already, through QuestZDoom's scheme (above).
  - Off-Hand Modifier (One-Handed): while it is held the main controller plays the off hand, so the off hand's
    thrust, pull, punch and watch check come from it; the main hand names nothing meanwhile.
  - Seated Play: Measure Me while seated adds back how far your eyes are below standing. The zones are measured
    from your eyes, so seated needs nothing else.
  - Slower Taps: the two-hand "together" window x1.5. Gestures has no button taps.
  - Rumble Strength: the watch-check tick.
  - Gesture Ease and the gesture buttons do not reach Gestures yet.

## The watch check's direction, measured (2026-11-02)

The owner reported "I look at the back of my wrist, not my pulse ... the card is upside down". The rig (QZD 17.3,
the controller turned about its own pointing axis, stage roll + = its top to the right) gives, on plain Doom 2:

| Pose | AttackRoll / OffhandRoll | Watch check |
|---|---|---|
| right hand, gun forward, back of the wrist up | -90 | held (2) |
| right hand, gun forward, pulse side up | +90 | no |
| right hand, across the chest, back of the wrist up | -90 | held (2) |
| right hand, across the chest, pulse side up | +90 | no |
| left hand, gun forward / across, back of the wrist up | +90 | held (2) |
| left hand, gun forward / across, pulse side up | -90 | no |

The same before and after the 2026-11-02 change: Gestures' direction (Back of Wrist, `rsqg_inspect_way` 2) was
already the watch side, so its code did not change, only the menu words. On SteamVR (`+vr_mode 10`) the roll comes
from `gl_openvr.cpp getMainHandAngles` instead of the OpenXR path; the gun model is turned by the same angle in
both (`GetHandTransform`), and a numeric check of that code gives the same sign, so the direction holds there too
(not headset-confirmed). What was upside down was RSQ Gun Cards' card (a constant half turn added 2026-10-31); see
its README. If the watch check still answers to the pulse side for you, check Inspect Twist Way on the Gestures
page: a saved Either Way or Pulse Side keeps answering to it.

## Known limits / open

- All rig only (simulated hands), not yet headset-confirmed: braced, punch, shove, quiet on the rope /
  Wheel, watch-check tick, gesture names, Fit to My Body, Watch Check Off, per-event two-hand switches.
- QuestZDoom gives no finger, grip or trigger travel. "Palms out" is read from the hands pointing up, side
  by side, no fire button.
- The drawn-shape matcher from RS_Gestures (shapes drawn in the air) is not ported.
- No netplay in QuestZDoom; every answer is about the local player.

## Credits

`CREDITS.txt`:

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

(The gun butt shove, BD22 VR Reloaded's, moved to RSQ_Melee on 2026-11-01 with its credit.)
```

From the old README: the punch reader is the boxing gloves' reader (RSQ_Melee's since 2026-11-01, Gun
Bonsai VR's before) and SuperPunchOut's ClassifyPunch, copied (no link to either).

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

(`rsqg_buttshove` and `rsqg_fear`, Gestures' own events for the shove's blow, became RSQ_Melee's `rsqml_buttshove`
and `rsqml_fear` on 2026-11-01.)
