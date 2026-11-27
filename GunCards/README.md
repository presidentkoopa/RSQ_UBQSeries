# RSQ Gun Cards

Cards on your hands that say what you hold. A small card beside the wrist shows the rounds in the gun and the reserve. Check your watch and a full card lies on the back of that wrist: the gun's counts, grenades and kills, or your health, armour and keys when the hand is empty. The same mod holds Weapon Condition (off by default): big hits wear the guns in your hands.

<a name="how-to-play"></a>
## How to play

"Main hand" is the hand of the engine's ready weapon; "off hand" is the other. A "gun" is any weapon with an ammo pile; an "item" is a weapon with none (a melee weapon, a tool). 35 tics are one second. The watch check is read by Gun Cards' own reader; RSQ Accessibility is not asked.

| Do this | What happens | Needs |
|---|---|---|
| Hold a gun in the main hand | The small card shows beside the wrist, right of the main hand: Ermac's panel in the gun's weapon-slot colour, the word AMMO or MAGAZINE, the rounds you can fire now big, and the reserve small in gold when the gun has a magazine | Show Cards: Always (default) |
| Hold a gun in the off hand | The same card on that wrist, mirrored, but only for a gun whose own pack carries the card's models and names the gun in an RSQGCOFF lump. Any other off-hand gun has no small card | Show Cards: Always (default); a pack that carries the off-hand card |
| Fire a gun with a magazine | The big number is green above half a magazine, yellow from half down to a quarter, red at a quarter or less. Any gun at 0 is red | Low Ammo Colour: On (default); Low Ammo Share (default 0.25) |
| Empty the magazine with rounds still in reserve | RELOAD in red takes the big number's place, then a red 0, switching every 52 tics until you reload | |
| Pick up ammo for a gun in your hand | "+N" shows in the reserve's place for 52 tics; pickups inside that time add up (at most +99 shown) | Pickup Note (default 52 tics) |
| Check your watch with either hand: turn the back of that wrist toward your eyes and look toward it. The back of the wrist must be less than 80 degrees off facing your eyes (90 is edge on), and the wrist less than 50 degrees from where your head points. Where the hand is, how still it is and how long you hold it do not matter | That hand's watch card fades in over 4 tics, flat on the back-of-the-hand side of the wrist, and that hand's small card goes. It stays while the back of the wrist is less than 88 degrees off facing your eyes and the wrist less than 65 degrees from where your head points, and 70 tics (2 seconds) after | Watch Card: On Check (default); Stays After (default 70 tics); Fade (default 4 tics) |
| Check your watch with a hand that holds a gun | The Weapon card: MAG or AMMO (RELOAD in red on an empty magazine with rounds to load) and RESERVE, the two counts big, "+N" in green after a pickup; then one line each: MODE (only when the gun's pack tells one), LAUNCHER n (only on BD22 VR's Rifle and Machinegun), GRENADES n, KILLS n in red, and GOLD n on the off hand's card | Watch Shows: Weapon (default); GRENADES needs a grenade pile (RSQ Grenade, Brutal Doom or the weapon sets); GOLD needs RSQ Score |
| Check your watch with an empty main hand or with fists | The Status card: H and A, health big (red at 25 or less) and armour big in blue, a key icon for each key kind this map has (lit when you hold it, dark when not), "+N" for other keys, G:n for grenades, GOLD n on the off hand's card | Key Icons: On (default); Map Keys Only: On (default) |
| Check your watch with an empty off hand | The Status card. With a weapon in the off-hand slot (such as BD22 VR's off-hand fists) it is drawn with the hand; with nothing in that slot it is drawn in the world at the wrist | |
| Check your watch with a hand that holds RSQ Saber's saber, RSQ Flashlight & Flare's flare or flashlight, or RSQ Tactical Rig's cigarettes | The item card, its words in the half of the card nearer your elbow: the item's name, its count big when it has one (flares left, battery, cigarettes; red at 0), LIT / UNLIT for a flare or ON / OFF for a flashlight, then H n, A n, G:n, the key icons, GOLD n on the off hand | Watch Shows: Weapon (default) or Both; counts and states need the mod that owns the item |
| Check the off-hand watch while that hand steadies a gun: the engine's two-hand steadying is on, or the off hand is within 16 map units (about 45 cm) of the gun hand and within 8 map units (about 23 cm) of the gun's line | Nothing. The off hand's check does not count | |
| Kill a monster within 35 tics of a hand's shot | That hand's gun gets one more on its KILLS line, for this level. The hand is the one the engine says fired the shot (bullets, pellets, rails, and a melee weapon's traced attack), or the one whose rounds went down (what flies). If both hands fired on the same tic, no gun gets the kill | |
| Hold a cooking RSQ Grenade | Its whole seconds left take the big number on the small card, amber for the first half of the fuse and red after, whatever Show Cards says except Off | RSQ Grenade answering its fuse count (its Cook Sense 3) |
| Bring the gun to between about 12 cm and 0.7 m from your eyes, within 30 degrees of where you look | The small card shows only while you do | Show Cards: On Look (default Always); Look Reach (default 0.7 m); Look Cone (default 30 degrees) |
| Check your watch | The small card shows, and stays 70 tics after. With Watch Card: On Check the watch card takes the watch check instead, so the small card is seen this way only with Watch Card: Off | Show Cards: Inspect (default Always); Watch Card: Off (default On Check); Stays After (default 70 tics) |
| Hold that hand's reload button, or the shared reload button | The small card shows while it is held and 70 tics after | Show Cards: On Reload (default Always); Stays After (default 70 tics) |
| Hold a gun | No small card. A cooking grenade's count is not shown either | Show Cards: Off (default Always) |
| Turn the back of either wrist to within 60 degrees of facing your eyes, the wrist within 45 degrees of where you look | The watch card shows without a watch check, with the small card beside it. Turned away, the small card shows alone | Watch Card: Always (default On Check) |
| Check your watch | Nothing | Watch Card: Off (default On Check) |
| Check your watch with a gun | The Status card instead of the Weapon card | Watch Shows: Status (default Weapon) |
| Check your watch with a gun | Both on one card: MAG and RESERVE and the counts, "H n" and "A n", the key icons and G:n, then CND, GOLD and LAUNCHER when they apply. No MODE, GRENADES or KILLS lines | Watch Shows: Both (default Weapon) |
| Check your watch with a gun | Below the Weapon card's lines: "LV n" with an XP bar, then up to 4 upgrades with their level (dark when switched off), and "+N MORE" when not all fit | Gun Bonsai on Card: On (default Off); RSQ Gun Bonsai VR |
| Hold a gun in each hand | One small card, on the main hand: the main gun's rounds big, the off-hand gun's rounds in the small number. The off hand's small card goes | Both Guns One Card: On (default Off) |
| Raise the gun to within 0.30 m of your eye, pointing within 25 degrees of where you look | That hand's small card hides | Hide at Eye: On (default Off); Eye Reach (default 0.30 m) |
| Turn your wrist | The small card turns toward your eyes every tic, at most 20 degrees each way | Tilt to Eyes: On (default Off); Tilt Max (default 20 degrees) |
| Hold a gun, or check your watch | The cards are flat signs placed at the hand once a tic, facing your eye, in place of the cards drawn with the hand. The saber, the flare, the flashlight and the cigarettes show the Status card; any other weapon with no ammo pile shows its name over the Weapon card's lines, with no counts. The small card's top word is MAG, AMMO, RELOAD or +N | Draw in World: On (default Off); World Card Size (default 1.4) |
| Take one blow of more than 20 damage | Each gun in your hands loses 3 condition (two guns of one class lose it once). A gun starts at 100 and stops at 0 | Weapon Condition: On (default Off); Big Hit Over (default 20); Wear per Hit (default 3) |
| Hit something with a worn gun | The damage is scaled by the gun's condition. Most guns: x0.90 at 70 to 79, x0.85, x0.80, x0.70, then x0.60 at 30 to 39, and under 30 more than new: x1.2, x1.5, then x1.8 under 10. Shotguns and chainguns, and precision guns, have their own tables | Weapon Condition: On (default Off) |
| Pull the trigger on a worn gun | From the pull until the gun is ready again its frames run slower at 40 to 69 condition (x0.85, x0.67, x0.70) and faster under 40 (x1.05, x1.2, x1.25 under 10). A frame 1 tic long cannot be shortened | Weapon Condition: On (default Off); Fire Rate Follows Condition: On (default) |
| Fire a gun whose condition is under 60 | Each shot has a small chance (0.5 to 7 in 100) to BACKFIRE: 1 to 5 health, armour ignored. Under 30 it can also MISFIRE for 4 to 12 (an energy gun OVERLOADs for 8 to 20 and never backfires). Neither can kill you. At most one a second a hand | Weapon Condition: On (default Off); the word is shown as RSQ VisualRewards' toast, else only a sound plays |
| Check your watch with a gun | A CND line: a bar and the number, green at 90 and up, then lime, yellow, orange, and red under 30 | Weapon Condition: On (default Off); Condition on Card: On (default) |
| Pick up one of RSQ VisualRewards' steel bits | Each worn gun in your hands gains the points that mod sends | Weapon Condition: On (default Off); RSQ VisualRewards |
| Buy REPAIR at RSQ Miniboss's kiosk | Every gun you carry goes back to 100 | Weapon Condition: On (default Off); RSQ Miniboss |
| Take a big hit with a gun that is at 0, or that the hit brings to 0 | The gun breaks: a sound, "<NAME> BROKE", and it is taken from you | Weapon Condition: On (default Off); Lose Gun at 0: On (default Off) |
| With a gun in the main hand, open Test and Debug and move Spot Up, Spot Side or Spot In (cm) | That gun's small card moves and the spot is saved for that gun's class on this machine. Other guns keep the Placement sliders | The rows are greyed with no gun in that hand |
| Set Edit Spot For to Off Hand | The Spot rows edit the off-hand gun. BD22 VR's off-hand copy of a gun uses its gun's spot until it has its own | Edit Spot For: Off Hand (default Main Hand) |
| Choose Reset This Gun or Reset All Spots and confirm | That gun's small card, or every gun's, goes back to the Placement sliders | |
| Turn on Hide HUD Health or Hide HUD Ammo | Another pack's status bar setting is switched; nothing in this mod changes. The rows are greyed when no loaded pack has the setting | BD22 VR Reloaded (the setting is its own) |
| Turn on Hand Numbers | Every 5 tics the middle of the screen shows the engine's hand positions and angles, the weapons held, the watch check's answer for each hand (0 or 2), and for each wrist how many degrees the back of the wrist is off facing your eyes and how many degrees the wrist is from where your head points | Hand Numbers: On (default Off) |
| Type `netevent rsqgc_cnd_set <0 to 100> [1 main, 2 off]` or `netevent rsqgc_cnd_hit <damage>` in the console | Sets the condition of the guns in your hands, or deals you a blow. Test commands with no menu row | sv_cheats 1 |
| Check your watch with a hand that holds any other weapon with no ammo pile (BD22 VR's chainsaw and Dragonslayer, gloves, a whip, any pack's melee weapon) | The Weapon card with the weapon's name where a gun has MAG and RESERVE, and no counts; then the same lines: GRENADES n, KILLS n in red, GOLD n on the off hand's card. There is no small card | Watch Shows: Weapon (default); with Both the name stands over "H n", "A n", the key icons and G:n |
| Kill a monster with a blow of a weapon that has no ammo pile, or of a weapon flagged a melee weapon (BD22 VR's axe): the monster's edge within 128 map units (about 3.7 m) of the hand that holds it | That weapon gets one more on its KILLS line, whatever the other hand fired. With such a weapon in each hand, the nearer hand's gets it. A blow is damage you deal through an attack actor of your own that is not a traced shot and not an explosion; a traced melee attack counts as a shot, above | |
| Hold BD22 VR's Silvergun (`BrutalRevolver`) in either hand | RESERVE, on the small card and the watch card, is the rounds you can still load: the pistol's pile divided by 3 (one chamber costs 3), rounded down. RELOAD shows only when at least one round can be loaded, and "+N" counts rounds | BD22 VR Reloaded. Any gun with a magazine whose own ammo use per shot is more than 1 is counted the same way |
| Play Brutal Doom without reloading: as Purist (its `IsPlayingAsPurist` token, with a Purist gun or any other) or with its `NoReloading` token | The gun's cards say AMMO with the pile the gun fires from, and no reserve. As Purist the SSG and the Grenade Launcher keep MAGAZINE and RESERVE, because they still load from the pile | Brutal Doom |
| Load or fire the launcher under BD22 VR's Rifle or Machinegun | LAUNCHER 1 in orange with a round in it, LAUNCHER 0 dark without, on that gun's watch card. The off hand's Rifle shows its own launcher | BD22 VR Reloaded; not on the Purist Rifle, which has no launcher |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Gun Cards

| Option | Default | What it does |
|---|---|---|
| Show Cards | Always | When the small card on the gun shows: never, always, when you look at the gun, on the inspect gesture or on reload. |
| Watch Card | On Check | The full card flat on the back of the wrist: off, when you check your watch, or always. |
| Watch Shows | Weapon | What the watch card shows with a gun in hand: the Weapon card, the Status card or both on one card. |
| **Look** | | |
| Card Colour | Per Gun | The cards' colour: each gun its own, by ammo type, or one colour for all. |
| Material | Glass | The card's material: solid, glass, glow, or no background panel. |
| Card Opacity | 0.85 (0.1 to 1) | How solid the glass and glow cards are. |
| Card Glow | Off | Makes the cards fullbright (Quest), or fullbright with a small light at the hand (PCVR). |
| Key Icons | On | Shows the key icons on the Status card, lit when you hold the key. |
| **HUD** | | |
| Hide HUD Health |  | Removes health and armor from the status bar, since the cards show them. |
| Hide HUD Ammo |  | Removes the ammo count from the status bar, since the cards show it. |
| **Gameplay** | | |
| Weapon Condition | Off | Big hits wear the guns in your hands; worn guns lose accuracy and damage, under 30 they turn wild and can backfire, and steel bits and the Boss kiosk repair them. |
| Test and Debug | (page) | Every other setting: card details, placement, condition tuning and test logs. |
| Reset All | (button) | Puts every RSQ Gun Cards setting back to its default. |

<details><summary>RSQ Gun Cards: Test And Debug (43 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Cards** | | |
| Gun Bonsai on Card | Off | Shows Gun Bonsai's level, XP and upgrades below the Weapon card on the watch. |
| Both Guns One Card | Off | Puts both guns on the main hand's small card, the off hand's rounds in the small row. |
| Small Card Colours | Ermac | The small card's colours: Ermac's own or the Wheel's palette. |
| Small Card Font | JFO | The small card's font: JFO or Ermac's. |
| Text Quality | Quest | Quest draws the text at half resolution with fewer voxels; PCVR draws it at full resolution. |
| Cards Alive | On | The cards breathe slowly, like the slow-motion bars; off keeps them steady. |
| Level Card Swap | On | The small card fades out while the weapon level card shows at that hand. |
| Ammo Word | On | Shows the AMMO or MAGAZINE word on the card. |
| Low Ammo Colour | On | Colours the magazine count green, yellow, then red as it runs low. |
| Map Keys Only | On | Shows only the key kinds this map has; off always shows all six. |
| **Behaviour** | | |
| Draw in World | Off | Draws the cards in the world at the hand, so no gun covers them (they may trail a fast hand). |
| Tilt to Eyes | Off | The small card turns toward your eyes every tic. |
| Hide at Eye | Off | Hides the small card while the gun is up at your eye for sights or a scope. |
| **Placement** | | |
| Small Card Up | 0 (-100 to 100) | Moves the small card up or down about the hand, in degrees. |
| Small Card Side | 0 (-100 to 100) | Moves the small card sideways about the hand, in degrees. |
| Small Card In | 0 (-12 to 12) | Moves the small card in toward you along the forearm or out, in cm. |
| Watch Card Up | 0 (-30 to 30) | Moves the watch card up or down as it reads. |
| Watch Card Side | 0 (-30 to 30) | Moves the watch card sideways; only when Draw in World is on, since the hand-drawn watch card cannot move sideways. |
| World Card Size | 1.4 (0.5 to 2.5) | The size of the cards drawn in the world. |
| **Card Spot** | | |
| Edit Spot For | Main Hand | Which hand's gun the spot rows below edit. |
|  |  |  |
| Spot Up |  | Moves this gun's small card up or down and saves the spot for this gun. |
| Spot Side |  | Moves this gun's small card sideways and saves the spot for this gun. |
| Spot In (cm) |  | Moves this gun's small card in or out and saves the spot for this gun. |
| Reset This Gun | (button) | Puts this gun's small card back on the Placement spot. |
| Reset All Spots | (button) | Puts every gun's small card back on the Placement spot. |
| **Condition** | | |
| Big Hit Over | 20 (5 to 100) | A blow of more than this much damage to you is a big hit. |
| Wear per Hit | 3 (1 to 20) | How much condition each gun in your hands loses to one big hit. |
| Fire Rate Follows Condition | On | A worn gun fires slower and a fresh one faster, where its frames allow. |
| Lose Gun at 0 | Off | A gun worn to 0 breaks and is taken; off, it stays at its worst. |
| Condition on Card | On | Shows the condition row and bar on the gun's watch card. |
| **Tuning** | | |
| Panel Style | 0 (0 to 18) | Ermac's panel: 0 gives each gun its own by weapon slot, 1 to 18 one panel for all. |
| Low Ammo Share | 0.25 (0 to 0.9) | A magazine at or below this share of a full one counts as low. |
| Fade (tics) | 4 (1 to 12) | How many tics the cards take to fade in or out. |
| Look Reach (m) | 0.7 (0.3 to 1.2) | For When I Look: the gun must be within this many metres of your eyes. |
| Look Cone (deg) | 30 (10 to 60) | For When I Look: the gun must be within this many degrees of where you look. |
| Stays After (tics) | 70 (0 to 105) | How many tics a card stays after the watch check ends or the reload is let go (70 is 2 seconds). |
| Tilt Max (deg) | 20 (5 to 45) | The most Tilt to Eyes turns the card, in degrees each way. |
| Eye Reach (m) | 0.3 (0.15 to 0.5) | The hand counts as at your eye within this many metres, pointing where you look. |
| Pickup Note (tics) | 52 (10 to 140) | How many tics a pickup's +N stays in the reserve's place (35 is 1 second). |
| **Debug** | | |
| Hand Numbers | Off | Puts what the engine says about the hands on screen, for a screenshot. |
| Debug Log | Off | Logs kills, keys, fuse counts, reloads, spots and the watch check for a test. |
| Condition Log | Off | Logs big hits, backfires, misfires and repairs, or also every shot. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Accessibility | It is not asked for the watch check, and Gun Cards' reader does not stand down for it. While it is loaded, its Wrist Turn setting (`rsqg_inspect_way`) is read by name: Palm Up makes the inside of the wrist the watch check and the back the pulse check; Either Way gives the watch check both sides and the pulse check answers -1. Its Watch Check switch, its Watch Check sliders, Gesture Ease, Fit to My Body, the Off Hand Modifier's swap, the tick in the hand and the gesture's name on screen do not reach Gun Cards' watch check |
| RSQ Gun Bonsai VR | With Gun Bonsai on Card, the Weapon card shows the gun's level, XP and upgrades (`RSQGB_Service` "level", "xp.permille", "upgrades"; an older build answers the level through `RSQ_MeleeUpgradeService` "weapon.level", "weapon.xp") |
| RSQ Score | GOLD on the off hand's watch cards is its bank (`RS_ScoreService` "gold") |
| RSQ Grenade | GRENADES and G:n count `RSQGN_Ammo` while you carry `RSQGN_Grenade`. A cooking grenade's seconds are asked of `RSQGN_Service` ("fuse.count", "fuse.amber"). It ships the off-hand small card for its grenade |
| Brutal Doom, BD22 VR Reloaded | GRENADES counts `GrenadeAmmo`. Fists (`Melee_Attacks`, `RSQ_Hands`) count as an empty hand. For the guns with BD22 VR's real magazines (`RSQ_Mag_<gun>`, `RSQ_Lent_<gun>`, `rsr_reload`, `rsq_reload_nonstd`) the card shows the magazine and the reserve less the lent rounds. Its off-hand copies (`RSQ_Off_<gun>`) take their gun's name and card spot. `Chain_saw` and `DSweap` have the Weapon card with their name and their KILLS count. Brutal Doom's `NoReloading` and `IsPlayingAsPurist` tokens are read by name: with either a gun's card counts its Ammo1 pile, except `SSG` and `GrenadeLauncher` as Purist. `BrutalRevolver` and its off-hand copy show RESERVE at 3 `Clip1` a round. LAUNCHER on `Rifle`, `RSQ_Off_Rifle` and `Machinegun` reads the tokens `RFGLoaded` (main hand) and `RSM_LoadedOff` (off hand), and for the Machinegun without `RSM_VR` its rockets and `FiredMGGrenade`. `RSM_LauncherService` is not asked: it answers only "ubl.loading". Hide HUD Health and Hide HUD Ammo switch its `rsq_hud_nohp` and `rsq_hud_noammo` |
| The weapon sets | Without the two above, GRENADES counts their quick frag (`RSQB_GN_Ammo`). A service with "GunModeService" in its name answers a gun's "firemode" for the MODE line |
| RSQ Miniboss | While its fight card is up on the off-hand watch (`RSQMB_Service` "fightcard.up") the off hand's watch card stands down. Its kiosk asks this mod's "cnd.on", "cnd.worn", "cnd.worn.guns" and "cnd.fix", and it asks `RSQGC_GCopyService` for the watch check ("inspect") for its fight call and for the pulse check ("pulse") for its Start Fight card (Miniboss's own code) |
| RSQ VisualRewards | BACKFIRE, MISFIRE, OVERLOAD and BROKE are shown as its toast (`RSQVR_Service` "toast"). It asks this mod's "levelcard" so the small card fades out while its weapon level card shows at that hand (Level Card Swap, default On), and "cnd.on" and "cnd.repair" for its steel bits |
| RSQ Wheel | Small Card Colours: Wheel and the cards drawn in the world follow its palette and font set (`wr_palette`, `wr_fontset`, `wr_ring_art`, the WRPALS and WRFONTS lumps). The Wheel reads this mod's `rsqgc_watch` and `rsqgc_color` settings and asks "cnd.get" (the Wheel's own code) |
| RSQ Flashlight & Flare | The item card asks `RSQFF_Service` ("flare.count", "flare.phase") for `RSQFF_Held` and `RSQFF_TorchService` ("battery", "torch.phase") for `RSQFF_Torch` |
| RSQ Saber | `UBQS_Saber` and `UBQS_SaberOff` are named SABER on the item card |
| RSQ Tactical Rig | `RSQTR_CigWeapon` is named CIGARETTES and counts `RSQTR_CigPack`. The Rig asks this mod's `RSQGC_GCopyService` for the watch check when RSQ Accessibility is not loaded (the Rig's own code) |
| RSQ Laser Sight | It asks this mod's `RSQGC_GCopyService` for the watch check when RSQ Accessibility is not loaded (Laser Sight's own code) |
| BD22_VoxelPack | When its key voxels are loaded (`voxels/keys/rkeya.kvx`) the key icons are its keys; otherwise Freedoom's |
| Any pack with an RSQGCOFF lump | Each class it lists gets the small card in the off hand |
| Any mod that asks | `RSQGC_Service`: GetInt "levelcard" (the hand, tics, the pawn), "cnd.on", "cnd.get" (a weapon), "cnd.pellets" (a weapon), "cnd.repair" (points, the pawn), "cnd.worn" and "cnd.worn.guns" (the pawn), "cnd.fix" (the pawn); GetDouble "cnd.spread", "cnd.pelletmul", "cnd.damage", "cnd.rate" (a weapon). `RSQGC_GCopyService`: GetInt "reader" (1), "inspect" (the hand: the watch check, 0 not, 2 checked), "inspect.tics" (the hand: tics it has been met), "inspect.any" (the higher of the two hands), "pulse" (the hand: the pulse check, the inside of the wrist less than 60 degrees off facing your eyes to start and 75 to stay, the same gaze; 0 not, 2 checked); GetString "pose.why" ("watch" or "pulse", the hand, the pawn: which of the two tests fails, with its numbers, or "met"). It answers whether or not RSQ Accessibility is loaded |

## Limits

- There are no keys. No grip, Use button, jump or stick is read. The reload buttons are read only for Show Cards: On Reload, and each hand's fire and alt fire only by Weapon Condition, to tell which hand fired.
- A card is made only for the weapon in each hand. Pointing at a gun on the floor shows nothing.
- The cards are drawn for the player at this machine only, and only while alive.
- Without tracked hands the watch check and On Look never happen.
- In the off hand, the small card needs the gun's pack to carry it. The watch card works for any off-hand weapon.
- No item has a small card.
- KILLS is this level's count, and only for kills within 35 tics of that hand's shot, or by a blow in reach of a hand's melee weapon. Brutal Doom's kick, or a rocket from the other hand's gun, that kills inside a blade's reach counts for the blade. A blade's own explosion and a thrown weapon that kills beyond the reach do not count as blows. Fists count no kills.
- Numbers stop at 999 and "+N" at 99.
- The watch card drawn with the hand cannot move sideways; Watch Card Side moves only the one drawn in the world. Small Card In and Spot In have 13 places, 2 cm apart.
- Drawn in the world: there is no item card (the saber, flare, flashlight and cigarettes show the Status card), and the big number is white, red only at 0.
- The key icons know a key by "red", "yellow" or "gold", "blue" and "skull" in its class name. Any other key is counted as "+N".
- Weapon Condition: shooting never wears a gun. Melee weapons, tools and thrown grenades keep no condition. Condition is kept per gun class, not per gun.
- Weapon Condition changes accuracy only for a gun whose pack asks "cnd.spread", and pellets only where a pack asks "cnd.pellets" or "cnd.pelletmul"; this mod changes neither by itself.
- Saved card spots live in one setting on this machine, 4000 characters at most; past that the oldest is dropped. Reset All does not clear them.
- The watch check has no box, no stillness and no hold: any time the back of a wrist is turned toward your eyes inside your view it counts, meant or not (a fist thrown with the back of the hand up, a hand reaching out palm down, a gun canted over onto its side). Its angles have no menu row.
- The watch check goes by where your head points; it cannot see where your eyes look.
- The watch check gives no tick in the hand and names nothing on screen.
- A Stays After of exactly 35 saved before 2026-11-27 is moved to 70 once, the first time this version loads (`rsqgc_cfgver`). Choose 35 on the menu after that and it stays.
- The LAUNCHER line, the Silvergun's RESERVE in rounds, and which guns keep a magazine as Purist go by class and token names of Brutal Doom and BD22 VR Reloaded. The Railgun's RESERVE is still its cell pile, though one of its rounds costs 10 cells.

## Credits

The full list is in **CREDITS.txt**.

- **Ermac:** the cards are his Force Unleashed holo HUD, used with the owner's blessing: the ammo panels, the AMMO /
  MAGAZINE / CHAMBER words and the digits, from his doom-force-unleashed devbuild. They are turned into voxels here;
  the design is his.
- **JFO**, the JDUI font by **Zedas**, in **Blackmore1014**'s edit "JDUI Brutal Doom Ultimate Edition": the cards'
  text.
- **The key icons:** BD_VoxelPack's key voxels (keycards by **Ghostpilot**, skull keys by **Voxelbro**), and
  Freedoom's status-bar keys (BSD licence) without the voxel pack.
- **The world cards** use the loaded IWAD's small font and status bar, by lump name.
- **Gun Bonsai** is **ToxicFrog**'s; the card only reads it, through RSQ Gun Bonsai VR.
- **presidentkoopa:** the Radiant Silvergun Quest series. Gun Cards moved out of RSQ Wheel, his RS_WeaponSelectionSystem
  port, on 2026-10-31.
- **QuestZDoom** (Emawind and Team Beef): the engine and its VR hand API.

---
Written from the code at commit e2b60912e, 2026-11-27; the watch check rows from the working tree of 2026-11-27 ("look at it, it shows").
