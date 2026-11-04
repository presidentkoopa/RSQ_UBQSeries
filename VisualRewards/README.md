# RSQ VisualRewards

HP bars over every monster, damage numbers that live in the room with you, level-up moments you can read in a
headset, and monsters that burst into health, armour and ammo when they die.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

Flat-screen damage numbers and HUD banners smear across your lenses in VR. Everything here is placed in the world
instead: at the monster, at your wrist, or standing in front of you like a sign. All on stock QuestZDoom 17.3, in
ZScript alone. No engine changes.

## Standout feature: every hit answers you, in the room

Shoot an imp. A small number pops on the side of the imp facing you, flashes white, snaps out and arcs away. Hit it
again and the next number steps out the other side, so they never stack. From the second hit, a running total rolls
up like a counter above its HP bar, with an "x2", "x3" combo beside it that heats from white to yellow to orange to
red. Kill it and the total punches once, holds and fades. Overdo it and OVERKILL stamps above. Land a Brutal Doom
head hit and HEADSHOT flashes in gold over a bigger number.

None of it gets in your way. Each number is traced clear of walls and the ceiling before it shows, kept at least
about a metre from your eyes, and pushed off the aim line of both your guns.

## Features

**HP bars** (coldcite's Top HP Bars, rebuilt)
- A bar appears over a monster the moment it is hurt, and follows it exactly, even when it is yanked, thrown or
  teleported.
- Tougher monsters get longer bars: a zombieman's is short, a Cyberdemon's nearly twice an imp's.
- Bars grow with distance so they stay readable across a room, and are unchanged up close.
- Overheal: health above full shows as a thin strip above the bar, with pips for each extra lap.
- A white flash the moment your hit lands. An up arrow on a monster that was raised from the dead.
- Markers beside the bar: hooked, stunned, locked on, Force-gripped, frozen, held, and a crown or chain for RSQ
  Miniboss's miniboss and its thralls.
- Eight colour sets, including three colour-blind sets and High Contrast, which add patterns as well as colour.
- LegenDoom's chosen monsters do not give themselves away before they turn.

**Damage numbers** (Xaser Acheron's damnums, redrawn for VR)
- Coloured by damage type: fire orange, plasma cyan, explosions gold, and so on, with a slow colour shimmer.
- Running total, combo counter, kill slam, OVERKILL and HEADSHOT words, each on its own switch.
- Never on Brutal Doom's invisible helpers or on corpses, and never more than the health the monster really had left.
- Gains on you: +health and +armour rise from the pickup and fly to your off-hand wrist; +ammo flies to the wrist of
  the hand whose gun uses it.
- Numbers hold still while a monster is in hit-stop, and slow down with the world in slow motion.
- Four number fonts and a Quest or PCVR quality setting.

**Level-up displays** (for Gun Bonsai)
- Player level-up: a band with LEVEL UP sweeping across it, then your new level and "+1 UPGRADE". It stands about
  2 m in front of you, follows your gaze lazily and faces you, so both eyes see it at one depth.
- Weapon level-up: a small tag rises off the gun. Its name types in letter by letter, the level stamps in, and NEW
  UPGRADE flickers green.

**Kill Rewards** (SoM's Universal(ish?) Kill Rewards)
- Monsters burst into bits when they die, from the first kill: health (25), armour (+10, up to 250) and ammo (5
  rounds for a gun you carry).
- Bigger monsters drop more, and bosses drop a fountain.
- A plain-words menu with presets, and SoM's raw numbers kept underneath.

## How To Play

1. Load the pack. HP bars, damage numbers and Kill Rewards work at once. The level-up displays need Gun Bonsai.
2. Hurt something. Its bar appears and the numbers start.
3. Keep hitting the same monster to build the combo. The chain cools off after about three seconds without a hit.
4. Walk over the bits a monster drops to collect them. They vanish after 7 seconds. Bits only come to you on their
   own if you set **Bits Fly to Me** above 0, or learn the Magnet node in RSQ Gun Bonsai VR.
5. If the screen feels busy, try **Aimed Only** (a bar only on what your guns point at), **Nearest 24 Only**, or
   lower **Most Numbers**.

## Controls

VisualRewards reads no buttons. It reacts to what you do.

| Action | How (VR) | Notes |
|---|---|---|
| See a monster's bar | Hurt it | With Aimed Only on: point either hand's gun at it. The bar stays half a second after you look away. |
| Build a combo | Keep hitting the same monster | About 3 seconds without a hit ends the chain. |
| Collect bits | Walk into them | With Bits Fly to Me or Magnet, bits in range fly to you and are collected without moving. |
| Gains on your wrist | Pick something up | Health and armour land on your off-hand wrist, ammo on the wrist of the hand that uses it. |
| Left-handed play | Nothing to set | Positions follow your actual hands. |

## Menu

Options → Radiant Silvergun Options → RSQ VisualRewards. One Reset All at the bottom puts every setting on every page
back to its default.

**HP Bars**

| Row | Default | What it does |
|---|---|---|
| HP Bars | On | Bars over hurt monsters. |
| Colours | Classic | Classic, Red, Protanopia, Deuteranopia, Tritanopia, High Contrast, Cyan Lavender Orange, Random. RSQ Accessibility's colour-blind setting overrides this. |
| Size | Standard | Small, Standard or Large. |
| Full Bright | Off | Bars ignore sector light. |
| Allow Stealth | On | A see-through monster's bar is see-through too. |
| Overheal | On | The strip for health above full. |
| Markers | On | Hooked, stunned, locked, gripped, frozen, held, miniboss and raised icons. |
| Aimed Only | Off | A bar only over the monster either hand's gun points at, even at full health. |
| Damage Chunk | Off | The health your hit took off stays lit for half a second, then drains. |
| Ally Colour | Off | Friendly monsters, such as Brutal Doom's marines, get a blue bar. |
| Nearest 24 Only | Off | Only the 24 nearest bars are drawn. |
| Distance Limit | Off | No bars beyond Limit Distance. |

**Damage Numbers**

| Row | Default | What it does |
|---|---|---|
| Damage Numbers | On | Numbers on hits. |
| Numbers For | Monsters Only | Or All Shootable (never your own body). |
| Shotgun Spray | Off | One number per pellet instead of one per target per tic. |
| Number Font | JFO Metal | JFO Metal, Ermac, Classic Doom, Classic Doom (small). |
| Number Colour | Default | Colour used when Hit Colours is set to damnums'. |
| Number Motion | Toss | Toss or Float, when Pop and Settle is off. |
| Damage Type Colours | On | Colour by damage type, when Hit Colours is set to damnums'. |
| Text Quality | Quest | Quest (half-resolution glyphs) or PCVR. |
| Hit Colours | By Damage Type | By Damage Type, By Hit Strength, damnums', a fixed colour, or Random. |
| Pop and Settle | On | White flash, snap out, arc away, fade. |
| Size by Hit | Off | Bigger hits draw a little bigger. |
| Grow with Distance | Off | Hit numbers grow with distance like the bars. |
| Running Total | On | A chain's hits roll up in one total above the bar. |
| Kill Slam | On | The total punches once on the kill. |
| Overkill Word | On | OVERKILL when the last hit went well past zero. |
| Headshot Word | On | HEADSHOT over Brutal Doom's head hits. |
| Out of Your Face | On | Numbers stay about a metre away and off both guns' aim lines. |
| Most Numbers | 12 | Only this many of the nearest numbers show (6, 12, 24, 48). |
| Gains on You | On | +health, +armour and +ammo fly to your wrist. |
| Freeze in Hit-Stop | On | A number on a frozen monster holds until it moves again. |
| Numbers in Slow-Mo | World Time | Slow with the world, or move at your own speed. |
| Combo Counter | On | The "xN" beside the bar. |
| Number Size | 1.00 | Digit size. |
| Word Size | 1.00 | Size of the words, the combo and the level-up text. |
| Headshot Flash | On | A headshot's number starts white for a few tics. Never with Photosensitive Mode. |
| Headshot Cycling | On | A shimmer and bobbing letters on headshots. |
| Combo Shake | On | The total and combo shake a little from x5. |
| Clear of Walls | On | Numbers are traced clear of walls and ceilings. |
| Total Colours | Follow Combo | The total's colour: follows the combo ramp, a fixed colour, or Random. |
| Combo Colours | White Yellow Orange Red | Six colour ramps, or Random (a fresh ramp each chain). |
| Headshot Colour | Gold | Any palette colour, or Random. |

**Level-Up Displays**

| Row | Default | What it does |
|---|---|---|
| Player Level-Up | On | The LEVEL UP band. |
| Level-Up Slow-Mo | Off | A short slow-motion pulse while the band is readable. Needs RSQ SlowMo. |
| Level-Up Band Colour | Gold | Band colour, or Random. |
| Level-Up Text Colour | Gold | "LEVEL UP" colour, or Random. |
| Weapon Level-Up | On | The tag that rises off the gun. |
| Weapon Tag Border | Gold | The tag's border colour, or Random. |

**Kill Rewards**

| Row | Default | What it does |
|---|---|---|
| Kill Rewards | On | Monsters burst into bits when they die. |
| Bits per Kill | Standard (1 per 10) | Few (1 per 20 health), Standard (1 per 10), Many (1 per 5), or Custom. |
| Boss Fountain | x3 | Bits multiplier for bosses (x1, x3, x5). |
| What Drops | Custom (below) | Even Mix, Mostly Health, Mostly Armour, Mostly Ammo, or the custom mix. |
| Bits Vanish After | 7 s | 7 s, 15 s, 30 s, 1 min or Never. |
| Ammo Bits Give | Any Gun I Carry | Or The Gun in Hand. |
| Bits Fly to Me | 0 (off) | Metres from which bits fly to you. |
| Drop Mode | By Health | By Health, or Range (a random count between the two Range rows). |
| Custom: Health per Bit | 10 | Health per bit when Bits per Kill is Custom. |
| Drop Chance % | 50 | Chance each bit drops. A boss always drops every bit. |
| Custom Mix: Health / Armour / Ammo | 15 / 20 / 65 | Weights for the custom mix. |
| Ammo Type 1 Counts | On | A gun's main ammo can drop. |
| Ammo Type 2 Counts (clips) | Off | A gun's second ammo type can drop too. |
| Range: Fewest Bits / Most Bits | 1 / 3 | The Range mode's limits. |
| Range: Random Between | On | Range mode picks a random count. |
| Debug Log | Off | One console line per kill. |

**Tuning and Debug**

| Row | Default | What it does |
|---|---|---|
| Size | 0.30 | Bar size. |
| Far Size | 2.00 | How much bars grow at range (1 = off). |
| Height | 0.10 | Bar height above the sprite, as a share of its height. |
| Limit Distance | 1536 | The distance used by Distance Limit, in map units. |

## Works with

- **Runs alone.** Bars, numbers and Kill Rewards need nothing else.
- **Gun Bonsai**: drives both level-up displays. With **RSQ Gun Bonsai VR**, the weapon tag knows which hand's gun
  levelled, and its Kill Rewards tree (Gastropub, Rich Bits, Magnet, Lucky Kill) adds more bits, richer bits, a
  magnet and bonus bursts on critical, Finisher and big-Score kills.
- **Brutal Doom / BD22**: HEADSHOT on its head hits. Its invisible helper monsters never get a bar, a number or bits.
- **RSQ Grapple, RSQ ShieldSaw, RSQ QuestSaber, RSQ Miniboss**: their hooked, stunned, locked, gripped, miniboss and
  thrall markers on the bars.
- **RSQ SlowMo**: the optional level-up pulse, and numbers that slow with the world.
- **RSQ Gun Cards**: +ammo gains land on the gun's card.
- **RSQ Grenade**: with its Scavenger node at level 3, one ammo bit in four is a grenade.
- **RSQ Accessibility**: its colour-blind palette overrides the bar colours and the default combo ramp. Photosensitive
  Mode dims flashes and limits how often they come.
- **Champions**: the bar sits just above a champion's tier icon.
- **coldcite's Top HP Bars**: if it is loaded too, this pack takes over so you never see two bars, and his menu entry
  opens this one.
- Load order: anywhere among the RSQ packs.

## Credits and licence

- **HP bars**: Top HP Bars 1.04 by coldcite (2017). His layout, bar art and idea; Classic and Red are his images, the
  other sets his art recoloured. His words: "Feel free to use this in your mods. You don't have to ask my
  permission!" Top HP Bars was based on SpriteShadow by Nash Muhandes (MIT, © 2021); no SpriteShadow code is copied.
- **Damage numbers**: damnums v1.0.2 by Xaser Acheron, with contributions by Major Cooke and thanks to Marrub and
  Zombie. MIT licence, © 2017 Xaser Acheron. Its idea, digit art, colour translations, damage-type colours and motion
  are his.
- **Fonts**: JFO, the JDUI font by Zedas, in Blackmore1014's "JDUI Brutal Doom Ultimate Edition". It ships with credit
  to Zedas and Blackmore1014 (owner's decision). Ermac's digits: iamErmac's Force Unleashed holo HUD digits.
- **Kill Rewards**: SoM's Universal(ish?) Kill Rewards v1.0, its bits, orb sprites and drop rules. SoM: "Feel free to
  use anything in this mod for yourself ... I don't need credit, unless you wanted to." We do.
- Lossvoise's high-visibility retexture is not included. Champions and LegenDoom Lite are read by name; nothing of
  either is bundled.
- Full licence texts are in `pk3/CREDITS.txt`.
- Code: presidentkoopa, for stock QuestZDoom 17.3 by Emawind84 and Team Beef. No engine changes.
