# Top HP Bars (RSQ HP Bars)

**The one thing:** a health bar over every monster you hurt that also shows what each series mod is doing to it
right now -- hooked, stunned, locked, gripped, frozen, held, raised -- in six colour sets, three of them built
for colour-blind eyes.

A health bar floats over every monster you have hurt. It is coldcite's Top HP Bars 1.04, kept as he drew it,
with colour-blind colour sets, a strip for health above 100 %, and small icons that show what the other
series mods are doing to that monster (hooked, stunned, locked on, gripped, frozen, held, raised). It also carries
Xaser Acheron's damnums damage numbers, fixed for Brutal Doom (no 9999 over corpses). It has no
buttons and asks nothing of your hands. It runs on stock QuestZDoom 17.3 in VR, on plain Doom 2 or with
Brutal Doom, and needs no other RSQ pk3; the icons need the mods that drive them (see "Works with").

Pk3: `pk3/RSQ_HPBars.pk3`.

## Features

**The bar.**
- A bar appears over a monster the moment it is hurt, and over a monster whose health changed without a hit
  (a healer, a buff). An unhurt monster has no bar.
- Six colour sets: Classic and Red (coldcite's two), Protanopia, Deuteranopia, Tritanopia, High Contrast.
  The colour-blind sets also hatch and gently pulse the low band and put a dark line through the mid band,
  so no colour is needed to read them. High Contrast adds a white rim and is always full bright.
- Length by toughness: tougher monsters get longer bars (a zombieman shortest, a Cyberdemon widest).
- Hit flash: the bar flashes white for one tic when your hit lands.
- Fade in: a new bar fades in over about a sixth of a second.
- Far Size: bars grow with distance (from 256 map units out to 1024), so they stay readable across a room
  and are unchanged up close.
- Bars sit on the real top of the sprite, on voxel monsters too, and follow a monster that is thrown,
  yanked or tumbling without trailing a frame behind it.
- A see-through monster gets a see-through bar (Allow Stealth).
- An invulnerable monster's bar shows as XX.

**Overheal.**
- A thin strip above the bar holds health over 100 %, one full health's worth per lap. Past one full strip,
  small diamonds at its end count the extra laps (up to 4). It drains strip first, diamonds next, bar last.

**Markers.** Small icons beside the bar, each a different shape so no colour is needed.
- Left of the bar: hooked (a hook), stunned (a star), locked (a reticle), gripped. These come from the other
  series mods (see "Works with").
- Right of the bar: frozen (a snowflake) while a hit-stop holds the monster; held (a padlock) while a
  Headlock (RSQ Melee) or human shield (RSQ Distance Grab) holds it; raised (an up arrow) for the rest of its life once an Arch-Vile has
  brought it back.
- Above the bar, with RSQ Miniboss: a gold crown over the miniboss, a chain link over each of its thralls.

**Damage Numbers** (on). Xaser Acheron's damnums, built in: every hit on a monster throws up the damage it did in
damnums' red Doom digits, tossed off the monster and fading, exactly as damnums draws them. Changed for Brutal Doom:
- No number when Brutal Doom finishes a body: its head hitboxes (9999 health, riding a monster or a dying body) and
  its boot smearers (1000) never show one, and a body that bleeds out or drops dead by itself shows nothing. That was
  the 9999 over every corpse.
- A number is never bigger than the health the monster had left: a 25 that kills an imp on 10 shows 10.
- No number for a hit on a monster that was already dead, or for Massacre / Brutal Doom's KillMe clean-up.
- **Do not load damnums alongside any more.** If it is loaded too, every hit shows two numbers (damnums' and these),
  and damnums brings back the 9999s. Remove damnums from the load order.

**Options, off until you turn them on.**
- Aimed Only: a bar only over the monster either hand's gun points at, and for half a second after the aim
  leaves it. An unhurt monster you aim at gets its bar too.
- Damage Chunk: what your hit took off stays lit white for half a second, then drains to the new edge. Hits
  while it is lit add to it.
- Ally Colour: friendly monsters (allies, Brutal Doom's marines) get a blue bar.
- Nearest 24 Only: only the 24 bars nearest you are drawn.
- Distance Limit: no bars farther than the Limit Distance slider.

**coldcite's own pk3.** If coldcite's Top HP Bars pk3 is also loaded, this one takes over: his bars are taken
off every monster, and his HUD Options entry opens this menu. Turn HP Bars Off and his bars show again on
everything that appears from then on.

## How to play

Nothing to bind, nothing to hold. Put the headset on, shoot a monster, and its bar appears above it. Look at
a monster you have not hurt: no bar. Hurt a zombieman and a Baron: the Baron's bar is clearly longer.

The settings are in Options -> Radiant Silvergun Options -> **RSQ HP Bars**. The sliders and Reset All are on
its **Tuning and Debug** page.

With **Aimed Only** on, point either hand's gun at a monster: its bar shows while you aim at it and for half
a second after you look away. Point at an unhurt monster and it gets a bar too.

Shoot a monster: the damage pops off it in red digits. Kill a Brutal Doom zombie: the last number is what it had left,
and nothing shows when its body drops.

With **Damage Chunk** on, hit a monster: a white block marks what the hit took off, holds half a second, then
drains.

## Settings

Options -> Radiant Silvergun Options -> **RSQ HP Bars**:

| Menu row | Default | What it does |
|---|---|---|
| HP Bars | On | Bars on or off. |
| Colours | Classic | Classic, Red, Protanopia, Deuteranopia, Tritanopia, High Contrast. RSQ Accessibility's Colour Blind Mode overrides this when it is set. |
| Size | Standard | Small / Standard / Large (sets the Size slider to 0.15 / 0.3 / 0.5). |
| Full Bright | Off | Bars ignore the room's light. High Contrast always does. |
| Allow Stealth | On | A see-through monster gets a see-through bar. |
| Overheal | On | The strip above the bar for health over 100 %, with its diamonds. |
| Markers | On | All the icons: hooked / stunned / locked / gripped, frozen / held / raised, crown / chain link. |
| Aimed Only | Off | A bar only over the monster either hand's gun points at, and half a second after. |
| Damage Chunk | Off | What your hit took off stays lit white for half a second, then drains. |
| Ally Colour | Off | Friendly monsters get a blue bar. |
| Nearest 24 Only | Off | Only the 24 bars nearest you are drawn. |
| Distance Limit | Off | No bars farther than Limit Distance. |
| Damage Numbers | On | damnums' damage numbers on hits. |
| Numbers For | Monsters Only | Monsters Only, or All Shootable (barrels, shootable props; never your own body). |
| Shotgun Spray | Off | One number per hit (each pellet) instead of one per monster per tic. |
| Number Font | Classic Doom | Classic Doom or Classic Doom (small): damnums' two Doom fonts. |
| Number Colour | Default | Default (the font's red) or any of damnums' 21 colours. |
| Number Motion | Toss | Toss (thrown off and falling) or Float (rising straight up). |
| Damage Type Colours | On | Fire orange, plasma cyan, explosions gold, ... (damnums' list); another mod can add its own. |

**Tuning and Debug**:

| Menu row | Default | What it does |
|---|---|---|
| Size | 0.3 | Bar size, 0.05 to 1.0. |
| Far Size | 2.0 | How much a bar grows at range, 1.0 (no growth) to 3.0. |
| Height | 0.1 | How far above the sprite's top the bar sits, as a fraction of its height, -0.5 to 0.5. |
| Limit Distance | 1536 | The Distance Limit cut-off, in map units, 256 to 4096. |
| Reset All | | Puts every RSQ HP Bars setting back to its default, Damage Numbers' too (asks first). |

## Works with

- **RSQ Accessibility**: Colour Blind Mode overrides Colours; Photosensitive Mode dims the hit flash to 40 %
  and spaces flashes at least 14 tics apart; Cue Size scales the marker icons.
- **RSQ Grapple**: the hooked icon while a monster is on the hook's line or flying from a yank; the stunned
  icon for the yank's landing hold or a crack's pain.
- **RSQ Whip**: the hooked icon on a monster the whip has wrapped or tied.
- **RSQ ShieldSaw**: the locked icon on a monster with a lock-on ring.
- **RSQ Saber**: the gripped icon on a monster held in a Force grip.
- **RSQ Melee and RSQ DistanceGrab**: the held padlock on a monster in Melee's Headlock or held as Distance
  Grab's human shield (read off the monster; nothing is asked).
- **Any hit-stop from the series** (Saber, ShieldSaw, Whip, DistanceGrab, a thrown gun from Tactical Rig):
  the frozen snowflake for the tics the monster is held (read off the monster).
- **RSQ Miniboss**: the crown and the chain links. Without it, no marks.
- **coldcite's Top HP Bars**: taken over (his bars removed, his HUD Options entry opens this menu).
- **Champions**: a bar over a champion wearing its tier icon is lifted above the icon. In Champions' dormant
  LegenDoom mode a champion that has not turned wears no icon, and its bar is not lifted.
- **LegenDoom** (3.0 or Lite 4.2): a monster picked to become legendary looks like any other until it turns:
  no bar while unhurt, then a plain bar of the same length, no overheal strip. Once it turns, its 300 %
  shows as a full bar, a full overheal strip and one diamond.
- **RSQ GunBonsaiVR**: no node changes the bars.
- **damnums**: built in (Damage Numbers). Do not load it as well: two numbers on every hit, and its 9999s on Brutal
  Doom's corpses come back.

## Load order

After Brutal Doom, the monster packs, LegenDoom, Champions and Gun Bonsai, with the other RSQ pk3s. Its place
among the RSQ pk3s does not matter: the mods that drive its icons are found at run time, loaded before or
after it.

## Known limits

- The frozen, held and raised icons are parts of a bar, so an unhurt monster shows none of them.
- The hooked, stunned, locked, gripped, crown and chain-link icons are asked for every 4th tic, so one can
  trail its cause by up to 4 tics.
- "Your hit", for the flash and the chunk, is any player's hit (in single player: yours).
- Lossvoise's flat retexture is not shipped (no permission).
- Damage Numbers: rig only, not headset-confirmed (2026-11-03). Only damnums' two Doom fonts ship (560 sprite frames;
  all 13 would be 3,640 in a load order already near the engine's 65,535). Damage changed without a hit (a script
  setting health) shows no number. Numbers are a hit's damage as the engine reports it, so a Brutal Doom headshot that
  its hitbox passes on to the monster shows on the monster.

## For other mods

Damage Numbers colour a damage type from LANGUAGE: `RSQTHP_DMG_TYPECOLOR_<type> = "RSQTHP_Dam<colour>"`. A mod
written for damnums (`DAMNUM_TYPECOLOR_<type> = "Dam<colour>"`) is read too.

The bars ask other mods by name through `ServiceIterator`; nothing links. A mod can put the left-hand icons
on a monster by defining a `Service` whose class name contains **`RSQTHP_Marker`** and answering `GetInt`
with `objectArg` = the monster, 1 or 0:

- `"hooked"`, `"stunned"`, `"locked"`, `"gripped"`: the icon of that name.

The bars also read, by name: `RSQGR_Service` (`"hooked"`, `"yanked"`, `"stunned"`), `SSQ_ScoreService`
(`"locked"`), `UBQS_SaberService` (`"gripped"`), `RSQMB_Service` (`"miniboss"`, `"thrall"`), and RSQ
Accessibility's `rsqa_colorblind`, `rsqa_photosafe` and `rsqa_cue_scale`.

## Credits

The series' version of **Top HP Bars 1.04 by coldcite** (based on SpriteShadow by Nash Muhandes). coldcite's
header: "Feel free to use this in your mods. You don't have to ask my permission!" Credit coldcite and Nash in
CREDITS.txt; check SpriteShadow's own terms before shipping.

Lossvoise's flat retexture (of Mere_Duke's version; zdoom forum thread t=56910) is not used. The series ships
coldcite's art and its own generated schemes only.

`pk3/CREDITS.txt`:

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

Damage Numbers are damnums by Xaser Acheron (with contributions by Major Cooke; thanks in its source
to Marrub and Zombie), github.com/XaserAcheron/damnums v1.0.2 (commit 953673c), folded in on
2026-11-03 under this mod's names (RSQTHP_DamNum*, rsqthp_dmg_* cvars, RSQTHP_Dam* colours, sprites
QC / QD). Its code, its Doom Classic and Doom Small digit art and digit-position sprite layout, its
colour translations and damage-type colours are his; the changes are listed at the top of
zscript/rsqthp/damnums/damnum.zs. Thank you, Xaser. damnums is released under the MIT License:

    MIT License

    Copyright (c) 2017 Xaser Acheron

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

Not included, credited for the record:
  - Lossvoise's flat high-visibility retexture of Mere_Duke's custom version (zdoom forum
    t=56910) is NOT shipped: no permission yet (credit chain coldcite -> Mere_Duke -> Lossvoise).
  - Champions and LegenDoom Lite: read by class / cvar name for compatibility (handler.zs); nothing of
    either is bundled.

Code: ZScript written for the Ultra Badass Quest series (presidentkoopa), for stock QuestZDoom 17.3
by Emawind84 and Team Beef. No engine change.
```
