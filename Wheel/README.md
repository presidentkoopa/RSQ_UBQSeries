<p align="center"><img src="../design/readme_art/mods/wheel_title.gif" alt="RSQ Wheel"></p>

# RSQ Wheel

A ring of cards that opens in the air in front of your hand, one card for each weapon slot or weapon you carry. Point a hand at a card and take it, and that gun is in that hand. A data sheet in the middle of the ring tells you about the gun you are pointing at.

<a name="how-to-play"></a>
## How to play

| Do this | What happens | Needs |
|---|---|---|
| Press Open Wheel (RSQoopaControls: right grip + right stick click) | The ring opens in front of your main hand and stays up. Letting go of the key takes nothing | |
| Pull a trigger on a card that says "N WEAPONS" | That slot opens: the ring now holds that slot's weapons and a BACK card, and stays up. Taking BACK returns to the slots | Ring Layout: Always Group (default) |
| Press Open Wheel while the ring is up | The ring closes. With a slot open it goes back to the slots instead | |
| Press Open Wheel twice within about a third of a second | The ring closes and the hand that last took a gun from it gets back the gun it held before | Double Tap above 0 (default 10 tics) |
| Open the ring, any way | Time stops until the ring closes | Time While Open: Frozen (default) |
| With the ring up, push the stick to walk or turn, or pull a trigger off the cards | Nothing: the Wheel freezes the player until the ring closes. A stick turn (snap or smooth) is handed back the tic it lands, so a snap can show for a frame | Hold Still While Open: On (default) for walking and turning |
| With the ring up, press Use, Toss Grenade or Quick Grenade | Nothing: the Wheel takes the press, so no door opens and no grenade is thrown | |
| Point either hand at a card | A beam runs from that hand. The card under it lights, grows, steps toward you and ticks in that hand. The other hand takes over the beam when it is on a card and the first is not | Either Hand: On (default) |
| Pull the trigger of either hand while a card is lit | The lit card's gun goes into the pointing hand and the ring closes. No shot is fired | |
| Press the off hand's alt fire on a card | That gun goes into the off hand and the ring stays up. It goes by the off hand's own beam, wherever the other hand points | |
| Press the main hand's alt fire on a card | Without RSQ Tactical Rig: a dull tick in the main hand, nothing else | |
| Take the fist card | The hand that took it gets its own fist, given to you if you had none | |
| Take a gun with no ammo anywhere | A dry click, the hand keeps the gun it had, and the ring closes | |
| Take the gun your other hand is holding (with Brutal Doom 22 VR, the other hand's own version of it counts) | The two hands trade guns, each in that hand's version; an empty hand hands over its fist (a spare numbered copy is taken instead, if you own one) | |
| Pull a trigger or alt fire while pointing at the data sheet | The press is swallowed and nothing happens | Data Sheet: On (default) |
| Leave the ring up with no card lit for four seconds | It fades for the last 25 tics with one tick in the hand, then folds away | Folds After (default 140 tics) |
| Turn more than 45 degrees away from the open ring | The ring swings round to sit ahead of you again | Ring Follows Past above 0 (default 45) |
| Press a key bound to next weapon or previous weapon | That hand steps to its next gun in slot order that has ammo, ring up or down | Weapon Wheel: On (default) |
| With the ring closed, point a hand at a weapon on the floor within 1.7 metres and hold for half a second | A data sheet for that weapon stands at the pointing hand until you point away | Point at a Gun: On (default) |
| Die, or leave the level | The ring closes at once | |
| Rest the beam on a card with "+N" in its corner for a fifth of a second, or press Use on it from a distance | A fan of that slot's other weapons opens out of the card | Ring Layout: When Crowded, with more weapons than Own Cards Up To |
| Hold the trigger on a fan card, move to another place in the fan, let go | The gun takes that place in its slot, and the order is saved. Let go without moving and the gun is taken | Ring Layout: When Crowded, with more weapons than Own Cards Up To |
| Press a key bound to next weapon or previous weapon | Guns that have a holster are skipped, and the cards of the guns it does reach wear a gold running light | Skip Holstered Guns: On (default Off) |
| With the ring closed, bring a forearm up across your chest, wrist in front of your face and hand pointing across your body, and hold it | A card stands over that wrist with the gun's name, rounds, and kills and hits | Wrist Card: On (default Off) |
| Point the other hand at a different gun's card | The data sheet turns into the two guns side by side | Two Hands Compare: On (default Off) |
| Twist the wrist of the hand the ring opened on | The cards turn round the ring | Wrist Roll Spin above 0 (default 0) |
| Open the ring with Opens On set to Off Hand | The ring opens in front of the off hand | Opens On: Off Hand (default Main Hand) |
| Point with the hand that did not open the ring | Nothing: only the hand the ring opened on points, and the gun goes to that hand | Either Hand: Off (default On) |
| Open the ring with Time While Open on Slow | Time slows until the ring closes. Without RSQ SlowMo loaded it stops instead | Time While Open: Slow (default Frozen), RSQ SlowMo |
| Open the ring with Time While Open on Normal | Time runs on | Time While Open: Normal (default Frozen) |
| Start a map | The ring opens by itself | Open at Level Start: On (default Off) |
| Type wr_toggle_any, wr_toggle_main, wr_toggle_off or wr_toggle in the console | The ring opens, or closes if it is up. No key is bound to these | |

## Keys

<!-- GEN:keys -->
Options > Customize Controls > RSQ Wheel

| Key | Default bind | Command |
|---|---|---|
| Open Wheel | LThumb | `+wr_wheel` |
<!-- /GEN:keys -->

LThumb is the Wheel's own default bind (`KEYCONF:35`). RSQoopaControls (RSQ Controls) puts Open Wheel on right grip +
right stick click (Tab).

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Wheel

| Option | Default | What it does |
|---|---|---|
| Weapon Wheel | On | Turns the weapon wheel on or off. |
| Open Wheel | (key) | The key that opens and closes the wheel. Choose a card with the trigger. |
| Either Hand | On | Either hand can point at a card and the gun goes into that hand; off, only the hand that opened it picks. |
| Ring Layout | Always Group | Every gun its own card, a card per slot only when crowded, or always a card per slot that opens to its guns. |
| Skip Holstered Guns | Off | Next and previous weapon skip guns that have a holster; the guns they do reach get a gold light on their card. |
| Wheel Size | 1 (0.3 to 3) | Size of the whole wheel: distance, cards and reach together. |
| **Time** | | |
| Time While Open | Frozen | What time does while the wheel is open: runs, slows, or stops. Slow uses RSQ SlowMo; without it, time stops. |
| **Look** | | |
| Palette | Standard | The wheel's colour scheme. |
| Card Look | By Gun | By Gun colours each card in its gun's colour with lit stone and halos; Classic is the ring as it was. |
| Gun Models | On | Each card shows the gun's turning voxel model instead of its icon. |
| Data Sheet | On | A data sheet with the hovered gun's stats opens beside the wheel. |
| **Feel** | | |
| Sound | On | Clicks on hover, expand, pick and close. |
| Rumble | 1 (0 to 2) | Strength of the controller rumble (QuestZDoom's own haptics switch still overrules it). |
| Test and Debug | (page) | Opens the rarer switches, every raw number and the debug log. |
| Reset All | (button) | Puts every RSQ Wheel setting on both pages back to its default. |

<details><summary>RSQ Wheel: Test And Debug (76 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Picking** | | |
| Opens On | Main Hand | Which hand the Open Wheel key opens the ring in front of. |
| Own Cards Up To | 10 (0 to 99) | With When Crowded, up to this many weapons each get their own card; past it, one card per slot. |
| Keep Out of Walls | On | Where the ring would open into a wall it slides away, steps toward you, or shrinks to fit. |
| Two Hands Compare | Off | A different gun's card under your other hand turns the sheet into a side by side comparison. |
| Open on Your Gun | Off | The ring opens with your gun's card under your hand. |
| Wrist Card | Off | Bring a forearm up across your chest as if checking a watch, and that hand's gun shows its card. |
| Open at Level Start | Off | The wheel opens at the start of every map (for testing). |
| Close Ends Slow Time | Off | With Time While Open on Slow: closing the wheel also ends slow time that something else started. |
| Hold Still While Open | On | No moving or stick turning in the game while the wheel is up (walking and looking round in the room still work). |
| Gun Weight Feel | 1 (0 to 1) | How much each card's rumble tick is shaped by the gun's weight. |
| Hold to Pick (tics) | 9 (3 to 35) | Ticks a pick must be held before it counts. |
| Double Tap (tics) | 10 (0 to 20) | A second tap within this many tics closes the wheel and puts your last gun back (0 is off). |
| Ring Follows Past (deg) | 45 (0 to 120) | Turn more than this far away from the ring and it swings round ahead of you again (0 is never). |
| Folds After (tics) | 140 (35 to 700) | Tics the wheel stays up with nothing hovered before it folds away. |
| Fold Warning (tics) | 25 (0 to 105) | Tics of warning before the wheel folds away (0 is no warning). |
| **Look** | | |
| Ring Plates | Ermac Style | The ring's plates: its own Ermac style or the status bar's stone. |
| Web View | Marine | The holster web shows the marine or the Tactical Rig's mirror of you. |
| Ammo Counts | On | Shows each weapon's ammo under its name. |
| Ammo Readout | LED | How the ammo count is drawn. |
| Rarity Colours | On | Cards are coloured by the weapon's rarity tier. |
| Mark Guns You Hold | On | Marks the cards of guns you are already holding. |
| Slot Numbers | On | Shows each card's slot number. |
| Cards Face You | On | Cards turn to face you, making the ring a shallow bowl. |
| Crowded Slot Style | Fan | A crowded slot unfolds as a fan or as stars round the card. |
| Hover Halo Breathes | Off | The hovered card's halo breathes. |
| Edge Sweep | Off | A spark runs round each card's edge. |
| Flash on Pick | On | The ring flashes when a fan opens or a pick is confirmed. |
| Spark Colour | Slot Colour | Colour of the burst off the card you take. |
| Hover Light | On | The hovered card lights the room with one light. |
| Background Stars | 0 (0 to 200) | How many quiet stars twinkle behind the ring. |
| **Data Sheet** | | |
| Weapon Stats | On | The data sheet shows the weapon's stats. |
| Track Kills and Accuracy | On | Counts kills and accuracy per weapon as you play. |
| Level Kills | Off | Adds a row with this level's kills and accuracy. |
| Gun Bonsai Rows | On | Shows each gun's Gun Bonsai level and upgrades on the sheet. |
| Point at a Gun | On | Point at a gun on the floor and the sheet shows it against what that hand holds. |
| Inspect Within (m) | 1.7 (0.5 to 10) | Only a gun this close shows its card when you point at it. |
| Compare With Yours | Off | The inspect card shows the difference from your own gun. |
| **Other Mods** | | |
| LegenDoom Rarity | On | Reads LegenDoom's weapon rarity onto the cards. |
| LegenDoom Effects | On | Shows a LegenDoom weapon's effects row on the sheet. |
| **Ring** | | |
| Ring Distance Ahead | 34 (5 to 120) | How far ahead of you the ring opens. |
| Ring Radius | 5 (1 to 40) | Radius of the ring. |
| Height Above Hand | 2 (-8 to 12) | How high above your hand the ring sits. |
| Lean Toward You | 12 (-30 to 30) | Leans the tops of the cards toward you. |
| Wrist Roll Spin | 0 (0 to 1) | How much wrist roll spins the ring (0 ignores it). |
| Stick Deadzone | 0.2 (0.05 to 0.9) | Thumbstick deadzone for picking with the stick. |
| **Cards** | | |
| Card Width | 4.2 (1 to 12) | Width of a card. |
| Card Height | 3 (1 to 12) | Height of a card. |
| Hover Step Out | 1.5 (0 to 6) | How far the hovered card steps toward you. |
| Hover Grow | 0.06 (0 to 0.5) | How much bigger the hovered card grows. |
| Others Fade To | 0.55 (0.05 to 1) | How far the other cards fade once one is hovered. |
| Cards Grow In (tics) | 6 (0 to 20) | Tics the cards take to grow out of your wrist. |
| Card Shadow | 0.32 (0 to 1) | Strength of the shadow behind each card. |
| Shadow Offset | 0.35 (0 to 1.5) | How far the card shadow is offset. |
| Idle Breathing | 0.35 (0 to 2) | How much the ring rises and falls while it sits there. |
| Breathing Speed | 1.7 (0.2 to 6) | Speed of the idle breathing. |
| Low Ammo Below (share) | 0.25 (0 to 0.9) | A weapon below this share of its ammo counts as low. |
| Low Ammo Pulse | 0.35 (0 to 1) | Strength of the low ammo pulse. |
| Model Turn Speed | 1.5 (0 to 6) | How fast the gun model turns on its card (0 holds it still). |
| Model Size | 0.16 (0.02 to 1) | Size of the gun model on its card. |
| Model Stand Off | 3 (0 to 12) | How far the gun model stands off its card. |
| Fan Close Grace (tics) | 6 (0 to 20) | Tics a fan stays open after your hand strays off it. |
| Star Line Stagger (tics) | 2 (0 to 12) | Tics between each line of a constellation drawing in. |
| Star Brightness | 0.5 (0 to 1) | Peak brightness of the background stars. |
| Light Size | 44 (8 to 160) | Size of the hover light. |
| Light Grace (tics) | 3 (0 to 12) | Tics the hover light holds between cards. |
| Sparks | 18 (0 to 80) | Particles in the burst off a card you take (0 is off). |
| Spark Speed | 1.4 (0.2 to 4) | Speed of the spark burst. |
| Volume | 0.65 (0 to 1) | Volume of the wheel's sounds. |
| Idle Shimmer | 0 (0 to 1) | Strength of the cards' idle shimmer. |
| Taken Card Spin (deg) | 360 (-720 to 720) | Degrees the taken card spins as the ring folds away. |
| **Data Sheet** | | |
| Data Sheet Size | 1 (0.5 to 4) | Size of the data sheet, in card widths. |
| Inspect Rest (tics) | 18 (0 to 70) | Tics you must point at a gun on the floor before its card shows. |
| Wrist Card Hold (tics) | 8 (2 to 30) | Tics the wrist card pose must be held. |
| Wrist Card Size | 0.6 (0.5 to 2) | Size of the wrist card. |
| Palette by Name | "Standard" | A palette or font set added by another pk3, typed by its name. |
| Debug Log | Off | Prints diagnostics to the console when the wheel opens. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ SlowMo | With Time While Open on Slow, opening the ring asks it to slow time and closing the ring ends that. Slow time that was already running is left running unless Close Ends Slow Time is on |
| RSQ Tactical Rig | The sheet gains a HOLSTER row. Main hand alt fire on a card opens the holster web: trigger on a ring assigns the gun to that holster, trigger on Clear unassigns it. Web View: Mirror shows the Rig's mirror. A holster draw right after a next or previous press wins over the Wheel's pick |
| RSQ Gun Bonsai VR | The sheet shows the gun's Gun Bonsai level, progress and up to four upgrades (Gun Bonsai Rows) |
| RSQ Gun Cards | With Card Look: By Gun, cards take Gun Cards' Card Colour setting. The sheet shows Gun Cards' weapon condition. The Wheel's own wrist card stands down while Gun Cards' watch card is on |
| RSQ Laser Sight | Nothing for pointing: with the ring up every hand points from the hand itself, never along Laser Sight's beam, and the ring draws its own beam there. Laser Sight's beam still shows on a hand holding a laser gun |
| RSQ Grenade | The grenade's card opens a fan of the other grenade kinds you own; taking one sets that kind. The grenade always goes to the main hand |
| RSQ ShieldSaw | The shield always goes to the off hand, whichever hand picks it, and is drawn by ShieldSaw itself. Its card wears the Wheel's shield icon or ShieldSaw's own model. On the holster assignment screen its card can be given only the off shoulder's ring (with RSQ Tactical Rig: the shield is then mounted there); any other ring gives a dull tick. Clear un-mounts it |
| RSQ Saber | The saber always goes to the main hand. Its card wears the Wheel's saber icon or the saber's own model; the Force hand's card wears the Wheel's icon |
| RSQ Whip | The whip always goes to the main hand. Its card wears the Wheel's whip icon or the whip's own model |
| RSQ Melee | The gloves share the one fist card, and a hand that owns its glove gets the glove from it. The card shows Melee's glove icon or its hand model |
| RSQ FnF | The flare and the flashlight cards wear the Wheel's icons |
| RSQ Score | The numbers on the holster web's rings are drawn in Score's combo font |
| BD22 VR Reloaded | A gun and its off hand version share one card; the off hand takes the off hand version. The off hand's fist is its RSQ_Hands. Pickup models it lends through MODELDEF are measured for the cards |
| Brutal Doom | Its fist joins the fist card. The dry click is Brutal Doom's own. Its head hits are counted and the sheet gains a HEADSHOTS row |
| RS_Headshots | Its headshot markers are counted and the sheet gains a HEADSHOTS row |
| LegenDoom | A legendary gun's card takes its rarity colour (Rarity Colours, LegenDoom Rarity). The sheet shows its rarity, its legendary name and what its effect does (LegenDoom Effects) |
| LegenDoom x BD22 VR patch | BD22 VR guns that stand in for LegenDoom weapons are read as those weapons |
| A weapon pack with a GunModeService (GNRC Reloaded) | The sheet shows the gun's fire mode |
| ModelSwapper | The sheet names the model the gun in a hand wears |
| RS_Main (its tier colour service) | Cards and the sheet take the weapon's tier colour (Rarity Colours) |
| DoomRL Arsenal, Doomablo, Pandemonia, Anarchy, Insurrection, Guncaster, MetaDoom, BorderDoom, DOOM Infinite, Combined Arms, Final Doomer, Lithium | Nothing. Their readers are parked: each answers "off" unless wr_unpark_mods is set to 1 in the console, whatever its own switch says |

## Limits

- The ring does not open while you are dead, or when it has no card to show.
- While the ring is up the Wheel sets the engine's total freeze on the player: no walking or firing until it closes. QuestZDoom turns the player for the turn stick before any mod sees it, and its freeze no longer stops turning, so the Wheel hands a stick turn back the tic it lands: a turn of the view that both hands share the same tic is the stick's, and only that is undone; looking round with your head is not.
- No grip button is read. The ring reads the Open Wheel key, fire and alt fire of both hands, and keys bound to next and previous weapon. Use is read only to open a fan (Ring Layout: When Crowded); otherwise Use and the grenade keys are taken and do nothing while the ring is up. The movement stick is not read.
- With Weapon Wheel off, the Open Wheel key and the console toggles do nothing and next and previous weapon are left to the engine.
- There is one page of cards: weapons. There is no inventory page.
- A card shows a turning 3D model only when the gun's pickup is a voxel the Wheel can measure, or one of the series' own hand weapons; any other gun keeps its flat icon.
- KILLS, FIRED and HIT are counted from a gun's ammo going down, so a gun that uses no ammo gets no such row.
- The sheet holds at most 28 rows; more are dropped.
- All text is drawn in the Wheel's own copy of RSQ Score's font. No setting changes it.
- The floor weapon sheet shows only with the ring closed and only for a weapon within Inspect Within.
- The ring, the beam and the freeze are built for the one player at this headset; other players' wheel events are ignored.
- The room effects of the wheel this came from (lit beam, floor mark, fog, sweep, glow wave) are not drawn on QuestZDoom 17.3; their settings do nothing.

## Credits

The full list, with every file and its source, is in **CREDITS.txt**.

- **presidentkoopa:** the wheel, RS_WeaponSelectionSystem, from his UZDXREMA engine and RS_VR_Unified; its sounds came
  across with it.
- **Ermac:** his Force Unleashed holo HUD art, which the ring's own plates and digits are drawn from (with the owner's
  blessing).
- **id Software:** the IWAD art the ring draws by name: STBAR, DoomFont, the status bar numerals.
- **RSQ Score's fonts**, carried from ijon's **Dakka**: the score-line font by **Blue Shadow** and the breakdown (combo)
  font by **Jimmy**.
- **JFO**, the JDUI font by **Zedas**, in the "JDUI Brutal Doom Ultimate Edition" edit by **Blackmore1014**.
- **LegenDoom** (Yholl and its contributors): the brass knuckles on the fist card.
- **danger_doughnut52** (dinopixel.com): the lightsaber card's pixel art.
- The whip, ShieldSaw, flare, flashlight, Force hand, gloves and padlock icons, the lock-on mark and the glow art are the
  series' own.
- **QuestZDoom** (Emawind and Team Beef): the engine, and the off-hand weapon and hand-pose API the ring reads.

---
Written from the code at commit 1a846b85c, 2026-11-27, then brought up to the owner's changes of the same day (Time While Open; Use and the grenade keys; letting go and the stick take nothing; Skip Holstered Guns; reach in, pull and throw back removed).
