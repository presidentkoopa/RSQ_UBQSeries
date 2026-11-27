# RSQ Score: rig check 2026-11-27 (agent C)

Rig: the scratch Linux headless QuestZDoom 17.3 rig, Freedoom 2, rig only, not headset. `rs_score_debug 1` prints, per
kill, every bonus row that paid with its share (`RS_Score[killer]: ... | Name 0.xxx`), the payment and the total.
Runs (logs in `logs/`, scripts `logs/C_s_<run>.txt`):
- **C_sc2 / C_sc3**: the full stack: brutal22test6, BD22 VoxelPack, BD22 VR Reloaded 3.0rc, then every series pk3 but
  Controls, Monsters, BDXM and GunBonsaiVR (Controls left out: its first-run "use RSQoopaControls?" box paused the game
  in C_sc1, whose times all froze at t34), probe last. Maps CRIG02 (a test room with 8 map monsters, which woke and
  fought each other, adding "everyone" kills) and CRIG01 (empty test room).
- **C_sc4**: Glow In The Dark, SlowMo, Score, Miniboss, VisualRewards, Graveyard on plain Doom (`rsqsm_down 0` from the
  map's load so a killing hit reaches Score's lives). **C_help2**: Controls + Score.
Kills are made by a test probe (DamageMobj with the player as source and a damage type; `c_shoot`: a real hitscan
LineAttack from the eye at a chosen height of the monster), the real rifle (trigger held), and monster-on-monster.
**Rank:** RSQ Miniboss's Rank starts at 48 here (RSQ Monsters not loaded), so every payment carries a Rank row
(x1.48 to x1.5): e.g. C_sc2.log:342-344 base 40 -> +59 (40 x 1.48).

