# RSQ UBQ Series
### Doom Arcade VR · twenty-one pk3s for stock QuestZDoom 17.3

"Doom Arcade VR" is the owner's (presidentkoopa's) name for what this series is.

The RSQ UBQ Series (Radiant Silvergun Quest) is a set of VR mods for Doom on stock QuestZDoom 17.3. You fight with your
hands and your body: a saber, a shield saw, a whip, a grappling hook, fists, a hand grenade, a flare. Points, lives,
minibosses, slow motion and coloured light sit around the fighting. Everything is ZScript and data. There are no engine
changes.

Each pk3 loads on its own. Load more of them and they start to work together: a whip crack pays a Score row, a
miniboss fight slows the world through SlowMo, a level-up washes the map in Glow In The Dark's colours.

*[GIF to come: one fight using several mods at once, filmed in the headset]*

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

Most of the series has no keys: you do it with your hands. Keys as they are in the code today (the owner's keys plan of
2026-11-10, `design/KEYBINDS_PLAN.md`):

**Grenade:** Quick Grenade · **SlowMo:** Slow Motion, Crisis Dive · **Grapple:** Fire Hook (which hand fires is a
menu option, Off Hand by default) · **Wheel:** Open Wheel (left thumbstick click by default) · **ShieldSaw:** Draw /
Put Back · **Tactical Rig:** Recenter Torso · **Distance Grab:** Main Hand Key and Off Hand Key, used only with its
Grab Keys option on (off by default) · **Graveyards:** Remove Gravestones on This Map, Remove All Gravestones ·
**Accessibility:** nine buttons that stand in for gestures (Off-Hand Modifier, Grab Pull, Grab Reach, Force Push, Force
Pull, Force Grip, Shield Throw, Flick Reload, Wrist Cross) · **Gun Bonsai VR:** Gun Bonsai's own key · everything
else: none.

The Saber's Training Remote and Glow In The Dark's Randomize Colours Now are buttons on their menu pages, not keys.
Every key is on its mod's page and in Customize Controls.

Status: the keys pass went in on 2026-11-10. It was load-checked; it has not been run on the rig yet. Code only.

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

Taken from each mod's README. "Shown on the rig" means frames or a log from the Linux QuestZDoom 17.3 rig with a
simulated headset and controllers: rig only, not headset-confirmed. "Code only" means written, never shown.

| Mod | Shown on the rig | Code only | Headset |
|---|---|---|---|
| Tactical Rig | 2026-11-09: the ammo pouch, refusals at a holster, a shotgun assigned to a holster, the grip hint | everything else | **Cigarettes** (the owner, 2026-11-09: "Cigarette works") |
| Accessibility | "New since the headset pass": rig only (the README.md status line) | not split out | README.md: 0.99 played and confirmed in the headset (see the note below) |
| Saber | 2026-11-09: loads with no script error; saber in the main hand, Force hand in the off hand. 2026-11-03 (earlier build): Force Only With Saber, the Force hand, Hand on the Hilt | cutting, blocking, deflecting, the throw, the Force, the training remote and the 2026-11-10 changes | nothing yet |
| ShieldSaw | 2026-11-09: loads; the Draw key puts the shield in the off hand. 2026-11-03 (earlier build): the stowed shield follows the body | the block, the bash, the rev, the throw and the catch | nothing |
| Melee | 2026-11-09: loads, page listed. No move exercised | everything else | nothing yet |
| Whip | "New since the headset pass": rig only (the README.md status line) | not split out | README.md: 0.99 played and confirmed in the headset (see the note below) |
| Grenade | 2026-11-09: throwing with the trigger, with alt fire, cook-then-throw | everything else | nothing yet |
| FnF | 2026-11-09: the flashlight taken into the off hand and switched off and on; the Beam Look lights | the grip, strike and throw of the flare; everything else | nothing yet |
| Grapple | "New on 11-06": rig only (the README.md status line) | not split out | README.md: 0.99 played and confirmed in the headset (see the note below) |
| Distance Grab | 2026-11-09: loads, page listed. 2026-11-03 (earlier build): a clip locked at range | the pull, catch, carry, throw and everything else | nothing yet |
| Laser Sight | 2026-11-09, current build: the beam staying on between shots (pistol, pump shotgun), the rifle's beam | the dot, targets, the grenade arc, colours, everything else | nothing yet |
| SlowMo | 2026-11-09: DOWN from start to finish; the Reload trigger | the key, the wrist cross, the Crisis Dive, the dodgeable rounds, three later fixes | nothing yet |
| Score | 2026-11-09: the head-shot check and its row; the Revival Fire; Revenge from DOWN | every other bonus row, combos, the target, lives | nothing yet |
| Miniboss | 2026-11-09: the reworked fight, called in, with RSQ Monsters (thralls on beams, the shield, the window, tier-ups, lives). 2026-11-05: the meter and the call-in | the fight's HUD bars, GUARD! / TARGET!, Graves Rise and more | nothing yet |
| VisualRewards | 2026-11-09: the four arrival beams with their sounds; DOWN's pops; HP bars in frames | monster words and pops, the scene music, Photosensitive Mode's versions | nothing yet |
| Gun Cards | "New on 11-06": rig only; per-gun card spots boot clean, not rig-tested (the README.md status line) | not split out | README.md: 0.99 played and confirmed in the headset (see the note below) |
| Wheel | 2026-11-09: loads, page listed. The ring was not exercised | everything else | nothing yet |
| Glow In The Dark | 2026-11-09 (the 18:49 build, not the current one): the built-in DarkDoomZ darkening MAP01 and switching live | the glow, the liquids, profiles, the reactions, the 11-09 evening changes | nothing yet |
| Gun Bonsai VR | "New on 11-06": HUD Colour Cycle per hand, rig only (the README.md status line) | not split out | README.md: 0.99 played and confirmed in the headset (see the note below) |
| Graveyards | its Readme has no Status section; it marks the RSQ Edition's additions (the gold stone, the Bones, Graves Rise) "rig only, not headset-confirmed". It says 31 stones raised 31 undead on the rig; the log of that run (`SlowMo/tools/rigtest/build/logs/v3c.log`) ends with risers still trying again ("did not fit"), so that number is not shown | not split out | nothing recorded |
| Monsters | 2026-11-09: ColorfulHell spawns; a missed miniboss window turning eleven monsters Common to Purple (a log; the flash not looked at). Not re-run since MeatGrinder was removed on 11-10 | the flash's look, the Vanilla and BD22 sets, bosses and EX forms | nothing yet |

