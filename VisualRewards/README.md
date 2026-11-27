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
| Kill a monster | It bursts into bits: one roll per 10 of its starting health, each roll a 50% drop; a boss drops every roll, three times as many | Kill Rewards: On (default) |
| Walk over a bit, or stand within 2 m of it (it flies to you) | Health bit: +25 health. Armour bit: +10 armour (up to 250). Ammo bit: +5 rounds for each gun in your hands | Bits Fly to Me (default 2 m) |
| Walk over a gold bit | +5 gold banked in RSQ Score. Gold comes only from a Big Boss, a Boss or a legendary champion | RSQ Score; Gold Bits: On (default) |
| Walk over a steel bit | +1 condition to each gun in your hands | RSQ Gun Cards with Weapon Condition on |
| Walk over a battery bit | 15% of your flashlight battery | RSQ FnF, which drops them |
| In an RSQ Miniboss Boss or Big Boss fight, kill within 256 units or within 2 s of your last kill | 2 more health bits and 2 more armour bits drop, every one | Fight Kill Rewards: On (default); RSQ Miniboss |
| Kill a monster within 3 times Bits Fly to Me (6 m) while you are DOWN | Its bits fly into your DOWN plate: health and armour bank for your revive, ammo is given at once | RSQ SlowMo |
| Pick up a health, armour or ammo item | A "+N" rises from it and flies to your wrist: health and armour to the off hand, ammo to the hand whose gun takes it | Gains on You: On (default) |
| Gain a player level, or a gun gains a level | LEVEL UP! in gold at the muzzle of the gun in that hand (the main hand for a player level) | Reward Words: World (default); Gun Bonsai's level-up event |
| Get invulnerable (sphere or any invulnerability power) | A magenta bar with Doomguy's god face in the top stack, draining over the time left | Invulnerability Bar: On (default) |
| Get up from RSQ SlowMo's DOWN | REVIVE! rises from the floor in front of you, in cyan | RSQ SlowMo |
| Kill the monster that put you DOWN | REVENGE! over it in magenta (in front of you if it is gone) | RSQ SlowMo |
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
This mod has no options page.
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| (this mod answers) `RSQVR_Service` | Play: "loaded", "kr.loaded", "kr.on", "kr.perk", "kr.magnet", "helper", "kr.battery", "scene.push", "scene.pop", "banner", "toast", "beam", "word", "word.hold", "word.clear", "pop", "worldword". UI: "loaded", "banner.lives", "invbar.bottom" |
| (this mod answers) `RSQTHP_DnService` | "crit": marks a monster's hits as crits for a few tics. Nothing is drawn for a crit |
| (this mod answers) `RSQVR_RSQDownJoin` | RSQ SlowMo's DOWN tells it "down.target" (that monster's bar is made and kept up), "down.time", "down.revenge", "down.up" |
| RSQ Score | Asks "banner" (+1UP), "toast", "worldword" (1UP), "banner.lives" (its lives row: the new face waits for the +1UP badge) and "invbar.bottom" (its combo rows go under the invulnerability bar). Gold bits drop only with Score loaded and bank there; the invulnerability bar sits under Score's bar |
| RSQ SlowMo | Asks "banner" (REVIVE), "toast", "scene.push" / "scene.pop" (DOWN's music), "word.hold" / "word.clear"; its DOWN target's bar stays up; numbers follow its slow motion; bits from a DOWN kill bank in its plate; Level-Up Slow Motion sends it `rsm_pulse` |
| RSQ Miniboss | Asks "beam", "word", "word.hold", "word.clear", "pop", "worldword", "banner" (BOSS INCOMING! with its siren, BOSS DEFEATED!, BOSS WINS!, the BIG BOSS ones), "toast", "scene.push" / "scene.pop" (the Bossfight track). Its Boss wears a crown with tier pips over its bar, a thrall a chain link. A Boss counts as a boss for bits; a thrall drops no health bits; Boss Effects Light halves beam sparks |
| RSQ Gun Bonsai VR | Its "bonsai-level-up" event shows LEVEL UP!. `RSQGB_Service` names the gun and its hand. `RSQ_MeleeUpgradeService` is asked for Bit Scavenger, Rich Bits, Magnet, Lucky Kill and Scavenger: all answer 0 now, so bits behave as with no Gun Bonsai |
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
- A bit is picked up only by touching it or by standing within Bits Fly to Me; at 0 m it never flies to you.
- With RSQ Score loaded, a quarter of a common monster's drop rolls are gold rolls, and on a common monster a gold roll drops nothing.
- With Reward Words on World (default) the REVIVE, +1UP and LEVEL UP banners and their chips are not shown at all; only the word in the world is.
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
Written from the code at commit a283738bb, 2026-11-27.