| README claim (line) | Verdict | Evidence | What actually happened (BROKEN/PARTLY) |
|---|---|---|---|
| F1 / Read This! opens the series' How To Play with a SCORE tab; needs any RSQ series mod (14) | FIXED (was PARTLY: README) | frames/Score/help2_help_with_RSQ_Controls_f120.png: with RSQ_Controls loaded, `menu_help` opens HOW TO RIP AND TEAR with CONTROLS and SCORE tabs | without RSQ_Controls (Score + 5 other series pk3s, C_sc4 `menu_help`) the Freedoom help page opens (frames/Score/sc4_glossary_..._help_without_controls_f635.png); only Controls/MENUDEF.txt defines ReadThisMenu — **FIXED 2026-11-27 (README, no code change).** README line 14's Needs now says RSQ Controls: How To Play lives there (Controls/MENUDEF.txt is the series' only ReadThisMenu); without it the engine's own help pages open |
| Glossary page opens (15), opens on Style (18), Up/Down move the pick (16), Left/Right change tab (18), Page Down (17), the look (23) | WORKS | C_sc4 `openmenu RSQSC_Glossary` + `rs_score_glosstest` 2,2,4,5,3,3,1; frames/Score/sc4_glossary_style_f575_daring_f590_...png: RSQ SCORE GLOSSARY, six tabs in family colours, Style first, AIR picked after two Downs, Right -> Daring (ABYSS TIER), detail with Bonus / Needs. (A pointer can open a menu here: this rig drove it by the test cvar, not keys) | |
| Down with a real key event; Back closes (16, 20) | WORKS (rig2) | C_gl3.log:64 "RIGKEY t79 DownArrow tap (key 208) menu 1" -> the pick moves to the 2nd row; 67 "RIGKEY t125 Escape" -> the Glossary closes (frames/Score/gl3_glossary_realkey_down_f145_escape_closes_f215.png) | the right stick (qz_rstick 0 -1, 6 tics) moved nothing (frames f155-f205) |
| Enter does nothing (19); mouse clicks (21-22) | CAN'T TEST | not sent | |
| Base: the killed monster's spawn health, to the player whose blow killed it (25) | WORKS | C_sc2.log:320-323 map RifleZombie spawnhp 40 base 40; C_sc3.log:441 Baron 1200 base 1200; C_sc3.log:566 Cyberdemon 5000 | |
| Bonuses capped at 3 x base; each row on its own row for 35 tics, growing while shown (26) | FIXED (was PARTLY) | frames/Score/sc4_rows_curveball_kill_f60.png: Base +20, CURVEBALL +4, RANK +19, BLUE CHAMPION +5 (with its icon) under the bar | frames/Score/sc4_rows_after_SSG_kill_f130_f140.png: the next kill (t170, 115 tics later, Coach Gun 0.25 paid: C_sc4.log:254-257) shows BASE +40 and RANK +32 (both kills summed) and no COACH GUN row. The 3x cap was not reached in any kill — **FIXED 2026-11-27.** Cause: handler.zs AddRowAt added a kill's points onto a row while its tic was set, and ExpireRows cleared a row only 196 tics after (the slider's top), whatever Bonus Time said; the HUD hid a row after Bonus Time (35) but its value and its slot stayed: the next kill within 196 tics summed onto the hidden rows (BASE +40, RANK +32) and its new rows were drawn under the hidden rows' kept slots (Coach Gun, a Daring row, went to the right column's 4th-5th slot, off the frame). Fix: ShownTics (handler.zs): the row's own player's Bonus Time (a user cvar, read through his userinfo: the same on every machine), the HUD's clamp and fade, max(t, 18) tics; AddRowAt starts a row again from 0 once that time is over and ExpireRows clears it then. Rig F_sc4 (the same kills): t46 Curveball kill, then the SSG kill at t169, 123 tics later, Coach Gun 0.250 (F_sc4.log): frames/Score/F_sc4_coachgun_kill_t169_123tics_later_f376_f384_f392_f404.png: BASE +20, RANK +13 and COACH GUN +5 (right column, under RANK), fading out; two kills 13 tics apart (t232, t245): frames/Score/F_sc4_two_kills_13_tics_apart_t232_f452_t245_f472.png: BASE +20 / RANK +11 / SPREE +1, then BASE +40 / RANK +22 / SPREE +2 (growing while shown, as line 26 says) |
| Raised Monster Pay 100% (27) | WORKS | spawned (raised) monsters paid the same base as the map's own: C_sc2.log:320 (map) vs 342 (spawned), both base 40 | |
| A crusher / the level kills: nothing (28) | CAN'T TEST | not run | |
| Fill the reward bar: a Score life; bar length rounded to 5000 (29) | WORKS | C_sc2.log:766 "-> 8801 (threshold 5000) rewards 1 lives 2"; 789-831 rewards 2..6, lives 3..7; 836 banner "LIFEUP"; the census threshold 5000 for this map | |
| New game: 1 Score life (30) | WORKS | C_sc2.log:305 / C_sc4.log:241 "lives 1" at start | |
| A killing hit with a life held: revive at full health, blast, ring of fire, invulnerable 5 s, mags filled (31) | WORKS | C_sc4.log:286-292 "REVIVED at tic 559 -- health 100, 0 lives left; 0 magazine(s) refilled, invulnerable 175 tics", life.used slow 5000 ms, GITD life flash, banner LIFEUSED, Graveyard gold tombstone; frames/Score/sc4_revival_fire_f435_f445.png (the ring of fire) | magazines: plain Doom pistol has none (0 refilled) |
| Die anyway while holding lives (32) | CAN'T TEST | not run | |
| New map keeps total and lives (33) | CAN'T TEST | not run | |
| Gold life crate (34) | see Miniboss.md | | |
| Head shots: +30 on zombie kinds, at/above head height (35) | WORKS | C_ptest.log:63-66: hit at 29.4 of 56 = body, bonus 0; hit at 54.0 = HEAD, "bonus 30"; kill "Headshot row PAYS" | |
| Critical shots: 15% a shot, cyan, x2, stun (36) | FIXED (was PARTLY) | C_sc2.log: 26 RSQ_PlayerRound fired (CSPN lines 678-748), 5 rolled crit (19%); CRITICAL HIT 20 -> 40, stun Pain state (679, 698, 708) | Score also rolls "crit shots" on BD's non-shot missile actors: DistantFireSoundRifle 6, EmptyBrass 6, DecorativeTracer 6, PlayerMuzzle1 4, RifleCaseSpawn 3 rolls in the same burst (C_sc2.log:683-716) — **FIXED 2026-11-27.** Cause: crit.zs WorldThingSpawned rolled every bMISSILE whose target is a player (RandomCrits' rule). BD's brass, case spawners, muzzle flashes, far-fire sound carriers and decorative tracers are such missiles (brutal22test6 Casing.dec EmptyBrass +THRUACTORS, RifleCaseSpawn / PlayerMuzzle1 +NOINTERACTION +NOCLIP; Tracers.dec DistantFireSoundRifle +NOCLIP Damage 0, DecorativeTracer Damage 0) and never touch a monster. What a shot is, from the engine: a missile whose impact can land a blow (p_map.cpp PIT_CheckThing: a NOINTERACTION / NOCLIP actor never collides, THRUACTORS passes every actor, impact damage is GetMissileDamage, 0 for Damage 0). Fix: crit.zs Strikes() (the class's default flags: not NOINTERACTION, NOCLIP or THRUACTORS, Damage not 0) gates the spawn roll; a player's missile that harms only by exploding (BD's RocketExplosion, GrenadeExplosion: Damage 0, A_Explode) rolls once at its first blow (CritBlow, marker RS_ScoreCritRolled), so it is judged as before. No class names. Rig, full BD stack, crit chance set to 1 so every roll prints: F_bd2.log: 28 rifle shots spawned 6 EmptyBrass, 5 DistantFireSoundRifle, 6 PlayerMuzzle1, 5 RifleCaseSpawn, 6 DecorativeTracer (CSPN) and 28 rolls, every one RSQ_PlayerRound. F_bd1.log: rifle and shotgun: only RSQ_PlayerRound rolls (342-381); rocket: VanillaCyberRocket rolled at its spawn and crit its hit 350 -> 700, its RocketExplosion rolled at its first blow 82 -> 164 (391-397); a GrenadeExplosion spawned with the player as target rolled at its first blow and crit 640 -> 1280 (411-413); a DecorativeTracer and EmptyBrass spawned on a Baron: no roll. Note: BD's RocketBackblast(2,3) also rolled (391-394): a real Damage 12 +RIPPER missile behind you (Explosives.dec), so it is a shot by this test |
| Melee hitscan: no crit roll (37) | CAN'T TEST | not run | |
| Big moment asks SlowMo for 600 ms at 35% (38) | WORKS | C_sc2.log:431 Telefragged, 476 Redline, 515 Air, 545 Fatality, 797 Multi-Kill: "slow-motion pulse 600 ms at 35%" | |
| The HUD: Score: total, reward bar, one face per life, bonus rows in three columns (39) | WORKS | frames/Score/sc4_rows_curveball_kill_f60.png (needs `screenblocks` under 11: the rig's ini has 12, which hides every HUD) | |
| Menu or automap hides the score line (40) | WORKS (menu) | frames f570-f620 of C_sc4 (Glossary open): no score line | automap not run |
| Spree (41) | WORKS | C_sc2.log:351 Spree 0.025 (2nd kill of a run), 787-829 0.050 ... 0.175 | |
| Untouchable (42) | WORKS | C_sc2.log:764 Untouchable 0.150 after 21 kills unhurt, rising to 0.500 (811) | |
| Infighter (43) | WORKS | C_sc2.log:385-388 monster kills monster: "[everyone]" +71 = 40 x 1.2 x 1.48 | the debug line names no row on the "everyone" path; read from the amount |
| Switcharoo (44) | WORKS | C_sc2.log:764 Switcharoo 0.150 (rifle then shotgun fired, then the kill) | |
| Air (45) | WORKS | C_sc2.log:511-515 Air 0.922 at z 217+, big moment | |
| Curveball (46) | WORKS | C_sc4.log:245 Curveball 0.200 (monster behind the pillar) | |
| Coach Gun SSG +0.25, Scrap +0.125 (47) | WORKS | C_sc4.log:254 Coach Gun 0.250; C_sc2.log:527 Coach Gun 0.125 (Scrap) | |
| Darwin (48) | WORKS | C_sc2.log:403-407 monster kills itself: +178 = 40 x 3.0 x 1.48 | as Infighter: read from the amount |
| Telefragged (49) | WORKS | C_sc2.log:427-431 Telefragged 1.000, big moment | |
| Brawler (50) | WORKS | C_sc4.log:261-263 Fist in the main hand, a Melee-type blow: Brawler 0.500; the same Fist with a None-type blow (269-274) paid none | |
| Redline (51) | WORKS | C_sc2.log:461 at 20 HP 0.120; 472-476 at 4 HP 0.440 + big moment | |
| Swan Song (52) | CAN'T TEST | not run | |
| Point-Blank (53) | WORKS | C_sc3.log:310 Point-Blank 0.100 at 60 units | |
| Cleaved (54) / Combo (55) | WORKS | C_sc2.log:564 Boot + Cleaved 0.300 + Combo 0.100 | |
| Juggle, Ring Out, Counter, Knockdown (56-59) | CAN'T TEST | need a real punch/kick/whip sequence | |
| Skeet (60) | WORKS | C_sc3.log:320-324 monster thrown up, z 42: Skeet 0.250 | |
| No-Look (61) | WORKS | C_sc4.log:245 No-Look 0.300 (monster off the view) | |
| Blind-fire, Off-hand, Two Guns, Combo Chain, Variety, Weapon Master (62-67) | CAN'T TEST | need hand-separated firing or several melee tools | |
| Giant Slayer (68) | WORKS | C_sc2.log:594 Baron 1200, a Melee blow: Giant Slayer 0.500, Cleaved | |
| Death from Above (69) | CAN'T TEST | not run | |
| Multi-Kill (70) | WORKS | C_sc2.log:787-829 shotgun in hand: 0.300, 0.600, 0.750 (cap), big moment from 0.6 (797) | |
| Hold Streak (71) | WORKS | C_sc3.log:431 third kill with the trigger held: Hold Streak 0.150 | |
| Double Tap (72) | WORKS | C_sc3.log:397 pistol: Double Tap 0.200; C_ptest.log:67 | |
| Hand Cannon (73) | CAN'T TEST | no revolver fired | |
| Headshot row (74) | WORKS | C_sc3.log:348-349 "Headshot row PAYS", Headshot 0.250 (rifle) | |
| Sights Up (75) | WORKS | C_sc2.log:320 Sights Up 0.200 (918 units, straight ahead) | |
| Direct Hit, Rip and Tear, Justice Shot (76-78) | CAN'T TEST | not run | |
| Read It (79) | WORKS | C_sc2.log:309-312 "Read It armed"; 793 Read It 0.500 | |
| Fatality (80) / Boot (81) | WORKS | C_sc2.log:541-545 Fatality 0.500 big moment; 564 Boot 0.200 | |
| Rows 82-180 (BD22 VR axe, Melee, Saber, ShieldSaw, Whip, Grapple, Distance Grab, Tactical Rig, Grenade moves) | CAN'T TEST | each needs that mod's own hand move (punch kinds, sabre cuts, throws, holster draws, cooked grenades) driven on the rig; not run in this batch. The roll-dependent ones also need rig2 (`qz_aimroll`) | |
| Stretched Second (181) | WORKS | C_sc3.log:495-566 kills during DOWN's slow: Stretched Second 0.188-0.300 | |
| Last Grain (182) | CAN'T TEST | not run | |
| Revenge (183) | WORKS | C_sm3.log:440 "RSQ Score award "Revenge": 100" (SlowMo's side; Score answered 100) | Score's own debug was off in that run |
| Boss (184), Finisher (185), Chain Gang (187), Riot Control (188) | see Miniboss.md | C_sc2.log:555 "award Finisher paid 100" (a VR Finisher during the BD fight) | |
| Rank (186) | WORKS | C_sc2.log:321 "Rank x1.48: +23 on the Rank row" (Rank 48), every payment | |
| Champions rows (189-220) | PARTLY | paid: Blue, Violet, Orange, White, Dark Green, Black Champion 0.250; Ghost 0.250; Pinata 0.250; Glass Cannon 0.350 (Black, one blow from full); Too Close for Comfort 0.350 (Orange, a kick): C_sc2.log:511, 564, 781; C_sc3.log:349, 431, 456; C_sc4.log:245, 263 | the rest (Bronze/Silver/Gold/Titan/Undying/Balloon/Hybrid/Pop!/Streak/Rainbow ...) were not met in this batch: CAN'T TEST |
| LegenDoom rows (221-226) | CAN'T TEST | LegenDoom is not on this machine | |
| RSQ Monsters roster rows (227-246) | CAN'T TEST | RSQ_Monsters must not be loaded (job rule) | |
| Hit Stop: 115 ms plus ramp at 5%, a 400+ monster (247) | WORKS | C_sc3.log:445 Baron: "hit-stop pulse 265 ms at 5%" | |
| Wrist Score (248) | CAN'T TEST | not run | |
| Reward Ammo / None, New Map Keeps modes, Revival Fire off, tints, Head Shots off, Crits off, Show Score off, Bonus Time 0, roster switches, family caps (249-259) | CAN'T TEST | option variants not run in this batch | |
| Options table: Show Score "false", Reward Bar "false" (454, 458) | FIXED (was PARTLY) | the How To Play rows say On; in the game the score line and bar are drawn by default (rs_score_hide false: frames above) | the Options table's "false" defaults are wrong in the README (display only) — **FIXED 2026-11-27.** Cause: tools/readme/gen_readme_tables.py looked a bool cvar's default ("false") up in the menu's value table, numbered 0 / 1 (RSQSC_ShowOnOff: 0 On, 1 Off), found nothing and printed "false". CVARINFO is right (rs_score_hide / rs_score_norewards false = shown). Fix: the generator looks a bool default up by number too; regenerated: Show Score On, Reward Bar On (and the same wrong cells in GlowInTheDark, Miniboss, VisualRewards and Wheel's tables: Keep, Food, 404 Mode not found, Enabled, Sensible enemies only, Monsters, By Gun, Fan) |

## The Glossary list (Score/tools/glossary_source.md: 211 rows + 171 named combos = 382)
- **Produced and paid on the rig (35 rows):** Spree, Untouchable, Infighter, Switcharoo, Air, Curveball, Darwin (the
  classics, 7 of 13), Coach Gun (SSG and Scrap), Telefragged, Brawler, Redline, Point-Blank, Cleaved, Combo, Skeet,
  No-Look, Giant Slayer, Multi-Kill, Hold Streak, Double Tap, Headshot, Sights Up, Read It, Fatality, Boot, Stretched
  Second, Rank, Finisher (award), Revenge (award), Blue / Violet / Orange / White / Dark Green / Black Champion, Ghost,
  Pinata, Glass Cannon, Too Close for Comfort. Evidence: the rows above. All WORK.
- **Not produced, why:**
  - Melee / Saber / ShieldSaw / Whip / Grapple / Distance Grab / Tactical Rig / Grenade rows (about 120): need those
    mods' own hand moves driven on the rig; not in this batch (CAN'T TEST).
  - All 171 named combos: each needs two or three tools from those mods on one monster within 3 s; none was driven (CAN'T TEST).
  - LegenDoom rows (6): LegenDoom not on this machine. RSQ Monsters roster (20): Monsters may not be loaded.
  - Classics not met: Scrapping as its own row (paid as Coach Gun 0.125), Swan Song, Last Grain, Blind-fire, Off-hand,
    Two Guns, Hand Cannon, Direct Hit, Justice Shot, Rip and Tear, Death from Above: not run.

## Counts (claims table)
(2026-11-27 fix job: lines 14, 26, 36 and the Options table FIXED: now WORKS 38, FIXED 4, PARTLY 1, CAN'T TEST 17)
WORKS 38, PARTLY 5, BROKEN 0, CAN'T TEST 17 (table rows; several CAN'T TEST rows group many README lines) (the menu-key rows re-run on rig2).
