# RSQ_Gestures

What your hands are doing, for any Radiant Silvergun Quest mod that asks. Stock QuestZDoom 17.3, no
engine change. Ported from the owner's **RS_Gestures** (written for his REMA engine).

It does nothing on its own: another mod asks it a question (the Wheel's weapon cards ask "is this hand
inspecting?") and it answers. When nothing has asked for a second, it stops measuring.

## The gestures

| Gesture | What you do | How a mod hears it |
|---|---|---|
| **Inspect** (new) | Hold the gun up in front of your face (upper chest to just above the eyes, an arm's length or less), twist your wrist past 45 degrees, hold it for a moment. Lower it or untwist it and it ends. Each hand on its own. | asks `"inspect"`: 0 not, 1 starting, 2 held |
| **Still** | A hand not moving. | asks `"still"`: how many tics |
| **Thrust / Pull** | A hand shoved fast along the way it points, or pulled back. | events `rsqg_thrust` / `rsqg_pull` (switch on: Thrust and Pull Events) |
| **Both hands down** | Both hands swept down past the hips together. | event `rsqg_pair` 0 (switch on: Two-Hand Events) |
| **Both hands apart** | Both hands thrown outward from the chest. | event `rsqg_pair` 1 |
| **Both palms out** | Both hands held out in front, pointing up, side by side, still, no trigger. | event `rsqg_pair` 2, and asks `"palms"` |
| **Braced** (new) | The engine's two-hand grip latch (`WF_TWOHANDSTABILIZED`): the off grip pressed with the controllers within 0.50 m. SteamVR and QuestZDoom's own Quest input both set it. One answer for every series mod instead of each testing the bit. Any player, not only this machine's. | asks `"braced"`, `"braced.tics"` |
| **Shove** (QoL GE2) | The same swing with a **gun** in that hand (anything but fists or a blade), or both hands driving a gun together, or braced: Brutal Doom's gun-butt shove. Its own answer, never a punch. Gestures only reports it: the knock back is Brutal Doom VR's own (its butt strike, Options' Two-Handed Butt Strike, `rsq_butt`, off by default; its pistol whip, `rsq_pistol_whip`, on), and nothing here pushes or hurts anything, so the two never collide. A blade in hand (axe, sword, chainsaw) is neither. | asks `"shove"`; event `rsqg_shove` (with Thrust and Pull Events on) |
| **Punch** (new) | A jab, hook or uppercut: a slow hand that then travels 0.15 m toward where you face at 2 m/s average, named by its travel against that line. Gun Bonsai's gloves' reader and SuperPunchOut's ClassifyPunch, copied (no link to Gun Bonsai). Never while braced, and never when both hands shove the same way together (a two-hand gun; Brutal Doom's butt-stroke push). | asks `"punch"`; event `rsqg_punch` (with Thrust and Pull Events on) |

**On the rope or at the Wheel nothing is a gesture** (QoL GE1): while RSQ Grapple answers `"climbing"`,
`"swinging"` or `"reeling"`, or RSQ Wheel answers `"IsOpen"`, and for a quarter second after, no thrust, pull,
punch, shove or two-hand event is read (asked by name through their services; neither mod is changed).

**Watch check** (inspect): a light tick in that hand when the pose is held (Watch Check Tick, on), and it can be
switched off altogether (Watch Check Off): then `"inspect"` answers -1, "not answering", and RSQ Gun Cards uses
its own watch pose. **Show Gesture Names** (on): a small grey line low in the view names each gesture as it is
recognised, for tuning; it is half-transparent and gone in 1.5 s. **Fit Zones to My Body** (off): stand tall, arms
straight out to your sides, press Measure Me and close the menu: two seconds later your eye height and reach are
measured and the zones scale from the body the defaults assume (eyes 1.60 m, reach 0.70 m). Each two-hand event
has its own switch under Two-Hand Events.

Every distance is measured from **your eyes, in metres, in your own frame** (forward, sideways, up), so
tall, short and seated players make the same gesture, and the map's squashed vertical
(`level.pixelstretch`, 1.2) is undone first. A left-handed player (QuestZDoom's Left-Handed control
scheme, which RSQ_Accessibility's Handedness sets) gets the same gestures on the other hand: "main" is
always the gun hand.

The thrust, pull and two-hand events are **off by default**, as they are in RS_Gestures. Inspect has no
switch: it answers whenever a mod asks.

## Settings
Options → Radiant Silvergun Options → **RSQ Gestures**: the inspect twist (and which way: either,
palm down only, palm up only), how long to hold it, the two event switches, and Tuning and Debug (where
the gun must be for inspect, every thrust and two-hand number, Debug Log, Reset All).

## For mod makers: asking by name (no compile dependency)

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

## What RS_Gestures has that this does not
- **The drawn-shape matcher** (`rsg_match`, `rsg_capture`, `rsg_record`: a shape drawn in the air,
  matched against recorded templates). Not ported: about 1,400 lines plus a recording menu, and nothing
  in the series asks for it yet. Its engine reads (the head's full pose, REMA's haptics, the body's yaw)
  would need the same stand-ins as below.
- **Open palm / closed hand** (`OpenPalm`, `Closed`). REMA reads finger touch, grip and trigger travel;
  QuestZDoom gives a mod none of them. "Both palms out" here reads the hands pointing up, side by side
  and no fire button held instead.
- REMA's own engine reads are replaced: the 250 ms hand velocity ring (`HandVelAtPoint`,
  `HandPeakAgeMs`) by a ring of the last 9 tics measured from the pose; `HandPos` by AttackPos /
  OffhandPos; `HmdPos` by the eyes rebuilt from QuestZDoom's `HmdPosition`; the body's yaw by the
  pawn's angle; real seconds by tics (this runs every real tic).

## Netplay
QuestZDoom has none. The hands are read on the machine that has them (the engine writes them for the
local player only) and every answer is about the local player. What a game should act on leaves as a
network event, as in RS_Gestures.

## Credits
See CREDITS.txt.
