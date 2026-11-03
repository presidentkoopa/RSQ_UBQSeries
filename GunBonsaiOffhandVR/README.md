# RSQ Gun Bonsai VR

**The one thing:** each hand earns its own XP, and every tool in the series has a tree to climb: the fists, the
saber, the shield, the whip, the grenade, the hook, slow motion, the rig.

An addon for ToxicFrog's **Gun Bonsai 0.10.6** (guns level up and earn upgrades as you use them). Stock Gun
Bonsai thinks you hold one gun. With a gun in each hand, this addon gives each hand its own XP, its own upgrades
and its own HUD, and pays each gun for the damage it really did. It adds upgrade trees for the series' tools,
Kill Rewards (monsters burst into bits of health, armour and ammo), the owner's own Gun Bonsai screens, and XP
from RSQ Score's style points. Needs Gun Bonsai 0.10.6 (not included) and a dual-wield VR engine (stock
QuestZDoom 17.3). Needs no other RSQ mod: each tree is offered only while its mod is loaded. Gun Bonsai itself is
never changed: the addon's files load after it and take its place where needed.

## Features

**Two hands.**
- Each hand has its own XP, upgrade tree and upgrade effects. The off hand's Rapid Fire, Shield, Lightning and
  Bandoliers run.
- Credit follows the gun: shots, fragments, explosions, minions and burns pay the gun that fired them, even after
  you switch or drop it. Two guns burning one monster each get their share.
