# RSQ Saber

`pk3/RSQ_Saber.pk3` (source folder `QuestSaber/`). Part of the Radiant Silvergun Quest series, for stock
QuestZDoom 17.3.

## What it is

A lightsaber in each hand (the second one is a dedicated off-hand weapon), with the Force. The blade cuts whatever your real swing passes it through; walking
and turning are not swings. It blocks and turns back shots and claws, and a parry (blade moving into the shot)
hits back harder. Hold the trigger to mark enemies, let go with a forward throw, and the saber flies to each
one and comes home. The off hand's alt trigger is the Force by gesture: push, pull, choke and fling. Holding
jump gives a Force jump. A training remote is there for practice. ZScript and data only, no engine change.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
`RSQ_Saber.pk3`

- **Needs no other RSQ pk3.**
- **Plain Doom 2 without Brutal Doom:** works. Brutal Doom's classes are looked up by name at run time, never
  required. The 10-27 handoff records rig runs on bare Doom 2. Without Brutal Doom Quest's hands, the off hand
  gets the saber's own bare Force hand when no second saber is out.
- With Brutal Doom, its sword (DSweap) becomes the saber (menu row "Brutal Doom Sword Becomes Saber", On).

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ Saber. One page, plus a "Controls" page and
  "Reset All" at the bottom.
- **You start holding it.** The saber is in slot 1. With "Start With Dual Sabers" On (default) the second saber
  is your off hand's weapon. There is no key for it.
- **Second Saber Starts: Put Away (default) / In Hand.** At the start (a new game, or the first time the second
  saber is given), Put Away means:
  - With RSQ Tactical Rig: it starts in its holster and the off hand is empty (Brutal Doom Quest's hands, or the
    saber's bare Force hand without Brutal Doom). Grip the holster (off hand's side) with the OFF hand to draw
    it, lit; grip again to put it away. Drawn or away, it stays that way across map changes and saves.
  - Without the Tactical Rig (or its "Tactical Rig" switch Off) there is no holster: it starts in the off hand
    with its blade OFF (a hilt). Light it with the Blade On / Off key, or throw it and it lights when caught.
    Drawn again later (after a gun took the off hand), it lights as usual.

  In Hand: as before, lit in the off hand at the start. Changing the row affects the next start, not a saber
  you already carry.
- **Binds (optional):** Options -> Customize Controls -> section **RSQ Saber**, or RSQ Saber -> Controls (the
  same three binds, shorter names):

| Customize Controls name | Controls page name | Does |
|---|---|---|
| Second blade on / off | Second Blade | Lights the second blade on the sabers in hand: the staff twirls in your hand. |
| Blade on / off (douse it) | Blade On / Off | Douses and relights the blades in hand (the hilt stays). If one is off, the press lights it; if all are lit, it douses them all. |
| Summon / dismiss training remote | Training Remote | A training drone that fires stings at you to deflect. |

The Second Saber key is gone (the owner, 11-01), and Brutal Doom's own Dual key no longer touches the saber.
An old saved "Dual key mode" (ubqs_dual_mode 1) reads as On and is rewritten to On.

## What to do in VR

- **Cut:** swing the blade through a monster. A real swing, harder than "Swing to Cut".
- **Stab:** thrust the hand along the blade. Hits one monster, 1.5x damage, no shove.
- **Block:** hold the blade in the path of a shot or a claw.
- **Parry:** move the blade into the shot as it arrives. Double knock in the hand, white burst.
- **Cross guard:** cross your two blades in front of you (an X or a +): nothing from in front gets through.
- **Blade lock:** bring your two blades together: they clash and lock with a snarl and flashes.
- **Mark and throw:** hold the trigger, sweep the hand over enemies (a diamond on each: a white centre in a ring of
  that saber's blade colour, so the off-hand saber's marks wear its own colour). Let go: it flies to
  each in turn and comes back. With nothing marked, let go while snapping the hand forward to throw it straight.
  Let go with the hand still: nothing happens.
- **Call it back:** trigger or alt while it is out of your hand.
- **Force push (main hand):** alt trigger on the main saber ("Main-Hand Force Push" On). Off: the main alt
  lights / douses the second blade instead.
