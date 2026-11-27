<p align="center"><img src="../design/readme_art/mods/gunbonsaioffhandvr_title.gif" alt="RSQ Gun Bonsai VR"></p>

# RSQ Gun Bonsai VR

An addon for Gun Bonsai (ToxicFrog's mod, where each weapon earns XP, levels up and picks upgrades). It makes Gun Bonsai work with a weapon in each hand: each hand's weapon has its own level, its own XP gauge on the HUD, and is paid XP only for the damage it did. It also draws Gun Bonsai's status screen and level-up choices as its own screens, adds an ammo and health row, and shows LegenDoom weapon powers in the same style. It has no upgrades of its own: every upgrade offered is Gun Bonsai's.

<a name="how-to-play"></a>
## How to play

"Main hand" and "off hand" are the engine's two weapon hands. "The info key" is whatever you have bound to Gun Bonsai's own command `bonsai-show-info`; that key comes from Gun Bonsai, this pk3 adds no key of its own to the Controls menu. On the two screens "menu up / down / left / right", "menu select" and "menu back" are the engine's menu keys, whatever your controller or keyboard sends for them; the code reads no controller button, grip, trigger or hand move directly.

| Do this | What happens | Needs |
|---|---|---|
| Hold a weapon in a hand | A gauge for that hand is drawn at the top of the view, the main hand's on the right, the off hand's on the left: the weapon's name, its level and XP, its XP bar, your player level and player XP bar. An empty hand has no gauge. The gauge's frame and bars cycle through colours all the time and the bars and text pulse in brightness | Dual HUD: On (default); Main HUD Colour Cycle and Off HUD Colour Cycle: On (default); GBOVR Menus and HUD: On (default) for the pulse |
| Hurt a monster with a weapon | That weapon gets XP: the damage times Gun Bonsai's damage-to-XP setting, times (log10 of the monster's starting health, minus 1) when that health is over 100. Damage past zero health pays nothing. Hurting yourself, a friendly monster or a thing that is no monster pays nothing | |
| Fire a bullet weapon from one hand | Every hit of that shot pays the weapon in the hand that fired it, even while the other hand fires in the same tic | |
| Fire a rocket or another projectile | The shot is tied to a weapon as it appears: the hand nearer to it (up to 3 points), the hand pointing its way (up to 2), the hand whose weapon is in its fire frames (2.5), the hand whose trigger is down (0.5); the higher total wins. Its blast and anything it spawns pay the same weapon | |
| Hit with a weapon that deals the blow itself, such as a saber cut | That weapon is paid, whichever hand holds it, and even if it is in neither hand | |
| Burn or poison a monster with Gun Bonsai's elemental upgrades from two weapons | Each tick of it pays both weapons, split by how much each one put on | |
| Switch the weapon in a hand | That hand's gauge follows. The upgrades of the weapon that left stop and the new weapon's start. A weapon held for the first time gets a new record at level 0 | |
| Take a hit | Your player upgrades and the upgrades on both hands' weapons all get to change the damage | |
| Fill a weapon's XP bar | A level waits for that weapon: Gun Bonsai's level-up flash and sound (when its settings have them) and its "level up ready" message. Nothing is chosen yet. If Gun Bonsai's "choices per gun level" is 0 or 1 the upgrade is chosen for you at once | |
| Press the info key while a weapon's level waits | That weapon's level-up screen opens: the weapon's name as the title and up to four cards, each one upgrade Gun Bonsai offers, with its description and NEW or the level it would go to. The main hand's weapon is served first, then the off hand's | GBOVR Menus and HUD: On (default) |
| On a level-up screen, menu left or up, menu right or down | The highlight moves to the card before or after, wrapping round. Page up and page down move it four cards | |
| On a level-up screen, menu select | The highlighted card is taken: the weapon gains the level and that upgrade, the next level costs more, and you gain 1 player XP. The screen closes | |
| On a level-up screen, press 1, 2, 3 or 4 on a keyboard | The card with that number on the page shown is taken | |
| On a level-up screen, menu back | The level is refused: no upgrade, and Gun Bonsai takes the XP of that level (a weapon's whole level; half of a player level) | |
| Gain enough player XP (Gun Bonsai's "gun levels per player level") | A player level waits: a longer flash, the sound and a message. With Gun Bonsai's "choices per player level" at 0 or 1 the upgrade is chosen for you | |
| Press the info key while a player level waits and no weapon level does | The player level-up screen opens, titled LEVEL and the number, with cards from Gun Bonsai's player upgrades. It is worked the same way | GBOVR Menus and HUD: On (default) |
| Press the info key with no level waiting | The STATUS screen opens. Left: PLAYER STATUS with your level, XP and your upgrades. Middle: a card for each hand's weapon with its picture, name, LV and XP. Right: each weapon's WEAPON STATUS, the list of its upgrades. Bottom: DESCRIPTION. The cursor starts on the main hand's weapon the first time and, with a weapon in each hand, on the other hand's weapon each time after | GBOVR Menus and HUD: On (default); a weapon in at least one hand |
| On the STATUS screen, menu up or down | The cursor walks every row and wraps: the main hand's weapon, its upgrades, the off hand's weapon, its upgrades, then your player upgrades. DESCRIPTION shows the upgrade's text and numbers, or the weapon's name and class | |
| On the STATUS screen with the cursor on a weapon, menu right or menu select | The cursor jumps to that weapon's first upgrade. Menu left jumps to your first player upgrade. With no upgrades there, nothing | |
| On the STATUS screen with the cursor on an upgrade, menu select | That upgrade is switched off, or back on. An upgrade that is off is grey and marked [OFF] | |
| On the STATUS screen with the cursor on an upgrade, menu left or right | The level that upgrade works at goes down or up by one, never under 1 and never over its top level. Shown as level/top. Nothing if the upgrade is off | |
| On the STATUS screen, press the info key again on a keyboard (a letter or digit key) | The cursor jumps to the other hand's weapon. With one weapon, the screen closes | |
| Look at the bottom of the view | Each hand's ammo on that hand's side (the reserve, and the magazine too when the weapon has two ammo pools), Doom's face in the middle, health to its left and armour to its right | GBOVR Menus and HUD: On (default); Ammo and Health Row: On (default) |
| Pick up a LegenDoom weapon power | A card shows for about 3 seconds (105 tics) under the gauges: the power's name flashing between two looks every 10 tics, its rarity and the gun it is on, LegenDoom's description and icon. LegenDoom's own pickup screen is taken off while the card is up. The card then folds, in 14 tics, into the row under that gun's gauge | LegenDoom; LegenDoom Card: On (default) |
| Hold a gun that carries a LegenDoom power | A row under that hand's gauge: the power's icon and name in its rarity colour. While the power's timed buff runs, a line under the name drains, and Murderous shows X3. The STATUS screen shows the same power as LEGENDARY POWER under that weapon's upgrades | LegenDoom; LegenDoom Gauge Row: On (default) |
| Kill with something no weapon owns: an object thrown with RSQ Distance Grab or the blast it set off, or a thrown gun that has no record | The XP goes to a player pool. Every time the pool reaches Gun Bonsai's base level cost you gain 1 player XP | RSQ Distance Grab, or RSQ Tactical Rig for the thrown gun |
| Throw a gun you have held at a monster (RSQ Tactical Rig) | The hit pays that gun's own record | RSQ Tactical Rig |
| Hurt a monster with the Force (RSQ Saber) | The Force hand's record is paid; without a Force hand, the main saber's. The Force hand is never picked by the hand guess above | RSQ Saber |
| Hold Brutal Doom 22 VR's axe in either hand, or both | Both hands' axes are one record: one level, one XP, one set of upgrades. It is kept when every axe is thrown | BD22 VR Reloaded |
| Score points while Gun Bonsai's score-to-XP factor is above 0 | The rise in score becomes XP, shared among the kills of the last 2 seconds by each victim's starting health; each share goes to the weapon that made that kill, a throw's share to the player pool | Gun Bonsai's score-to-XP factor above 0 (Gun Bonsai's own option) |
| Type `bonsai-hands` in the console | Prints each hand's weapon, level, XP and upgrade count, and how often the mod knew or guessed which weapon to pay. It has no key and no menu row | |
| Hold weapons with Dual HUD off | One gauge at Gun Bonsai's own HUD position, for the main hand's weapon; for the other hand's when the main hand is empty | Dual HUD: Off (default On); Single HUD Follows: Main Hand (default) |
| The same, with Single HUD Follows changed | The one gauge shows the off hand's weapon, or the weapon of the hand that last earned XP | Dual HUD: Off (default On); Single HUD Follows: Off Hand or Last XP (default Main Hand) |
| Press the info key with GBOVR Menus and HUD off | Gun Bonsai's own list menus open in place of this mod's screens. Its status menu shows one hand's weapon, says Mainhand or Offhand and "press again for other hand"; each press of the info key from play steps to the other hand. No ammo and health row is drawn and the bars do not pulse | GBOVR Menus and HUD: Off (default On) |
| Hold a weapon with that hand's Colour Cycle off | That hand's gauge keeps Gun Bonsai's own colours, and cycles only while a level waits | Main HUD Colour Cycle or Off HUD Colour Cycle: Off (default On) |
| Pick up a LegenDoom power with LegenDoom Card off | LegenDoom's own pickup screen shows; no card | LegenDoom Card: Off (default On) |
| Hold a LegenDoom gun with LegenDoom Gauge Row off | No row under the gauge | LegenDoom Gauge Row: Off (default On) |
| Play left-handed | The two gauges swap sides (the main hand's on the left) and so do the ammo counters | QuestZDoom's own left-handed control scheme |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > GunBonsaiOptions

| Option | Default | What it does |
|---|---|---|
| RSQ Gun Bonsai VR | (page) |  |

<details><summary>RSQ Gun Bonsai VR (9 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **HUD** | | |
| GBOVR Menus and HUD | On | The new status screens, bottom row and breathing XP bars; off uses Gun Bonsai's own. |
| Ammo and Health Row | On | Shows the ammo and health row at the bottom of the HUD. |
| Gauge Size | 1.5 (0.5 to 2) | The size of the ammo and health row. |
| Dual HUD | On | Draws a HUD for each hand instead of a single one. |
| Single HUD Follows | Main Hand | With Dual HUD off, which hand the single HUD follows: main, off, or the last to earn XP. |
| Main HUD Colour Cycle | On | The main hand's HUD cycles its colours. |
| Off HUD Colour Cycle | On | The off hand's HUD cycles its colours. |
| More Settings | (page) | Every other setting: HUD position and colour tuning. |
| Reset All | (button) | Puts every RSQ Gun Bonsai VR setting back to its default. |

</details>

<details><summary>RSQ Gun Bonsai Vr: More Settings (15 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **LegenDoom** | | |
| LegenDoom Card | On | LegenDoom's pickup card in this HUD's style; off brings LegenDoom's own back. |
| LegenDoom Gauge Row | On | LegenDoom's gauge row in this HUD's style; off brings LegenDoom's own back. |
| HUD Inset | 0.04 (0 to 0.25) | How far the HUD sits in from the edge of the view. |
| **HUD Position** | | |
| Main HUD Across | 0.99 (0 to 1) | Where the main hand's HUD sits across the view (Dual HUD only). |
| Main HUD Down | 0.02 (0 to 1) | Where the main hand's HUD sits down the view (Dual HUD only). |
| Main HUD Mirror | Both | Mirrors the main hand's HUD horizontally, vertically or both. |
| Off HUD Across | 0.01 (0 to 1) | Where the off hand's HUD sits across the view (Dual HUD only). |
| Off HUD Down | 0.02 (0 to 1) | Where the off hand's HUD sits down the view (Dual HUD only). |
| Off HUD Mirror | Vertical | Mirrors the off hand's HUD horizontally, vertically or both. |
| **HUD Colour Cycle** | | |
| Main Cycle Speed | 1 (0 to 3) | How fast the main HUD's colours cycle (also the level-up cycle). |
| Main Cycle Spread | 1 (0 to 3) | How widely the main HUD's colours spread across it. |
| Main Cycle Intensity | 1 (0 to 2) | How strong the main HUD's colour cycle is. |
| Off Cycle Speed | 1 (0 to 3) | How fast the off HUD's colours cycle (also the level-up cycle). |
| Off Cycle Spread | 1 (0 to 3) | How widely the off HUD's colours spread across it. |
| Off Cycle Intensity | 1 (0 to 2) | How strong the off HUD's colour cycle is. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| Gun Bonsai (ToxicFrog) | Required, and loaded before this pk3. Ten of its files are replaced by this pk3's copies at the same paths (the event handler, the HUD, the per-player stats, the weapon record and its type guess, the debug commands, the status menu, the burn base class, Juggler and Rapid Fire). Its three menus `GunBonsaiStatusDisplay`, `GunBonsaiWeaponLevelUpMenu` and `GunBonsaiPlayerLevelUpMenu` are pointed at this mod's screens. A link to this mod's options is added at the foot of Gun Bonsai's own options page. Gun Bonsai's own upgrades, costs and settings are unchanged; Juggler and Rapid Fire work on the off hand's weapon too |
| This mod's service `RSQ_MeleeUpgradeService` | Answers, to any mod that asks by name: `loaded` 0 always; `present` 1; `level`, `plevel`, `unlocked`, `punlocked` 0 always; `weapon.level` and `weapon.xp` (a weapon's level, and its XP in thousandths of the next level; -1 with no record); `claim` (an actor whose master is a weapon is paid to that weapon); `credit.push` and `credit.pop` (damage by the player's own body between the two is paid to that weapon); `stagger` (a monster held in its pain frames, at most 350 tics); `freeze` (frozen at most 700 tics; a boss slowed instead; with a number over 1 the next hit of 20 or more does that many times its damage); `knockdown` (down for a count of at most 10, not a boss); `whip.mark` (that player's next hit on the monster within 70 tics is multiplied); `is.melee` (whether Gun Bonsai counts a weapon class the player has used as melee); `kr.luckyfx`; text `kr.lucky`; number `force.start` (0) and `upgrade.num` (0). `ram` and `head.mps` are not answered |
| This mod's service `RSQGB_Service` | Answers for a weapon, or for a player and a hand: `loaded` 1, `level`, `xp`, `xp.next`, `xp.permille`, `count` (how many upgrades), `hand` (0 main, 1 off, -1 neither), `player.level`; text `upgrades` (each as Name:level:max:Class:on:Colour, joined by a bar) and `name`. -1 or empty text when the weapon has no record |
| This mod's service `RSQ_HudService` | Answers `gauges.top` and `gauges.bottom`: where the hand gauges begin and end, in thousandths of the screen's height; -1 while no gauge is drawn |
| This mod's service `RSQTHP_MarkerGBVR` | Answers `stunned` 1 for a monster this mod is holding staggered or down |
| RSQ Melee | Its gloves' helper actors are paid to the glove (`claim`). Its staggers are done by this mod (`stagger`). It asks `is.melee`. It asks `loaded`, gets 0, and so plays every move from its own menu rows; none of its rows is locked. The STATUS screen uses its glove icons for a glove or bare fist with no picture |
| RSQ Saber | Force damage is paid as in How to play (found by the names `UBQS_Force`, `UBQS_ForceHand`, `UBQS_Saber`). It asks `loaded`, gets 0, and plays as without this mod |
| RSQ ShieldSaw | Its bash, grind and rev block are paid to the ShieldSaw (`credit.push`, `credit.pop`) and its returned bullet too (`claim`). It asks `ram` on every bash and gets no answer. It asks `loaded`, gets 0, and plays as without this mod |
| RSQ Whip | Its damage is paid to the whip (`credit.push`, `credit.pop`). Its Long Thong reads 0. The STATUS screen has a picture for the whip |
| RSQ Grenade | Thrown grenades, bomblets and type blasts are paid to the grenade weapon (`claim`). It asks `loaded`, gets 0: every grenade type is owned and its own freeze and stagger are used |
| RSQ Distance Grab | A thrown object's hit within 105 tics of leaving the hand, and the blast of anything a throw set off, pay the player pool and no weapon (`RSQDG_ThrowService`: `throw.by`, `throw.blast`, `throw.age`) |
| RSQ Tactical Rig | A thrown gun (a weapon nobody owns) pays its own record, or the player pool when it has none. Its Gun Toss, Boomerang Gun, Smoker and Chain Smoker read 0 |
| RSQ Grapple | This mod asks `RSQGR_Service` for `hook.dealing` to send the hook's damage to the player pool. The Grapple does not answer that request, so its kick is paid by the ordinary rules above |
| RSQ Score | Asks `RSQ_HudService` to put its line between or under the gauges. This mod reads its score, progress, lives and rewards every frame and draws none of them. A `rs_score_hide` saved by an older build of this mod is put back once |
| RSQ VisualRewards | Hears Gun Bonsai's `bonsai-level-up` (this mod's copies send it) for its LEVEL UP words; asks `RSQGB_Service` for a hand's level and the weapon's name; asks `RSQTHP_MarkerGBVR`. Its Kill Rewards ask `plevel` and `level` and get 0. The LegenDoom card's title uses its QVW letters; without them, Doom's small font |
| RSQ Wheel | Reads a weapon's level, XP and upgrade list from `RSQGB_Service`; its watch card reads `weapon.level` and `weapon.xp`. The STATUS screen uses its whip and fist icons when a weapon has no picture |
| RSQ Gun Cards | Reads a weapon's level, XP and upgrade list from `RSQGB_Service` |
| RSQ Miniboss | Reads a hand's `level`, `xp` and `xp.next` from `RSQGB_Service`. A monster carrying its `RSQMB_Ward` counts as a boss for `freeze` and `knockdown` |
| RSQ Glow In The Dark | Reads `level`, `xp.permille` and `name` from `RSQGB_Service` for its level-up wave |
| RSQ SlowMo, RSQ LaserSight | They ask `loaded`, get 0, and play as without this mod. This mod's own calls to SlowMo (`RSQSM_Service` `active`, `adrenaline.add`, the `rsm_pulse` event) are in code nothing calls |
| LegenDoom, LegenDoom Lite | The card and the row (How to play). Powers are found as items named `LD<Slot>Effect_<Power>`; names, descriptions and icons are LegenDoom's. LegenDoom's pickup messages (ids 12300 to 12303) are removed while the card shows. The two LegenDoom rows on the menu are greyed without it |
| BD22 VR Reloaded | A shot fired as one of its rounds (`RSQ_PlayerRound`) is tied to the hand that pulled the trigger in that tic, and the round's hit pays that gun. Its axe is one record in both hands. Its LegenDoom mode names each gun's slot (`RSLDP_Service` `ld_prefix`). Its `rsq_hud_nohp` setting removes the health and armour numbers from the bottom row; the face stays |
| Brutal Doom | While the ammo and health row is drawn, its `bd_sbartype` is set to 5 so its own HUD draws nothing; the old value is put back when the row or GBOVR Menus and HUD is turned off. Its fist sprite is used as the bare fist's picture |

## Limits

- This mod adds no upgrade. No file in the pk3 defines an upgrade class: every choice on a level-up screen is Gun Bonsai's own.
- No other mod's menu row is locked or unlocked by this mod. Its service answers `loaded` 0 and every upgrade level 0, whatever was learned in an older save.
- The pk3 does not include Gun Bonsai. Its code builds on Gun Bonsai's classes, so Gun Bonsai must be loaded, and before it.
- No controller button, grip, trigger, stick or hand move is read. Everything goes through the info key and the engine's menu keys.
- A level-up screen cannot be left without choosing or refusing: menu back refuses the level and costs its XP.
- The number keys take only cards 1 to 4 of the page shown.
- With no weapon in either hand the STATUS screen closes as soon as it opens, so player upgrades cannot be seen or changed then.
- Pressing the info key again while the STATUS screen is open only works from a keyboard key that is one letter or digit. Both weapons are on the screen anyway; use menu up and down.
- The gauges, the ammo and health row and the LegenDoom card and row are not drawn over any menu, on the automap, or with the HUD off (screen size above 11).
- A waiting level does not change the gauge's colours while that hand's Colour Cycle is on (default): the gauge cycles all the time.
- Gauge Size sizes the ammo and health row only. The XP gauges follow Gun Bonsai's own HUD size.
- The position sliders move a gauge only with Dual HUD on; with it off the one gauge is placed by Gun Bonsai's own HUD settings.
- When a shot cannot be tied to a weapon and both hands hold one, the weapon is guessed. `bonsai-hands` counts how often.
- Up to 96 shots and blasts are remembered at once, each for at most a minute; when more are alive the oldest is forgotten and its hits are guessed.
- A new map or a loaded game forgets every shot in flight: its hits are guessed.
- Removing this pk3 while the ammo and health row is on leaves Brutal Doom's `bd_sbartype` at 5.
- LegenDoom's own buff list at the top of the view is not changed.
- The upgrade names in this pk3's text lump (197 of them, from Haymaker to Double Hook) belong to upgrades that are no longer in it.

## Credits

The licence of Gun Bonsai, and of the files here that derive from it, is in **COPYING.md**.

- **Rebecca "ToxicFrog" Kelly:** Gun Bonsai (MIT). The ten shadowed files are derived from Gun Bonsai 0.10.6;
  its licence is in COPYING.md. Gun Bonsai's HUD art (Sungraphica, CC-BY-4.0, with Craneo), item and effect sprites
  (Willibab), Freedoom sprites and sounds (GameSupplyGuy) stay in Gun Bonsai's pk3 and are drawn from there.
- **presidentkoopa:** this pack, its trees and screens (from his mockups), and SuperPunchOut, whose sounds it uses:
  the hit and the knock from Punch Out Doom / Virtual Punch Out, and the Super Punch-Out!! announcer's count
  (Punch-Out!! is Nintendo's). The HUD Colour Cycle's tuning is from his earlier fork.
- **coldcite:** the Top HP Bars bar art the Berserk gauge is made from ("feel free to use this in your mods").
- **RSQ Melee's** bursts (kiddolink's "VFX Hit Impact", bought for this series) and sparks are played by name, not
  shipped here.
- **id Software / GZDoom:** stock sounds played by name (the item pickup, the ice break).
- **QuestZDoom** (Emawind and Team Beef): the engine and its two-hand weapon API.

---
Written from the code at commit 7bd62b727, 2026-11-27.