**Known not to work** (from reading the code and the built pk3s):

- RSQ Monsters' **Monster Diagnostics** page: only God Mode works (its README).
- The **Fire Hook** key in the RSQ_Grapple.pk3 now in pk3/: `tools/build_all.py` leaves Grapple's KEYCONF.txt out, so
  the key's command does not exist in that pk3 (the pk3 holds no KEYCONF).
- The same tool leaves the Whip's KEYCONF.txt out of RSQ_Whip.pk3, so the whip is not added to weapon slot 1.

**About "0.99 played and confirmed in the headset."** Five READMEs (Accessibility, Grapple, Gun Cards, Whip, Gun Bonsai
VR) still carry this line. The only record of it in the repo is one note in `BUGS_0.99a.md` (item 46: "owner confirmed
every mod in the headset 11-03"). It does not say which parts. Everything changed since 2026-11-03 is rig only or code
only.

**Since these READMEs were written:** the 2026-11-10 rig test (`design/rigtest_2026-11-10/RESULTS.md`, BD22 VR 2.0.4f)
showed the Miniboss rename (MINIBOSS INCOMING; the called-in kill paying Score's Miniboss row at 3x), GUARD! and
TARGET! over the miniboss, the tier gem and Champion icons beside the HP bar (VisualRewards) and on Score's Champion
rows, the floating tier gems, the Saber's training remote (only with a saber, its wrist panel and 30-second round),
and SlowMo's Be Quick or Be Dead plate. Rig only, not headset-confirmed. Every launch had no script error from the
series.

---

## Coming later (planned, not built)

The owner's planned projects (`design/PLANNED_PROJECTS.md`). None of these is in the pk3s.

- **The Arcade:** arcade words and numbers in the world, contextual challenges, time attack. Design only.
- **Grapple 2.0:** jpalomo's hookshot rebuilt in ZScript, the weight rule both ways, air steering.
- **Gun Bonsai VR's Big Pass:** many more features per weapon, gated behind weapon and player levels. Part of it:
  close-call slow motion, condition and gold bits, weapon wear, and maybe the whip in one hand with a pistol in the
  other.
- **RSQ Score's Big Pass:** not yet scoped.
- **Monster Assembly:** the RSQ Monsters rebuild: new menus, Brutal Doom's own monsters on the colour ladder, real
  bosses and a boss bar beside the Miniboss meter.
- **Wheel support for other weapon mods:** parked for now (only LegenDoom is read).
- **Lasers for a non-BD weapon set.**
- **Netplay:** parked until QuestZDoom has netplay.

---

## Credits

Every folder's CREDITS file, gathered. Each mod's own CREDITS and README say exactly which file is whose.

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