- **Force by gesture (off hand):** hold the off alt trigger, then
  - thrust the hand forward = push (things thrown back, shots turned),
  - yank it back = pull (monsters and pickups come to you; your sabers come home),
  - hold still on an enemy (about a quarter second) = choke. It hangs where your hand points.
    Let go of alt with a fling = throw it.
- **Force jump:** hold jump with a saber or the Force hand out: you go higher and fall slowly.
- **Flick reload:** with a gun in the main hand and the off-hand saber or Force hand out, flick the gun down.
- **Second saber away / out (with RSQ Tactical Rig):** grip the second saber's holster with the off hand. Put
  away, the off hand holds the Force (Brutal Doom Quest's fist, or the saber's bare Force hand).

## Features

"On" = on by default (CVARINFO). "Option" = off by default.

| Menu row | Default | What it does |
|---|---|---|
| Sabers | On | The saber at all. |
| Start With Dual Sabers | On | The second saber is the off hand's weapon (the Tactical Rig holster puts it away and draws it). Off: one saber. |
| Second Saber Starts | Put Away | At the start: in its Tactical Rig holster, or without the rig in the off hand with the blade off. In Hand: lit in the off hand (the old way). |
| Main-Hand Force Push | On | The main saber's alt trigger is a Force push. Off: it toggles the second blade. |
| Brutal Doom Sword Becomes Saber | On | Brutal Doom's sword (pickups and the one you carry) is replaced by the saber. |
| Damage | 30 | The cut's damage (15-60). |
| Max Lock-On Targets | 5 | How many enemies one throw visits (1-5). |
| Main Blade Colour | Blue | |
| Main Blade Length | 76 cm | 54, 65, 76, 88 or 99 cm. |
| Off Blade Colour | Red | |
| Off Blade Length | Same as Main | |
| Off Blade Light | On | The off blade's own dynamic light. |
| Swing to Cut | 8 | How fast the blade must move to cut (lower = easier). |
| Blade Block Width | 1.5 | How far off the blade's line a shot may pass and still be blocked. |
| Hit-Stop | Off (Option) | A cut freezes the monster: Light 3, Medium 4, Heavy 6 tics. |
| Perfect Parry Slow-Mo | Option | A parry gives half a second of slow motion. Needs RSQ SlowMo. |

Always on, no row: swept-arc cuts (a fast flick between two frames still cuts), the parry double knock, the stab,
the hum growing louder and higher on a hard swing.

Deliberately not on the menu (CVARINFO lists them; they keep working at their defaults): start holding it
(on), the world-drawn saber, light detail, where turned shots go (where you look), throw strength, the Force at
all (on), Force jump (on), Force gesture speed and straightness, saber sound (Graflex), rumble (on),
handedness (follows the game), training remote level (2), diagnostics.

## Test it

Load only the base order plus `RSQ_Saber.pk3`. Steps marked **(not yet headset-confirmed)** were only run on
the simulated rig (2026-10-31 onward). Older features were also logged as "not yet run on the owner's
headset" in docs/HANDOFF_polish.md.

1. Menu: Radiant Silvergun Options -> RSQ Saber. All rows above are there.
2. Start a map with the saber in hand. A lit saber in the main hand, hum on draw. The second saber: see 20 and 21.
3. Swing at an imp: it is cut. A slow wave does nothing. Walk and turn without swinging: no cuts.
4. Flick the blade fast past a monster: it still cuts (swept arc). **(not yet headset-confirmed)**
5. Stab: thrust straight at one monster in front of another. Only the first is hit, harder, not shoved.
   **(not yet headset-confirmed)**
6. Hold a blade still across an imp's fireball: it is blocked and sent back. One short buzz.
7. Parry: swing into a fireball or a zombie's shot as it arrives. Two knocks in the hand, a white burst, a higher
   clash. **(not yet headset-confirmed)**
8. Let an imp claw at you with the blade in its way: the claw is stopped and the imp reels.
9. Cross both blades in front of you: shots from in front stop. Touch the blades together: clash and lock.
10. Hold the trigger and sweep over three monsters: a diamond on each (white centre, ring in the blade's
    colour), a buzz each. Let go: the saber
    visits each, then comes home and relights in your hand.
