# RSQ UBQ Series
### DoomVR - Arcade Edition · twenty-one pk3s for stock QuestZDoom 17.3

The RSQ UBQ Series (Radiant Silvergun Quest) is **DoomVR - Arcade Edition**: Brutal Doom 22 rebuilt for VR from the
hands up, and played as an arcade game. It is twenty-one pk3s for stock QuestZDoom 17.3, written entirely in ZScript
and data, with no engine changes.

*[GIF to come: one fight using several mods at once, filmed in the headset]*

## The idea

Most VR ports of Doom keep the flat game and give it a headset. This series starts from the other end. Every weapon,
tool and system is designed for two tracked hands and a body in a room first, and the game around it is built to be
played for mastery: a score, a run, a margin for error that you earn.

**VR first.** The hands are the interface. BD22 VR Reloaded puts both hands on every Brutal Doom gun, with the
magazine changed by hand from pouches on the belt and the guns drawn from holsters on the body. Melee is real: fists,
two sabers and the Force, a shield saw that blocks, bashes and returns when thrown, a whip, a grappling hook aimed with
the arm, grenades pinned, cooked and thrown. Information lives on the body as well: ammo and status on the wrists, a
watch check instead of a menu.

**Arcade oriented.** RSQ Score reads how you fight, not only what you kill: air kills, reflected shots, chains
between tools. Each map sets a target, and crossing it earns a life that holds a killing blow at 1 HP. Gun Bonsai VR
gives each hand its own experience and its own upgrade trees, more than 170 nodes built around what the body does.
SlowMo slows the world while your head and hands stay in real time, and Be Quick or Be Dead turns a death into a few
seconds of last chance. Minibosses are called in by the player when the meter is full; monsters climb a ladder of
thirteen tiers, and Champions are scored apart.

**One series, any subset.** Every pk3 loads and plays alone. Loaded together, they find each other by name and work
as one game: the whip pays Score, a miniboss fight drives SlowMo, a level-up colours the world through Glow In The
Dark. One Accessibility page serves every mod: one-handed, seated, left-handed, colour-blind and motion- or
light-sensitive play.

## Where it stands

