# RSQ VisualRewards

Health bars over monsters, damage numbers off every hit, and kill rewards: monsters burst into small bits of health, armour and ammo when they die. It also draws what other RSQ mods ask it to show: banners, toasts, words over monsters, reward words in the world, arrival beams and the invulnerability bar.

<a name="how-to-play"></a>
## How to play

There is no key, no button and no hand move of its own. The mod answers what you already do: hit, kill, walk over things, pick things up. "A bit" is one of the small orbs a dead monster bursts into.

| Do this | What happens | Needs |
|---|---|---|
| Hit a monster with anything | A health bar appears over it from that hit and stays while it lives, white for one tic after your hit | HP Bars: On (default) |
| Hit a monster with anything | A small number of the health it really lost jets up from where you hit, spins a little and fades in about 0.6 s | Damage Numbers: On (default) |
| Hit the same monster again within 3 seconds | A running total over its bar and an "xN" combo beside it; both step white, yellow, orange, red and shake from x5 | Running Total, Combo Counter: On (default) |
| Hit a Brutal Doom monster in the head | HEADSHOT over a bigger gold number that jolts and arcs out to one side | Headshot Word: On (default); Brutal Doom |
| Kill a monster | Its total (or the killing hit's number) punches once, holds and fades | Kill Slam: On (default) |
| Kill a monster | It bursts into bits: one roll per 10 of its starting health, each roll a 50% drop; a boss drops every roll, three times as many. One ammo roll in three is a teal ammo bit | Kill Rewards: On (default); the teal bit: Ammo for Other Guns: On (default) |
| Walk over a bit, or stand within 2 m of it (it flies to you) | Health bit: +25 health. Armour bit: +10 armour (up to 250). Ammo bit: +5 rounds for each gun in your hands. Always these amounts | Bits Fly to Me (default 2 m) |
| Walk over a light green ammo bit | +5 rounds for each ammo type of the guns you carry but hold in neither hand, once a type. With every gun you carry in a hand: as an ammo bit | Ammo for Other Guns: On (default) |
| Walk over a gold bit | +5 gold banked in RSQ Score. Gold comes only from a Big Boss, a Boss or a legendary champion; any other kill rolls no gold and drops the same bits as without Score | RSQ Score; Gold Bits: On (default) |
| Walk over a steel bit | +1 condition to each gun in your hands | RSQ Gun Cards with Weapon Condition on |
| Walk over a battery bit | 15% of your flashlight battery | RSQ FnF, which drops them |
| In an RSQ Miniboss Boss or Big Boss fight, kill within 256 units or within 2 s of your last kill | 2 more health bits and 2 more armour bits drop, every one | Fight Kill Rewards: On (default); RSQ Miniboss |
| In an RSQ Miniboss Boss fight, take one of the Boss's lives | 6 ammo bits burst out at its feet (one in three light green), every one dropping | RSQ Miniboss; Kill Rewards: On (default) |
| Kill a monster within 3 times Bits Fly to Me (6 m) while you are DOWN | Its bits fly into your DOWN plate: health and armour bank for your revive, ammo is given at once | RSQ SlowMo |
| Pick up a health, armour or ammo item | A "+N" rises from it and flies to your wrist: health and armour to the off hand, ammo to the hand whose gun takes it | Gains on You: On (default) |
| Gain a player level, or a gun gains a level | LEVEL UP! in gold at the muzzle of the gun in that hand (the main hand for a player level), and a LEVEL UP! toast low in the view | Reward Words: World (default); Gun Bonsai's level-up event; the toast: Toasts: On (default) |
| Get invulnerable (sphere or any invulnerability power) | A magenta bar with Doomguy's god face in the top stack, draining over the time left | Invulnerability Bar: On (default) |
| Get up from RSQ SlowMo's DOWN | REVIVE! rises from the floor in front of you, in cyan, and a toast low in the view says what getting up gave: "REVIVE! +100 HP  +10 ARMOR  3S INVULNERABLE" (only the parts that are not zero) | RSQ SlowMo; Reward Words: World (default); the toast: Toasts: On (default) |
| Kill the monster that put you DOWN | REVENGE! over it in magenta (in front of you if it is gone), and a REVENGE! toast low in the view | RSQ SlowMo; Reward Words: World (default); the toast: Toasts: On (default) |
| Gain a life in RSQ Score | 1UP in gold rises from the life crate you took (else in front of you), and a 1UP! toast low in the view | RSQ Score; Reward Words: World (default); the toast: Toasts: On (default) |
| Hit a monster while you are DOWN | The time that hit bought ("+0.4s") pops over it in crimson | RSQ SlowMo; Damage Numbers: On (default) |
| Walk within about 1.4 m of a LegenDoom legendary drop | The power's name over it in its rarity's colours; it goes when you are 1.8 m away | Drop Words: On (default); LegenDoom or BD22 VR's LD mode |
| Point either hand's gun at a monster | Its bar shows while you aim and half a second after, even at full health; no other bars show | Only Where I Aim: On (default Off) |
| Kill with a last hit well past zero | OVERKILL over the number | Overkill Word: On (default Off) |
| Hit a monster | What the hit took off stays lit white on the bar half a second, then drains | Damage Chunk: On (default Off) |
| Gain a level with Reward Words on HUD or Both | LEVEL UP! banner with PLAYER LV n and +1 UPGRADE; a gun's level shows its name, a big LV n and NEW UPGRADE by the gun | Reward Words: HUD or Both (default World); Banners: On (default) |
| Gain a level with Reward Words on HUD or Both and Banners off | The old band across the view (player), or a small tag at the hand (gun) | Banners: Off (default On) |
| Hurt a LegenDoom legendary until it rises | THREAT! over it for 3 seconds | Threat Word: On (default Off); LegenDoom |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ VisualRewards

| Option | Default | What it does |
|---|---|---|
| **HP Bars** | | |
| HP Bars | On | Health bars over monsters. |
| Bar Colours | Classic | The bars' colour scheme, colour-blind schemes included. |
| Bar Size | 0.3 (0.05 to 1) | How big the bars are. |
| **Damage Numbers** | | |
| Damage Numbers | On | Numbers rise off a monster for each hit. |
| Number Size | 1 (0.25 to 3) | How big the damage numbers are. |
| **Kill Rewards** | | |
| Kill Rewards | On | Monsters burst into bits of health, armour and ammo when they die. |
| Bits per Kill | $RSQ_MENU_KR_STANDARD | How many bits a kill throws. |
| Bits Fly to Me (m) | 2 (0 to 4) | Bits within this many metres fly to you (0 is off). |
| **Level Up** | | |
| Player Level Up | On | The LEVEL UP band when you gain a level. |
| Weapon Level Up | On | A tag off the gun when a weapon gains a level. |
| **Banners** | | |
| Banners | On | The big banners: REVIVE, -1UP, BOSS DEFEATED!, BOSS WINS!, +1UP. |
| Scene Music | On | A scene's own track (a Boss's) crossfades over the level music. |
| Test and Debug | (page) | Every look and number of the bars, damage numbers, bits, gold, steel, words and banners, and the logs. |
| Reset All | (button) | Puts every RSQ VisualRewards setting back to its default. |

