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
| Colours | Classic | Classic, Red (coldcite's two), Protanopia, Deuteranopia, Tritanopia, High Contrast. The colour-blind sets also hatch and gently pulse the low band, put a dark line in the mid band, and High Contrast adds a white rim and is always full bright. |
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

## Credits

From the old README:

> The series' version of **Top HP Bars 1.04 by coldcite** (based on SpriteShadow by Nash Muhandes). coldcite's header: "Feel free to use this in your mods. You don't have to ask my permission!" Credit coldcite and Nash in CREDITS.txt; check SpriteShadow's own terms before shipping.

> Lossvoise's flat retexture (of Mere_Duke's version; zdoom forum thread t=56910) is not used (owner, 10-28: no). The series ships coldcite's art and its own generated schemes only.

`pk3/CREDITS.txt`, unchanged:

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