- Two HUDs: main hand top right, off hand top left, mirror images. Left-handed (RSQ Accessibility's Handedness,
  else QuestZDoom's scheme): swapped. With one gun, one gauge, as stock.
- Gun Bonsai's Show Info key reaches and spends a level the off hand earned.
- Knockdown and Executioner are sized by the health a monster started with (LegenDoom legendaries and champions
  included).

**Kill Rewards.** Monsters burst into bits of health (25), armour (10) and ammo (5 rounds) when they die. One bit
per 10 of the monster's spawn health, three times as many for a boss (a Cyberdemon: 1200, every one of them);
each ordinary bit drops at 50%, rolled once per bit. The mix is 15 health / 20 armour / 65 ammo, ammo for any gun
you carry, and a bit lies on the floor for 7 s. Legendary and champion monsters get the ordinary bits (their own
showers are their mods'); a Champions Titan counts as a boss. On from the first kill, no unlock.

**Stock Gun Bonsai Upgrades: Silvergun.** Gun Bonsai's own upgrades that do not mesh with the series are out of
the pool everywhere: Dark Harvest, Life / Armour / Ammo Leech, Intuition, Juggler, Player Damage, Thorns. "All"
puts every stock upgrade back. An upgrade a save already holds keeps working.

**XP Source.** Damage (Gun Bonsai's own), Style (RSQ Score's bonus points become XP, split along the combo
chain: the finishing tool 50%, the setup tools 50%, plus a share to the player bar) or Both.

**The screens.** The owner's own Gun Bonsai HUD, status screen and level-up menus (Screen Skin: Mockup, Hex Rail
or Terminal; Gun Bonsai's own if you prefer), with per-hand ammo, health, face and armour along the bottom.

**Gauges.** A ShieldSaw gauge (option) for the shield while it rides on your shoulder; a Berserk Meter gauge per
glove that has learned it.

**The trees** (what each node does is in its tooltip; the moves are the owning mod's, the levels and numbers are
here):

- **Fists** (RSQ Melee's gloves; each glove levels on its own): Heavy Hands -> Haymaker -> Wallflower ->
  Knockdown; Heavy Hands 2 -> Body Blow (3 -> Knockdown), Clear Out; Heavy Hands -> Uppercut (an unlock) ->
  Launcher -> Juggle, Meteor, Ground Pound. One element per glove: Explosive Fist, Frost Fist, Shock Fist, Fire
  Fist. One-Two -> Three-Hit -> Dempsey, Finisher (needs Executioner). Rage -> Blood Rush, Berserk Meter. Pistol
  Whip -> Rifle Butt. The off glove's Headlock: Human Shield -> Headlock Uppercut, Heavier Headlock -> Slam,
  Throw Into, Chokehold. After the player's Guard: Counterpunch, Swat Back -> Hadouken -> Catch, Bullet Time Fists
  (needs RSQ SlowMo). Ground Pound, Clear Out need RSQ Gestures. Star Punch is no longer offered.
- **Player (fists side):** Guard -> Parry, Reflect Guard -> Absorb and Release (needs RSQ Gestures); Taunt (needs
  RSQ Gestures); Critical Hits -> Headshot, Backstab.
- **Saber** (RSQ Saber): Battle Meditation -> Saber Throw, Saber Barrage -> Returning Blade; Momentum -> Riposte
  Edge -> High Ground, Strike True, Kyber Attunement; Point Taken -> Run Through; Deflector -> Return to Sender,
  Guided Return -> Piercing Return, Precognition; Two Sabers -> Assault, Cross Guard -> Clash; Double-Bladed; the
  Force: Force Sensitive -> Force Push, Force Pull, Force Choke, Force Jump, Force Speed; Force Lightning (Push 2
  and Choke 2). A Force power does nothing until its node is learned; then levels 1-4 are 40 / 70 / 100 / 130%
  of the saber's own (Force Base Strength). Chain Choke is no longer offered.
- **ShieldSaw** (RSQ ShieldSaw): Lockstep -> Ricochet -> Hunter's Return -> Meat Grinder -> Cleaver; Ricochet 2
  -> Wall Bounces; Broadening -> Bulwark -> Rebound -> Reflect; Broadening 2 -> Back Plate; Bulwark 2 -> Shield
  Wall; Battering Ram -> Wall Slam -> Charge -> Shield Dash, Strike True; Battering Ram 2 -> Shield Size; Hungry
  Blades -> Rev Shield, Buzzsaw Return; Spartan (Broadening and a saber's Deflector).
- **Whip** (RSQ Whip): Sting -> Stun, Strike True, Crack Shot -> Return Crack; Long Thong -> Quick Mark; Heavy
  Yank -> Pull and Punch (needs RSQ Melee); Lasso -> Bola; Snag -> Mantle, Momentum -> Tarzan.
- **Grenade** (RSQ Grenade): Bandolier -> Scavenger; Strong Arm -> Flat Arc, Bounce, Skeet -> Skeet Window (needs
  RSQ SlowMo); Cook Sense -> Short Fuse, Slow Burn (needs RSQ SlowMo), Impact, Stun; Cook Sense 2 -> Smoke, Flash
  -> Charm, Infight; Big Bang -> Frag -> Sticky, Cluster; Big Bang -> Incendiary; Frag -> Freeze; Teeth. Cook
  Sense reaches 3 only with RSQ Gun Cards.
- **Grapple** (RSQ Grapple; player nodes): Grapple (the unlock: the hook fires only once learned) -> Long Line ->
  Barbed Claw; Fast Reel -> Heavy Haul -> Get Over Here -> Bowling, Scorpion (needs RSQ Melee); Heavy Haul 2 ->
  Double Hook; Momentum (the swing as an unlock) -> Slingshot, Steady Line, Twin Lines, Zip Kick.
- **Any melee weapon:** Lunge, Executioner, Adrenaline.
- **Tactical Rig** (player): Quick Draw -> Pair Draw, Showdown (needs RSQ SlowMo); Gun Toss -> Boomerang Gun;
  Smoker -> Chain Smoker (the cigarette is yours from the start; Smoker lengthens its slow motion and makes you
  untouchable during it); with RSQ LaserSight, Quick Draw -> Target Lock -> Headshot Reaction.
- **SlowMo** (player): Longer -> Cheaper -> Second Wind; Deeper -> Marksman -> Time Dilation, Dodger -> Lean
  Dodge, Matrix (Deeper 3). Slow motion itself is no unlock: your key works from the start. Deeper at level 0 is
  your own World Speed row.
- **Kill Rewards** (player): Gastropub -> Rich Bits -> Lucky Kill; Gastropub -> Magnet.
- **Two hands** (player): Akimbo, Crossfire, Alternator. **The body** (player): Evasion, Southpaw, Steady Aim.
- **Distance Grab has no tree.** Its nodes are no longer offered; the grab works in full from the start.

## How to play

In **Gun Bonsai's own options**, set its upgrade binding mode to **per weapon**. With a gun in each hand,
per-class binding thrashes; the addon warns once at start-up if it is not set.

Shoot with either hand: each gun earns its own XP and its own gauge fills. When a gun levels, press Gun Bonsai's
own Show Info key (bind it where Gun Bonsai puts it in Customize Controls; the addon adds no binds of its own)
and pick an upgrade for that gun. The player bar fills from throws, the hook, the whip and the style share; when
it levels, the player nodes are offered.

The trees are climbed by using the tool: punch with the gloves, cut with the saber, throw the shield, crack the
whip, throw the grenade, fire the hook. A node is offered only once the glove, weapon or player holds its parent.

The menu is Options -> Radiant Silvergun Options -> **RSQ Gun Bonsai VR**; Gun Bonsai's own options page also
links to it at its bottom. To see every tree at once, Tuning and Debug -> **Debug: Add All** (every node of ours
at its cap, on the player and every weapon carried) or **Debug: Add Incremental** (one more level of each node
offered now; press again to climb). Console: `rsqgb_add_all`, `rsqgb_add_step`.

Recommended with RSQ Score: XP Source Style, or Gun Bonsai's own score-to-XP factor 1 with its damage-to-XP
factor 0 (both above 0 pays every kill twice; the console says so).

## Settings

Options -> Radiant Silvergun Options -> RSQ Gun Bonsai VR.

| Menu row | Default | What it does |
|---|---|---|
| Stock Gun Bonsai Upgrades | Silvergun | Silvergun: the pruned pool (Dark Harvest, the Leeches, Intuition, Juggler, Player Damage, Thorns out). All: every stock upgrade back. |
| Berserk Meter Gauge | On | The Berserk Meter's gauge, one per glove that has learned it. |
|   Gauge Animation | On | Its light: a band rising through the fill, a breathing edge, a glint when full. |
| XP Source | Damage | Damage / Style (RSQ Score's style points become XP) / Both. Style without RSQ Score acts as Damage. |
| ShieldSaw Gauge | Off | A third gauge, top centre, for the ShieldSaw on your shoulder. RSQ Score moves down to make room. |
| Kill Rewards | On | Bits of health, armour and ammo on a kill. |
| Kill Rewards Options | - | Its page, below. |
| Screen Skin | Mockup | Which screens draw Gun Bonsai: Gun Bonsai (its own) / Mockup / Hex Rail / Terminal. |
| Ammo And Health | On | With a skin: per-hand ammo, health, face and armour along the bottom (hides Brutal Doom's HUD under it). |

**Kill Rewards Options**

| Menu row | Default | What it does |
|---|---|---|
| Kill Rewards | On | The same switch. |
| Bits per Kill | Standard (1 per 10) | Few (1 per 20 health) / Standard / Many (1 per 5) / Custom (below). |
| Boss Fountain | x3 | Times as many bits for a boss. |
| What Drops | Custom | Even Mix / Mostly Health / Mostly Armour / Mostly Ammo / Custom (the sliders below). |
| Bits Vanish After | 7 s | Never / 7 s / 15 s / 30 s / 1 min. |
| Ammo Bits Give | Any Gun I Carry | The Gun in Hand / Any Gun I Carry. |
| Bits Fly to Me (m, 0 = off) | 0.0 | Bits inside this radius are pulled to you (the Magnet node raises it). |
| Drop Mode | By Health | By Health (the fountains) or Range (a random count). |
| Custom: Health per Bit | 10 | Custom amount: health per bit. |
| Drop Chance % | 50 | Each bit's chance, rolled once per bit; a boss's bits always drop. |
| Custom Mix: Health / Armour / Ammo | 15 / 20 / 65 | Custom weights, 0-100 each. |
| Ammo Type 1 Counts | On | Which of a gun's two ammo types count. |
| Ammo Type 2 Counts (clips) | Off | |
| Range: Fewest Bits / Most Bits | 1 / 3 | Range mode. |
| Range: Random Between | On | Range mode. |
| Debug Log | Off | One console line a kill. |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Force Base Strength | 0.00 | What an unlearned Force power does, as a share of the saber's own. 0: nothing until learned. |
| First Star After | 1 | Star Punch's banking, read by RSQ Melee. |
| Star Every | 2 | |
| Grapple XP | 1.0 | XP for what the hook does (bites, yanks, swinging, kills it was in on), times this. |
| Style XP Scale | 1.0 | XP per style point. |
| Style Player Share % | 10 | The extra share of style XP to the player bar. |
| HUD Inset | 0.04 | Fraction of each screen edge kept clear. |
| HUD Size | 1.00 | |
| Debug: Add All | - | Every node of ours at its cap. |
| Debug: Add Incremental | - | One more level of every node offered now. |

Not on the menu (console cvars): `bonsai_vr_dual_hud` (on), `bonsai_vr_hud_hand`, the per-hand HUD anchors
`bonsai_vr_hud_main_x/y/mirror` and `bonsai_vr_hud_off_x/y/mirror`, and `bonsai_vr_warn_binding` (on).

## Works with

- **RSQ Melee:** the gloves, the punch and the moves. Melee asks this addon for levels and numbers; the glove
  nodes ask Melee about the last punch. Without Melee no glove node and no Guard is offered.
- **RSQ Saber, RSQ ShieldSaw, RSQ Whip, RSQ Grenade, RSQ Grapple, RSQ Tactical Rig, RSQ SlowMo, RSQ
  LaserSight:** each reads its tree's levels from this addon by name and does the move itself. Without the addon
  each is as it was.
- **RSQ Score:** XP Source Style reads a kill's style points and combo chain; Score reads how far the ShieldSaw
  gauge reaches and moves down; Lucky Kill reads Score's big moments.
- **RSQ SlowMo:** Adrenaline charges its meter; Showdown, Time Dilation and the grenade's windows pulse it.
- **RSQ Grapple:** the hook's XP (bites, yanks, swinging, kills it was in on) is paid to the player bar.
- **RSQ Wheel and RSQ Gun Cards:** read a gun's level, XP and upgrades (RSQGB_Service).
- **RSQ Miniboss:** a miniboss counts as a boss for Kill Rewards while Miniboss's "Boss Kill Rewards" is on, and
  Knockdown and Executioner size it by its legendary health.
- **RSQ Gestures:** Ground Pound, Clear Out, Absorb and Release and Taunt are offered only with it loaded.
- **RSQ Accessibility:** Handedness swaps the two HUDs; Text Size grows the screens' text.
- **Brutal Doom:** with a skin and Ammo And Health on, Brutal Doom's HUD is hidden under the bottom row and put
  back when Screen Skin is Gun Bonsai.

## Load order

Right after Gun Bonsai 0.10.6 (after Brutal Doom, the monster packs and the other gameplay mods); the RSQ pk3s
whose trees it carries can go before or after it. Other Gun Bonsai patches that replace the same files clash with
this one.

## Known limits

- Gun Bonsai's upgrade toggle / tune menu still addresses one weapon.
- Both HUDs draw the player XP bar (it is in the frame art).
- Credit for a shot in flight across a save / load or a level change is dropped.
- Removing the addon with a skin on leaves Brutal Doom's HUD type changed: pick your HUD again in Brutal Doom's
  options.

## For other mods

`RSQ_MeleeUpgradeService` (by name): GetInt `level` (a node on a Weapon's record), `plevel` (a player node),
`unlocked` / `punlocked` (1 once learned), `weapon.level` / `weapon.xp`, `claim` (credit an actor to a weapon),
`credit.push` / `credit.pop` (bracket script damage for a weapon), `stagger`, `freeze` (with a shatter),
`knockdown`, `whip.mark`, `is.melee`, `ram`, `head.mps`, `force.start`; GetDouble `upgrade.num` (a node's number
at a level). A mod that spawns its own shot can also call `TFLV_VR_Attribution.Claim(shot, weapon)`.

`RSQGB_Service` (by name, read-only): GetInt `loaded`, `level`, `xp`, `xp.next`, `xp.permille`, `count`,
`hand`; GetString `upgrades` (`Name:level:max:Class:on:Colour|...`), `name`. objectArg the Weapon, or the pawn
with intArg 0 main / 1 off.

`RSQ_HudService` (ui): `shield.gauge.top`, `shield.gauge.h`, `shield.gauge.drop` (permille of screen height; -1
while the gauge is off).

Console: `bonsai-hands` prints each hand's record and the attribution counters.

## Credits

Gun Bonsai is by Rebecca "ToxicFrog" Kelly, MIT licensed. This is a derivative work under the same terms. The
patch and the series' upgrades: presidentkoopa, same terms. Gun Bonsai's MIT licence and the note on files
derived from it: `COPYING.md`.

Gloves, punch reader and sounds from SuperPunchOut (presidentkoopa); glove mesh and fit by Ermac (iAmErmac,
PunchOutVR / Virtual Punch Out); punch, star and knockdown sounds from Punch Out Doom (DerrickDavison) through
Virtual Punch Out; the count is the Super Punch-Out!! announcer, as SuperPunchOut ships it. Punch-Out!! is
Nintendo's. (The gloves, the punch reader and the punch and star sounds live in RSQ Melee, whose credits carry
these lines. Knockdown's sound and the count stay here.)

Kill Rewards: SoM's "Universal(ish?) Kill Rewards" v1.0 (the bits on a kill, their three orb sprites and the drop
rules), folded in with his permission ("Feel free to use anything in this mod for yourself"). Thank you, SoM.

The Berserk Meter's gauge is coldcite's Top HP Bars health bar ("Feel free to use this in your mods") stood on
end and recoloured red.

Screens designed by presidentkoopa. The gauge frame is Gun Bonsai's own HUD art; the screens write in Doom's own
IWAD fonts. `sprites/ui/hud.xcf` is Sungraphica's (see `COPYING.md`).

vr patch conceptualized by PresidentKoopa, authored with agentic ai.
