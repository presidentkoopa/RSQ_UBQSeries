# The Big Boss (built 2026-11-16)

Owner, 2026-11-16 08:40: "An EX Tier Boss Bar is a good idea. For now let's build it such that every Boss we kill, the EX
bar fills by 25%, when maxxed, it calls in a Bossfight with an EX tier monster with thralls. Reward is a guarenteed
legendary kiosk with all epic or legendary loot or whatever." The EX-tier ones are called **Big Boss** (owner 08:40).

Built in RSQ Miniboss (`Miniboss/zscript/rsqmb/bigboss.zs`, with small changes to `bossfight.zs`, `tierup.zs`, `kiosk.zs`,
`hud.zs`, `service.zs`, `boss.zs`, `handler.zs`) and RSQ VisualRewards' banners (`rsqvr/banners.zs`: three new moments).
**Rig only, not headset-confirmed** (evidence: `Miniboss/docs/rig_2026-11-16_bigboss/`, and for the owner's answers of
09:5x `Miniboss/docs/rig_2026-11-16_bigboss_v2/`).

**Owner's answers (2026-11-16 09:5x)** on the first build's choices: the fight stays as built (a full Boss fight: EX health,
3 lives, 3-5 thralls); **arrival: "both, same rules. on a timer or we call"**; **the bar black with a red edge** (gold was
provisional); **the kiosk: five Epic offers instead of LUCKY**. Everything else as built.

## 1. The Big Boss bar

- **Where:** beside the Boss meter in the top stack, the same size: the two rows (icon, gap, bar) side by side, 1.2 bar
  thicknesses apart, the pair centred where the Boss meter alone stood (under Score). RSQ SlowMo's rows under it are
  unchanged: the meter still answers `meter.x` / `meter.w` / `meter.h` as the centred slot, so they stay centred under Score.
  Off (Big Boss off): the Boss meter alone, as before.
- **How it is made:** exactly as the Boss meter (one shared draw, `hud.zs` BarBody / BarIcon): coldcite's well and fill
  (`RSQMBHE` / `RSQMBHW`), 8 tinted steps, the sweeping band, the breathing edge; full, the beat, the brighter band and
  the glint. Photosensitive Mode as the meter.
- **Colour: black with a red edge** (owner 09:5x): the fill near black in its 8 steps (the blocks still read), a red border
  round the bar, the sweeping band, the breathing edge and the full beat in red; the red border beats when full. Beside the
  Boss meter (red while it fills, gold when full) the two never read alike.
- **Icon:** the Boss meter's crowned skull made the Big Boss's: the skull and crown black, its outline red, a ruby in the
  crown, red eyes (`RSQMBEK0` dim / `RSQMBEK1` lit, 16 x 16, `Miniboss/tools/gen_exbar.py`); it fills from the bottom with
  the bar.
- **Fills:** +25% for every Boss won (the BOSSWIN moment: a called-in fight's Boss killed by a player, `tierup.zs`
  TierUpOnKill). A Big Boss won adds nothing. Full, it stays full until its Big Boss comes. The fill glides up over 20 tics
  as the meter's does; on a new map or a load it shows what it holds at once.
- **Kept** on the player (`RSQMB_Meter.exFill`, an inventory token): it rides the save and every map change, as RSQ
  Score's gold bank does, and is kept through a death's reload the same way (the bar at death written to
  `rsqmb_ex_keep`, noarchive, "<map>|<fill>", and given back, the larger, when that map loads again).
- **Hidden** with the Boss meter: while any Boss or Big Boss fight runs (from its arrival until its Boss is dead or gone),
  with Show Meter off, and with Bosses off.
- **Empties** when the Big Boss fight starts (its bind: the monsters have landed and are bound as the set piece).

## 2. The Big Boss fight