Nothing here is headset-confirmed unless the Status section says so. Most of it is **rig only, not
headset-confirmed** (frames or a log from the Linux rig, with a simulated headset and controllers) or **code only,
not shown**. RSQ Grapple is **waiting on Grapple 2.0**. The [Status](#status) section has one line per mod.

Built on Brutal Doom 22 (Sergeant Mark IV), the owner's BD22 VR Reloaded, QuestZDoom 17.3 (Emawind and Team Beef),
Gun Bonsai (ToxicFrog), Legion of Bones (SpacemanStrife), Champions (Mikk-), m8f's Graveyards, ijon's Dakka scoring and
Tartlman's Minibosses!. [Credits](#credits) has the rest.

---

## Load order and install

Load these in this order. This is the owner's load order, and the one the rig tests run on:

| # | File | What it is |
|---|---|---|
| 1 | doom2.wad | Doom II, the IWAD |
| 2 | brutal22test6.pk3 | Brutal Doom 22 (Sergeant Mark IV) |
| 3 | BD_VoxelPack.pk3 | Brutal Doom's voxel pack |
| 4 | BD22 VR Reloaded 2.0.4f | the owner's VR weapons for Brutal Doom 22 (hands on every gun, reloads by hand) |
| 5 | LOB_v1.05.pk3 | Legion of Bones (SpacemanStrife) |
| 6 | mk-champions | Champions |
| 7 | GunBonsai-0.10.6.pk3 | Gun Bonsai (ToxicFrog) |
| 8 | the RSQ pk3s below | any order among themselves |

Only the IWAD is needed by everything. Lines 2 to 7 are what the series is tested with: each RSQ mod finds them by name
and uses them when they are there. Gun Bonsai is needed by one pk3 (RSQ_GunBonsaiVR, below). Legion of Bones goes after
Brutal Doom and before the RSQ pk3s (RSQ Graveyards' readme explains why).

To install: take the pk3s you want from [pk3/](pk3/), put them with your other QuestZDoom mods, and add them to your
load order after Gun Bonsai. Take one or take them all. Plain Doom II with RSQ pk3s and nothing else works too.

Several mods have a Quest look and a PC VR look on their pages (lights, glow, laser beams); pick the one for how you
play.

**Take these out of an old load order.** They are old names of pk3s in this list, and two copies of one mod do not
load together: UltraBadassQuestSaber.pk3 (now RSQ_Saber), UltraBadassShieldSaw.pk3 (now RSQ_ShieldSaw),
RSQ_TopHPBars.pk3 and RSQ_HPBars.pk3 (now RSQ_VisualRewards), Gameplay_GB_VR_Offhand_Patch.0.10.6.pk3 (now
RSQ_GunBonsaiVR), and RSQ_Gestures.pk3 (folded into RSQ_Accessibility on 2026-11-05). Do not load darkdoomz.pk3 with
RSQ_GlowInTheDark either: DarkDoomZ is built in, and the game stops at start-up with both.

### The pk3s

The 21 pk3s that `tools/build_all.py` builds, in the order the shared menu shows them.

**Body**

| pk3 | What it does |
|---|---|
| RSQ_TacticalRig.pk3 | Your guns on your body: six holsters on hips, chest and shoulders, a spot on the belt for your grenade, sabers, whip, flares, ammo and keys, and Ermac's cigarette in your pocket. |
| RSQ_Accessibility.pk3 | One page of settings every series mod reads: one hand, seated, left-handed, colour blind, motion sensitive or light sensitive. It also carries the series' gesture reader (the watch check, punches, two-hand moves). |

**Hands**

| pk3 | What it does |
|---|---|
| RSQ_Saber.pk3 | A lightsaber in each hand: cut, block bullets, send fireballs back, throw it at marked enemies. Leave the other hand free for the Force: push, pull, grip, fling, jump. |
| RSQ_ShieldSaw.pk3 | The shield saw from Doom: The Dark Ages on your back: block with it, bash with it, rev the blades, throw it round the room and catch it. |
| RSQ_Melee.pk3 | Fighting with your body: jabs, hooks and uppercuts read from your hand, open-palm slaps for fireballs, the gun-butt shove, boxing gloves and the Headlock. |
| RSQ_Whip.pk3 | A simulated bullwhip: crack it with your wrist, snag a beam and swing, rope a monster and yank it in. |
| RSQ_Grenade.pk3 | A hand grenade: pull the pin, cook it, throw it with your arm. Nine kinds. Also the series' barrels and explosions. |
| RSQ_FnF.pk3 | Flash and Flare: a road flare you strike and throw by hand, and a flashlight clipped to your chest. |

**Reach**

| pk3 | What it does |
|---|---|
| RSQ_Grapple.pk3 | A grappling hook from either hand, aimed with your arm: fling yourself at walls or drag monsters to your feet. Plays like jpalomo's jp_grapple by default; turn on Swing and Momentum for a full rope. **Waiting on its 2.0 update.** |
| RSQ_DistanceGrab.pk3 | Turn your palm out toward anything lying in the room, flick your wrist, and it flies to your hand. Carry it, club with it, throw it. Lift doors by hand. |
| RSQ_LaserSight.pk3 | A laser out of every Brutal Doom gun's own barrel, both hands, with a dot where the shot will land. It bends into the arc of the grenade launcher. |

**Game**

| pk3 | What it does |
|---|---|
| RSQ_SlowMo.pk3 | The world slows, you don't: dodgeable bullets, a Crisis Dive, and Be Quick or Be Dead (DOWN), one last stand when a killing blow puts you on the floor. Other mods slow the world through it. |
| RSQ_Score.pk3 | Points for every kill and a bonus for how you made it, combos, a target per map, and extra lives you earn. Built on ijon's Dakka scoring. |
| RSQ_Miniboss.pk3 | Fill the meter, check your watch, press Use: a miniboss lands with its thralls. Kill a thrall to open its shield for a few seconds. Built on Tartlman's Minibosses!. |
| RSQ_VisualRewards.pk3 | Health bars over monsters, damage numbers that fly, kill bits that come to you, level-up banners, and the four arrival beams. |
| RSQ_GunCards.pk3 | Ammo cards on your guns, and a status card on your wrist when you check your watch. |
| RSQ_Wheel.pk3 | Every gun you carry on a ring of cards; point and let go to pick one. With RSQ Tactical Rig, it is where you choose which holster each gun lives in. |
| RSQ_GlowInTheDark.pk3 | Coloured light up every wall, liquids that breathe, and DarkDoomZ's darkness built in. The owner's Glow In The Dark 1.1 rebuilt, with More Lights' glowing flats. |
| RSQ_GunBonsaiVR.pk3 | Gun Bonsai rebuilt for two hands: each hand earns its own XP and upgrades, with more than 170 new upgrades for what you do with your body. |
| RSQ_Monsters.pk3 | The owner's RS Monsters, Quest edition: Colourful Hell's thirteen-colour ladder, and monsters that flash white and come back a tier higher. |
| RSQ_Graveyard.pk3 | m8f's Graveyards, RSQ Edition: a gravestone stands where you died the next time you play the map. A spent Score life leaves a gold one. |

---

## What needs what

**Needs another pk3 to load:** only **RSQ_GunBonsaiVR**. It needs Gun Bonsai 0.10.6 loaded before it (it replaces some
of Gun Bonsai's files by path).

Every other pk3 loads and plays alone. The mods find each other by name (services, network events, class names) and
add features when the other one is there. Without it, nothing happens and nothing breaks.

**Features that only work with another mod**, read from the code:

| Feature | In | Needs |
|---|---|---|
| The holster assignment screen | RSQ Wheel | RSQ Tactical Rig |
| Every upgrade tree (saber, shield, whip, grenade, hook, fists, slow motion, Gunslinger, Kill Rewards) | RSQ Gun Bonsai VR | the mod the tree is for |
| Ground Pound, Clear Out, Taunt | RSQ Gun Bonsai VR | RSQ Melee |
| Bullet Time Fists, the F.E.A.R. Effect window | RSQ Melee | RSQ SlowMo |
| Target Lock and Headshot Reaction | RSQ Laser Sight | RSQ Gun Bonsai VR and RSQ Tactical Rig |
| The arrival beams, GUARD! / TARGET! and the pops of a miniboss fight | RSQ Miniboss | RSQ VisualRewards (without it, teleport fog) |
| The tier-ups of a miniboss fight | RSQ Miniboss | RSQ Monsters |
| Graves Rise | RSQ Miniboss | RSQ Graveyard and Legion of Bones |
| The Bones Bridge | RSQ Graveyard | Legion of Bones |
| Gold tombstones | RSQ Graveyard | RSQ Score |
| The big moments (miniboss tint, the Red Map, the level-up wave, the combo glow, the grey of slow motion) | RSQ Glow In The Dark | RSQ Miniboss, RSQ SlowMo, Gun Bonsai, RSQ Score |
| The BD22 monster set | RSQ Monsters | Brutal Doom |
| Bones Drop Battery Bits | RSQ FnF | RSQ VisualRewards and Legion of Bones |
| Legendary weapons from a miniboss fight | RSQ Miniboss | Champions and LegenDoom |

**Steps aside for another mod**, by name in the code:

- RSQ Grenade lets Brutal Doom VR's own grenade be the grenade, unless you turn on Replace Brutal Doom's Grenade.
- RSQ Melee's gun-butt shove stands down for Brutal Doom VR's own butt strike.
- RSQ SlowMo stands down for another slow-motion mod (Xortts' Bullet Time X, RS_SlowMo) while Yield to Other Mods is on.
- RSQ Laser Sight and QuestZDoom's own laser sight (m8f's): with both loaded, Which Laser picks one.
- RSQ VisualRewards takes over from coldcite's Top HP Bars when both are loaded.

Each mod's own README has its full "Plays well with" list.

---

## Keys

Keybinds are a precious resource in VR (the owner, 2026-11-10). Most of the series has no keys: you do it with your
hands, the trigger and alt fire, and anything that can be switched on or off is a row on the mod's page, not a key.
Keys as they are in the code after the keys pass of 2026-11-10 (`design/KEYBINDS_PLAN.md`):

| Mod | Keys | Menu buttons and gestures that replaced keys |
|---|---|---|
| Tactical Rig | Recenter Torso | the grip holsters, both hands (no holster keys); both hands to your chest recenters too |
| Accessibility | nine buttons that stand in for gestures: Off-Hand Modifier, Grab Pull, Grab Reach, Force Push, Force Pull, Force Grip, Shield Throw, Flick Reload, Wrist Cross | |
| Saber | none | Training Remote: Summon / Send Away is a menu button (saber only); the off-hand saber's second blade lights by twisting the wrist |
| ShieldSaw | Draw / Put Back (also calls a thrown shield home) | lock-on is holding the off trigger; the throw is the swing; recenter is Tactical Rig's key or hands to chest |
| Melee | none | |
| Whip | none | attack and alt attack; the rope is climbed with Distance Grab's grab keys |
| Grenade | Quick Grenade | |
| FnF | none | |
| Grapple | Fire Hook (one key; which hand fires is the Fire Hook From row, Off Hand by default) | grabbing the rope is the grip |
| Distance Grab | Grab / pull, main hand and off hand: unbound, read only with its Grab Keys row on (off by default); RSQ Grapple's and RSQ Whip's ropes are taken through them | |
| Laser Sight | none | |
| SlowMo | Slow motion on/off, Crisis Dive (Shootdodge renamed) | the wrist cross |
| Score | none | |
| Miniboss | none | |
| VisualRewards | none | |
| Gun Cards | none | |
| Wheel | Open Wheel (hold, point, release; left thumbstick click by default) | |
| Glow In The Dark | none | Randomize Colours Now is a menu button |
| Gun Bonsai VR | Gun Bonsai's own key | |
| Monsters | none | |
| Graveyards | none | Remove Gravestones on This Map and Remove All Gravestones are menu buttons |

Every key is on its mod's page and in Customize Controls. No RSQ key has a default binding except the Wheel's. Each
mod's README has a Controls section: its keys, which hand and button does what, its gestures and its menu buttons.

Status: the keys pass is code only, not shown, in the keys themselves. The 11-10 rig runs drove a few of them by their
commands (the ShieldSaw's `ssq_draw`, the Saber remote's `netevent ubqs_remote`) and showed the ShieldSaw's trigger-hold
lock, rig only, not headset-confirmed. The Quick Grenade key was shown on the rig after a fix (ae089395).

---

## Radiant Silvergun Options

Every series pk3 adds its page to one shared menu: **Options > Radiant Silvergun Options**. Options shows that row
once, however many series pk3s you load, in any order. With Simple Options on, the row is there too, above "Full
options menu".

Inside, each loaded mod has one row, in four groups with a blank line between:

| Group | Rows |
|---|---|
| Body | RSQ Tactical Rig · Accessibility |
| Hands | RSQ Saber · RSQ ShieldSaw · RSQ Melee · RSQ Whip · RSQ Grenade · RSQ FnF (Flash and Flare) |
| Reach | RSQ Grapple · RSQ Distance Grab · RSQ Laser Sight |
| Game | RSQ SlowMo · RSQ Score · RSQ Miniboss · RSQ VisualRewards · RSQ Gun Cards · RSQ Wheel · RSQ Glow In The Dark · RSQ Gun Bonsai VR, then RSQ Monsters and RSQ Graveyards |

A mod you did not load adds no row. Each mod's front page holds its settings, with the rarely needed ones on one
Test and Debug page, and a Reset All at the foot. (Two pages differ: RSQ Graveyards has no Test and Debug page, and RSQ
Monsters' front page has no Reset All.) Accessibility's page also has Reset Every Mod.

Status: on the rig on 2026-11-09, with every RSQ pk3 loaded, Options had one Radiant Silvergun Options row, Simple
Options had one, and the menu held all 21 rows (log `design/rigtest_2026-11-09/logs/main_A-G_I.log`, lines 1122 and
1225). The groups and their order are code only. Rig only, not headset-confirmed.

---

## Status

Taken from each mod's README and the batched rig test of 2026-11-10 and 11-11 (`design/rigtest_2026-11-10/RESULTS.md`,
its group files `RESULTS_P1.md` to `RESULTS_P4.md`, `RESULTS_FIX.md` and `RESULTS_LSREADOUT.md`, its `evidence/` and
`PLAN.md`), and the fixes committed and shown since. Three labels: **rig only, not headset-confirmed** (frames or a
log from the Linux QuestZDoom 17.3 rig, a simulated headset and controllers); **code only, not shown** (built, never
shown); **not yet run** (waiting in the batched rig test). Nothing is headset-confirmed unless the repo records the
owner saying so.

Every launch of the 11-10 rig test, on the owner's order with BD22 VR Reloaded 2.0.4f, had no script error from our
packs.

| Mod | Status |
|---|---|
| Tactical Rig | rig only, not headset-confirmed: the rig clutter fixes, rings only for what the hand can use, in frames (T1, 11-10); the ammo pouch, holster refusals, an assignment, the grip hint (11-09). Headset-confirmed: cigarettes (the owner, 11-09: "Cigarette works"; recorded only in its README). code only, not shown: the cigarette pocket rules, everything else. not yet run: nothing from the rig test |
| Accessibility | rig only, not headset-confirmed: Seated Play on Auto (N7); Rumble Backup sent from SlowMo's and Melee's rumbles (logs; N6); loads clean (11-10); the gesture reader on an older build (10-31). code only, not shown: everything else, and most of the 11-10 code-read fixes. not yet run: nothing from the rig test |
| Saber | rig only, not headset-confirmed: the second saber lit on its first draw, Force Pull's gates, the remote's distance, its +25 health and its slow (A1 to A3); the training remote as a saber game, its wrist panel and 30-second round, one throw (2.06 m/s no, 3.09 m/s yes) (11-10). Found broken, then fixed and shown: Slappers Only fighting Start With Saber; the Force out of reach with Melee's gloves. code only, not shown: the wrist twist (the rig cannot pass a controller's roll), cutting, blocking, the rest of the Force and the rest. the remote's deflect slow sent by the saber, once Deflector is learned under Gun Bonsai VR (11-11). not yet run: nothing from the rig test |
| ShieldSaw | rig only, not headset-confirmed: a ricochet with the rings staying on their targets (H1), one throw with nothing locked, 2.06 m/s no, 3.09 m/s yes (H3), the trigger-hold lock (11-10); a far zombie's bullet read as a shot, partly synthetic (H2); the Draw key putting the shield in the off hand (11-09). Found broken, then fixed and shown: a slanted shot through the plate read as a miss (now a block). code only, not shown: the rest of the block, the bash, the rev, the throw's flight and the catch. a far zombie's bullet (11.8 m, flat floor) blocked by the plate, health unchanged (11-11). not yet run: nothing from the rig test |
| Melee | rig only, not headset-confirmed: both hand models, the punches, the boxing gloves, the Headlock, the fireball and bullet swats, the off-hand fist and the barrel kick, Ground Pound's and Clear Out's rings, Guard, Slappers Only, its rumble route (M1 to M8, N6, 11-10); the gloves a glove's size and in slot 1, the Wheel's glove cards wearing its icons (11-10, 11-11), the gloves in slot 1 by its own KEYCONF on the Wheel (11-11). Found broken, then fixed and shown: Slappers Only against Start With Saber. code only, not shown: the moves above level 1 and the rest. not yet run: nothing from the rig test |
| Whip | rig only, not headset-confirmed: Whip and Gun (the cursor, the crack, a one-handed swing, the Leash, a reel to a heavy one), the Rope perks with Gun Bonsai VR, the touch hold on the rope (11-10); the mark, the locked crack and the aim ray on an earlier build (11-03). Found broken, then fixed and shown: Whip and Gun's stale gold diamond (N2). code only, not shown: a gun in the other hand firing, the lasso, the yank, the mantle and the rest. not yet run: nothing from the rig test |
| Grenade | rig only, not headset-confirmed: Brutal Doom's barrels replaced by default and a chain of 9 growing to the mega blast (G2); Quick Grenade on BD22's Toss Grenade and on its key, after a fix (11-10); trigger, alt fire and cook-then-throw (11-09). code only, not shown: SlowMo's Quick Grenade slow, the Kinetic sounds and the rest. not yet run: G1's pin and toss sounds and the side-by-side with BD22's own toss |
| FnF | rig only, not headset-confirmed: the flare's and the flashlight's states read on Gun Cards' item card (11-10); the flashlight into the off hand, off and on; the Beam Look lights (11-09). code only, not shown: the flare's grip, strike and throw, everything else. No check of its own in the rig test |
| Grapple | **Waiting on Grapple 2.0.** rig only, not headset-confirmed: the touch hold on the rope (11-10); older builds (10-27 to 11-03) and clean loads. code only, not shown: the one Fire Hook key, the grip keys on the rope, and the rest of the current build. No other check in the rig test |
| Distance Grab | rig only, not headset-confirmed: the heavy throw's weight logged (D1), Palm Gate off only with Grab Keys on (D2) (11-10); a clip locked at range (11-03, earlier build). Found broken, then fixed and shown: AMMO FULL over a full gun you carry, dropped at your feet (D3). code only, not shown: swings, the shield, doors, switches and the rest. not yet run: nothing from the rig test |
| Laser Sight | rig only, not headset-confirmed: the beam on between shots and through a BD22 VR hand reload (L1); the greyed rows (L3); Glow Intensity's brighter bloom (L4); the range readout as glyphs in every placement and unit, and At the Dot at one apparent size (11-10); At the Dot in Feet (11-11). Found broken, then fixed: M8F's autoloaded laser with BD22 VR (now held off while ours is on; a log of the switch only); the canvas readout, never drawn in VR (rebuilt as glyphs, shown). Not shown: Beam Sparkle, Glow Intensity's wider light. code only, not shown: the dot's targets, the grenade arc and the rest. not yet run: nothing from the rig test |
| SlowMo | rig only, not headset-confirmed: a miniboss window broken early ending the slow and the bar (S1), the Fog Tint Strength row (S2), the fog off with Glow In The Dark (S3), the Training Remote trigger with bolts sent back by a probe (S4), Chain Reaction's slow, Be Quick or Be Dead's plate and breathing letters, MINIBOSS INCOMING (11-10); the menu header breathing and still in Photosensitive Mode, the Training Remote slow sent by the saber itself (11-11); DOWN from start to finish and the Reload trigger (11-09). code only, not shown: the keys, the wrist cross, the Crisis Dive, the Quick Grenade trigger, the dodgeable rounds. not yet run: nothing from the rig test |
| Score | rig only, not headset-confirmed: the menu without MeatGrinder's rows (R2), one Miniboss row at 3x, a Champion row with its icon, the wrist digits stepping aside (11-10); the head-shot check, the Revival Fire, Revenge (11-09). code only, not shown: the other rows, combos, the target, lives. not yet run: nothing from the rig test code only, not shown (11-11): the line centred just below Gun Bonsai VR's gauges, nothing drawn over a menu, the wrist hidden in a menu |
| Miniboss | rig only, not headset-confirmed: a failed landing retrying quietly, the life bars counting inherited lives, the classic pick's HUD bars, Graves Rise in all four modes, no life crate and no x3 bits (B1 to B3, B5, B6); Legendary Thralls off, with LegenDoom added (B4, not the owner's order); the rename, the bar stack, GUARD! and TARGET! (11-10); the reworked fight (11-09); the meter and the call-in (11-05). Found broken, then fixed and shown: a Bossfight's first landing often failing (7 of 7 first try after). code only, not shown: the pops, the edge arrows and more. not yet run: nothing from the rig test |
| VisualRewards | rig only, not headset-confirmed: the miniboss music stopping at a map change and the volume set only while fading (V1, V2); no extra x3 on a miniboss's bits; AMMO FULL over a full gun; the tier gem and Champion icons beside the HP bar, on, off and on (11-10); the four arrival beams, DOWN's pops, HP bars (11-09). code only, not shown: monster words and pops, DOWN's music, Photosensitive Mode's versions. not yet run: nothing from the rig test |
| Gun Cards | rig only, not headset-confirmed: the item card for the saber, the flashlight and the flare (11-10); count colours, RELOAD and the ammo colours on earlier builds (10-31 to 11-05). Found broken, then fixed and shown, partly: the item card's far half under the hand (N1; the flare card still loses a letter or two under the wrist in the rig's pose). code only, not shown: the watch-check reader, Draw in the World, the item card's key icons and the rest. not yet run: nothing from the rig test |
| Wheel | rig only, not headset-confirmed: Opens On Main / Off (N4); the glove cards wearing RSQ Melee's icons (11-10), with the gloves in slot 1 by Melee (11-11); loads clean, its page listed (11-09, 11-10). code only, not shown: the rest of the ring, the Open Wheel key pressed on a controller. not yet run: nothing from the rig test |
| Glow In The Dark | rig only, not headset-confirmed: DarkDoomZ's fog going off with Glow In The Dark (S3) and the landing's darkness dropped once (B1), logs only (11-10); the built-in DarkDoomZ darkening MAP01 and switching live (11-09). code only, not shown: the glow, the liquids, the other reactions, Randomize Colours Now as a button. No check of its own in the rig test |
| Gun Bonsai VR | rig only, not headset-confirmed: its own screens and rows (11-11): both hands' gauges cycling colour, the status screen, the level-up cards, a level-up by card on every weapon tree and every player tree, the greyed HUD rows; loads clean; nodes from the debug Add All at work: the whip's Rope perks, Two Sabers, Force Sensitive, Ricochet (11-10). code only, not shown: the owner's HUD decisions of 11-11 (ShieldSaw Gauge removed, no HUD over menus, Display Info on the main hand first, pictures for the whip and the bare fist), the trees' moves in play beyond those, the Ammo and Health Row, the rest of the 11-10 fixes. not yet run: refusing a level, toggling an upgrade on the status screen |
| Monsters | rig only, not headset-confirmed: a Monster Set saved as 2 reading as ColorfulHell, and the retier (R1); Tier Icons Above Monsters from its page (N5); the floating tier gems (11-10); a missed miniboss window tiering eleven monsters up (11-09, before MeatGrinder was removed). code only, not shown: the flash's look, the Vanilla and BD22 sets, bosses. not yet run: nothing from the rig test |
| Graveyards | rig only, not headset-confirmed: the obituary as words over the stone and a brighter gold candle (11-11); Graves Rise in all four modes and a riser finding a spot near a blocked stone (11-10); stones back on reload, a gold stone, Graves Rise (the README GIFs, 11-11); the Bones Bridge (11-06). Graves Rise's "31 raised 31" not shown. code only, not shown: the words on a gold stone, a riser given up after 5 tries, the remove buttons. not yet run: netgames |

