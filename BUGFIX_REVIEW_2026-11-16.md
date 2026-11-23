# Bugfix review, 2026-11-16: every code change from the README session, for the bugfix lane to check

The README session (the owner with Claude, 2026-11-16 09:17 to 11:xx) read each mod's code to rewrite its README. Two
agents read RSQ Tactical Rig and RSQ Wheel in full and listed what looked like defects. The owner went through them
one by one and said fix, log or remove. This file lists **every code change that session made**, so the bugfix lane can
check each one.

**None of it has been run.** Not load-checked, not on the rig, not in the headset. No pk3 was rebuilt. Every item below
is **code only, not shown** until someone shows it.

A default that changed only reaches fresh settings and Reset All: a saved config keeps the value it has.

## A. Defaults changed at the owner's word

| # | Mod | Setting | Was | Now | File | Owner |
|---|---|---|---|---|---|---|
| A1 | Grenade | Replace Brutal Doom's Grenade (`rsqgn_replace_bd`) | false | **true** | `Grenade/CVARINFO.txt` | "Make it on" |
| A2 | Melee | Two-Handed Butt Strike (`rsqml_butt`) | 0 | **1** | `Melee/CVARINFO.txt` | "ideally it is on by default", "Yes, default on" |
| A3 | Tactical Rig | Torso (`rsqtr_vest`) | false | **true** | `TacticalRig/CVARINFO.txt` | "Torso on" |
| A4 | Tactical Rig | Cigarettes (`rsqtr_cig`) | false | **true** | `TacticalRig/CVARINFO.txt` | "Cigarettes on" |
| A5 | Wheel | Freeze Time While Open (`wr_freeze`) | false | **true** | `Wheel/CVARINFO.txt` | "Freeze by default" |
| A6 | SlowMo | Adrenaline (`rsqsm_adrenaline`) | false | **true** | `SlowMo/CVARINFO.txt` line 20 | "Turn it on". Check: the key and wrist cross need 25 adrenaline to start, so a fresh game cannot slow time until the meter has some; Slow Motion Length greys |
| A7 | SlowMo | Be Quick or Be Dead (`rsqsm_down`) | false | **true** | `SlowMo/CVARINFO.txt` line 123 | "Turn it on". Check: every monster's killing blow now goes to DOWN on a fresh install, with and without RSQ Score |

A1, A2 and B1 are on main since commit 64da223d0; A3 to A5 and B2 to B12 since 6f67fbdb0; B13 and B14 came after.

**To check:**
- A1: with BD22 VR Reloaded loaded, a new game hands out RSQ Grenade's grenades and BD22 VR's own grenade stands down
  (it reads the same cvar by name). The Tactical Rig's buckle gives RSQ Grenade's.
- A2: see B1, which is what makes it hold.
- A3: the torso draws from the first map; nothing else assumes it is off (the mirror, the fade looking down).
- A4: a new game has a pack of three; the pocket's ring and the ritual work with nothing else changed.
- A5: opening the ring stops the world with and without RSQ SlowMo, and closing it starts it again. With it on, Slow
  Time While Open no longer matters (the code asks SlowMo only when Freeze is off: `zscript.zs` near 4689).

## B. Code changed

