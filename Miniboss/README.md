# RSQ Miniboss

Fill the Bossfight meter with stylish kills, check your watch, and call the fight in: a miniboss and its thralls
teleport in where you can see them, and you choose how to take them apart.

Status: 0.99. The original set piece was played and confirmed working in the headset. Everything below marked 11-09 is
**code only: not compiled, not rig-tested, not headset-confirmed**. The pk3 is `pk3/RSQ_Miniboss.pk3` (rebuilt 11-09).

**What's new**
- **11-09, the fight reworked** (the owner's design, design/MINIBOSS_REWORK.md; mockups design/mockups/miniboss/):
  - a staggered arrival on RSQ VisualRewards' arrival beams, inside RSQ SlowMo's landing slow, with SlowMo's edge arrows
    pointing to any landing out of view;
  - every monster a Boosted Legendary Champion; the miniboss 1.25x (its hitbox too), faster and keener to shoot;
  - a HUD bar stack in the meter's place: thrall bar, window bar, its bar, its life bars;
  - the thralls make it immune; a thrall killed opens a short window to break one segment; a missed window tiers
    everything up; no thralls rise; RSQ Glow In The Dark follows the fight;
  - **Miniboss From / Thralls From** (on RSQ Monsters' page, under Bossfight): pick the miniboss and its thralls from
    ColorfulHell, MeatGrinder or a mix instead of the map's own monsters (below);
  - **head shots** on the 1.25x miniboss are judged on its grown body by RSQ Score's head check.
- **11-07** (rig only): a Bossfight win drops RSQ Score's life crate where the miniboss died; Graves Rise has no cap.
- **11-06** (rig only): Tier From; Graves Rise (Legion of Bones); the original tether trail at about half the old cost;
  Ignore Spawn Restrictions.
- **11-05** (code only): a killed miniboss refills RSQ Tactical Rig's cigarettes.

RSQ is a series of VR mods for stock QuestZDoom 17.3, built in ZScript alone with no engine changes. RSQ Miniboss is a
rebuild of Tartlman's Minibosses! with new rules, and it reads monsters by their health, never their class name, so it
works the same on Doom's monsters, Brutal Doom's and most monster packs.

## Standout feature: the Bossfight

No miniboss is picked when a level loads any more. You earn it.

- **The meter** sits under RSQ Score's bar, smaller than Score and centred under its bar (never wider than it, at any Text
  Size or screen shape), above RSQ SlowMo's two bars and Score's combo rows. It fills most from
  RSQ Score's style points (style bonuses and combos), then kill chains (kills within 3 seconds), Gun Bonsai XP, and
  slowly from time spent pushing into the map. Without RSQ Score each kill counts for more. It is kept from map to map.
- **How it looks**: coldcite's Top HP Bars block bar lying down, the same rim and well as RSQ SlowMo's countdown bar
  (SlowMo's bars span the meter's row while both show) and the side gauges' style, with a crowned skull at its left. Red while it fills (the skull lights up from the jaw as it does),
  with a band of light running through it.
- **Full**, it tells you without words: a sting, the bar turns gold and comes alive (the band runs gold, the bar and the
  skull swell with a slow beat, a glint crosses it every few seconds), and (with RSQ Glow In The Dark) the map's glow
  beating red like a heart. With RSQ Accessibility's Photosensitive Mode: no glint, a slower, dimmer beat. No words on
  the bar. If a due Bossfight has to wait, one small line under it says why: No Miniboss: Low Health, No Room, Too Busy
  (a heavy fight), Too Early (the first minute), Near Exit, Cooldown, Map Limit, or No Monsters.
  While a Bossfight runs (from its arrival until the miniboss is dead) the meter is hidden.
- **Call it in**: hold the watch check (the wrist turned to your eyes) and press Use. Or wait: it comes by itself about
  a minute after the meter filled.
- **It arrives in view, at a distance**: somewhere you can see, 12 to 32 m away, with room for the whole crew. The world
  and you slow (RSQ SlowMo, 4 s); the thralls land one at a time about 0.3 s apart, each on an RSQ VisualRewards arrival
  beam in its own ladder colour, then the miniboss makes its entrance (beam sets, one picked at random per Bossfight: V1
  thralls + V3 miniboss, or V2 thralls + V4 miniboss). RSQ SlowMo's edge arrows point to any landing out of view. Each one
  arrives a Boosted Legendary Champion (as RSQ SlowMo's DOWN spawns them); the miniboss stands 1.25x (its hitbox too), moves
  x1.25 and shoots far more often. The miniboss's landing sends an RSQ Glow In The Dark wave in its colour. Without
  VisualRewards: the original Minibosses! teleport fog.
- **Who comes scales with you**: the monster types already in this map, stronger ones as your Gun Bonsai level, this
  map's score and your Bossfights won climb.
- **Where they come from** (RSQ Monsters > Bossfight, 11-09): **Miniboss From** Same as Monster Set (the map's own
  monsters, as above), ColorfulHell, MeatGrinder or Mixed; **Thralls From** Same as Miniboss, ColorfulHell, MeatGrinder,
  Mixed or Map's Own Monsters. A pick keeps its family (an imp stays an imp) and is taken from the chosen set. A thrall
  keeps the colour it had on the map (Common when it had none); a miniboss from a set stands at least one colour above
  its strongest thrall. Same as Miniboss with a Brutal Doom or Vanilla miniboss gives ColorfulHell thralls (Brutal Doom's
  monsters have no colour ladder). A family the MeatGrinder set lacks comes from ColorfulHell.
- **It waits** (and says why on the bar) during a map's first minute, near the exit, while your health is low, while
  more than 3 awake monsters are after you, when there is no room in view, during the cooldown, and after 2 a map.
- **Ignore Spawn Restrictions** (off; owner 11-06; rig only, not headset-confirmed): a due Bossfight comes anyway during the
  first minute, near the exit, with low health, in a heavy fight and with no room in view (it then takes a spot anywhere it
  fits, and as a last resort sets the monsters down untested). The cooldown, the 2-a-map cap and "no monsters in this map"
  still apply: they limit how often one comes, not where or when.
- **Kill its miniboss** for a guaranteed drop (a gun from this map's types that you don't have yet; under Brutal Doom,
  whose map guns are not guns until touched, one from your weapon slots no higher than one above your best; else a power-up),
  three times the boss bits from RSQ VisualRewards' Kill Rewards, Champions' own loot for the powers it inherited,
  RSQ Score's Miniboss and Bossfight rows, and RSQ Score's life crate where it died (11-07; touch it: +1 life).

Then the set piece itself:

- **The HUD stack** (in the meter's place, under RSQ Score's bar): the THRALL BAR (one segment per thrall it came with,
  each a share of its health), the WINDOW BAR when one is open, ITS BAR in its colour with the crowned skull, and thin
  LIFE BARS under it (they replace the old orbs).
- **Shield up**: while a thrall lives, shots on the miniboss do nothing. Grey Xs bounce off where they hit and "GUARD!"
  pops over it in silver; "TARGET!" hangs over each thrall; the thrall bar is grey under a shield; the room glows a cold
  grey.
- **Kill a thrall**: the world slows, the power that thrall gave the miniboss pops out of it in its colour and is gone, and
  the shield drops for 1 second per thrall it came with (3 thralls: 3 s), or until you break one segment, whichever comes
  first. A big pulsing "TARGET!" over the miniboss; the window bar (one step per thrall, draining tallest first); the room
  glows gold. The step you break it in sets RSQ Score's pay (the first, the most).
- **Miss the window** (the segment survives): the miniboss and its thralls tier up with RSQ Monsters' tier flash by how
  much was left (a sliver +1, about half +2, untouched +3), and by default every other monster on the map with them. Those
  tiers are put back when you re-enter a hub level. The shield is back up.
- **One-on-one**: every segment broken, no thrall bar; "TARGET!" over it; its bar drains as you hit it.
- **A life lost**: its bar empties, the next life bar rises into it, it is invulnerable behind its flames for 5 s and tiers
  up one with the flash (Tier Up Each Life); the room glows red, then its new colour. **No thralls rise.**
- **Its death**: a map-wide RSQ Glow In The Dark wave in its colour, then the map's glow colours re-roll; the loot and
  Score's Miniboss and Bossfight rows as before.
- Hit the shielded miniboss while its thralls still stand and you arm the **greed rule**. If a window runs out (or one
  window's length passes) with the miniboss and a thrall still alive, every monster on the map is enraged: twice as fast
  and far quicker to shoot, until the miniboss dies. Kill it while its thralls still stand, before the rage comes, and RSQ
  Score pays a Greedy bonus.

## Features

**Bossfight**
- Meter: Score style x 0.25 (at most 120 a kill), 4 a kill (10 + health / 50 while Score's style is not filling it, at
  most 30), +6 per kill in a chain (at most +30), Gun Bonsai XP x 0.2 (needs RSQ Gun Bonsai VR), 2 every 2 seconds you
  moved. x Meter Speed. A Bossfight's own monsters never fill it, and it is frozen while one runs.
- Bossfight Meter Fills From picks Score style, Gun Bonsai XP or both (Both by default); kills, chains and time count in
  every setting. If the chosen mod is missing, the other one fills it when loaded; with neither, kills and time do.
- The call-in reads the watch check from RSQ Accessibility (which now holds RSQ Gestures), or RSQ Gun Cards' copy of it, or this mod's own copy (so it works
  with neither loaded). Use is only read while a watch check is held.
- The spot: the map's own monster start spots in front of you and points along your view, each tested with a probe the
  size of the monster that would stand there (floor, ceiling, walls, other monsters), the miniboss's spot in your line
  of sight, at least half its thralls fitting round it.
- Tier 0 to 4: Gun Bonsai player level / 2 + this map's score / 4000 + Bossfights won / 2. Tier 0 sends a middling type
  from the map, tier 4 the strongest; thralls are weaker types; tier 3 and up brings one more thrall.
- With LegenDoom 3.0, Champions and the LDL x BD22 VR patch loaded: legendary weapons drop only from a Bossfight's monsters
  (the patch asks this mod by name). LegenDoom without Champions is unchanged.
- Classic Pick at Level Load (Test and Debug, off) brings back the old way: a miniboss chosen from the level's own
  monsters at the start.

**The fight**
- **Segments**: one per thrall it came with, each its health at the landing / the thralls; damage goes into the open
  segment first, its own bar only once every segment is broken.
- **Shield**: immune while a thrall lives, a segment is left and no window is open.
- **Window**: 1 s per thrall it came with, opened by a thrall's death on the first unbroken segment, closed early by
  breaking it. A kill while one is open waits its turn. Score pays 100 x the steps left ("Thrall Slow Kill" row).
- **Missed window**: tier-up +1 / +2 / +3 by the segment left (RSQ Monsters' RS_Retier, asked by name); map-wide by option.
- **Powers lost**: each thrall's Champions power goes with it (a token taken back, a life it added, Black's damage, the
  toughness).
- **Lives**: 3 by default. Each lost life gives 5 seconds of invulnerability; tier up one each (option). No revive.
- **Greed Enrages Monsters**: struck while shielded, then the window ends with a thrall still up: map-wide rage until the
  miniboss dies. Everything enraged is put back exactly as it was afterwards.
- **Effects**: the original Minibosses!' art, in each set piece's own colour: plasma beads along each link, BFG and plasma
  bursts when a link breaks, a BFG burst for a lost life and its death, flames while it is invulnerable; red sparks over
  enraged monsters. Since the rework no life orbs and no BFG ball over each thrall (the HUD's life bars and "TARGET!"
  replace them); a thrall's death pops in its power's colour (RSQ VisualRewards' pop). The IWAD's sprites drawn by a small pooled
  set of VisualThinkers, only within 4000 units of you. Each link is the original's own trail: 30 plasma beads from
  thrall to miniboss, moved every tic, at every density (Effects Density sets the flames and the cap). Since 1.0 a
  link's 30 beads are placed in one pass (a bead that did not move is left alone): the same picture for less than half
  the script time (rig: 0.24 -> 0.12 ms a tic with 8 thralls all moving; rig only, not headset-confirmed).
- Sounds are Doom's own: a BFG burst for a lost life, a fireball pop for a thrall, the Icon of Sin's roar for the rage.

**Counts as a boss** (each on its own switch; the engine's boss flag is never set)
- **Boss Kill Rewards**: RSQ VisualRewards' Kill Rewards treat it as a boss kill.
- **Can't Be Yanked**: RSQ Grapple and RSQ Whip pull you to it instead of yanking it.
- **Can't Be Headlocked**: RSQ Melee's headlock refuses it.
- **Legendary Boss Health**: made legendary here, it gets the higher of LegenDoom's (Lite 4.2 or 3.0) boss and normal legendary health (none when LegenDoom 3.0's Legendary Monsters is Disabled).
- **Map-wide Roar** (optional, off by default): its sight and death sounds carry across the map.
- **Can't Be Morphed** (optional, off by default).

**With other monster mods**
- **LegenDoom Lite or LegenDoom 3.0**: every thrall is made legendary, and a legendary thrall makes the miniboss legendary too. With LegenDoom 3.0 and the LDL x BD22 VR patch, the legendary miniboss drops a BD22 VR gun; with Champions too, only a Bossfight's monsters drop legendary guns.
- **Champions**: champion thralls are picked first, and the miniboss inherits their powers, up to 4. Yellow, White, Dark
  Green, Cyan and Titan powers pass on as they are; Dark Red and Undying add a life each (up to +2); Black adds 50% damage;
  any other colour or mutation makes it 50% tougher (up to x2).

## How To Play

1. Add the pk3 to your load order. Fight as usual: stylish kills and quick chains fill the Bossfight meter under the score.
2. When the bar turns gold and the skull lights up, find a spot you like, look out over open ground, check your watch and press Use.
3. Watch them land, one by one, then the miniboss. The beaded lines run from each thrall into it; "TARGET!" marks the thralls.
4. Kill a thrall: the shield drops for a few seconds. Pour everything into the miniboss and break the open segment before
   the window bar drains, or everything tiers up.
5. Every segment broken: one-on-one. Each emptied bar costs it a life (and it climbs a colour); the flames mean it cannot
   be hurt for a moment.
6. Kill it and grab the drop.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Call a Bossfight in | Watch check + Use, with the meter full | Off with "Call It In": it then only comes by itself. |
| Find the miniboss | Look for the lines and the big "TARGET!" | Flames: invulnerable. Its life bars are on the HUD. |
| Drop its shield | Kill a thrall | A window of 1 s per thrall; RSQ SlowMo slows the world for it. |
| Break a segment | Hit the miniboss in the window | The sooner, the more RSQ Score pays. Missed: everything tiers up. |
| Arm the greed rule | Hit the shielded miniboss while a thrall lives | Clear every thrall in time to disarm it. |

## Menu

**Options → Radiant Silvergun Options → RSQ Miniboss**

Where a Bossfight's monsters come from (Miniboss From, Thralls From) is on RSQ Monsters' page, under Bossfight.

| Row | Default | What it does |
|---|---|---|
| Bossfights | On | The meter fills and called-in fights come. |
| Meter Speed | 1.00 | How fast the meter fills (0.25 to 4). |
| Bossfight Meter Fills From | Both | Score (its style points), Gun Bonsai (Gun Bonsai VR's XP) or Both. Kills, chains and time always fill it. A choice whose mod is not loaded uses the other one if that is loaded, else kills and time alone. |
| Bossfight Kill Drops a Life Crate | On | A Bossfight's miniboss drops RSQ Score's gold life crate where it died: 10 s to touch it (or pull it with RSQ Distance Grab) for one extra life (needs RSQ Score). |
| Call It In: Watch Check + Use | On | Off: a full meter's fight only comes by itself. |
| Ignore Spawn Restrictions | Off | A due Bossfight comes regardless of Too Early, Near Exit, Low Health, Too Busy and No Room. Cooldown and Per Map Cap still apply. |
| Effects | On | Links, orbs, flames, teleport fog and sparks. Per player. |
| Effects Density | Low | Low (Quest-safe), Medium, High: flames and the cap on effects drawn (links always use the original's 30 beads). Per player. |
| *Fight* | | |
| Thralls | 3 | Thralls per miniboss, 1 to 8. |
| Lives | 3 | Lives in all. |
| Tier From | Whichever Is Larger | Set, Gun Bonsai VR Level, Score Lives or Whichever Is Larger: what sets a Bossfight's tier (above). |
| Graves Rise (Legion of Bones) | Off | With Legion of Bones and RSQ Graveyards, a Bossfight landing raises undead from the tombstones, no cap (above). |
| Graves Area | Map | Map (every tombstone) or Radius. |
| Graves Radius | 1024 | Map units from where the Bossfight landed, for Radius (32 = 1 m). |
| *Rules* | | |
| Legendary Thralls (LegenDoom) | On | With LegenDoom (Lite or 3.0), every thrall of a Classic Pick is made legendary (a Bossfight's monsters always arrive legendary). |
| Tier-Up Hits the Whole Map | On | A missed window tiers up every monster on the map RSQ Monsters can tier, not only the miniboss and its thralls (put back when a hub level is entered again). |
| Tier Up Each Life | On | The miniboss tiers up one, with RSQ Monsters' flash, each time a life bar empties. |
| Inherit Powers | On | The miniboss inherits its thralls' powers. |
| Greed Enrages Monsters | On | The greed rule. |
| Score Awards | On | Sends awards to RSQ Score. |
| *Counts as a Boss* | | |
| Boss Kill Rewards | On | Counts as a boss for Kill Rewards. |
| Legendary Boss Health | On | Higher of LegenDoom's boss and normal legendary health. |
| Can't Be Yanked | On | Grapple and Whip cannot yank it. |
| Can't Be Headlocked | On | Melee's headlock refuses it. |
| Can't Be Morphed | Off | Immune to morphing. |
| Map-wide Roar | Off | Sight and death sounds at full volume map-wide. |
| Test and Debug | | The page below. |
| Reset All | | Resets every RSQ Miniboss setting (both pages). |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| *Bossfight* | | |
| Arrives By Itself (s) | 60 | Seconds after the meter filled that it comes by itself (0: only when called). |
| Map Start Wait (s) | 60 | Never in a map's first seconds. |
| Cooldown (s) | 90 | Seconds after one began before the next may come. |
| Per Map Cap | 2 | Most Bossfights a map. |
| Wait Under Health | 40 | It waits while your health is under this. |
| Wait Over Awake Monsters | 3 | It waits while more awake monsters than this are after you. |
| Nearest Arrival | 384 | The arrival spot's least distance (map units; 32 = 1 m). |
| Farthest Arrival | 1024 | Its greatest distance. |
| Exit Distance | 768 | It waits within this of an exit. |
| Landing Slow Motion (s) | 4.0 | RSQ SlowMo for the landing (0: none; at most 5): the staggered arrival fits inside it. |
| Bits Multiplier | 3 | Times more Kill Rewards boss bits for a Bossfight's miniboss. |
| Score Style Fill | 0.25 | Meter points per Score style point. |
| Gun Bonsai XP Fill | 0.20 | Meter points per Gun Bonsai XP point. |
| Score Per Tier | 4000 | This map's score that raises the tier by one. |
| Show Meter | On | The meter on the HUD. Per player. |
| Meter Size | 1.5 | Its size. Per player. RSQ SlowMo's two bars under it span the meter's row while the meter shows. |
| *Classic* | | |
| Classic Pick at Level Load | Off | The old way: a miniboss chosen from the level's monsters at the start. |
| Per Map | 1 | Classic: minibosses per level, 0 to 4. |
| Map Chance | 100 | Classic: % chance a level gets any. |
| *Fight* | | |
| Thrall Range | 1024 | Classic: how far from the miniboss a thrall may stand. |
| Power Cap | 4 | Most distinct powers inherited (legendary not counted). |
| Invulnerable (s) | 5.0 | Seconds invulnerable after a lost life. |
| Slow Depth | -1 | World speed % in a thrall kill's window; -1 uses RSQ SlowMo's own. |
| Rage Speed | 2.00 | Enraged monsters' speed multiplier. |
| Effects Range | 4000 | Effects drawn only within this distance of you. Per player. |
| Debug Log | Off | Console lines for every rule as it fires. |

## Works with

- **Alone**: the whole Bossfight works: the meter fills from kills, chains and time, the watch check is read by this mod's
  own copy, and the set piece runs in full. Without RSQ SlowMo there is no slow motion (the window still times the
  greed rule and chains).
- **RSQ Score**: head shots on every monster, the 1.25x miniboss judged on its grown body; its style points fill the meter most (unless Fills From is Gun Bonsai); the meter sits under its bar and its combo rows go below; Thrall
  Slow Kill, Miniboss, Greedy and Bossfight rows; a Bossfight's miniboss killed drops Score's life crate (one extra life when touched).
- **RSQ SlowMo**: the landing (4 s) and each thrall kill's window slow the world; its edge arrows point to each landing
  out of view (RSQSM_Service "arrow.add"); its two bars sit under the meter (under the fight's HUD stack while one runs). A heavy hit from a
  miniboss or thrall can set off SlowMo's Heavy Hit Slowdown (every heavy hit during a Bossfight).
- **RSQ Glow In The Dark**: the heartbeat while the meter is full; the map's glow takes the miniboss's colour while it lives;
  the fight (11-09): an arrival wave in its colour, a steady cold grey while it is shielded, gold pulsing in a window
  (steady in Photosensitive Mode), red then its new colour on a lost life, a map-wide wave and a colour re-roll on its death.
- **RSQ Monsters**: its ladder colours (each monster's bar, beam and glow colour) and its tier changes with the tier flash
  (RSQMN_RosterService "tier", "retier"; a CH colour change swaps the body and this mod follows it); its Bossfight rows,
  Miniboss From and Thralls From ("set.class", "class.set", "class.tier"). Without it, the map's own monsters.
- **RSQ Gun Bonsai VR** (with Gun Bonsai): XP fills the meter (unless Fills From is Score); the player level raises the tier.
- **RSQ Accessibility (Gestures), RSQ Gun Cards**: their watch-check reader is used first when loaded.
- **RSQ VisualRewards**: the arrival beams (V1-V4), the words over the monsters ("TARGET!", "GUARD!" in RS Score's font)
  and the thrall-kill pop (RSQVR_Service "beam", "word", "word.hold", "word.clear", "pop"; without them, the old fog and no
  words). HP bars mark the miniboss and its thralls (the crown carries one pip per Bossfight tier, none at tier 0 and 4 at tier 4); Kill Rewards treat it as a boss, a Bossfight's x3 more.
- **RSQ Grapple, RSQ Whip, RSQ Melee**: refuse to yank or headlock it (switches above).
- **RSQ ShieldSaw and RSQ Gun Bonsai VR**: read its true legendary health when it was made legendary here.
- **RSQ Tactical Rig**: its optional "watch check + Use moves the gun" uses the same press. While a Bossfight is ready to
  call (the meter full, Call It In on), the press calls it in and the gun stays where it is; the rest of the time the press
  moves the gun as before.
- **LegenDoom Lite 4.2, LegenDoom 3.0 and Champions**: see Features. All optional and found by name; with LegenDoom 3.0 under
  BD22 VR, load the LDL x BD22 VR patch after it (rig only, not headset-confirmed).
- **Brutal Doom, XMVE**: a Bossfight brings the map's own (replaced) types. Brutal Doom's gore and props are never enraged.

## Credits and licence

- Origin: **Minibosses! v0.1.1 by Tartlman** (ZDoom forum, November 2019; "All code by me. Special thanks to the Hideous
  Destructor server for helping me out!"). The idea of a miniboss with extra lives, thralls tied to it by trails, damage
  cut per living thrall, invulnerability after a lost life and thralls raised again comes from it. This is a rebuild; its
  code is not copied. Its to-do list asked for LegenDoom compatibility, and this delivers it.
- Set-piece design (legendary thralls, inherited powers, slow time on a thrall's death, the chain, the greed rule) and
  the Bossfight (the meter, the call-in, the arrival in view, scaling, the payoff): presidentkoopa.
- The arrival's idea of spawning at the map's own monster start spots: Dynamic Enemy Reinforcements v3 by Joshua Hard
  (MIT). Its code is not copied.
- Effects design (the IWAD sprites BFS1, APLS, BFE1, APBX, BAL2, FIRE in AddStencil): Tartlman's Minibosses!.
- Code: written for this pack. No sprites or sounds are shipped (the IWAD's own sprites and sounds are used by name); the HUD graphics are the only art.
- HUD art: the white box and the placeholder shield icon (graphics/RSQMBWH, RSQMBSH) are generated for this pack by
  tools/gen_hudart.py (the shield from the owner's mockup).
- Recognised by name, not shipped: Champions, LegenDoom Lite, LegenDoom 3.0, RSQ SlowMo, RSQ Score, RSQ Glow In The Dark, RSQ Gun Bonsai VR, RSQ Accessibility (Gestures), RSQ Gun Cards, RSQ VisualRewards, RSQ Monsters.
- QuestZDoom: Emawind and Team Beef.

Free to share as part of the Radiant Silvergun Quest series.