<details><summary>RSQ VisualRewards: Test And Debug (98 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **HP Bars** | | |
| Full Bright | Off | Bars ignore the sector's light. |
| Fade With Stealth | On | Bars fade with a see-through monster. |
| Overheal Strip | On | A strip above the bar for health over the monster's start health. |
| Status Markers | On | Hooked, stunned, locked, gripped and frozen icons beside the bar. |
| Tier Icons | On | The tier gem and the Champion icon beside the bar. |
| Only Where I Aim | Off | A bar only over the monster a gun points at. |
| Damage Chunk | Off | What your hit took off stays lit half a second, then drains. |
| Ally Bars | Off | Friendly monsters get a blue bar. |
| Nearest 24 Only | Off | Only the 24 bars nearest you are drawn. |
| Distance Limit | Off | No bars farther than the Limit Distance. |
| Far Size | 2 (1 to 3) | How much bigger bars grow at range (1 is off). |
| Height | 0.1 (-0.5 to 0.5) | The bar's height above the monster, as a share of its height. |
| Limit Distance | 1536 (256 to 4096) | Distance Limit's distance, map units. |
| **Damage Numbers** | | |
| Numbers For | false | Numbers for monsters only, or for every shootable thing. |
| Number Font | JFO Metal | The digits' font. |
| Word Size | 1 (0.25 to 3) | How big HEADSHOT, OVERKILL, the combo and the level-up text are. |
| Text Quality | Quest | Quest draws half-resolution glyphs; PCVR draws full ones. |
| Hit Colours | Damage Type | How a hit's number is coloured: by damage type, by hit strength, Classic, or one colour. |
| Classic Colour | $C_DEFAULT | The number colour when Hit Colours is Classic. |
| Classic Type Colours | On | With Hit Colours on Classic, fire is orange, plasma cyan and so on. |
| Total Colours | Follow Combo | The running total's colour. |
| Combo Colours | Fire | The colour ramp the combo steps through. |
| Headshot Colour | Gold | A headshot number's colour. |
| Pop and Settle | On | A number flashes white, snaps out, then jets up and over. |
| Motion Without Pop | Toss | How numbers move with Pop and Settle off: tossed or floating. |
| Size by Hit | Off | Bigger hits show a little bigger. |
| Grow with Distance | Off | Numbers grow with distance like the bars. |
| Running Total | On | A chain's hits roll up in one total above the bar. |
| Kill Slam | On | On the kill the total punches once, holds and fades. |
| Combo Counter | On | An xN combo counter beside the HP bar. |
| Combo Shake | On | The total and the combo shake a little from x5. |
| Overkill Word | Off | OVERKILL over a kill whose last hit went well past zero. |
| Headshot Word | On | HEADSHOT over a head hit. |
| Headshot Flash | On | A headshot's number is white for its first tics. |
| Headshot Cycling | On | Headshot numbers shimmer and their letters bob. |
| Shotgun Spray | Off | One number per pellet instead of one per target per tic. |
| Gains on You | On | Health, armour and ammo gains rise from the pickup and fly to your wrist. |
| Freeze in Hit Stop | On | A number on a monster in a hit stop holds until it ends. |
| Numbers in Slow Motion | World Time | Numbers slow with the world, or move at your speed. |
| Out of Your Face | On | Numbers never come nearer than about 1 m, and stay off your guns' aim. |
| Clear of Walls | On | Numbers are kept clear of walls and ceilings. |
| Most Numbers | 12 | Only this many nearest numbers show. |
| **Kill Rewards** | | |
| Boss Fountain | x3 | A Boss throws this many times the bits. |
| What Drops | $RSQ_MENU_KR_CUSTOM | The mix of health, armour and ammo bits. |
| Bits Vanish After | 7 s | How long bits stay before they vanish. |
| Bits Vanish As | Blink Out | Bits blink out or fade out when their time is up. |
| Ammo Bits Give | $RSQ_MENU_KR_GUNINHAND | Ammo bits fill the guns in your hands, or any gun you carry. |
| Drop Mode | $RSQ_MENU_KR_BYHEALTH | Bits by the monster's health, or a random count in a range. |
| Health per Bit | 10 (1 to 100) | With Bits per Kill on Custom, one bit per this much health. |
| Drop Chance | 50 (0 to 100) | The chance each bit drops, in percent (a Boss always drops). |
| Mix Health | 15 (0 to 100) | With What Drops on Custom, the health weight. |
| Mix Armour | 20 (0 to 100) | With What Drops on Custom, the armour weight. |
| Mix Ammo | 65 (0 to 100) | With What Drops on Custom, the ammo weight. |
| Ammo for Other Guns | On | One ammo bit in three is light green: 5 rounds for each gun you carry but do not hold (all in hand: as an ammo bit). |
| Ammo Type 1 Counts | On | A gun's first ammo type counts for ammo bits. |
| Ammo Type 2 Counts | Off | A gun's second ammo type (clips) counts for ammo bits. |
| Range Fewest | 1 (1 to 25) | Range mode's fewest bits. |
| Range Most | 3 (1 to 25) | Range mode's most bits. |
| Range Random | On | Range mode picks a random count between the two. |
| **Fight Rewards** | | |
| Fight Kill Rewards | On | During a Boss or Big Boss fight, a close or quick kill drops extra health and armour bits. |
| Close Kill (units) | 256 (0 to 1024) | A kill this close to you counts as close (0 turns close kills off). |
| Quick Kill (s) | 2 (0 to 5) | A kill this soon after your last counts as quick (0 turns quick kills off). |
| Extra Health Bits | 2 (0 to 10) | Extra health bits a close or quick kill drops. |
| Extra Armour Bits | 2 (0 to 10) | Extra armour bits a close or quick kill drops. |
| Thralls Drop Health | On | In a fight, a thrall's extra health bits drop too. |
| **Gold and Steel** | | |
| Gold Bits | On | Gold bits bank in RSQ Score for the Boss kiosk. |
| Gold From | Special Kills | Gold drops only from Big Bosses, Bosses and legendary champions, or from every kill. |
| Gold Share (%) | 25 (0 to 100) | The percent of a kill's bits that are gold. |
| Gold per Bit | 5 (1 to 50) | The gold each bit is worth. |
| Boss Gold Fountain | 20 (0 to 100) | Gold bits a Boss throws on top of its bits. |
| Champion Gold Fountain | 6 (0 to 50) | Gold bits a legendary champion throws on top of its bits. |
| Big Boss Gold Fountain | 180 (0 to 300) | Gold bits a Big Boss throws. |
| Gold Bits Vanish After (s) | 20 (5 to 60) | How long a gold bit stays before it vanishes. |
| Steel Bits | On | Steel bits repair the guns in your hands. |
| Steel Share (%) | 15 (0 to 100) | The percent of a kill's bits that are steel. |
| Condition per Steel Bit | 1 (1 to 10) | The condition each steel bit adds to each gun in your hands. |
| **Level Up** | | |
| Level Up Slow Motion | Off | A short slow motion through the level-up band. |
| Band Colour | Gold | The level-up band's colour (REVENGE and REVIVE use it too). |
| Text Colour | Gold | The LEVEL UP text's colour. |
| Wrist Toast | On | On, a small tag at the hand for about a second; off, the full tag rising off the gun. |
| Weapon Tag Colour | Gold | The weapon tag's border colour. |
| **Words** | | |
| Arrival Beams | On | Monsters another mod brings in arrive on a beam. |
| Monster Words | On | Words over a monster: GUARD!, TARGET! and the like. |
| Reward Words | World | REVENGE!, REVIVE!, LEVEL UP! and 1UP as signs in the world with a toast, banners on the HUD, or both. |
| Word Font | Score Small | The letters of every word over a monster. |
| Monster Word Size | 1 (0.25 to 2) | The size of every word over a monster (1.00 is the size it shipped at). |
| Threat Word | Off | THREAT! over a LegenDoom legendary once it rises (off: its HP bar tells it). |
| Threat Word (s) | 3 (0 to 10) | How long the legendary's word stays after it rises (0 keeps it for its life). |
| Drop Words | On | The rarity and power's name over a LegenDoom drop until it is picked up. |
| Pops | On | The small ring and star burst another mod asks for. |
| **Banners and Music** | | |
| Banner Size | 1 (0.5 to 2) | How big the banners are. |
| Toasts | On | The small messages low in the view (a backfire, a repair, a reward word), with Banners on or off. |
| Invulnerability Bar | On | The magenta bar in the top stack while you are invulnerable. |
| Scene Music Volume | 1 (0.1 to 1) | How loud a scene's track plays. |
| Scene Crossfade (s) | 2 (0.5 to 5) | How long a scene's track takes to come in or go. |
| **Logs** | | |
| Gold Log | Off | A console line for every kill that threw gold and every gold bit picked up. |
| Steel Log | Off | A console line for every kill that threw steel and every steel bit picked up. |
| Debug Log | Off | A console line for each kill: what burst into how many bits. |

</details>

<details><summary>Hp Bars (1 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| RSQ VisualRewards | (page) |  |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| (this mod answers) `RSQVR_Service` | Play: "loaded", "kr.loaded", "kr.on", "helper", "kr.battery", "burst.ammo", "scene.push", "scene.pop", "banner", "toast", "beam", "word", "word.hold", "word.clear", "pop", "worldword". UI: "loaded", "banner.lives", "invbar.bottom" |
| (this mod answers) `RSQTHP_DnService` | "crit": marks a monster's hits as crits for a few tics. Nothing is drawn for a crit |
| (this mod answers) `RSQVR_RSQDownJoin` | RSQ SlowMo's DOWN tells it "down.target" (that monster's bar is made and kept up), "down.time", "down.revenge", "down.up" |
| RSQ Score | Asks "banner" (+1UP), "toast", "worldword" (1UP), "banner.lives" (its lives row: the new face waits for the +1UP badge) and "invbar.bottom" (its combo rows go under the invulnerability bar). Gold bits drop only with Score loaded and bank there; the invulnerability bar sits under Score's bar. With Reward Words World its 1UP word also brings a 1UP! toast |
| RSQ SlowMo | Asks "banner" (REVIVE), "toast", "scene.push" / "scene.pop" (DOWN's music), "word.hold" / "word.clear"; its DOWN target's bar stays up; numbers follow its slow motion; bits from a DOWN kill bank in its plate; Level-Up Slow Motion sends it `rsm_pulse`. With Reward Words World its REVIVE banner is not shown, but its numbers go into the REVIVE! toast |
| RSQ Miniboss | Asks "burst.ammo" (6 ammo bits each time a Boss loses a life), "beam", "word", "word.hold", "word.clear", "pop", "worldword", "banner" (BOSS INCOMING! with its siren, BOSS DEFEATED!, BOSS WINS!, the BIG BOSS ones), "toast", "scene.push" / "scene.pop" (the Bossfight track). Its Boss wears a crown with tier pips over its bar, a thrall a chain link. A Boss counts as a boss for bits; a thrall drops no health bits; Boss Effects Light halves beam sparks |
| RSQ Gun Bonsai VR | Its "bonsai-level-up" event shows LEVEL UP!. `RSQGB_Service` names the gun and its hand. Kill Rewards asks it nothing: bits are the same with or without it |
| RSQ Gun Cards | Its small card of that hand stands down while the gun's level card shows ("levelcard"; only with Reward Words HUD or Both). Steel bits need its Weapon Condition and repair through it. Ammo gains on the wrist fade into its own +N. Asks "toast" |
| RSQ Grapple | Hooked and stunned marks beside the bar. Asks "worldword" |
| UltraBadassShieldSaw | Locked mark beside the bar |
| UltraBadassQuestSaber | Gripped mark beside the bar |
| RSQ Whip, RSQ Gun Bonsai VR (any `RSQTHP_Marker` service) | Asked for whipped, hooked, stunned, locked and gripped: the Whip's whipped mark, Gun Bonsai VR's stunned mark |
| RSQ Distance Grab | Asks "toast" and "word" |
| Any mod that freezes or holds a monster | A hit-stop (its freeze count running down) shows the frozen mark; a hold (the count kept still, with gravity or infighting borrowed) shows the held mark. Read off the monster, no mod named |
| RSQ Monsters | Its tier gem (1 to 13) beside the bar; tier names and colours on TIER UP / TIER DOWN chips |
| RSQ Grenade | Its Incendiary fire lights the burning mark. Asks "toast" and "worldword" (the type's name on the grenade in the hand) |
| RSQ Melee, RSQ Tactical Rig, RSQ Graveyard, GNRC Reloaded | Ask "worldword", "toast" or "word.hold" by name |
| RSQ FnF | Asks "kr.battery" (battery bits) and "toast" |
| RSQ LaserSight (any `...MuzzleService`) | LEVEL UP! and other muzzle words stand at the real muzzle; without it, 20 units in front of the hand |
| RSQ Accessibility | Colour Blind picks the bars' colour set, the combo colours, the DOWN time colour and the THREAT! colour; Photosensitive Mode drops white flashes, blinks and shakes; Text Size scales banners; Cue Size scales the icons beside the bar |
| Champions | A champion's type icon (and Titan, Undying, Ghost, Balloon) beside the bar, and Champions' own floating icon hidden while the bar shows |
| LegenDoom (and BD22 VR's LD mode) | A risen legendary wears a gem over its bar; a candidate is not given away by its boosted health; drop words; a fist drop is given a fist model. BD22 VR's Legendary Economy off: no gold at all |
| Brutal Doom | Its head hits make HEADSHOT; its hit boxes, boot smearers and dying bodies get no bar, number or bits; its damage types colour the numbers |
| coldcite's Top HP Bars | Its bars are taken off while ours are on; its menu entry opens ours |

## Limits

- No key, button, grip or hand gesture is read anywhere. Besides `rsqthp_reset` and the test events (sv_cheats only) there is no command.
- A monster has no bar until its health differs from its starting health, unless Only Where I Aim is on.
- Your own bar is hidden in first person. Damage numbers never show for hits on players.
- Only the 12 nearest numbers show (Most Numbers); bars can be cut to the nearest 24 or by distance (off by default).
- Bits vanish after 7 s (gold after 20 s), blinking out first. One death throws at most 100 bits; past that each bit is worth several and drawn bigger.
- An ammo bit gives nothing when neither hand holds a gun that uses ammo (Ammo Bits Give: Guns in Hand).
- A light green ammo bit feeds only guns you carry outside your hands; with every carried gun in a hand it is an ordinary ammo bit (Ammo Bits Give decides).
- A bit is picked up only by touching it or by standing within Bits Fly to Me; at 0 m it never flies to you.
- Gold is rolled only on a death that may drop it (a Big Boss, a Boss or a legendary champion with Gold From: Special Kills); every other kill drops the same bits with or without RSQ Score.
- With Reward Words on World (default) the REVIVE, +1UP and LEVEL UP banners and their chips are not shown; the word stands in the world and one toast says it (REVIVE! with its health, armour and invulnerable seconds; mags are in RSQ SlowMo's own MAGS REFILLED toast). On HUD or Both there is no reward toast.
- Level Up Slow Motion, Text Colour, Wrist Toast and Weapon Tag Colour act only on the old band and tag (Banners off and Reward Words HUD or Both).
- One banner at a time per player; at most 5 wait, more are refused. At most 3 toasts at once.
- Words, numbers, beams and banners are drawn for the console player's own view only.
- A scene's music never carries into the next map.
- Out of VR, Only Where I Aim reads the view and the main hand only.

## Credits

The full list, with every file and licence, is in **CREDITS.txt**.

- **coldcite:** Top HP Bars 1.04, the bars' layout, art and idea (itself based on Nash Muhandes' SpriteShadow, MIT).
- **Xaser Acheron** (with Major Cooke; thanks to Marrub and Zombie): damnums 1.0.2 (MIT), the damage numbers' idea,
  Doom digit art, colours and motion.
- **SoM:** Universal(ish?) Kill Rewards 1.0, the bits, their orbs and the drop rules.
- **Zedas** and **Blackmore1014:** the JFO font (JDUI Brutal Doom Ultimate Edition), the default number font.
- **iamErmac:** the Force Unleashed holo digits (Ermac font).
- **Blue Shadow:** RS Score's score-line font (via ijon's Dakka), the monster words (Score Big; and Score Small, RS
  Score's RSSCFN2).
- **Not yet cleared:** the SOTN word font's letters are cut from the owner's sheet of Castlevania: Symphony of the Night's
  words (Konami); the letters that sheet lacks were drawn to match. Before any release they must be credited or redrawn.
- **presidentkoopa:** the design, the arrival sounds and the two music tracks (sources to be recorded before release).
- **freesound_community** (Pixabay, Pixabay Content License): "Siren Alarm", BOSS INCOMING!'s siren.
- **End of Starchild:** V1's growth and narrowing, as a motion reference only.
- **Not yet cleared:** V3's dome, splash, burst and columns and V4's skull pillar are frames cut from a ripped
  "Z-Fighter effects" sheet. Before any release they must be credited properly or redrawn.
- **QuestZDoom** (Emawind and Team Beef): the engine.

---
Written from the code at commit a283738bb, 2026-11-27; updated the same day for the owner's answers to the findings (F1, F2 to F6, F8, F10), the teal ammo bit for other guns and "burst.ammo".