**Known not to work** (from reading the code and the built pk3s):

- RSQ Monsters' **Monster Diagnostics** page: only God Mode works (its README). (Its **Tier Icons Above Monsters** row
  is on the RSQ Monsters page since 11-10, rig only, not headset-confirmed: N5.)
- (Fixed 11-10: RSQ Grapple's and RSQ Whip's ropes no longer need RSQ Distance Grab's grab keys. The controller grips
  take the rope, code only, not shown; an empty hand held still on the rope takes it, rig only, not headset-confirmed:
  `design/rigtest_2026-11-10/evidence/ROPE_*`.)
- (Fixed 11-10, commit 09243dd8: `tools/build_all.py` left Grapple's and the Whip's KEYCONF.txt out of their pk3s, so the
  Fire Hook key did not exist and the whip was not in slot 1. Both now pack; not shown on the rig since.)

**About "0.99 played and confirmed in the headset."** Older READMEs carried this line (Gun Bonsai VR's installed
README.md still does). The only record of it in the repo is one note in `BUGS_0.99a.md` (item 46: "owner confirmed
every mod in the headset 11-03"). It does not say which parts. Everything changed since 2026-11-03 is rig only or code
only.

---

## Coming later (planned, not built)

The owner's planned projects (`design/PLANNED_PROJECTS.md`). None of these is in the pk3s.

**The Big Four** (named 2026-11-09):

- **RSQ Score's Big Pass:** its pruning, the names too. Not yet scoped.
- **Gun Bonsai VR's Big Pass:** its pruning, and many more features per weapon, gated behind weapon and player levels
  with branching paths. Part of it: close-call slow motion, condition and gold bits, weapon wear.
- **Monster Assembly:** the RSQ Monsters rebuild: menus redone, Monster Diagnostics written up, Brutal Doom's own
  monsters on the colour ladder, the tier icons back. The bosses live here: a **Boss** is a real boss, the EX-tier
  monsters and their fights (none exist yet), and the **boss bar** is built with them, a second bar beside the Miniboss
  meter. (A **Miniboss** is RSQ Miniboss's.)
- **The Arcade:** arcade words and numbers in the world, contextual challenges, a conductor, bits as jackpot, time
  attack. Design only.

**Also planned:**

- **Grapple 2.0:** jpalomo's hookshot rebuilt in ZScript, the weight rule both ways, air steering. RSQ Grapple waits on
  it.
- **The Whip's Rope perks:** Fast Reel, Steady Line and Slingshot as Gun Bonsai VR nodes on the whip tree, from the
  Whip's unused code.
- **The bind whip, "Indiana Jones":** the whip in one hand and a pistol in the other, the whip hand's own ray as the
  snag cursor while its trigger is up. Built from the Whip's unused bind-whip code, with the Rope perks.
- **Wheel support for other weapon mods:** parked for now (only LegenDoom is read).
- **Lasers for a non-BD weapon set.**
- **Netplay:** parked until QuestZDoom has netplay.

---

## Credits

Every folder's CREDITS file, gathered. Each mod's own CREDITS and README say exactly which file is whose.

**The DoomVR lineage.** This series stands at the end of a long line of people who put Doom in a headset:
- **biospud:** GZ3Doom, GZDoom on the Oculus Rift, later ViveDoom.
- **Fishbiter:** forked it as OpenVRDoom and added motion controls.
- **hh79 (hari):** carried that desktop fork forward through newer GZDoom versions (3.5, 4.1, 4.3 as gzdoomvr), with fixes
  backported from QuestZDoom.
- **Team Beef (DrBeef):** QuestZDoom, Doom on the standalone Quest.
- **Emawind84:** continued QuestZDoom, bringing it up to GZDoom 4.11 and on to 17.3, the engine this series targets.
- **Ermac:** DoomXR, from Emawind84's fork.
- **presidentkoopa:** moved DoomXR onto UZDoom 5.0, now his own engine, REMA, which this series will move to after 2.0.

**The series:** presidentkoopa: the design, the direction of every change, his headset testing, and his own libraries
and mods the series draws on (RS Combat FX, RS Ballistics, RS_WorldHands, RS_Gestures, RS_SlowMo, RS_Score, RS_Holsters,
RS_VRBody, RS_WeaponSelectionSystem, RS Monsters, SuperPunchOut, Glow In The Dark 1.1, BD22 VR Reloaded). The code is
ZScript written for the series.

**The engine:** QuestZDoom 17.3 by Emawind and Team Beef: the engine, its off-hand weapon and its hand-pose script API.

**Where the owner's gathered art and sounds come from** (the owner, 2026-11-10: "thats all i remember for now"; which
file came from which game is not recorded):

- Melee sprites: Street Fighter II (Capcom).
- Explosion sprites and sounds: Gunstar Heroes (Treasure / Sega), Top Gear 2 (Genesis), Castlevania: Bloodlines
  (Konami), Streets of Rage 2 (Sega).
- Explosion sprites: Mega Man X3 (Capcom), Metal Slug X (SNK), Castlevania: Symphony of the Night (Konami), Dark Wizard
  (Sega), The King of Dragons (Capcom).
- The Be Quick or Be Dead (DOWN) music and the miniboss music: Phantasy Star IV (Sega).
- The DOWN bar and the chevrons: Kirby Mass Attack (HAL Laboratory / Nintendo).

**Other people's work, by mod:**

- **Accessibility:** the gesture reader ported from presidentkoopa's RS_Gestures; the hand reading after RSQ Grapple's.
- **Distance Grab:** presidentkoopa's RS_WorldHands (the pull, tumble, gravity and sag); Doom's own sounds. Ideas only:
  QuestZDoom's bundled laser sight, DXR's debug cone.
- **FnF:** the flare model is the owner's; the hands are BD22 VR Reloaded's FBX hand. saegiru's Emergency Flare (UDV
  Survival Flares, in JohnnyDoom's UAC Survival Pack): box and flare sprites and the three flare sounds. DooMAD's ammo
  box voxel from BD_VoxelPack (its voxel authors: Ghostpilot, DooMAD, Monfriez, DooMGoaT, Exl, Scott_AW, ReaperMan, 4mer,
  phi108, Conrad RDW, Voxelbro, zedas). The battery after Ermac's VR-Flashlight (base: SuaveSteve's Steve's Flashlight).
  The DarkDoomZ beam style: an altered rewrite of DarkDoomZ (Caligari87, zlib).
- **Glow In The Dark:** presidentkoopa's Glow In The Dark 1.1 (wall glow after ColorfulMaps by Solid_Head and NightFright's
  Lite; liquids after Finder153's GlowingLiquids). More Lights by Jakie (SnakieJakie): its glowing-flat list.
  DarkDoomZ by Sterling Parker (Caligari87), zlib, built in as an altered version; its credits: Josh771's Dark Doom
  (inspiration), Kinsie, Gutawer, FishyClockwork, phantombeta, Marisa Kirisame, Accensus, mshahen (sound, not shipped),
  testers Fort of Hard Knox, a1337spy, Orange Bomb.
- **Grapple:** jpalomo's jp_grapple: the claw and chain sprites and five sounds, and the OG hook rebuilt number for
  number. The Combat FX and Ballistics looks are the owner's libraries.
- **Champions:** by Mikk- (ZDoom forums, "[v2.9.1] CHAMPIONS", forum.zdoom.org/viewtopic.php?t=60456). Not in any RSQ
  pk3: the series reads its champions and icons by name (RSQ Monsters, Miniboss, Score, Visual Rewards).
- **Graveyards:** m8f's Graveyards (GPLv3), RSQ Edition by presidentkoopa; tombstone graphics by Captain J (minor edits by
  m8f). Legion of Bones (SpacemanStrife) is used by name only.
