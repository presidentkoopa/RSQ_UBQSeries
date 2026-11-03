# RSQ HP Bars

A health bar floats over every monster you have hurt. It is coldcite's Top HP Bars 1.04, kept as he drew
it, with colour-blind colour sets, a strip for health above 100 %, and small icons that show what the other
series mods are doing to that monster (hooked, stunned, locked on, gripped, frozen, held). It has no buttons
and asks nothing of your hands.

Pk3: `pk3/RSQ_HPBars.pk3`.

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
**RSQ_HPBars.pk3**

- Works on plain Doom 2 without Brutal Doom (it was run on vanilla doom2 on the rig). No monster class
  is named in the code.
- Needs no other RSQ pk3 to work alone. The icons left of the bar need the mods that drive them (see
  "Works with").
- If coldcite's own Top HP Bars pk3 is also loaded, this one takes over: one bar per monster.

## Setup

- No buttons to bind (KEYCONF only holds the Reset All command).
- Menu: Options -> Radiant Silvergun Options -> **RSQ HP Bars**. Sliders are on its
  **Tuning and Debug** page.

## Features

Front page (RSQ HP Bars):

| Row | Default | What it does |
|---|---|---|
| HP Bars | On | Bars on or off. |
| Colours | Classic | Classic, Red (coldcite's two), Protanopia, Deuteranopia, Tritanopia, High Contrast, Cyan Lavender Orange (cyan full, lavender mid, orange low), Random (each bar picks three fresh colours). The colour-blind sets also hatch and gently pulse the low band, put a dark line in the mid band, and High Contrast adds a white rim and is always full bright. |
| Size | Standard | Small / Standard / Large. |
| Full Bright | Option (off) | Bars ignore the room's light. |
| Allow Stealth | On | A see-through monster gets a see-through bar. |
| Overheal | On | A thin strip above the bar holds health over 100 %. Past one full strip, small diamonds at its end (up to 4). |
| Markers | On | The icons: hooked / stunned / locked / gripped left of the bar; frozen (snowflake), held (padlock) and raised (purple up arrow) right of it; with RSQ_Miniboss, a gold crown above the miniboss's bar and a grey chain link above each of its thralls' bars. |
| Aimed Only | Option (off) | A bar only over the monster either hand's gun points at, and for half a second after. An unhurt monster you aim at gets its bar too. |
| Damage Chunk | Option (off) | What your hit took off stays lit white for half a second, then drains. |
| Ally Colour | Option (off) | Friendly monsters get a blue bar. |
| Nearest 24 Only | Option (off) | Only the 24 bars nearest you are drawn. |
| Distance Limit | Option (off) | No bars farther than the Limit Distance slider (Tuning). |

Damage Numbers rows (same page; Xaser Acheron's damnums, folded in and rebuilt for VR on 2026-11-03; all
rig only, not yet headset-confirmed):

| Row | Default | What it does |
|---|---|---|
| Damage Numbers | On | The damage each hit did, in the world at the monster. |
| Numbers For | Monsters Only | Or All Shootable (barrels, props; never your own body). |
| Shotgun Spray | Option (off) | One number per pellet instead of one per monster per tic. |
| Number Font | JFO Metal | JFO Metal, Ermac, Classic Doom, Classic Doom (small). Words (HEADSHOT, OVERKILL, xN) are always JFO. |
| Number Colour | Default | Used only with Colour by Hit Strength off (damnums' 21 colours). |
| Number Motion | Toss | Used only with Pop and Settle off (damnums' Toss or Float). |
| Damage Type Colours | On | Used only with Colour by Hit Strength off (fire orange, plasma cyan, ...). |
| Text Quality | Quest | Quest (half-resolution glyphs) or PCVR. |
| Hit Colours | By Damage Type | By Damage Type (bullets white, shells yellow, fire orange, explosives red, plasma cyan, BFG lime, rail blue, melee pink, saws crimson, Saber sky, Force lavender), By Hit Strength (white / yellow / orange / red by the share of health), damnums' (the Number Colour and Damage Type Colours rows), any of 17 colours, Random. |
| Pop and Settle | On | A super tiny number appears where you hit (the bullet's puff, the missile's spot) and jets up and out of the monster like a small fountain, spinning at its own random speed (mostly a little, sometimes a lot), gone in 0.63 s. Off: damnums' Toss / Float. |
| Size by Hit | Option (off) | Bigger share of health, a little bigger number (0.85x to 1.25x). |
| Grow with Distance | Option (off) | Hit numbers grow with range (the bars' Far Size curve). Off: never. |
| Running Total | On | From the second hit within 3 s, one total centred above the monster's bar: it rolls up like a counter and bounces a little on each hit, steps colour with the combo, grows a little to x5. Its colour drains, then it fades, 3 s after the last hit (Score's chain window). Under a low ceiling it goes beside the bar. |
| Kill Slam | On | On the kill the total (or the killing hit) punches once, holds, fades. The number is the health really taken. No sprite behind it. |
| Overkill Word | On | OVERKILL over a kill whose last hit went past zero by more than half the monster's health. |
| Headshot Word | On | HEADSHOT over Brutal Doom's head hits: a number 1.35x bigger with a sharp jolt and the Castlevania life (white flash, a slow gold / white shimmer, its letters bobbing). |
| Out of Your Face | On | Never nearer your eyes than about a metre; slid off either gun's aim line. |
| Most Numbers | 12 | Only the nearest 6 / 12 / 24 / 48 show. |
| Gains on You | On | +health (green), +armour (blue), +ammo (gold) rise from the pickup and fly to the wrist (ammo to its gun's hand, the rest to the off hand). |
| Freeze in Hit-Stop | On | A number on a monster in a hit-stop stands still until it ends, then pops. |
| Numbers in Slow-Mo | World Time | With RSQ_SlowMo: World Time (slow with the world) or Your Time. |
| Combo Counter | On | "xN" beside the HP bar (the other side when a wall is on that side); shakes gently from x5. |
| Number Size | 1.0 | Slider. 1 = a hit's digits 2.5 map units tall (about 7 cm: 1.4 degrees at 3 m, 0.5 at 8 m, 0.2 at 20 m), never more than 1.8 degrees however near. |
| Word Size | 1.0 | Slider. HEADSHOT, OVERKILL, xN, the level-up band's text and the weapon tag. |
| Headshot Flash | On | A headshot's number is white for its first 2-3 tics (never with RSQ_Accessibility's Photosensitive Mode). |
| Headshot Cycling | On | The headshot's shimmer and bobbing letters (steps of 4 tics, 8 with Photosensitive Mode; never a strobe). |
| Combo Shake | On | The total and the combo wobble a little from x5. |
| Clear of Walls | On | Each hit's jet is traced before it shows: kept under the ceiling and out of walls. |
| Total Colours | Follow Combo | Or one of 17 colours, or Random. |
| Combo Colours | White Yellow Orange Red | The ramp the total and combo step through (x1-2, x3-4, x5, x6+): five ramps or Random (a fresh ramp each chain). With RSQ_Accessibility's colour-blind palette on, the default ramp becomes a safe one. |
| Headshot Colour | Gold | 17 colours or Random. |
| Player Level-Up | On | Gun Bonsai's player level-up: LEVEL UP scrolls across a band in front of you (in very fast, readable about 0.45 s in the middle, fast out; 1.26 s), with PLAYER LV n and +1 UPGRADE trailing. It stands about 2 m in front of your eyes (nearer if a wall is closer) and follows your gaze lazily. |
| Level-Up Slow-Mo | Option (off) | A short RSQ SlowMo pulse through the readable part (needs RSQ_SlowMo). |
| Level-Up Band Colour / Level-Up Text Colour | Gold | 17 colours or Random. |
| Weapon Level-Up | On | Gun Bonsai's weapon level-up: a small tag rises off the gun (Gun Cards' size): the gun's name types in letter by letter with a white flash each, LV n stamps in with one punch, NEW UPGRADE flickers green, then it fades (2 s). |
| Weapon Tag Border | Gold | One steady colour: 17 colours or Random. |

Drawn with the engine's VisualThinkers from textures: no sprite frames, no actor per digit, one pool of at most
200 glyphs that the engine never ticks. Do not load damnums as well (two numbers per hit, and its 9999s on Brutal
Doom corpses come back).

Always on (no row):

- **Length by toughness**: tougher monsters get longer bars (a rifle zombie shortest, a Cyberdemon widest).
- **Hit flash**: the bar flashes white for one tic when you hit the monster.
- **Raised marker**: a monster an Arch-Vile brings back gets its bar at once, with a purple up arrow
  (shown with Markers on).
- **Fade in**: a new bar fades in over about a sixth of a second.
- Bars sit right on voxel monsters and on monsters thrown or tumbling (Grapple yanks).

Tuning and Debug page: Size, Far Size (bars grow up to 2x at range), Height, Limit Distance (1536),
Reset All.

## Test it

Load only the order above plus RSQ_HPBars.pk3. Start MAP01.

1. Shoot an imp once. A bar appears over it. It fades in and flashes white on each hit (fade and flash:
   not yet headset-confirmed).
2. Hurt a zombieman and a Baron (or any big monster). The Baron's bar is clearly longer. (not yet
   headset-confirmed)
3. Look at a monster you have not hurt. It has no bar.
4. Options -> Radiant Silvergun Options -> RSQ HP Bars -> Colours: step through all six. Each set changes
   the bar at once. High Contrast has a white rim and stays bright in a dark room.
5. Size: Small, then Large. The bars shrink and grow.
6. Turn on **Damage Chunk**. Hit a monster: a white block stays on the bar for half a second, then drains.
   (not yet headset-confirmed)
7. Turn on **Aimed Only**. Only the monster your gun points at shows a bar. Point away: it goes within a
   second. Point at an unhurt monster: it gets a bar. (not yet headset-confirmed)
8. Turn on **Nearest 24 Only** in a big fight: far bars drop out once more than 24 show. (not yet
   headset-confirmed)
9. Turn on **Distance Limit**: far bars vanish. Move the Limit Distance slider on Tuning and Debug and
   watch the cut-off move. (not yet headset-confirmed)
10. **Ally Colour** needs a friendly monster (a Brutal Doom marine ally): its bar is blue. (not yet
    headset-confirmed)
11. Raised marker: let an Arch-Vile raise something. The raised monster gets a bar with a purple up arrow.
    Brutal Doom's own imp leaves a separate corpse, so a BD monster may never show it; it showed on a
    stock imp. (not yet headset-confirmed)
12. Frozen and held markers need other mods (steps 14 and 15). (not yet headset-confirmed)
12a. With RSQ_Miniboss (Markers on): hurt the miniboss: a gold crown above its bar. Hurt one of its thralls: a
     grey chain link above that bar. Kill the miniboss: the thralls' links go. Rig frame 2026-11-01; **not yet
     headset-confirmed**. Like every bar, the mark needs the monster hurt first (an unhurt one has no bar).
13. Reset All on Tuning and Debug. Everything goes back to the defaults above.
13a. With LegenDoom (or LegenDoom Lite): a monster that will turn legendary has no bar until you hurt it, then
     the same plain bar as its neighbours; when it turns (at half health) its bar fills again with the overheal
     strip. Rig 2026-11-02, with the real LegenDoom Lite 4.2 and 3.0 pk3s and with Champions' dormant LegenDoom
     mode (`test/ld.sh`); **not yet headset-confirmed**.

Damage Numbers (rig only, not yet headset-confirmed):

19. Shoot an imp once: a tiny number jets up out of where you hit it, spinning, and fades. Shoot a Baron with a
    chaingun: one total rolls up above its bar, "x12" beside the bar, stepping white, yellow, orange, red. Kill it
    with a rocket: the total punches once, OVERKILL over it, and fades.
20. Brutal Doom: shoot a zombie in the head: HEADSHOT (gold) over a bigger number with a jolt, a white flash and a slow shimmer.
20a. With Gun Bonsai: level a gun (the tag rises off it) and the player (the LEVEL UP band).
21. Get hurt, then walk over a stimpack and a clip: +10 green and +10 gold rise and fly to your wrists.
22. Number Font and Text Quality: step through them on a held number (a hit-stop holds it still).

With other series mods (each not yet headset-confirmed):

14. RSQ Melee: headlock a monster. A padlock shows right of its bar while you hold it.
15. Any hit-stop (Saber, ShieldSaw, Whip, DistanceGrab, a thrown gun from Tactical Rig): a snowflake shows
    for the few tics the monster is frozen.
16. RSQ_Grapple: hook a hurt monster. The hooked icon shows left of its bar; a yank's landing shows stunned.
17. RSQ_ShieldSaw: lock on. The locked icon shows. RSQ_Saber: Force-grip a hurt monster. The gripped icon
    shows.
18. RSQ_Accessibility: set Colour Blind Mode. It overrides the Colours row. Photosensitive Mode makes the
    hit flash weaker (40 %) and no faster than about 2.5 a second.

## Works with

- **RSQ_Accessibility** (read): Colour Blind Mode overrides Colours; Photosensitive Mode dims and slows the
  hit flash; Cue Size scales the marker icons.
- **RSQ_Grapple**: hooked and stunned icons (asked by name).
- **RSQ_ShieldSaw**: locked icon.
- **RSQ_Saber**: gripped icon.
- **RSQ Melee**: held padlock for a headlocked monster (read off the monster; nothing is asked).
- Any hit-stop from the series: frozen snowflake (read off the monster).
- coldcite's Top HP Bars: taken over (his bars removed, his HUD options entry opens this menu).
- Champions: a bar over a champion wearing its icon is lifted above the icon.
- LegenDoom (3.0 or Lite 4.2, read by name): a monster picked to become legendary looks like any other until it
  turns -- no bar while unhurt, then a plain bar of the same length, no overheal strip. Once it turns, its 300 %
  shows as a full overheal strip and one diamond (with Champions' dormant mode, as that champion).
- RSQ_Miniboss (read, by name: RSQMB_Service "miniboss" / "thrall"): the crown and chain-link marks. Without it, no marks.

- **RSQ_SlowMo** (asked by name: RSQSM_Service "active" / "scale"): damage numbers slow with the world, or not.
- **RSQ GunCards** (found by name, not asked or changed): an ammo gain lands on that wrist where Gun Cards shows its
  +N. Landing exactly on its card needs a hook from Gun Cards (see "Next").
- **Score**: a running total fades on Score's 3 s chain window; Score is not asked.

## Known limits / open

- Everything from 2026-10-31 (frozen, held, Aimed Only, the QoL round: length, flash, raised, fade in,
  Damage Chunk, Ally Colour, Nearest 24, Distance Limit) ran on the simulated rig only.
- The raised marker may never show on Brutal Doom's own monsters (BD leaves a separate corpse actor).
- Frozen and held icons need a bar, so an unhurt monster shows neither.
- The stunned icon can trail by up to 4 tics (bars ask every 4th tic; a stun lasts 8).
- Readability at Quest resolution, the low-band pulse, and icon size at 2x were never judged in a headset.
- "Your hit" for the flash and chunk is any player's hit (single-player: yours).
- Champions writes its boosted health as the start health, so a set-up champion reads 100 %, not overheal.
- Lossvoise's flat retexture is not shipped (no permission).

## Next (Damage Numbers, asked for, not built)

- CRIT word and the magenta tier: after 2.0. The hook is in: `RSQTHP_DnService` `GetInt("crit", "", tics, 0,
  monster)` marks that monster's hits for `tics` tics (default 2); nothing is drawn for a crit yet.
- Backstab: not wanted (owner, 2026-11-03). 3D voxel tumbling numbers: not built.
- Score payout names (a kill's points and best bonus rising from the body) and move colours (a number tinted by
  the move that made it) need Score to answer by name, e.g. `RS_ScoreService GetString("kill.rows", ...)` and
  `GetString("blow.last", "", player, 0, monster)`. Not built.
- Gun Cards draws its card with the hand, so its world position is not readable: landing a gain exactly on its +N
  needs a Gun Cards Service answering the card's world position per hand and whether its +N shows.
- A number beside a bar near a wall can be hidden by the wall, like any sprite.

## Credits

From the old README:

> The series' version of **Top HP Bars 1.04 by coldcite** (based on SpriteShadow by Nash Muhandes). coldcite's header: "Feel free to use this in your mods. You don't have to ask my permission!" Credit coldcite and Nash in CREDITS.txt; check SpriteShadow's own terms before shipping.

> Lossvoise's flat retexture (of Mere_Duke's version; zdoom forum thread t=56910) is not used (owner, 10-28: no). The series ships coldcite's art and its own generated schemes only.

Damage numbers: damnums by Xaser Acheron (MIT). Fonts: JFO, the JDUI font by Zedas in Blackmore1014's "JDUI Brutal
Doom Ultimate Edition" edit (NO REUSE LICENCE STATED: ask Zedas and Blackmore1014 before any public release, as
Gun Cards' CREDITS says); Ermac's Force Unleashed digits, as Gun Cards ships them. Full text in pk3/CREDITS.txt.

`pk3/CREDITS.txt` (before the Damage Numbers):

```
RSQ Top HP Bars -- credits
==========================

Top HP Bars 1.04 by coldcite (2017). The layout, the bar art (both styles, all 44 frames), the
default look and the idea are his; Classic and Red ship his images byte for byte, and every other
colour set is his style-A art recoloured pixel by pixel (tools/gen_art.py in the source repo).
His header: "Feel free to use this in your mods. You don't have to ask my permission!"
Thank you, coldcite.

Top HP Bars was based on SpriteShadow by Nash Muhandes. SpriteShadow's repository
(github.com/nashmuhandes/SpriteShadow, checked 2026-10-27) is released under the MIT License:

    MIT License

    Copyright (c) 2021 Nash Muhandes

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

(coldcite's 1.04 predates that licence file; the thread, forum.zdoom.org viewtopic p=1087777,
states no other terms. The pattern used from it -- a world sprite that follows its owner -- is
rewritten here; no SpriteShadow code is copied.)

Not included, credited for the record:
  - Lossvoise's flat high-visibility retexture of Mere_Duke's custom version (zdoom forum
    t=56910) is NOT shipped: no permission yet (credit chain coldcite -> Mere_Duke -> Lossvoise).
  - damnums by Xaser Acheron (MIT) is meant to be loaded alongside; nothing of it is bundled.
  - Champions and LegenDoom Lite: read by class / cvar name for compatibility (handler.zs); nothing of
    either is bundled.

Code: ZScript written for the Ultra Badass Quest series (presidentkoopa), for stock QuestZDoom 17.3
by Emawind84 and Team Beef. No engine change.
```

Builder notes (art, tests, internals) are in `HANDOFF.md`.
