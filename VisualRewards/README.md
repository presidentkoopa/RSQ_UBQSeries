# RSQ VisualRewards

HP bars over every monster, damage numbers that live in the room with you, level-up moments you can read in a
headset, and monsters that burst into health, armour and ammo when they die.

Status: 0.99. Played and confirmed working in the headset; refinement and bug fixing ongoing. The arrival beams, words
and pops (11-09) were run on the rig the same day (QuestZDoom 17.3 Linux rig on Freedoom 2; **rig only, not
headset-confirmed**): each kind hides its monster and shows it on time, the role sounds play, words, held words, clears
and pops answer; one compile error fixed (a monster's fill colour is read-only: put back with SetShade). Their look is
not yet seen. The pk3 is `pk3/RSQ_VisualRewards.pk3` (rebuilt
11-09).

**What's new**
- **11-09 evening, scene music** (rig only, not heard): the start of the arcade brain (design/ARCADE_BRAIN.md). Other
  mods report a scene by name (`RSQVR_Service` "scene.push" / "scene.pop"); its track crossfades over the level music,
  and when it ends the level music crossfades back in where it has got to. A Bossfight plays the owner's track.
  **Scene Music** (Arrivals and Words, on) turns it off for you.
- **11-09** (rig only): **arrival beams** V1-V4 for monsters other mods bring in, with their own sounds for a
  miniboss, a thrall and a chump; **words** over monsters in RS Score's font (TARGET!, GUARD!); a **pop** in a colour
  (below). Built for RSQ Miniboss's Bossfight; any mod can ask for them by name.
- **11-07** for RSQ SlowMo's DOWN v3 (rig only): a kill you make while DOWN within 3x your Bits Fly to Me reach still
  bursts into bits, but they fly to you quickly and bank (health and armour, paid when you get up; an ammo bit gives its
  ammo as it arrives); a kill farther off drops ordinary bits (Bits Fly to Me at 0: none bank). REVIVE is shown every
  time you get up, bigger and longer at the better tier; the RAGE word and the DOWN skull are gone (SlowMo draws each
  target's icon over its HP bar); a DOWN target's HP bar shows even if you never hit it.
- **11-06** (rig only): Bits Vanish As (Blink Out / Fade Out); a yellow **battery bit** for RSQ FnF's "Bones Drop Battery
  Bits" (it acts like every Kill Rewards bit and refills 15% of the flashlight battery of whoever picks one up; nothing
  here drops one by itself).

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
- Markers beside the bar: hooked, whipped, stunned, locked on and Force-gripped on the left; ally (a heart, so an
  ally doesn't rely on colour alone), raised, frozen or held, and burning (a flame while it is in fire, gone once the fire stops landing) on
  the right.
- Above the bar: a crown or chain for RSQ Miniboss's miniboss and its thralls, one gold pip per Bossfight tier beside
  its miniboss's crown (tier 0: the crown alone, up to four pips at tier 4), and a pink gem on a LegenDoom legendary once
  it has turned (left of the crown when it is both). LegenDoom is optional: without it there is simply no gem.
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
- Bigger monsters drop more, and bosses drop a fountain (an RSQ Miniboss Bossfight's miniboss: x3 more, its own setting).
- A plain-words menu with presets, and SoM's raw numbers kept underneath.

**Arrival beams, monster words and pops** (new on 11-09, for RSQ Miniboss's Bossfight; code and art only, NOT YET RUN in
an engine)
- A monster another mod brings into the fight arrives on a beam, in the colour it asks for, sized to the monster: **V1**
  the beam opens around it and rings drop down it; **V2** a floor ring flash, the beam slams down, rings ride up it, the
  monster white, then its colour, then itself; **V3** a column that hides it completely, cut at the real ceiling indoors
  (the splash hangs from it, sparks drop) or climbing out of sight under the sky (a stepped taper, flames trailing up),
  picked by the ceiling above; **V4** for a boss: six beams spiral in, merge, a skull pillar, the monster arrives. The
  monster is not drawn at all until its reveal. Each has its sound: a miniboss's beam starts on a riser and lands a hit
  on the reveal, a thrall's is one of two, a summoned chump's a short one.
- Words over a monster in RS Score's font, in the room like the damage numbers: a one-off word pops, flickers to white,
  drifts up, holds about a second and fades (GUARD! in silver on a shielded miniboss); a held word stays until it is
  cleared or the monster dies (TARGET!, big and pulsing on the miniboss once its shield is down).
- A pop: a small pixel ring and star burst at a monster, in a colour (a thrall's kill, the colour of the power lost).
- Pixel art throughout, four flat bands of the colour. Photosensitive Mode: no white silhouette, no white flicker, the
  white flashes at 40%.
- Nothing here plays by itself: another mod asks for it by name (below).
- To run on the rig first: it compiles; each kind on an imp, a cacodemon and a 1.25x miniboss (sizes, the reveal tic
  matches the answer); V3 under a low ceiling, a high one and the sky; the colours (a Black-tier colour too); a monster
  killed and one removed mid-beam (shown again, nothing left hidden); a save and load mid-beam and with a held word
  up; the words' size and reading distance in the headset, and both eyes; Photosensitive Mode; the sounds' reach.

## How To Play

1. Load the pack. HP bars, damage numbers and Kill Rewards work at once. The level-up displays need Gun Bonsai.
2. Hurt something. Its bar appears and the numbers start.
3. Keep hitting the same monster to build the combo. The chain cools off after about three seconds without a hit.
4. Bits a monster drops within 2 m fly to you and are collected, even standing still; walk over the rest. They
   vanish after 7 seconds. **Bits Fly to Me** sets the reach (0 turns it off, also with Magnet); the Magnet node in RSQ
   Gun Bonsai VR reaches further.
5. If the screen feels busy, try **Only Where I Aim** (a bar only on what your guns point at), **Nearest 24 Only**, or
   lower **Most Numbers**.

## Controls

VisualRewards reads no buttons. It reacts to what you do.

| Action | How (VR) | Notes |
|---|---|---|
| See a monster's bar | Hurt it | With Only Where I Aim on: point either hand's gun at it. The bar stays half a second after you look away. |
| Build a combo | Keep hitting the same monster | About 3 seconds without a hit ends the chain. |
| Collect bits | Stand near them, or walk into them | Bits within Bits Fly to Me (2 m) or Magnet's reach fly to you and are collected without moving. |
| Gains on your wrist | Pick something up | Health and armour land on your off-hand wrist, ammo on the wrist of the hand that uses it. |
| Left-handed play | Nothing to set | Positions follow your actual hands. |

## Menu

Options → Radiant Silvergun Options → RSQ VisualRewards: one page (HP Bars, Damage Numbers, Kill Rewards, Level-Up),
with Test and Debug and Reset All at its foot.

| Row | Default | What it does |
|---|---|---|
| *HP Bars* | | |
| HP Bars | On | Bars over hurt monsters. |
| Bar Colours | Classic | Classic, Red, Protanopia, Deuteranopia, Tritanopia, High Contrast, Cyan Lavender Orange, Random. RSQ Accessibility's colour-blind setting overrides this. |
| Bar Size | 0.30 | Bar size (0.05 to 1). |
| Full Bright | Off | Bars ignore sector light. |
| Fade With Stealth | On | A see-through monster's bar is see-through too. |
| Overheal Strip | On | The strip for health above full. |
| Status Markers | On | Hooked, whipped, stunned, locked, gripped, ally, raised, frozen, held, burning, miniboss (with Bossfight tier) and legendary icons. |
| Only Where I Aim | Off | A bar only over the monster either hand's gun points at, even at full health. |
| Damage Chunk | Off | The health your hit took off stays lit for half a second, then drains. |
| Blue Bars for Allies | Off | Friendly monsters, such as Brutal Doom's marines, get a blue bar. |
| Nearest 24 Only | Off | Only the 24 nearest bars are drawn. |
| Distance Limit | Off | No bars beyond Limit Distance. |
| *Damage Numbers* | | |
| Damage Numbers | On | Numbers on hits. |
| Numbers For | Monsters Only | Or All Shootable (never your own body). |
| Number Font | JFO Metal | JFO Metal, Ermac, Classic Doom, Classic Doom (small). |
| Number Size | 1.00 | Digit size. |
| Word Size | 1.00 | Size of the words, the combo and the level-up text. |
| Text Quality | Quest | Quest (half-resolution glyphs) or PCVR. |
| Hit Colours | By Damage Type | By Damage Type, By Hit Strength, Classic (the two Classic rows below), a fixed colour, or Random. |
| Classic Colour | Default | Colour used when Hit Colours is Classic. |
| Classic Type Colours | On | Colour by damage type, when Hit Colours is Classic. |
| Total Colours | Follow Combo | The total's colour: follows the combo ramp, a fixed colour, or Random. |
| Combo Colours | White Yellow Orange Red | Six colour ramps, or Random (a fresh ramp each chain). |
| Headshot Colour | Gold | Any palette colour, or Random. |
| Pop and Settle | On | White flash, snap out, arc away, fade. |
| Motion Without Pop | Toss | Toss or Float, when Pop and Settle is off. |
| Size by Hit | Off | Bigger hits draw a little bigger. |
| Grow with Distance | Off | Hit numbers grow with distance like the bars. |
| Running Total | On | A chain's hits roll up in one total above the bar. |
| Kill Slam | On | The total punches once on the kill. |
| Combo Counter | On | The "xN" beside the bar. |
| Combo Shake | On | The total and combo shake a little from x5. |
| Overkill Word | Off | OVERKILL when the last hit went well past zero. |
| Headshot Word | On | HEADSHOT over Brutal Doom's head hits. |
| Headshot Flash | On | A headshot's number starts white for a few tics. Never with Photosensitive Mode. |
| Headshot Cycling | On | A shimmer and bobbing letters on headshots. |
| Shotgun Spray | Off | One number per pellet instead of one per target per tic. |
| Gains on You | On | +health, +armour and +ammo fly to your wrist. |
| Freeze in Hit-Stop | On | A number on a frozen monster holds until it moves again. |
| Numbers in Slow-Mo | World Time | Slow with the world, or move at your own speed. |
| Out of Your Face | On | Numbers stay about a metre away and off both guns' aim lines. |
| Clear of Walls | On | Numbers are traced clear of walls and ceilings. |
| Most Numbers | 12 | Only this many of the nearest numbers show (6, 12, 24, 48). |
| *Kill Rewards* | | |
| Kill Rewards | On | Monsters burst into bits when they die. |
| Bits per Kill | Standard (1 per 10) | Few (1 per 20 health), Standard (1 per 10), Many (1 per 5), or Custom (Health per Bit on Test and Debug). |
| Boss Fountain | x3 | Bits multiplier for bosses (x1, x3, x5). |
| What Drops | Custom (Test and Debug) | Even Mix, Mostly Health, Mostly Armour, Mostly Ammo, or Custom (the mix on Test and Debug). |
| Bits Vanish After | 7 s | 7 s, 15 s, 30 s, 1 min or Never. |
| Bits Vanish As | Blink Out | Blink Out: fullbright flashes, faster and faster, then gone (its last 2 s). Fade Out: a smooth fade over its last second. Photosensitive Mode always fades. |
| Ammo Bits Give | Any Gun I Carry | Or The Gun in Hand. |
| Bits Fly to Me (m) | 2 | Metres from which bits fly to you (0 off). |
| *Level-Up* | | |
| Player Level-Up | On | The LEVEL UP band. |
| Level-Up Slow-Mo | Off | A short slow-motion pulse while the band is readable. Needs RSQ SlowMo. |
| Band Colour | Gold | Band colour, or Random. |
| Text Colour | Gold | "LEVEL UP" colour, or Random. |
| Weapon Level-Up | On | The tag that rises off the gun. |
| Weapon Tag Colour | Gold | The tag's border colour, or Random. |
| *Arrivals and Words* | | |
| Arrival Beams | On | Monsters another mod brings in arrive on a beam (server setting). Off: they simply appear. |
| Monster Words | On | Words another mod puts over a monster (GUARD!, TARGET!). Follows Word Size and Far Size. |
| Pops | On | The small ring and star burst another mod asks for at a monster. |
| Scene Music | On | A scene's own track (a Bossfight's) crossfades over the level music; off, you keep the level music. |
| Scene Music Volume | 1.00 | How loud the scene track plays. |
| Scene Crossfade (s) | 2.0 | How long the scene track takes to come in and to go. |
| Reset All | | Every setting on both pages back to its default. |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| *HP Bars* | | |
| Far Size | 2.00 | How much bars grow at range (1 = off). |
| Height | 0.10 | Bar height above the sprite, as a share of its height. |
| Limit Distance | 1536 | The distance used by Distance Limit, in map units. |
| *Kill Rewards* | | |
| Drop Mode | By Health | By Health, or Range (a random count between the two Range rows). |
| Health per Bit | 10 | Health per bit when Bits per Kill is Custom. |
| Drop Chance | 50 | Chance each bit drops. A boss always drops every bit. |
| Mix: Health / Armour / Ammo | 15 / 20 / 65 | Weights for the custom mix. |
| Ammo Type 1 Counts | On | A gun's main ammo can drop. |
| Ammo Type 2 Counts | Off | A gun's second ammo type can drop too (clip mods). |
| Range: Fewest / Most | 1 / 3 | The Range mode's limits. |
| Range: Random | On | Range mode picks a random count. |
| Debug Log | Off | One console line per kill. |

## Works with

- **Runs alone.** Bars, numbers and Kill Rewards need nothing else.
- **Gun Bonsai**: drives both level-up displays. With **RSQ Gun Bonsai VR**, the weapon tag knows which hand's gun
  levelled, and its Kill Rewards tree (Gastropub, Rich Bits, Magnet, Lucky Kill) adds more bits, richer bits, a
  magnet and bonus bursts on critical, Finisher and big-Score kills.
- **Brutal Doom / BD22**: HEADSHOT on its head hits. Its invisible helper monsters never get a bar, a number or bits,
  and neither do the dying bodies a monster leaves (crawling, burning, slumped, last stand): one monster pays once.
- **RSQ SlowMo's DOWN** (new on 11-06, v3 on 11-07; rig only, not headset-confirmed): each hit that adds time to the
  DOWN clock pops the time it bought (e.g. "+0.4s") at the monster in DOWN's crimson (Damage Numbers row); REVENGE
  (magenta, a target you kill) and REVIVE (cyan, every time you get up, bigger and longer at the better tier) fly past
  on the level-up band in the numbers' JFO font; a DOWN target's HP bar shows even if you never hit it, and SlowMo
  draws the target's icon over it. Kills within 3x your Bits Fly to Me reach bank their bits for the revive (above).
  The RAGE word and the red skull are gone.
- **RSQ Grapple, RSQ ShieldSaw, RSQ QuestSaber, RSQ Whip, RSQ Miniboss**: their hooked, stunned, locked, gripped,
  whipped, miniboss (with its Bossfight's tier) and thrall markers on the bars. An older RSQ Whip shows the hook, as it
  used to.
- **LegenDoom (3.0 or Lite)**: the gem on a legendary once it turns, never on a monster it has only picked.
- **Burning**: any fire damage lights the flame (BD22's flamethrower and burning ground, RSQ Grenade's Incendiary,
  RSQ Gun Bonsai VR's burn). Brutal Doom has no afterburn on a living monster, so the flame shows while it is in fire:
  it goes out once that fire's own interval passes with no new hit (flamethrower stream 1 tic, burning ground 26,
  Incendiary 7, anything else the gap between its hits, up to 26), checked every 4th tic. RSQ FnF's flare sets
  nothing on fire, so it never shows the flame.
- **RSQ SlowMo**: the optional level-up pulse, and numbers that slow with the world.
- **RSQ Gun Cards**: +ammo gains land on the gun's card.
- **RSQ Grenade**: with its Scavenger node at level 3, one ammo bit in four is a grenade.
- **RSQ Accessibility**: its colour-blind palette overrides the bar colours and the default combo ramp. Photosensitive
  Mode dims flashes and limits how often they come.
- **Champions**: the bar sits just above a champion's tier icon.
- **coldcite's Top HP Bars**: if it is loaded too, this pack takes over so you never see two bars, and his menu entry
  opens this one.
- **RSQ Miniboss** (11-09, the Bossfight rework; asked by name, nothing links): its arrival beams, its words (GUARD!,
  TARGET!) and its thrall-kill pops, through `RSQVR_Service`:

  | Request | Arguments | Answer |
  |---|---|---|
  | `GetInt("beam", kind, rgb, size, monster, role)` | kind "v1" "v2" "v3" "v4"; rgb 0xRRGGBB; size (1.0 = the monster's own height; 0 = 1.0); the monster, already spawned at its spot; role (nameArg, optional) 'miniboss', 'thrall' or 'chump' for its sound (none: V3 / V4 a miniboss, V1 / V2 a thrall) | tics until the monster is shown (V1 7, V2 12, V3 19, V4 31), or 0 when it did not play (Arrival Beams off, no or dead monster, unknown kind, a beam already on it). It hides the monster but does not freeze it. Game tics: it does not slow with SlowMo's world. |
  | `GetInt("word", text, rgb, seconds, actor)` | seconds 0 = 1 s | 1 (0: no actor) |
  | `GetInt("word.hold", text, rgb, size, actor)` | size 1 normal, 2 large and pulsing, 0.6 small; again with the same text: new colour / size | 1 (0: no actor) |
  | `GetInt("word.clear", text, 0, 0, actor)` | | 1 |
  | `GetInt("pop", "", rgb, size, actor)` | | 1 (0: no actor) |

  The answers never depend on a player's own settings (netplay); Monster Words and Pops off only stop the drawing.
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
- **Arrival beams**: our own pixel art (the beam, rings, sparks, licks, flames, the pop), End of Starchild's death pillar
  as a motion reference only. **V3's column and bursts and V4's skull pillar are frames cut from the Z-Fighter effects
  sheet, posterized: a rip that asks for credit. Credit it or redraw them before release.** The words use RS Score's
  font (Blue Shadow, via Dakka). The arrival sounds were supplied by the owner (presidentkoopa), 2026-11-09; source not
  stated. The art is exported by `tools/gen_beams.py` from the approved mockups in `tools/beam_spec/` (needs Pillow,
  numpy, scipy); `tools/beam_check.py` checks it all without an engine.
- Full licence texts are in `pk3/CREDITS.txt`.
- Code: presidentkoopa, for stock QuestZDoom 17.3 by Emawind84 and Team Beef. No engine changes.