- **When (owner 09:5x: "both, same rules. on a timer or we call"):** the bar full makes a Big Boss due, and it comes by
  exactly a Boss's rules: **called in** (the watch check + Use; or the Start Fight card on the inside of the off wrist,
  which skips the guardrails) **or by itself** Arrives By Itself (`rsqmb_bf_auto`, 60 s) after the bar filled. Then the
  Boss fight's guardrails: Too Early, Cooldown, Low Health, Near Exit, Too Busy, No Room (Ignore Spawn Restrictions works
  on it as on a Boss); **never held by the Map Limit**, and it does not count against it. While it waits the line under
  the pair says why: `No Big Boss: Cooldown`.
- **Which one the player calls:** while a Big Boss is due, every call is the Big Boss's (it goes before a full Boss meter;
  the Boss meter keeps filling and waits). The Start Fight card says so: **BIG (skull) BOSS!**, the banners' red letters
  and the black skull edged red on a red-bordered card (`RSQMBWC2`, `gen_exbar.py`), in place of the gold **START (skull)
  FIGHT?** of a Boss; grey **FIGHT NOT READY** when nothing can be called. The full Big Boss bar beats beside the meter.
- **The machinery is the Boss fight's** (`bossfight.zs` PlanArrival / StartArrival / ArrivalStep, `handler.zs` Bind,
  `fight.zs`): the same thralls (3-5, the world tier's colours), beams, landing slow motion and dark, the charge, the
  segments and shield, the lives, greed, inherited powers, legendary thralls, music. Only the monster is different.
- **The monster: an EX-tier monster of RSQ Monsters**, from the **Big Boss pool** (built once a map, `bigboss.zs`
  ExPoolBuild), so a new EX boss joins without an edit to RSQ Miniboss:
  1. **Every loaded monster class whose name ends in `EX`** (RSQ Monsters' own definition of an EX form: RS_TierLadder
     IsEXName, its `ex` request) **that RSQ Monsters puts at a boss colour** (its roster service, by name, answers
     `class.tier` Black 12 or White 13). Today: Colorful Hell's ten EX bosses (Black Imp, Cacodemon, Hell Knight,
     Revenant, Mancubus, Spider, Chaingunner and Zombie EX; White Shotgunner and Lost Soul EX). The EX projectiles are not
     monsters and the EX minions have no ladder tier: left out. **A new EX boss named `RS_<gate>EX` whose gate is on the
     ladder joins by itself** (e.g. the Colourful Hell Plus Cyberdemon / Arch-vile / Arachnotron / Spectre EX bosses being
     ported into `Monsters/zscript/monsters/plus/`).
  2. **The registry:** every lump named **`RSQBIGBS`** in any loaded pack (`RSQBIGBS.txt`; all of them are read, so each
     pack adds its own), one monster class name a line, `//` comments. An EX boss that is not named `*EX`, or not on the
     ladder (e.g. a White Mastermind, a Fusion White Arachnotron), joins here. A name that is not a loaded monster class
     is passed over (Debug Log says so).
  - **The pick:** the pool's EX bosses of a family on this map come first (the map's roster types, matched by RSQ
    Monsters' gate, `set.class` at 12 / 13 + `EX`, or by the Boss bar's clean name: IMP, CYBERDEMON ...), one at random;
    else any of the pool at random. Empty pool (no RSQ Monsters, nothing registered): the map's strongest type.
- **The Boss bar** (`bossbar.zs`, unchanged) carries the Big Boss's health: its clean name + WARLORD (an EX class has no
  vanilla ancestor, so the bar's own rule names it: IMP WARLORD, CHAINGUNNER WARLORD; Benellus' tag for the White
  Shotgunner EX), the slant, GUARD, the x count, the clock, the thralls.
- RSQMB_Service: `bigboss` (with a monster: 1 the Big Boss or one of its thralls; without: 1 while a Big Boss fight is on
  or landing), `ex` (the bar, 0..1000), `ex.ready` (1 full); `tier` answers 4 for a Big Boss.

## 3. Banners (RSQ VisualRewards, by name, the Arcade Gold style)