- **Grenade:** JohnnyDoom's UAC Survival Pack (its grenade: original by Froon, Brutal Doom version by Saegiru, sprites by
  Pa1nki113r): sounds, sprites, the explosion and its ammo rules. The grenade model by Gomuz. The handling from the
  owner's BD22 VR Reloaded and RS_Grenade. Barrels and explosions: Reactorcore's Explosion Spriteanim Sheet Minipack
  (CC0, by a page comment only), Rufaswan's rips (sheet by Magma MK-II), one sheet from the owner's list above,
  Meatgrinder's blood burst (Sergeant Mark IV, via RS Monsters; licence not stated), End of Starchild (structure
  reference only); the owner's Kinetic explosion sounds.
- **Gun Bonsai VR:** Gun Bonsai © 2022 Rebecca "ToxicFrog" Kelly, MIT. `sprites/ui/hud.xcf` © 2022 Sungraphica. Sounds
  from SuperPunchOut (via Punch Out Doom by DerrickDavison and Virtual Punch Out) and the Super Punch-Out!! announcer.
  coldcite's Top HP Bars bar for the Berserk Meter; SoM's Kill Rewards; Mikk's Critical Shots (the idea only).
- **Gun Cards:** Ermac's Force Unleashed holo HUD (with the owner's blessing). JFO, the JDUI font by Zedas, in
  Blackmore1014's "JDUI Brutal Doom Ultimate Edition" edit. BD_VoxelPack's key voxels (keycards by Ghostpilot, skull keys
  by Voxelbro); Freedoom's status-bar keys (BSD).