11. Throw with nothing marked: snap the hand forward and let go. Press the trigger again while it flies: it
    comes back.
12. Main-hand alt: a Force push (thump, dust down the cone, monsters thrown back).
13. Off hand: hold alt and thrust forward (push), yank back (pull: a pickup comes to you), hold still on an imp
    (it lifts, crackles and chokes, blue outline). Fling and let go: it flies and hurts what it hits.
14. Hold jump: higher jump, slow fall.
15. Controls (three binds; no Second Saber key): Second Blade key: the staff twirls in the hand and cuts what it touches. Blade On / Off: the blade
    goes out and back. Training Remote: a drone appears; deflect its stings; press again to dismiss.
16. Options, one at a time, then back off:
    - Hit-Stop (Medium): a cut monster freezes for a beat. **(not yet headset-confirmed)**
    - Perfect Parry Slow-Mo: needs RSQ SlowMo loaded. A parry slows the world for half a second. Without SlowMo,
      nothing happens and no error. **(not yet headset-confirmed)**
17. Two-hand hold (SteamVR grip on the off controller near the main): the off-hand saber stays drawn.
    **(not yet headset-confirmed)**
18. With a gun in the main hand and the off saber out, flick the gun down: it reloads.
19. Brutal Doom's Dual key with the saber in the main hand: the second saber does not move.
20. With RSQ Tactical Rig, new game, Second Saber Starts Put Away: the second saber is in its holster and the off
    hand is empty (it distance-grabs with Brutal Doom Quest's hands). Grip the holster with the off hand: it comes
    out lit. Change map, and save and load: it stays out. Grip again: it goes away, and stays away across maps.
    **(rig only, not headset-confirmed: logged 11-02 on doom2 and on the full order)**
21. Without the Tactical Rig, new game, Put Away: the second saber is in the off hand with its blade off. Blade
    On / Off key: it lights (with the main saber lit too, only the dark one lights). **(rig only, not
    headset-confirmed, 11-02)**
21b. Second Saber Starts In Hand, new game: lit in the off hand, with or without the rig, as before. **(rig only,
    11-02)**
22. Main-Hand Force Push Off: main alt lights the second blade instead. Brutal Doom Sword Becomes Saber Off (new
    map): Brutal Doom's sword is its own again. **(not yet headset-confirmed)**
23. "Reset All" puts everything back.
24. With RSQ Accessibility (Steady Hands On, its default): hold fire and point the saber at a far monster with
    your hand held still. The diamond lands on the one you point at, not a neighbour. Raise the off hand at a
    far imp: the grip outline holds on it. Steady Hands Off: as before. **(not yet headset-confirmed; rig: load
    only)**
25. With RSQ Accessibility: Rumble Strength 0, then cut a monster and clash: no rumble. Rumble Strength 2:
    stronger. **(not yet headset-confirmed)**
26. With RSQ Accessibility, Slower Taps On: hold fire, paint a monster, let go with the hand still, then press
    fire again within about 1.5 s: the diamonds are still there (1 s without Slower Taps).
    **(not yet headset-confirmed)**
27. Lock marks wear the blade colour: set Main Blade Colour to red and Off Blade Colour to blue, paint a monster with each
    saber. The main saber's diamond has a red ring, the off saber's a blue ring; both have a white centre.
    Change the colour in the menu: marks already up recolour. **(not yet headset-confirmed; rig frames 11-02)**

## Works with

- **Brutal Doom VR (BD22Q):** its off-hand fist (RSQ_Hands) holds the Force: with the saber in the main hand
  and a fist in the off hand, the off alt trigger is the Force; the fist still punches on its trigger. Its sword
  becomes the saber (menu row). Its Dual key (+user3) does nothing to the saber. Flick reload follows BD22Q's
  own flick setting. With a gun in the main hand BD22Q puts its own hands in the off hand (measured on the rig:
  a second saber drawn from the holster then is replaced by them within about 20 tics); with the saber in the
  main hand the drawn second saber stays.
- **RSQ Tactical Rig:** saber holster spots (Left saber / Right saber). The main saber is put away and drawn
  there by the main hand; the second saber by the off hand at its own spot. That holster is the only way the
  second saber is put away.
- **RSQ ShieldSaw:** rest the lit main blade across the front of the shield and the shield's block grows
  (ShieldSaw's "Saber Over Shield").
- **RSQ SlowMo:** the Perfect Parry Slow-Mo option.
- **RSQ DistanceGrab:** reaches with a doused hilt in hand, not with a lit one. Its rule also counts the saber's
  bare Force hand as busy, so on Doom 2 without Brutal Doom a holstered second saber leaves an off hand that
  holds the Force hand and does not grab; with Brutal Doom Quest the off hand holds its hands and grabs.
- **RSQ Score:** the training remote's points, and saber bonuses (cuts, throws, Force, parries, riposte).
- **RSQ HP Bars:** a monster in a Force grip shows the "gripped" marker; hit-stop shows the frozen marker.
- **Gun Bonsai with the RSQ Gun Bonsai VR patch:** the saber levels up; melee upgrades (Momentum, Riposte
  Edge, Piercing Return, Saber Throw, Force Push / Pull / Choke / Jump levels, Chain Choke). Without the patch
  nothing changes.
- **RSQ Accessibility:** one-handed Force buttons, Hold to Toggle for the Force, Gesture Ease, photosensitive
  flashes, colour-blind outlines. Inert without it. Also (2026-11-01, not yet headset-confirmed):
  - Steady Hands: pointing reads the smoothed hand: painting locks (fire held) and choosing what the Force
    grips. Cuts, swings, throws, the Force push and pull stay on the raw hand. Where a deflected shot goes reads
    your HEAD (where you look), not a hand, so Steady Hands does not touch it.
  - Rumble Strength scales every saber rumble (0 = none).
  - Slower Taps: the second press that picks your painted marks back up waits 1.5 s instead of 1 s.
  - Seated Play: nothing to read; the saber has no height-from-floor test.

## Known limits / open issues

- The saber's models and its sounds are slated for replacement (see Credits).
- SNDINFO's header says "Wardust's saber set, and four synthesized (clash, burn, catch, drop)". The four
  synthesized sounds break the stock-sounds rule (open). Wardust is not named in CREDITS.txt, which says the
  sounds' source is not recorded; the two notes disagree.
- Clash double knock: not rig-tested. Rumble strengths are first guesses; nothing about rumble could be felt on
  the rig.
- A blocked shot can carry on up to one tic past you before it is put back on the blade (not seen in runs).
- The second saber's holster in the headset: only the network events were run on the rig (11-01), not a real
  grip on a real body.
- Not run in a netgame.

## Credits

From CREDITS.txt, unchanged:

```
BORROWED, WITH THANKS
  RS_Main (Ermac -- DXR, Rusted Legacy)
      combat FX sprites, used for the Force and the blade's impacts:
        UXFL  the choke/grip lightning arcs        (RSL2*)
        UXPD  blast smoke -- Force push, and the smoke off a cut   (JSMO*)
        UXFH  the armed-hand flare                 (RSF7*)
      and the Force choke loop:
        ubqs/grip   built from monsters/RSELLOOP.ogg
  QuestZDoom (Emawind)
      the engine this targets, and the off-hand weapon and AttackPos/Angle/Pitch/Roll script API
      the whole mod is built on.
  li-gnrcwpn
      ubqs/rbeep -- the training remote's ready beep, from the plasma rifle's alt-fire alert
      (weapons/plasrifle/PLBEEP).

MODELS AND SOUNDS (the project owner, 10-28)
  The saber models come from Sketchfab, sourced at the same time and from the same site as the
  owner's Star Wars 3D weapon models. Their authors and licences are not recorded here yet.
  The sounds come from the same place as the owner's RS lightsaber; their source is not recorded.
  SLATED FOR REPLACEMENT (owner, 10-28): the models and those sounds are to be replaced with assets
  from a named, credited source (with a recorded licence), since their authors can't be traced.
  The blade and glow shapes and the generated sounds are this pack's own.

THE SABER ITSELF
  Made by the project owner (presidentkoopa) and this pack.

SHARING
  Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors'
  terms. Much of Ermac's work (he is DoomVR's co-designer) is MIT-licensed; sharing it here is
  the project owner's decision. (The old "not for distribution" line was carried over from
  another repo by mistake.)
```