| Moment | Headline | Chips |
|---|---|---|
| `BIGBOSSINCOMING` | **BIG BOSS INCOMING!** (gold bands, the crowned skull), with BOSS INCOMING!'s siren (`RVQSIREN`, as the file is, once) | as BOSSINCOMING: the name, TIER n (the EX monster's own ladder colour: Black 12 / White 13), the thralls, FIGHT IN |
| `BIGBOSSWIN` | **BIG BOSS DEFEATED!** | as BOSSWIN: TIER UP + the colour |
| `BIGBOSSLOSS` | **BIG BOSS WINS!** (red) | as BOSSLOSS: TIER DOWN + the colour, NO LEGENDARY |

VisualRewards reads `BIG` + a Boss moment as that moment with BIG in the headline (`banners.zs` Add); nothing else of
the banners changed. Test: `netevent rsqvr_bntest 10 / 11 / 12`. Without the banners: BIG BOSS DEFEATED! / BIG BOSS
WINS! over the monster, as the Boss's words.

## 4. The win

As a Boss win (world tier +1 with its words, RSQ Score's life crate, the "Miniboss Called" Score row), and **the Boss
kiosk** (`kiosk.zs`, the SOTN look) in place of its one legendary weapon (no separate legendary drop), with **five offers,
every one Epic** (owner 09:5x: "MORE offers instead of LUCKY"): LegenDoom's top rarity (each offer is a legendary weapon
already), **on five different guns where possible**: BD22 VR Reloaded rolls six as for a Boss (`roll`) and raises each to
Epic by its own `raise` (an effect LegenDoom rolls at Epic on that gun); up to ten rolls; with fewer than five guns that
have an Epic effect, a second Epic effect on a gun already offered fills the row. The five stand in one row 92 mockup
pixels apart, a little smaller than a Boss kiosk's three (guns x0.38, their boxes 88 wide, long effect names shrink to fit).
The LUCKY and REPAIR buttons are numbered apart from the offers now (8 and 9; the console door still takes 3 and 4 on a
three-offer kiosk). Epic's price (900 to start). No LUCKY button (nothing to
raise); the note line reads BIG BOSS: EVERY OFFER EPIC (both shown on the rig). The sign's second line reads BIG BOSS -
EPIC (in the code; above the rig frames' view, not shown).

## 5. The loss (mirrors BOSSLOSS)

A Score life spent during the Big Boss fight, or leaving the map with it on, is a loss exactly as for a Boss
(`tierup.zs` FightLost): the Big Boss and its thralls leave on beams (no legendary, no drops, no kill), the world tier -1,
BIG BOSS WINS! (on the next map, ~20 tics in, when the map was left). **The Big Boss bar stays empty** (it emptied when the
fight started): four more Bosses bring the next Big Boss. Dying with no life reloads the map (nothing counted; the bar as
it was at death comes back with the reload).

## 6. Options

- **RSQ Boss > Big Boss > Big Boss** (`rsqmb_ex`, on): off, no bar, nothing fills, no Big Boss.
- **Test and Debug > Big Boss Bar +25% (Test)** / **Big Boss Bar Empty (Test)**: `netevent rsqmb_exfill <permille>` (-1 =
  +25% as a Boss won, 1000 = full now, 0 = empty), with sv_cheats 1 or Debug Log on.

## 7. Shown on the rig (rig only, not headset-confirmed)

`Miniboss/docs/rig_2026-11-16_bigboss/` (probe `Miniboss/tools/rigtest/bigbossprobe`, `run_log.txt`):
- **bbp_mode 1, four real Boss wins:** two Boss fights called on MAP01, each Boss killed by the player: the bar 0 -> 25 ->
  50; MAP02 entered: 50 carried; two more: 75 -> 100, "No Big Boss: Cooldown" while it waits; the Big Boss (the pool
  10 EX bosses, the map's families first: RS_BlackCGuyEX) with 3 thralls, BIG BOSS INCOMING!, CHAINGUNNER WARLORD on the
  Boss bar, the bar emptied at the bind; killed: BIG BOSS DEFEATED!, TIER UP; the kiosk, every offer EPIC
  (`bar_fill_0_25_50_75_100.png`, `m1_*`).
- **bbp_mode 3:** the bar filled by the test door; the Big Boss (RS_BlackImpEX, 5 thralls) close up on the Boss bar; its
  thralls and then it killed; its kiosk opened: three EPIC offers at 900 G, BIG BOSS: EVERY OFFER EPIC, no LUCKY
  (`m3_*`).
- **bbp_mode 2, the loss:** world tier 3, a Score life spent by a fall in the Big Boss fight: the monsters leave on beams,
  BIGBOSSLOSS `tierdown:2|nolegendary:`, BIG BOSS WINS!, tier 3 -> 2, the bar 0 (`m2_*`).
- Script errors in every run: only BD_VoxelPack's four voxeldef lines; no VM abort.
- Seen on the rig: banners queue one after another, so in this compressed test (four Bosses inside two minutes, Score
  lives and +1UPs piling up) a banner can show later than its moment; with the 20 s cooldown BIG BOSS INCOMING! showed
  with its arrival.

## 7b. Shown on the rig after the owner's answers (rig only, not headset-confirmed)

`Miniboss/docs/rig_2026-11-16_bigboss_v2/` (`run_log.txt`):
- `bars_black_red_beside_red_boss_meter.png` (run bb_m4): the Boss meter 50% red beside the Big Boss bar 50% black with its
  red border; the Big Boss bar full (red band, beat) beside the meter at 50%; both full (the meter gold).
- `card_BIG_BOSS_inside_off_wrist_f00073.png`: the rig's off hand turned inside-wrist (qz_lhand), the card **BIG (skull)
  BOSS!**; Use (+use): "BIG BOSS CALLED IN (the Start Fight card: no rules)", the arrival (`after_card_use_*`: BIG BOSS
  INCOMING!, IMP WARLORD, TIER 12, 4 thralls).
- Run bb_m3: the watch-check call (`rsqmb_callin`): "BIG BOSS CALLED IN (watch check + Use)"; its kiosk
  `kiosk_five_epic_offers_*`: five offers, all EPIC at 900 G, on five guns (rocket launcher, pistol, plasma gun, shotgun,
  BFG), readable in the SOTN look.
- Run bb_m2t: the timer (Arrives By Itself 8 s): the bar full at t41, the Big Boss arriving by itself by t350.
- Every run: script errors only BD_VoxelPack's four; no VM abort.

## 8. Choices

Answered by the owner (09:5x): the fight as built (EX health, 3 lives, 3-5 thralls); both arrivals by a Boss's rules
(called in, or Arrives By Itself); the bar black with a red edge and a matching icon; five Epic offers instead of LUCKY.

Still standing, as built (the owner said "everything else as you built it"): the pair layout (the Boss meter moves left to
sit beside the Big Boss bar, the pair centred under Score); never held by the Map Limit; a Big Boss win also pays as a Boss
win (world tier +1, Score's life crate, the same Score row); Epic is the top rarity (LegenDoom has none above it); the bar
hides during every fight with the Boss meter; a loss leaves the bar empty.

## 9. screenblocks on the rig and in the headset

The rig's own ini has `screenblocks=12`; the owner's own `qzdoom.ini` has `screenblocks=11` (and `hud_toggled=false`). Every
HUD of this pack, and RSQ Score's, draws nothing at 12 by its own choice (`hud.zs` RenderOverlay: `screenblocks > 11`;
Score hides at 12): the full-screen, no-HUD setting (`togglehud` sets it). QuestZDoom's OpenXR mode
(`hw_openxrdevice.cpp`) sets screenblocks to 12 itself only while it renders the 3D scene and puts the player's own value
back in TearDown, before the HUD layer draws; the rig is that same unmodified engine code. So it is a setting, not a rig
artifact of the flat screen: with the owner's 11 the HUD draws in the headset as on the rig with 11; it would vanish there
too only if he chose 12 (or pressed togglehud).

## 10. Next: the Big Boss fight, rethought (owner 2026-11-16 10:59-11:32; design, not built)
The owner: "we need to rethink the EX tier boss arrival, maybe conceptually it is different than a miniboss fight".
- **The Big Boss is always an EX-tier monster** (Black or White EX; 16 in the pool with Colourful Hell Plus's).
- **Arrival: "the stage turns"**: the world freezes and dims, the siren, a House of the Dead style WEAK POINT card
  (blueprint grid, the monster sketched, its weak points circled, its name) fills the view, then it drops in front of
  the player with a shockwave. (Card mockup: to do.)
- **The fight: phases with a weak-point window** (name open: "Critical Window" in the owner's sketch, "maybe rename
  this"). Owner 11:32, his words: "the ex boss arrives and the fight begins, it takes damage sure but after it
  __something__, the crosshairs assemble over the weak point. they can be smaller on the body but highly visible
  somehow, successful elimination of a weak point drops the health of the boss by an amount equal to 10% of its total
  hp. getting all weak points adds an additional 20%, so if we accomplish all goals in the critical window we can
  damage it by an amount equal to 50% of its total hp / life bar (and it has several life bars, right), but after that
  it enters GUARD for a time and has our nice miniboss shield around it".
  - Three weak points per window, each with its own HP bar; our crosshairs assemble on them (fly-in: pieces start
    invisible far out and fade in as they fly together, then snap; owner likes the closing ring best).
  - Each weak point broken: -10%. All three in the window: +20% more (50% in all). The Boss bar shows the stake in
    yellow (the owner's sketch, `mockups/weak_points/owner_sketch_2026-11-16.png`; our version
    `mockups/weak_points/weak_points_real.gif`).
  - After the window: GUARD for a time, with the Boss fight's shield.
  - A break staggers it ("let's talk about this more").
- **Every Big Boss has its arrival card** (owner 12:13): the WEAK POINT card with its sketch and its weak points circled.
- **Personalities:** each EX boss gets its own; a dossier of all 19 EX / Plus bosses (attacks, tells, weak-point spots,
  a natural window trigger) is being written to go through with the owner.
- **Open:** what opens the window (the "something"); its name; 50% of the current life bar or of all its health; how
  long GUARD lasts and what happens in it; thralls (duel, waves, or as today) per boss; losing (the Boss fight's lives
  are the Boss's own: X3 refills; the player loses by spending a Score life or leaving the map); "Time to die"
  (White Arch-vile EX) and its death clock: decided (owner 2026-11-17), at zero it enrages instead of killing you
  (not built yet).
- Crosshair fly-in mockups: `mockups/crosshair_flyin/` (four styles; all ten RSQMBX assembling).

## 11. Big Boss #1: the Obsidian Tyrant (owner 2026-11-16 11:41-11:57; design LOCKED by the owner 12:02, not built)
Colourful Hell Plus's Black Cyberdemon EX, the Hell Smith (`RS_BlackCybieEX`, 24,000 before boosts; design/EX_BOSS_DOSSIER.md 15).
Personality: a blacksmith who forges earthquakes; slow, heavy, loud, every attack telegraphed by the hammer.
- **The window is called EXPOSED!** (owner's pick; for every Big Boss unless he says otherwise).
- **Arrival (the stage turns):** world freezes and dims, the siren, the WEAK POINT card (OBSIDIAN TYRANT, Hell Smith,
  head and both forge arms circled), then it drops in with a hammer slam: five pentagram lines crack out, a quake.
- **What opens EXPOSED!:** its own BigHell (invulnerable, a hellfire pentagram, 12 hammer slams x 8 shockwaves),
  survived, then its built-in exhaustion: **100 tics, kept at 3 seconds ("it's hard")**. A fallback timer forces
  BigHell if it hasn't come: **45 seconds** (owner 11:57).
- **Weak points:** head and both forge arms on its kneeling frame (HSMI N: about (64,72), (28,44), (112,58) in sprite
  pixels). -10% of the current life bar each; all three +20% (PERFECT!).
- **It summons during EXPOSED! too** (owner 11:51: "we want to have a challenge during Exposed. have it summon during its exposed window and during the guard state after"): portals open while it kneels, so the three weak points are broken under pressure.
- **GUARD after the window:** the Boss shield, and **its own portal summons (red-tier minions, Moloch wraiths) are the
  thrall wave**; the shield drops when they're dead, or after a time cap (owner: "yes, its summons are the wave").
- **Three lives as three acts (proposed):** 1 The Forge (hammer, triple fireballs, flame bolts, the reflecting
  charge); 2 The Smithy (adds lightning, homing fire, portal summons between windows); 3 Supersmith (faster, heals
  standing on its pentagrams).
- **Supersmith's pentagrams (owner):** when it plants one to heal, a **CRITICAL TARGET!** label with a line points
  down to the pentagram on the floor, with a **3-second countdown**. Each pentagram has **a small HP bar**; shoot it
  down. **Countdown runs out with it standing: SUPERSMITH+** (owner 11:57): faster, and its next BigHell has more
  slams; it lasts **until its next EXPOSED!**. Mockup `mockups/big_boss_tyrant/tyrant_critical_target_real.gif`
  (broken in time, then missed).
- Mockups: one EXPOSED! cycle `mockups/big_boss_tyrant/tyrant_exposed_cycle_real.gif` (slams shortened to 8; summons in EXPOSED! and GUARD); the arrival `mockups/big_boss_tyrant/tyrant_arrival_real.gif` (BIG BOSS INCOMING!, the world greys and freezes, the WEAK POINT card draws itself: the sketch, three circles, WEAK POINT, OBSIDIAN TYRANT / HELL SMITH TYPE EX-12; then it drops in: hammer slam, five pentagram lines, a quake, the Boss bar fills).

## 12. Big Boss #2: the Imp Warlord (owner 2026-11-16 12:02-12:10; design LOCKED by the owner 12:10, not built)
Smoking Black Imp EX (`RS_BlackImpEX`, 8,600 before boosts; dossier 3). Personality: a chain-smoking anime villain who
announces his special move.
- **Arrival:** the WEAK POINT card circles his head and both hands (the charge orbs).
- **What opens EXPOSED!:** his Kamehameha. He announces it at full volume (the whole map hears, HAAAAA!!), arms out,
  two charge orbs growing in his hands (AGUR F frame). EXPOSED! for 3 seconds. **The two orbs are weak points
  (CHARGE ORB!)**, the head the third.
- **Break both orbs before the clock ends: the beam is CANCELLED!** (he staggers). All three: PERFECT!. Miss: the
  railgun beam fires at you.
- **He calls BACKUP first** (owner 12:1x: "he will need to summon backup so he has a chance to charge n attack, the
  player needs a challenge"): his gang comes out of the smoke as he starts to charge, and they press in while the
  orbs grow.
- **The challenge during EXPOSED!:** the backup, and his Smokeout: beeping markers under you, then fire columns; keep
  moving while you shoot.
- **GUARD:** he vanishes in smoke (his own pain move) and reappears with the shield; his gang (imps of his family)
  comes out of the smoke as the wave.
- **Lives:** 1 his cone of fireballs and the slow seeking orb; 2 adds the seeker rain from above; 3 FINAL FORM: a
  third orb over his head, charges back to back.
- Smokeout in game uses his original art (owner 12:10: "we can use the og art in game"); the mockup's orange bars are
  placeholders.
- Mockup: `mockups/big_boss_impwarlord/impwarlord_exposed_real.gif`.

## 13. Big Boss #3: the Black Knight unleashed (proposed 2026-11-16 12:1x; design LOCKED by the owner 2026-11-17 05:2x, not built)
`RS_BlackRevenantEX` (7,500 before boosts; dossier 6). Personality: Monty Python's knight, except it works; refuses to
stay dead. His own kit gives three lives as three bodies.
- **Arrival:** the WEAK POINT card circles his helmet, sword arm and shield arm; he walks out of the fog with his own
  line, "None shall pass".
- **What opens EXPOSED!:** his shield. Hurt him and he raises a reflective, invulnerable shield (his own move): your
  shots bounce back. When it drops: SHIELD DOWN! and EXPOSED! (3 s). Weak points: SWORD ARM!, SHIELD ARM!, helmet.
- **The challenge during EXPOSED!:** his SQUIRES! (Hell Knight thralls) charge in while his guard is down; his
  bouncing nail mines.
- **GUARD:** the Boss shield plus his reflecting shield (shots bounce back at you); the squires are the wave.
- **Lives as bodies:** 1 the Knight (sword, shield, hook chain that pulls you in, dart cleave); 2 "Just a shade wound",
  his wraith (flies through walls, fire rain, soul seekers; EXPOSED! when it solidifies to cast); 3 the Black Knight's
  shadow with the wraith behind it (the shadow walks at you through walls; break the wraith's weak points and the
  shadow falls with it, as in his original).
- **Pace (owner 2026-11-17):** he raises the shield on most hurts, so only one shield drop in each ~20 s opens EXPOSED!;
  the others just drop.
- Mockup (life 1): `mockups/big_boss_blackknight/blackknight_exposed_real.gif`.

## 14. Big Boss #4: the thing from the bog (proposed 2026-11-16 12:1x; design LOCKED by the owner 2026-11-17 05:2x, not built)
`RS_BlackFatsoEX` (18,000 before boosts; dossier 7). Personality: a swamp god with indigestion. Resists plasma.
- **Arrival:** the WEAK POINT card circles his belly, head and shoulder.
- **What opens EXPOSED!:** his Burp wind-up (GULP... GULP..., the belly glows green: BDEM H/I frames).
- **Weak points:** BELLY!, head, shoulder. **Break the belly and the burp BACKFIREs** on him (he chokes on his own
  acid); all three: PERFECT!. Miss: the burp comes out at you as crawling blobs and acid puddles.
- **The challenge during EXPOSED!:** BURP BLOBS! crawl at you and leave acid puddles you must step around.
- **GUARD:** his swamp spawn (Mancubus-family thralls) are the wave.
- **Lives:** 1 the weaving orb fans and bombs; 2 adds ground splashes and the Burp; 3 the swamp rises: puddles spread
  and merge, he's faster.
- **The Burp from Act 1 (owner 2026-11-17):** in his original kit the Burp is phase 2 only; ours has it from life 1 so
  EXPOSED! can open; the ground splashes stay for life 2.
- Mockup: `mockups/big_boss_bog/bog_exposed_real.gif`.

## 15. Big Boss #5: BENELLUS, GOD OF SHOTGUNS, ANGRIER (proposed 2026-11-16 12:1x; design LOCKED by the owner 2026-11-17 05:2x, not built)
`RS_WhiteSGEX` (12,537 before boosts; dossier 9). Floating, winged. Personality: a deity whose only sacrament is
buckshot.
- **Arrival:** the WEAK POINT card circles his face, and the two ghost guns that will appear beside you.
- **What opens EXPOSED!:** his ShotgunRounded: a spark charge (BEHOLD!), then **two ghost shotguns appear either side
  of YOU** and fire after a beat (his own move).
- **Weak points:** the two GHOST GUN!s beside you (turn your head and shoot left and right, a VR move) and his face.
  Break both guns before they fire: UNLOADED!; all three: PERFECT!.
- **The challenge during EXPOSED!:** his two Shotgun Shrines (800 HP turrets) spray sparks at you.
- **GUARD:** the Shrines are the wave: SHOOT THE SHRINES! to drop the shield. He teleports on pain.
- **Lives:** 1 focused blasts and the wild spray; 2 adds his bouncing shotgun mines (Gifts); 3 ANGRIER: four ghost
  guns, two of them behind you. On death he rains shotguns.
- **Ghost guns hold for EXPOSED! (owner 2026-11-17):** his original guns fire after 13 tics; ours hold for the full 3 s
  of EXPOSED! before they fire.
- Mockup: `mockups/big_boss_benellus/benellus_exposed_real.gif`.

## 16. Before building (owner 2026-11-17)
All five designs (sections 11-15) are good to go; the owner wants to talk about the arrival card before building starts.