- **Laser Sight:** inspired by m8f's Laser Sight (Alexander Kromm, GPLv3); nothing of it is used. The beams are measured
  from Brutal Doom Quest's gun models.
- **Melee:** SuperPunchOut (presidentkoopa): gloves, punch reader, sounds; the glove mesh by Ermac (PunchOutVR / Virtual
  Punch Out); punch sounds from Punch Out Doom (DerrickDavison). Punch-Out!! is Nintendo's. Brutal Doom's fist numbers
  (parsed, not shipped). BD22 VR Reloaded's butt shove. The hand model by Ermac (Rusted Legacy, MIT) and BD22 VR's FBX
  hand. Hit sparks: a community sheet ripped by shezzor. "VFX Hit Impact" by kiddolink (bought by the owner for the
  series).
- **Miniboss:** Tartlman's Minibosses! v0.1.1 (the origin; its effects' design). Joshua Hard's Dynamic Enemy
  Reinforcements (MIT; the idea of spawning at the map's monster spots). coldcite's bar art. The tier gems and Champion
  icons are the series' own.
- **Monsters:** Colourful Hell by Hege Cactus, rebuilt in ZScript (and its CHP edition, whose author is still to be
  credited). The tier flash: presidentkoopa's Hackfraud tree. coldcite's bar pictures. The voxel models, brightmaps and
  decals: their makers are still to be credited.
- **Saber:** RS_Main combat FX sprites and the choke loop (Ermac: DXR, Rusted Legacy). BD22 VR Reloaded's FBX hand.
  danger_doughnut52's "Jedi Lightsaber (Star Wars)" pixel art. li-gnrcwpn's beep. The saber model is believed to be from
  Star Wars Jedi Outcast (Raven Software / LucasArts) and the saber sounds from a lightsaber soundfont library; their
  authors are not recorded.
- **Score:** the scoring design is ijon's (Dakka / Vanilla VR Dakka Points, WTFPL): the bonuses, the reward loop, the
  HUD and its graphics. The fonts by Blue Shadow (the score line) and Jimmy (the breakdown). The six score sounds are
  Painkiller's (People Can Fly), via Dakka. The revival rebuilt from Dakka's numbers; its flames are doom2.wad's
  Arch-vile fire.
- **ShieldSaw:** the shield saw is id Software's (Doom: The Dark Ages). Ermac's Rusted Legacy (MIT code): his two shield
  models, the hand model and the sounds. The owner's RS Combat FX and RS Ballistics.
- **SlowMo:** the owner's RS_SlowMo design and RS Ballistics' tracer and whiz sounds. coldcite's bar. RSQ Score's
  breakdown font (Jimmy) and JFO (Zedas, Blackmore1014). Kirby Mass Attack (above). Doom's own cues by name.
- **Tactical Rig:** Ermac's Virtual Tactical Vest (the idea, the cigarette, butt and smoke) and his ZBlood-VR Zippo.
  The marine torso and helmet: Doom Eternal's Classic Slayer (id Software), rips shared on Sketchfab. The Quake torso:
  Quake's Grunt, cut by Vittorio Romeo's Quake VR mod. Zippo and cigarette sounds from Pixabay (freesound_community).
- **VisualRewards:** coldcite's Top HP Bars 1.04 (based on Nash Muhandes' SpriteShadow, MIT). Xaser Acheron's damnums
  (MIT; contributions by Major Cooke, thanks to Marrub and Zombie). SoM's Universal(ish?) Kill Rewards. JFO and Ermac's
  digits. The Z-Fighter effects sheet (a rip, not cleared: its maker is still to be credited). RSQ Score's font (Blue
  Shadow). Arrival sounds supplied by the owner; the two music tracks from Phantasy Star IV.
- **Wheel:** presidentkoopa's RS_WeaponSelectionSystem. Ermac's Force Unleashed holo HUD art. LegenDoom 3.0's brass
  knuckles (Yholl and contributors). danger_doughnut52's lightsaber. JFO. RSQ Score's fonts. The IWAD's own art by lump
  name.
- **Whip:** Moses C. Nah's Whip Project (MIT Newman Lab, BSD 3-Clause): the thong's stiffness, damping and masses.
  runevision's Eye of the Temple devlog (the first version's idea). Sounds from Pixabay. BD22 VR Reloaded's FBX hand.

*[Picture to come: the series' pk3s on the QuestZDoom launcher's load order]*