| # | Mod | What was wrong | What changed | Where | Risk |
|---|---|---|---|---|---|
| B1 | Melee | On the first map with BD22 VR Reloaded, `Migrate()` copied that pack's `rsq_butt` over `rsqml_butt`. Its default there is 0 (`src/CVARINFO.rsq:49` at BD22 VR 7c3ed23), so A2 would have been switched off again for everyone who never touched it | The one `CopyI("rsq_butt", "rsqml_butt")` line is gone. Speed and forward share still copy | `Melee/zscript/rsqml/club.zs`, `Migrate()` | Low. A player who had deliberately turned BD22 VR's butt strike OFF now gets it on |
| B2 | Tactical Rig | **Shoulder to ShieldSaw** off did not give the off shoulder back to guns: `ShieldHolster()` never read the row, so a gun was still refused there | `ShieldHolster()` returns -1 (no claim) when `rsqtr_yield_shield` is off | `TacticalRig/zscript/rsqtr/hooks.zs` about line 53 | **Medium.** `ShieldHolster()` has about fifteen callers in `rig.zs` and one in `ghost.zs`; all of them now treat that shoulder as an ordinary gun holster when the row is off. The 11-07 note above the function says the shoulder was the ShieldSaw's "whether the shield is on the shoulder or in the hand": that was the owner's rule then, and this changes it only with the row off (it is on by default) |
| B3 | Tactical Rig | "No flares left" printed with Messages off; the other short lines did not | It now needs **Messages** on, like the others. The refusal buzz is unchanged | `TacticalRig/zscript/rsqtr/rig.zs` about line 3264 | Low |
| B4 | Tactical Rig | The mirror read `p.mo.health` with no check that `p.mo` exists | `rig && p.mo && p.mo.health > 0` | `TacticalRig/zscript/rsqtr/mirror.zs` about line 255 | Low |
| B5 | Tactical Rig | Holster Rings had a third choice, "Always While Moving Holsters", that drew exactly as "Hand Nearby" | The choice is off the menu. `RingMode()` is untouched: a saved 2 still reads as 1 | `TacticalRig/MENUDEF.txt` (`RSQTR_Markers`), comment in `CVARINFO.txt` | Low. A config holding 2 shows an unnamed value on that row until it is changed |
| B6 | Tactical Rig | Two settings nothing used: `rsqtr_cig_zippo`, `rsqtr_pairs` | Both lines deleted; `rsqtr_pairs` taken out of Reset All's extra list | `TacticalRig/CVARINFO.txt`, `TacticalRig/MENUDEF.txt` | Low to medium. `rig.zs` about line 2936 still does `CVar.FindCVar("rsqtr_pairs")` in its settings-version step; it is null-checked. An old ini line naming either cvar now loads as an unknown cvar (the comment said "kept so old ini lines load") |
| B7 | Wheel | The grenade's fan of kinds could never open on the default ring: fans exist only with Group by Slot off and more guns than Flat Ring Up To (99) | On a ring built without fans, the grenade's own gun card (never a slot's card, never BACK) may open, and only its kinds. New helpers `nadeCard()` / `nadeFan()`; the three fan gates read `(mFansEnabled \|\| nadeFan(...))`; `expandSlot()` narrows `variants` to the grenade alone when fans are off | `Wheel/zscript/wheel/zscript.zs` about lines 896, 964, 4371-4380, 4392-4404, 10241 | **High. The one to look at first.** Untested logic in the ring's hover and expand path. To check: default ring, grenade alone in its slot: rest 7 tics on its card or press Use: the kinds fan opens, a kind is picked, the ring closes. Grenade sharing a slot: open the slot, then the same on the grenade's card. No other card may fan. Group by Slot off with few guns: the same. Nothing else about hover, the data sheet or the holster web may change. Compile: `(Class<Weapon>)(mTypes[cardIndex])` casts a `Class<Inventory>` |
| B8 | Wheel | **Open at Level Start** always opened on the off hand | `openRig(opensOnHand())` | `Wheel/zscript/wheel/zscript.zs` about line 8836 | Low |
| B9 | Wheel | With Slow Time While Open on, every level load set Bullet Time X's `bt_adrenaline_unlimited` to 1, though the Wheel no longer drives that mod | The lines are gone | `Wheel/zscript/wheel/zscript.zs` about line 3443 | Low. If anyone still plays the Wheel with Bullet Time X and relied on it, it is their setting again |
| B10 | Wheel | Console `wr_reset` skipped Group by Slot, Keep Out of Walls and Inspect Within | `wr_group_slots wr_walls wr_inspect_reach` added to the alias | `Wheel/KEYCONF` line 54 | Low |
| B11 | Wheel | Ammo Readout's "LCD, punched out" drew exactly as "LED segments" | The choice is off the menu | `Wheel/MENUDEF.txt` (`wr_Readouts`) | Low. A saved 1 shows an unnamed value and draws as before |
| B12 | Wheel | **Face Parallax** only moves painted faces, which are off with no row to turn them on | The slider is off the Test page. The cvar and its code stay | `Wheel/MENUDEF.txt` | Low |
| B13 | Distance Grab | A walk-up grip on a gun you own with full ammo carried it off, while a pulled one is left at your feet with AMMO FULL (and the trace line said "left at your feet") | The walk-up grip now treats AMMO FULL as it treats HEALTH FULL and ARMOR FULL: the word over it, and it is left where it is | `DistanceGrab/zscript/rsqdg/near.zs`, the walk-up take, about line 272 | Low to medium. It reverses the 11-12 rule written there ("a full gun walked up to keeps today's rule"): the owner chose it on 11-16 ("Fix the behaviour"). To check: full shotgun in hand, grip another shotgun on the floor: AMMO FULL over it, a soft buzz, the gun stays; not full: taken as before |
| B14 | Grenade | Infight's grenade is green (0x3CDC5A) and its sparks and haze were red (0xFF3C3C); every other kind is one colour | The sparks and haze are 0x3CDC5A | `Grenade/zscript/rsqgn/kinds.zs` about line 94 (`COL[]`, the last entry) | Low |

## C. Logged or decided, not changed

| # | Mod | What | Owner |
|---|---|---|---|
| C1 | Tactical Rig / Gun Bonsai VR | Boomerang Gun level 1 never finds "the holster it came from" (a draw clears it) and files the gun in the first empty holster with no assignment check (`rig.zs` about 1503, 1670, 2265) | "Log for GBOVR pass" |
| C2 | Distance Grab | The lock is at once (Lock Delay 0), so amber shows only for a refused lock | "leave it as is for now" |
| C3 | Distance Grab | **Duck Under Doors** (on) does nothing on the default Arc pull; it acts on Steer, Lob and lock-on barrels (`flight.zs` about 1049-1079) | "Log it" |
| C4 | Distance Grab | The burning barrel can be grabbed and thrown but never goes off | "Log it" |
| C5 | Distance Grab | Lift Doors and Palm Flips Switches ignore the master **Distance Grab** row and Not With Melee (`door.zs` about 148-150) | "Keep as is". The README says so |
| C6 | Distance Grab | A palm works any Use line, a level's exit included | "Fine as is" |
| C7 | Grapple | **Fire Hook** has no default key and the hook always leaves the off hand | **To build:** "Let me pick the hand": an option row, Hook Hand: Off or Main. Not started |
| C8 | Grenade | Switching weapons while a grenade cooks sets it off at your body | **To build:** "Drop it at my feet": switching away drops the live grenade and it goes off when its fuse ends. Not started |
| C9 | SlowMo | **Slow Me Too Strength** (Test and Debug) looks to change nothing (`clock.zs` about 1073) | "Log it" |
| C10 | SlowMo | While a Boss slow window runs, a slow motion asked for under a reason SlowMo does not know is treated as the Boss's: its label and its switch (`clock.zs` about 461, 1207) | "Log it" |
| C11 | Visual Rewards | With Banners on (the default) Level-Up Slow-Mo, Text Colour, Weapon Level-Up: Wrist Toast and Weapon Tag Colour change nothing; Band Colour only tints the REVENGE / REVIVE band (`rsqthp/damnums/events.zs` about 252, 286, 1124) | "Log it". The README says these belong to the Banners-off look |
| C12 | Visual Rewards | Champions' own icon is hidden whenever Tier Gem and Champion Icons is on, even with HP Bars off or before the monster has a bar: no icon until it is hurt, or never (`rsqthp/handler.zs` about 196, 396, 466-478) | "Log it" |
| C13 | Visual Rewards | Toasts (the small one-line notes) are drawn with Banners off and have no row of their own (`rsqvr/banners.zs` about 885-887) | "Log it" |
| C14 | Visual Rewards | With Banners off, a +1UP still tells RSQ Score to hold the new life's face back about 2.5 s for a banner that never shows (`rsqvr/banners.zs` about 338-348) | "Log it" |
| C15 | Visual Rewards | Console `rsqthp_reset` skips the newer settings: tier icons, wrist toast, gold, steel, Word Font, the LegenDoom rows (`VisualRewards/pk3/KEYCONF.txt` line 1). The menu's Reset All is separate | "Log it" |
| C16 | Visual Rewards | With Mix: Health, Armour and Ammo all at 0 a kill drops no bits at all, gold and steel included (`rsqvr/killrewards.zs` about 285, 328) | "Log it" |
| C17 | Visual Rewards | Steel bits from a kill made while DOWN are not banked like the rest; they stay ordinary bits (`rsqvr/killrewards.zs` about 463) | "Log it" |

## D. Read in the code, the owner has not been asked

- Grenade: Cluster bomblets use the older burst (`thrown.zs` about 426).
- Tactical Rig: a debug line still says the "Grip inside the ring" hint text is shown (`rig.zs` about 2797); the words
  were removed.
- Wheel: Weapon Condition, crit and fire mode never show on the data sheet on QuestZDoom (their readers answer "not
  there", `wr_q_shim.zs` about 886-895); no reader for the GNRC or WoS weapon sets.
- SlowMo, nothing a player sees: the DOWN bar's refill glint never runs (`down.zs` about 740); `rsqsm_down_step` has no
  effect; debug level 2 cannot be reached; a stale comment at `down.zs` about 1462.
- Visual Rewards, nothing a player sees: the DOWN skull marker never draws (`rsqthp/bar.zs` about 352).
- The front page's SlowMo text (the owner's words) says "nearly 40 contextual-world triggers"; the options page has about 25 switches.

## E. The other eleven mods: read from the code, waiting for the owner

Nothing in this section has been changed in the code. Each line is what a player would see, then where it is in the
code. The last column is for the owner: **fix**, **log**, **fine as is**, or an answer. "Invisible" means a player would
never notice. Found by a full read of each mod's code on 2026-11-16; none of it has been run.

### Laser Sight

**Questions**

| # | Question | Owner |
|---|---|---|
| LS-Q1 | Headshot Reaction, Spread Ring and Show Range ship off. Should any of them be on out of the box? | |
| LS-Q2 | The two pictures at the top of the page show the PC VR look that was taken out. Keep them with the note, or wait for new captures? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| LS1 | Fire only the off-hand gun and its beam blinks out on every shot; only the main hand's triggers keep a beam up through the fire frames | `LaserSight/zscript/rsqls/sight.zs` about 152 | |
| LS2 | Play with this mod, then remove it, and QuestZDoom's own laser stays switched off until you turn it on in its menu (its switch is saved as off) | `sight.zs` about 179 | |
| LS3 | Fire one bullet-type attack while holding a grenade launcher and its arc is gone for the session. Whether Brutal Doom's kick does this was not verified | `learn.zs` about 108 | |
| LS4 | Main Hand Dot and Off Hand Dot do nothing unless Colour Mode is "Beam and Dot", and are not greyed | `MENUDEF.txt` 108-109; `sight.zs` about 467 | |
| LS5 | Off Hand Colour does nothing in "One Colour" mode, and is not greyed | `MENUDEF.txt` 107; `sight.zs` about 463 | |
| LS6 | Target Colour does nothing under Colour Blind Mode | `sight.zs` about 504 | |
| LS7 | Beam Sparkle never sparks on the bent arc beam | `sight.zs` about 806 | |
| LS8 | With "0 = never" on Off When Aimed Down, the laser also stays on through a weapon switch | `sight.zs` about 429 | |
| LS9 | Invisible: `rsqls_beam_type` is read by nothing, has no row and Reset All misses it | `CVARINFO.txt` 74 | |
| LS10 | Mostly invisible: a bent arc beam with no landing dot tells other mods "no laser", so Distance Grab and the Wheel draw their own beam on that hand | `sight.zs` about 557, 811 | |
| LS11 | Invisible: the second FlameCannon line can never be reached; a stale comment says the Wheel does not read the beam yet (it does) | `bdbore.zs` 21, 44; `sight.zs` 139, 1342 | |

### Graveyard

**Questions**

| # | Question | Owner |
|---|---|---|
| GY-Q1 | Living Stones and Bones Bridge ship off. Should either be on out of the box? | |
| GY-Q2 | The page promised a bounce on the pop-in; the code has none to see (GY1). Bring the bounce back, or is growing to full size fine? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| GY1 | The pop-in has no visible bounce: a stone just grows to full size (the overshoot peaks at 1.0009 of full) | `Graveyard/zscript/gy_Stone.zs` 210-212 | |
| GY2 | Load a save more than a second into a map and every stone shrinks and pops back in at once, candles fading in again | `gy_EventHandler.zs` 35-36; `gy_Stone.zs` 62 | |
| GY3 | Bones Bridge on: a monster revived (an Arch-Vile, a Boss revive) and killed again before its first timer ends gives two undead from one corpse | `bones.zs` 253-268, 298-301, 329 | |
| GY4 | With "Something On It (LoB)", a corpse lying where the wider rising actor can never fit (against a wall, in a doorway) never rises, retrying for ever with nothing shown. How often: not verified | `bones.zs` 140, 304-309 | |
| GY5 | Graves Rise on "Thralls Per Stone" with many thralls: risers share one 40-unit ring and 16 fallback spots, so some are dropped after 5 tries and fewer rise than counted. Not verified in play | `bones.zs` 149-172, 314, 363-365 | |
| GY6 | Photosensitive Mode: the stones sit full-bright through the whole Boss wait, candles about 1.3 times wider, where the intent reads as a calm half lean | `gy_Stone.zs` 100, 259, 322 | |
| GY7 | Photosensitive Mode does not calm Candle Flicker | `gy_Stone.zs` 331-338 | |
| GY8 | Rows that do nothing and are not greyed: Pop In on Spawn, Bounce Amount, Bounce Speed with Animate Gravestones off; Candle Flicker, Light Radius, Light Brightness, Light Cull Distance with Grave Light off; Bones Bridge without Legion of Bones | `menudef.txt` 46-62 | |
| GY9 | Switching Bones Bridge off and on again before a corpse's timer ends still lets it rise | `bones.zs` 296 | |
| GY10 | Without VisualRewards, in a netgame one player's Use on a stone prints the obituary on every machine | `gy_Stone.zs` 109 | |
| GY11 | The store is never trimmed: every death on every map stays until a remove button is pressed | `gy_Storage.zs` | |
| GY12 | Invisible: Reset All misses `gy_living_debug`; two identical obituary lines show once; a hub map re-entered later gets no staggered pop; at Respawn Delay Instant a blocked corpse spawns and deletes a test actor every tic; `build_all.sh` zips `add-ons/` though `build_all.py` leaves it out | `cvarinfo.txt` 21; `gy_Stone.zs` 173, 62; `bones.zs` 307; `build_all.sh` 141 | |

### Whip

**Questions**

| # | Question | Owner |
|---|---|---|
| WP-Q1 | **Whip Pulls Monsters** ships off. With it off there is no yank and no Leash: a light monster only flinches, a heavy one does nothing. The page sells both. Turn it on by default? | |
| WP-Q2 | **Lock-On Controls** ships on, and while it is on there is no Lasso (the page's opening line), and the Whip and Gun and Aim With Off Hand rows do nothing. Is that the intended default, and should the Lasso work under Lock-On? | |
| WP-Q3 | Crack Wraps Monsters, Knockback, Hit-Stop and Crack Fireballs ship off. Any of them on out of the box? | |
| WP-Q4 | No keys are bound and none are needed; the four old key events only work typed at the console. Remove them? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| WP1 | The Lasso row reads On, but at defaults closing the off hand on the whip does nothing (Lock-On Controls makes Whip and Gun mode permanent, and that mode refuses the lasso) | `Whip/zscript/rsqwp/weapon.zs` 233; `swing.zs` 167 | |
| WP2 | The Leash row reads On, but at defaults no monster is ever leashed (it also needs Whip Pulls Monsters) | `whip.zs` 2576 | |
| WP3 | With Crack Wraps Monsters on, yanking a wrapped monster only makes it flinch, and a heavy one gives nothing, until Whip Pulls Monsters is on too | `whip.zs` 2163-2186 | |
| WP4 | With Whip Pulls Monsters and Lock-On Controls both on, every marked crack leashes, with no gun and no trigger held, and it wins over the wrap | `whip.zs` 2576-2578; `swing.zs` 167 | |
| WP5 | Whip and Gun and Aim With Off Hand change nothing while Lock-On Controls is on, and are not greyed | `swing.zs` 167; `weapon.zs` 111 | |
| WP6 | After the whip catches an edge while you stand, Jump drops the rope instead of starting a swing (only a gold-spot rope waits for the jump) | `weapon.zs` 149-150; `whip.zs` 3445-3475 | |
| WP7 | With Whip In: Off Hand, holding Use on a rope never climbs (Use always takes hold with the main hand) | `swing.zs` 638-639 | |
| WP8 | With Gun Bonsai VR's Momentum raising top speed to 36 or 42, hauling on the rope or a heavy yank cuts you back to 30 | `whip.zs` 2182, 2858 | |
| WP9 | Under Lock-On Controls the small hop comes whenever Jump Starts Swing is off, even with Grip Starts Swing on | `swing.zs` 590-597 | |
| WP10 | Reset All on the Test and Debug page resets only that page's numbers, not the main page's switches | `rsmenu.zs` 416-427; `MENUDEF.txt` 154 | |
| WP11 | The main page's Reset All skips four settings with no row (`rsqwp_whip_mode`, `rsqwp_mass_max`, `rsqwp_slide_speed`, `rsqwp_slide_gap`); the last three shape the Leash | `rsmenu.zs` 462-506 | |
| WP12 | Console `rsqwp_reset` leaves eight settings alone: Lock-On Controls, Crack Wraps Monsters, Whip Pulls Monsters, Crack Stun Hold, Hard Crack Crits, On a Rope Jump Lets Go, On a Rope Fire Lets Go, Crack at Gold | `KEYCONF.txt` 9 | |
| WP13 | Crack Fireballs only swats missiles whose shooter is a monster | `whip.zs` 3118 | |
| WP14 | The Bola ties 2 monsters at most, whatever the Gun Bonsai VR node's level (for the GBOVR pass) | `whip.zs` 2270 | |
| WP15 | Invisible: `core.altReel` never used; `rsqwp_geo_mode`, `rsqwp_chain_links`, `rsqwp_chain_scale` read but never defined; the claw flight, the PH_HOLD yank, the chain look and the Bitten ledger are dead code; Hold to Toggle and Slower Taps reach only the keyless bind whip; `rsqwp_whip_mode` and Whip Aim's value 2 (Lock) have no input | `core.zs` 24, 320; `hook.zs` 235, 246 | |

### Miniboss (player-facing: Boss)

**Questions**

| # | Question | Owner |
|---|---|---|
| MB-Q1 | The page had a whole "colour bonus" section and a **Tier From** row (Gun Bonsai VR level or Score lives picking the Boss's level). Neither is in the code: the level comes from RSQ Monsters' world tier only, Boss at +2, thralls at +1. Is the code right and the page old, or is this a feature that got lost? | |
| MB-Q2 | The page said the HUD shows the Boss's colour gem, a Champion-power icon each, one segment per thrall and a stepped gold bar. The HUD draws none of those; lives show as "X3". Old plan, or missing work? | |
| MB-Q3 | "Thralls (3)" on the menu gives a random 3 to 5 at the default. Intended? | |
| MB-Q4 | RSQ Score's own row is still named "Miniboss" (`Score/zscript/rsscore/handler.zs` 850), and Glow In The Dark's console line says "miniboss fight". Rename both to Boss? | |
| MB-Q5 | Graves Rise (Legion of Bones), Ignore Spawn Restrictions, Can't Be Morphed and Map-wide Roar ship off. Any on out of the box? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| MB1 | Shots inside a window drain a hidden segment: the Boss's bar does not move and nothing shows how long the window has left | `Miniboss/zscript/rsqmb/items.zs` 58; `bossbar.zs` 386, 465 | |
| MB2 | With more than five thralls only five thrall bars are drawn | `bossbar.zs` 469 | |
| MB3 | Call the fight by watch check, get held by a wait rule, and the wrist's Start Fight card goes grey, so it cannot force the fight | `bossfight.zs` 513 | |
| MB4 | Turn **Bosses** off during a landing and the landed monsters stay hidden and frozen, with Champions' chance left forced until the next map; turn it off mid-fight and the bar vanishes while the fight goes on | `bossfight.zs` 354 | |
| MB5 | "Big Boss Bar +25% (Test)" and "Big Boss Bar Empty (Test)" only print a console line unless sv_cheats or Debug Log is on | `bigboss.zs` 239 | |
| MB6 | Power Cap at 4 behaves exactly as 5 | `handler.zs` 276 | |
| MB7 | Slow Depth steps -1, 4, 9, 14 and 4 acts as 5 | `MENUDEF.txt` 142; `handler.zs` 73 | |
| MB8 | Graves Radius does nothing in the two Whole Map modes and is not greyed | `bossfight.zs` 1022 | |
| MB9 | The kiosk takes the gold and marks SOLD before the gun is made. Whether BD22 VR can fail at that point: not verified | `kiosk.zs` 1004 | |
| MB10 | Show Meter off also hides the Boss's bar in a fight; nothing draws at screen size 12 | `hud.zs` 371 | |
| MB11 | Boss Kills Tier Up Monsters off also stops the tier-down on a loss | `tierup.zs` 293 | |
| MB12 | Reset All does not put back RSQ Monsters' world tier that Boss kills raised | | |
| MB13 | No sound when the meter fills (the page promised a sting) | `bossfight.zs` 221 | |
| MB14 | The page said the kiosk never opens mid-fight; no such check was found (not verified elsewhere) | `kiosk.zs` 690-725 | |
| MB15 | Invisible: `rsqmb_bf_tier_score`, `rsqmb_bf_tier_from` and the "RSQMB_TierFrom" list are unused; `BB_CHARGE`, `HandLevel`, `IsFists`, `mapWeapons`, `chosen` never used | `CVARINFO.txt` 19-20; `MENUDEF.txt` 33 | |

### Gun Cards

**Questions**

| # | Question | Owner |
|---|---|---|
| GC-Q1 | **Weapon Condition** ships off, so steel bits (Visual Rewards) and the kiosk's REPAIR never show on a fresh install. Turn it on by default? | |
| GC-Q2 | Gun Bonsai on Card, Card Glow, Both Guns on One Card, Draw in the World, Tilt to Your Eyes and Hide at Your Eye ship off. Any on out of the box? | |
| GC-Q3 | The Volatile wear profile is the Workhorse curve unchanged. Give it its own behaviour, or drop the name? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| GC1 | With Watch Card on Always On, the small card vanishes whenever the wrist is not turned to you, which is most of the time while aiming | `GunCards/zscript/rsqgc/card.zs` 955-965, 1042 | |
| GC2 | Remove HUD Health and Armor and Remove HUD Ammo do nothing unless BD22 VR Reloaded or a weapon set is loaded (the settings are that pack's), and are not greyed | `MENUDEF.txt` 44-45 | |
| GC3 | With the Condition and Gold rows on the Weapon card, Gun Bonsai upgrades are cut off and "+N MORE" never appears; the card holds 8 small lines | `side.zs` 147-156, 285-298 | |
| GC4 | A worn gun fires slower only while the trigger is held; tapping a semi-automatic mostly skips the slowdown | `cnd.zs` 552-555 | |
| GC5 | Any gun whose class name contains saw, axe, flare, shield, fist, torch or knife keeps no condition, a "SawedOff" shotgun for one | `cnd.zs` 57-59 | |
| GC6 | At 1 health a backfire shows "BACKFIRE -0" | `cnd.zs` 406-411 | |
| GC7 | With Both Guns on One Card, a main-hand watch check makes the off card's small number show the main gun's rounds | `card.zs` 981-984 | |
| GC8 | The off-hand watch card on Both on One Card never shows gold | `side.zs` 249-260 | |
| GC9 | Turning on Lose the Gun at 0 never breaks a gun already at 0 | `cnd.zs` 444 | |
| GC10 | Solid cards pop in and out and ignore Cards Alive (opacity is not applied to them) | `card.zs` 907 | |
| GC11 | Rare: a thrown player projectile spawned within 64 units of a flying rocket is scaled as that rocket's gun | `cnd.zs` 348-355 | |
| GC12 | Without Visual Rewards or RSQ Miniboss nothing can repair a gun | | |
| GC13 | The saber's item card has no LIT / OFF word (the page said it had) | `items.zs` 70-73 | |
| GC14 | Invisible: with Material Solid from the start the list of new layers is never emptied and grows; Reset All does not reset `rsqgc_cnd_force`; the two-handing 26-unit limit can never fail after the 16-unit test | `card.zs` 908, 1362-1367, 626-630 | |
| GC15 | Not verified: whether the damage scaler's puff test (`bIsPuff`) exists on QuestZDoom 17.3; whether key icons sit right on the item card's rows | `cnd.zs` 290 | |

### Glow In The Dark

**Questions**

| # | Question | Owner |
|---|---|---|
| GD-Q1 | With **Level-Up Wave (Gun Bonsai)** off, the Boss's death wave is dropped too. Should the Boss wave have its own switch or always play? | |
| GD-Q2 | With **Boss Tint (Boss)** off, **Darken the Map** does nothing either. Intended? | |
| GD-Q3 | Secret Rooms Shimmer and Blend Rooms ship off; Lights Over Pools and Lights on Items ship at 0. Any on out of the box? | |
| GD-Q4 | Credits say the Glow list ships "unchanged as GLDEFS.txt"; the Liquids section says it is merged with More Lights. Which is true? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| GD1 | After loading a savegame, the next darkness change (a Boss fight, a landing, any Darkness row) darkens the already darkened rooms a second time: the map stays too dark, and Disable or switching the mod off no longer gives the map's own light back. Not run; whether stock DarkDoomZ does the same is not verified | `GlowInTheDark/zscript/rsqgd/ddz.zs` 29-34 | |
| GD2 | With Re-roll Colours on Never, a Boss's death still re-rolls the colours and overwrites the Colour Seed | `handler.zs` 306; `Miniboss/.../fight.zs` 138 | |
| GD3 | With Floor and Ceiling Glow off (or a profile with no ceiling glow, such as Minimal) those rooms ignore the life flash and the Boss fight's timed colours, yet still take the Boss tint and the Red Map | `handler.zs` 372-376, 401, 453 | |
| GD4 | Guess Liquids by Name changes nothing until the next map | `liquid.zs` 107; `handler.zs` 114-121 | |
| GD5 | "Colours From" offers Custom and Random Profile, and both look exactly like Classic (1.1) | `profiles.zs` 152; `MENUDEF.txt` 141 | |
| GD6 | Use DarkDoomZ Pairing does nothing on Random Profile, with no greying and no message | `menu.zs` 68 | |
| GD7 | Shuffle Profile Now and Randomize Current Look re-roll during a Boss fight or life flash, when Randomize Colours Now refuses | `handler.zs` 766-779 | |
| GD8 | Shuffle Profile Now shows new colours on the old profile for up to a second before the new profile appears; on Custom it leaves the Profile row alone | `handler.zs` 768-776 | |
| GD9 | Custom Pulse Speed at 90 with Hue Drift spins the whole colour wheel 1.5 times a second, against the mod's own "nothing flashes" rule | `handler.zs` 458; `MENUDEF.txt` 173 | |
| GD10 | Reset All pressed during a Boss fight: Post-Gain goes back to its pre-fight value, not the default, when the Boss dies | `react.zs` 133 | |
| GD11 | With the mod off, Sector Light Effects set to Remove still deletes flicker and pulse lights | `ddz.zs` 23-27 | |
| GD12 | Strength does not touch liquids; hurt floors, secret rooms and teleporter pads ignore both Strength and Glow Height | `handler.zs` 411, 430, 437, 445, 457 | |
| GD13 | On Each Death, On Each Level-Up and Every N Minutes keep the same seed across maps, so with Random Profile the same profile carries into the next map | `handler.zs` 282 | |
| GD14 | Rows that do nothing unless another row is set, not greyed: Colour Seed (only on Never), Re-roll Every (min), Custom Tint, every Custom Profile row | `MENUDEF.txt` | |
| GD15 | Not verified: whether Randomize Colours Now's KEYCONF alias runs from a menu button on QuestZDoom 17.3 (the other two buttons call the event directly) | `MENUDEF.txt` 99; `KEYCONF.txt` 2 | |
| GD16 | Invisible: the darkness sends a network event every screen tic; liquids are rewritten every 3 tics even with the mod off; Secret Rooms Shimmer keeps the whole map animating; unused `SequenceBusy`, `DdzText`, `keysMask` | `ddz.zs` 37-39; `handler.zs` 622, 569, 288 | |

### Score

**Questions**

| # | Question | Owner |
|---|---|---|
| SC-Q1 | Counts on the page were off. The code registers 226 bonuses (not "about 240"), 242 named combos, 20 RSQ Monsters rows (not 32), 7 award rows (not 9), 41 Champions / LegenDoom / Boss rows (not 42). The draft now uses the code's numbers. Does any missing row mean lost work? | |
| SC-Q2 | **New Map Keeps** ships at Nothing: score, bar and lives are wiped every map. Intended default? | |
| SC-Q3 | Score on the Wrist, Hit-Stop on Big Kills, Reward Screen Flash and Revival Screen Flash ship off. Any on out of the box? | |
| SC-Q4 | Score's bonus row and award label still say "Miniboss" ("Miniboss", "Kingslayer ... on the miniboss", "Rage Quit: the miniboss"). Rename to Boss? | |
| SC-Q5 | Head Shot Damage changes damage even on plain Doom II (+30 on zombie and imp kinds, the blow again on Baron kinds). Intended with nothing else loaded? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| SC1 | After a long map, slow-motion big moments stop firing on the next map until it has run as long as the last one had at its final moment: the cooldown tic is kept on the player and never reset. The same stale tic blocks hit-stop | `Score/zscript/rsscore/handler.zs` 714, 701, 250-284; `tracker.zs` 86 | |
| SC2 | Leave a map within about 5.5 s of a kill and the next map's breakdown shows blank gaps above new rows, and the first new "+N" on those rows includes the old map's number | `handler.zs` 963, 1184; `hud.zs` 436-442 | |
| SC3 | Rainbow is described as "in one map" but its colour count is never cleared: it counts across the whole game and each step pays once per game | `rows.zs` 1238-1254; `tracker.zs` 79-80 | |
| SC4 | With a life held, ordinary damage that leaves you at exactly 1 HP spends a life though the hit would not have killed you | `handler.zs` 1301 | |
| SC5 | **Screen Flash** does nothing you can see unless Reward Screen Flash or Revival Screen Flash is also on | `handler.zs` 1441-1470 | |
| SC6 | Five names are both a combo and a separate bonus (Bouncer, Hooked Keg, Ice Breaker, Riot Control, Rope-a-Dope), so the same word can show on two lines for different reasons | `combos.zs` 69, 119; `rows.zs` 199, 1357 | |
| SC7 | The first kill of a new map can pay Spree as if the last map's run were still going | `bonuses.zs` 41 | |
| SC8 | Not verified: whether SlowMo raises health above 1 on the same tic DOWN ends. If it does not, Score would spend a life on a successful get-up | `handler.zs` 1293-1301; `SlowMo/.../down.zs` | |
| SC9 | The saved gold bank after a death is restored only for the local player | `gold.zs` 75 | |
| SC10 | Dying through the life hold (a telefrag) loses every life | `handler.zs` | |
| SC11 | Award rows are paid outside the 300% Kill Bonus Cap | `handler.zs` 888-899 | |
| SC12 | A saved HUD "Down" under 13 is forced to 13 once (the page said the default was 10) | `CVARINFO.txt` 101; `hud.zs` 66-72 | |
| SC13 | Invisible: `rs_score_hs` is declared, read by nothing, no row; `tracker.lastResetTic` written and never read; Bonus Time's top step is 3 tics short; `zscript.txt` line 8 says 241 bonuses | `CVARINFO.txt` 127; `handler.zs` 265, 283, 1184 | |

### FnF (flashlight and flares)

**Questions**

| # | Question | Owner |
|---|---|---|
| FF-Q1 | **Bones Drop Battery Bits**, Smoke, Soft Light, Shoot Out Flares, Refill Each Level and Beam Hotspot ship off. Any on out of the box? | |
| FF-Q2 | Dust in the beam shows only on PCVR and High quality; the default Quest quality has none. Fine? | |
| FF-Q3 | Outside VR the hands are never read, so neither item can be taken. Say so on the page (the draft does), or add a key? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| FF1 | With Sounds off you still hear the pocket take, the flashlight click and the flare's bounce knock | `FlashFlare/zscript/rsqff/handler.zs` 178, 190; `torch.zs` 322, 345, 354; `burn.zs` 224 | |
| FF2 | In the DarkDoomZ beam look, Beam Quality does not change how far the light reaches, and the row is not greyed | `MENUDEF.txt` 51; `torch.zs` 478-482 | |
| FF3 | Beam Length above about 13 m changes nothing on Quest quality: the cone is capped at the light's range | `torch.zs` 551-552 | |
| FF4 | Grip at the pocket with your hands close together and keep squeezing over two seconds: no flare appears and nothing says why | `handler.zs` 307-311 | |
| FF5 | With RSQ Tactical Rig loaded, the four Pocket rows and three Flashlight Clip rows do nothing and are not greyed | `MENUDEF.txt` 85-93 | |
| FF6 | With Shoot Out Flares on, the flare is a target about 4 units wide, likely very hard to hit (not verified in play); any damage puts it out, not only your shots | `burn.zs` 205-206, 240-250 | |
| FF7 | Bones Drop Battery Bits matches monsters by names such as "Reaper", "Conqueror", "Balrog" without checking Legion of Bones is loaded, so another mod's monster of that name drops bits | `battery.zs` 157-168, 194 | |
| FF8 | A boosted monster's "ignite below N% health" is tested against the monster type's normal health, not the boosted monster's own | `fire.zs` 64 | |
| FF9 | A flare bouncing between two monsters can hit the first again (only the last one hit is remembered) | `burn.zs` 230-236 | |
| FF10 | Beam Colour: Random can repeat the same colour (the page said a new one every time) | `torch.zs` 351 | |
| FF11 | The burn-out smoke puff shows even with Smoke off | `burn.zs` 79 | |
| FF12 | Netplay only: other players' flashlights are drawn at your clip offsets (a TODO in the code) | `torch.zs` 678-692 | |
| FF13 | Nearly invisible: flare boxes tend to lie beside the items a map lists first; a crackle already playing does not stop when Sounds goes off | `handler.zs` 732-741 | |

### Accessibility

**Questions**

| # | Question | Owner |
|---|---|---|
| AC-Q1 | The page said RSQ Grapple reads Hold to Toggle, Steady Hands, Gesture Ease, Slower Taps, Text Size, the Off-Hand Modifier, Colour Blind Mode and Rumble Strength. The current Grapple (2.0) reads none of them; its only link is the comfort vignette. Should Grapple 2.0 get these back (work for a coding session), or is the vignette enough? | |
| AC-Q2 | **Menus: Simple** hides Glow In The Dark's "Darkness (DarkDoomZ)" page as well as the Test and Debug links. Keep that page visible in Simple? | |
| AC-Q3 | All nine One-Handed keys ship unbound, and nearly everything ships off (Photosensitive Mode, Comfort Vignette, Sound Cues, Two-Hand Gestures, Rumble Backup). Any on out of the box? | |
| AC-Q4 | Glow In The Dark reads no Accessibility setting at all, Photosensitive Mode included, and FnF reads only rumble. Should either follow Photosensitive Mode? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| AC1 | With the current Grapple, punches, shoves and two-hand gestures are still read while you hang on the hook (the reader asks Grapple "climbing", "swinging", "reeling" and Grapple 2.0 answers none) | `Accessibility/zscript/rsqg/gestures.zs` 216-217; `Grapple/zscript/rsqgr/service.zs` 42-48 | |
| AC2 | Grapple's vignette is always full strength, not stronger the faster you move | `Grapple/zscript/rsqgr/core.zs` 836, 980, 1195 | |
| AC3 | Measure Standing Height shows nothing in the headset; the result is a console line only | `rsqa_qol.zs` 205-208 | |
| AC4 | No row clears a measured standing height and Reset All keeps it, so a height measured while sitting sticks until you measure again | `MENUDEF.txt` 102, 132 | |
| AC5 | Take more than about 3 seconds to close the menu after Measure Me and it can finish from a single instant, or much later, and silently turn Fit to My Body on with a wrong body. Not verified: assumes the game clock runs while the menu is open | `gestures.zs` 283-284, 300-311 | |
| AC6 | With Hold to Toggle, turning One-Handed off while a button is latched and on again makes the first press do nothing | `rsqa_core.zs` 95, 101-107 | |
| AC7 | Left-Handed then Right-Handed always returns you to control scheme 0, not your earlier right-handed scheme. Not verified that QuestZDoom has other right-handed schemes | `rsqa_hand.zs` 58 | |
| AC8 | "Punch Kept (ms)" changes nothing a player can see; no mod asks for punches or shoves | `gestures.zs` 819, 828 | |
| AC9 | Tick When Ready, Show Gesture Names and Watch Check do nothing unless a mod is asking or Two-Hand Gestures is on | `gestures.zs` 190-193 | |
| AC10 | Hold to Toggle moves nothing in Whip (it has no key) | | |
| AC11 | The four two-hand switches still gate RSQ Melee's moves when Two-Hand Gestures is Off | `gestures.zs` 690-693 | |
| AC12 | "Vignette on Knockback" fires on any sudden speed jump, your own leaps included | `rsqa_qol.zs` 227 | |
| AC13 | Invisible: Reset Every Mod's console count is too high (ShieldSaw, Melee, Whip, Grenade, Saber and FnF each count twice); nobody asks the service for "rumble", "taps", "seated.eye" or "stand.eye"; palms-out sends seconds held, not speed; `CVARINFO.txt` line 28's comment still names Grapple's Fire Hook key | `rsqa_qol.zs` 394-402; `rsqa_core.zs` 384-391; `gestures.zs` 765 | |

### Monsters

**Questions**

| # | Question | Owner |
|---|---|---|
| MO-Q1 | Out of the box nothing visibly changes: the set is "BD22 + XMVE Tiers", World Tier is 1, and all 17 ColorfulHell caps ship at 1 (everything rolls Common), so Black, White and EX bosses never roll in a map. The ladder only shows once a Boss win raises the World Tier. Is that the intended first-run experience? | |
| MO-Q2 | **World Tier** is a saved setting: a Boss win raises it and it carries into your next game until reset on the Test and Debug page. Should a new game start it at 1? | |
| MO-Q3 | With the default set, the whole ColorfulHell section of the main page (Extra Colours, Black Boss, White Boss, Drops) changes nothing in maps. Grey it out unless the set is ColorfulHell? | |
| MO-Q4 | Painted Colour Art is On but draws nothing without the twelve separate art pk3s. Say where to get them on the page? | |
| MO-Q5 | Tier Icons ship off. On out of the box? | |
| MO-Q6 | The Credits said Colourful Hell Plus's author "is still to be credited"; `CREDITS.txt` credits Dewzanity. The draft now names Dewzanity. The Credits also list coldcite's health-bar pictures, voxel models, brightmaps and decal pictures as in the pk3, and no such files are in the folder. Remove those lines? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| MO1 | "What Is It" answers "not ours, tier 0" for every Brutal Doom, XMVE or plain monster, which is every monster on the default set | `Monsters/zscript/monsters/RS_Retier.zs` 1145-1154 | |
| MO2 | At World Tier 14 or more, "One Tier Up" and "Whole Map One Tier Up" flash those monsters DOWN to White strength | `RS_Retier.zs` 748, 1160-1163, 1188-1190 | |
| MO3 | Raise World Tier far past 13 then lower it a little and ColorfulHell monsters drop below White though the World Tier is still above 13 | `RS_BDTier.zs` 1271-1272 | |
| MO4 | Turn "Colour Ladder On BD Monsters" off mid-map and every monster stays coloured and strengthened until the next map; World Tier moves made while it is off are never applied | `RS_BDTier.zs` 1046, 1248-1249 | |
| MO5 | Reset All does not reset the three `rs_chp_*` settings (Everlasting White Spidey and the other Plus alternates) | `MENUDEF.txt` 191; `CVARINFO.plusex` 5-10 | |
| MO6 | "Red Baron Form" also changes the Red Arch-Vile; its half-and-half value 2 has no menu choice | `baron/RS_Baron.zs` 171-179; `archvile/RS_Archvile.zs` 197-205 | |
| MO7 | "Cyan Shotgunner Dodges" switches the dodge of eight Cyan families | `archvile/RS_Archvile.zs` 499 and seven more | |
| MO8 | "Green Knight Leads Shots" also governs the Common Baron and Common Cyberdemon | `baron/RS_Baron.zs` 1142; `cyberdemon/RS_Cyberdemon.zs` 1145 | |
| MO9 | "Orange Revenant Variant" shows bare "0 / 1 / 2" with no meaning | `MENUDEF.txt` 115-120 | |
| MO10 | The White Arch-vile EX fight prints debug lines ("RSPLUSEX WVILE ...") to the player's console | `plus/RS_PlusEX.zs` 124, 181, 199 | |
| MO11 | The test spawn row can only spawn the Black EX of the Arch-vile and Cyberdemon, never their White EX | `RS_Diagnostics.zs` 54-71 | |
| MO12 | Extra Colours and Drops rows show their last pick, not the real settings, if those are changed on Test and Debug | `RSQ_MonsterMenu.zs` 525-531 | |
| MO13 | Extra Colours, Black Boss and White Boss only gate spawn rolls: a tier change or the World Tier still produces those colours | `RS_Retier.zs` 63-65 | |
| MO14 | Invisible: a per-map registry of roster monsters is built and never read; `RS_MonsterCommands.zs` is on disk but not loaded; `EXCLUDED.txt` lists files no longer there; the Diagnostics header still says ten families have an EX; Colourful Hell's ambush / bonus system (49 classes) is in and nothing fires it | `RS_Roster.zs` 132-155; `zscript.txt` 10; `RS_Diagnostics.zs` 11 | |

### Gun Bonsai VR (all of this is for the GBOVR pass)

**Questions**

| # | Question | Owner |
|---|---|---|
| GB-Q1 | The whole Grapple tree (14 upgrades) is never offered and the hook earns no XP: the repo's Grapple is 2.0, which does not answer Gun Bonsai VR. Rebuild the link in the GBOVR pass, or drop the tree from the page? The draft says "not offered with Grapple 2.0". | |
| GB-Q2 | **XP Source** ships on Damage. Style and Both need RSQ Score. Should the series default be Both? | |
| GB-Q3 | Never offered at all: Star Punch, Chain Choke, Slow Motion, Ammo Readout, Keys by Hand and the nine Distance Grab upgrades. Cut on purpose, or waiting? | |
| GB-Q4 | Gun Toss and Boomerang Gun need Tactical Rig's gun throwing, which ships off. Turn that on by default, or leave these two as opt-in? | |
| GB-Q5 | "No bosses" upgrades (executions, finishers, cuts, knockdowns) test only the engine's boss flag, which RSQ Miniboss never sets, so a Boss can be executed. Should a Boss count as a boss here? | |

**Likely bugs**

| # | What a player would see | Where | Owner |
|---|---|---|---|
| GB1 | With RSQ Grapple loaded you are never offered a hook upgrade, the hook earns no XP, and the Grapple XP slider does nothing | `GunBonsaiOffhandVR/rsq/zscript/up_hook.zs` 17, 201; `menudef.rsq` 118 | |
| GB2 | With XP Source on Style, Brutal Doom and stock Doom guns, gloves, the axe, the whip and the grenade never fill their own gauges; the player bar fills instead (Score names its tools `gun.pistol`, `glove.jab` and so on; this pack only knows `gun`, `glove`, `punch`, `kick`, `blade`) | `stylexp.zs` 127-133; `Score/.../tools.zs` 218-224, 357-359 | |
| GB3 | Headshot has no upper height limit and does not rule out a carried weapon as the thing that hit, so a blast from above a monster, or a saber cut, can count as a headshot. Where the saber's own position sits: not verified | `up_fists.zs` 840-847 | |
| GB4 | Adrenaline can be offered on plain Doom's fist or chainsaw and does nothing without RSQ SlowMo; Force Speed and Shield Wall are offered without it too | `up_melee.zs` 259; `up_saber.zs` 310; `up_shield.zs` 176 | |
| GB5 | With two sabers a Force power can be learned again on the off saber; only the higher of the two counts, so that level-up is wasted | `up_saber.zs` 133; `core.zs` 46 | |
| GB6 | A Boss can be executed, finished, cut apart or knocked down (see GB-Q5). Whether its ward blocks the killing blow: not verified | `up_melee.zs` 224; `up_fists.zs` 394; `up_saber.zs` 209; `core.zs` 366 | |
| GB7 | The status key pressed again does not step to the other hand's gun; the step happens the next time the screen opens | `menus.zs` 276-310; `EventHandler.zsc` 205 | |
| GB8 | Not verified: lowering an upgrade's level on the status screen may let it be offered again past its cap | `up_gloves.zs` 177-186 | |
| GB9 | Rows that do nothing alone, not greyed: Force rows without Saber, Style rows without Score, Berserk gauge rows without Melee, LegenDoom rows without LegenDoom. Without Score, Style and Both behave as Damage | `menudef.rsq` | |
| GB10 | Console only: the "each kill pays twice" warning still prints with XP Source on Style or Both, where it no longer applies | `up_melee.zs` 38 | |
| GB11 | From the Tactical Rig read (C1): Boomerang Gun level 1 never finds the holster the gun came from | `TacticalRig/zscript/rsqtr/rig.zs` about 1503, 1670, 2265 | |
| GB12 | From the Whip read (WP14): the Bola ties 2 monsters at most whatever the upgrade's level | `Whip/zscript/rsqwp/whip.zs` 2270 | |

## What the lane needs to rebuild

`RSQ_Grenade.pk3`, `RSQ_Melee.pk3`, `RSQ_TacticalRig.pk3`, `RSQ_Wheel.pk3`, `RSQ_DistanceGrab.pk3`, `RSQ_SlowMo.pk3` (and the READMEs inside the others that were
rewritten the same day: ShieldSaw, Saber, Grapple, DistanceGrab).
