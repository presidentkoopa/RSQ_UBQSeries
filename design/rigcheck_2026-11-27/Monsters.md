# RSQ Monsters: rig check 2026-11-27

Rig: **rig2** (`/home/claude/rigdata/run1_rig2.sh`, through `probes_MN/` wrapper `mnrun.sh`: a scratch copy of the rig per run,
deleted after it), Freedoom 2 MAP01, skill 3, rig only (no headset). Builds: `pk3/RSQ_Monsters.pk3` and
`pk3/RSQ_Controls.pk3` as committed with Part 1 (the owner's answers F1, F2, F3; F4 kept; F7 dropped).

Stacks:
- **Monsters alone** (runs K1-K8, F1, F2, F_look): RSQ_Monsters.pk3 + the test probe (and for F2/K1-K3 a second probe that
  reads RSQ Monsters' own family lookup).
- **Full stack** (runs D*, BD1, load_full): brutal22test6, BD22 VoxelPack, BD22 VR Reloaded 3.0rc, the four XMVE pk3s
  (04-07, XMVE not BDXM), then every series pk3 in `pk3/` but BDXM (`RSQ_BDXMTiers_*`), GunBonsaiVR (it needs Gun Bonsai:
  33 compile errors, MN_load_full first try) and Controls. RSQ Miniboss's Rank was turned off (`rsqmb_rank_on 0`) where a
  run sets the Monster Tier: with Rank on, MAP01's Rank Ceiling set it straight back to Common (seen in the first MN_D1b
  try, whose log the second try overwrote; Miniboss/CVARINFO.txt:103-104).

Test probe (TEST ONLY, never in a pk3 of the series): `probes_MN/mn_probe_zscript.txt` logs every monster death (MNDIE),
every actor spawned within 256 units of a death in the 300 tics after it (MNDROP: class, count; INV = an inventory item),
what of that still lies on the floor (MNFLOOR, items that were there before excluded), which drop spawner each pickup
came out of (MNVIA: nearest source spawned in the 4 tics before within 48 units; approximate where several sources
land on one body), the player's damage (MNDMG), a watched monster per tic (MNW: full-bright, health, alpha, position),
and every spawn of the 51 F6 classes (MNF6). `probes_MN/mn_monprobe_zscript.txt` prints RSQ Monsters' family for each
ColorfulHell body (MNFAM). Scripts: `logs/<run>_script.txt`; generators `probes_MN/gen*.py`. Frames:
`frames/Monsters/` (320x200 screenshots, sheets of 4-7; each one was looked at).

Kills are the probe's: the player's DamageMobj (Bullet unless noted), so Brutal Doom's own weapon deaths (fatalities,
headshot gibs by a real gun) are not what was tested.

## The owner's question: what do killed monsters drop on the floor?

**Answer: not only RSQ VisualRewards' bits and the series' rewards. Colourful Hell's own drops land too, in a Boss fight
and on a ColorfulHell map: its health bundle (Doom health bonuses, Brutal Doom's `HealthPlus`), its armour bundle,
backpack bundle, ammo, the medikit and weapons, as each monster's DropItem list says. The higher the colour, the more:
a Common or Green ColorfulHell monster drops little or nothing of its own; Red, Black and White ones drop bundles and
medikits. The medikits and stimpacks that cover the floor in most fights are RSQ Miniboss's built-in Champions' item
bundles, not Colourful Hell's. In a fight RSQ Miniboss takes a thrall's gun away (not the Boss's).** On the default BD22
XMVE set nothing of Colourful Hell drops: Brutal Doom's and XMVE's own drops, VisualRewards' bits, Champions' bundles.

| Case (run) | What appeared on the kills (class x count) | Lying 140-320 tics later | Frame |
|---|---|---|---|
| Boss fight, Monster Tier Common, defaults (Boss and thralls Colourful Hell's: Blue Shotgunner Boss, Green Spectres / Imp / Caco thralls) (MN_D1.log:5140-5179, 5345-5406; MN_D1a.log) | VisualRewards bits `RSQ_KRAmmoBit` 38, `RSQ_KRArmorBit` 25, `RSQ_KROtherAmmoBit` 10, `RSQ_KRHealthBit` 4; Champions `champion_Bundle` x3 -> `champion_HealthBonus` 69, `ArmorShardVOX` 44, `EasyClip2` 28, `AmmoShell` 12, `Stimpack2` 6, `Medikit2` 5, `AmmoCell` 6, `LightArmor`, `AmmoRocket`; LegenDoom Lite items. The Boss's own (Colourful Hell's DropItem list): `RS_CH_Shell` x2, Doom `HealthBonus` -> `HealthPlus` x2, `Shotgun` -> `ShotgunSpawner`; Score's `RSQ_ScoreLifeCrate`, `RSQ_KRGoldBit` 24 (D1.log:5368-5385) | all of these but the bits that flew to the player (D1.log:5391-5405) | `frames/Monsters/MN_D1b_fight_floor_thralls.png` (piles of medikits, health and armour bonuses, ammo by the bodies) |
| Boss fight, Monster Tier Red (MN_D1b: Black Imp Boss, Red Shotgunner and Caco thralls; MN_D4: Black Imp EX, Red Zombie / Demon / PE thralls; MN_D4b: Black Shotgunner Boss) | as above, plus Colourful Hell's own: thralls `RS_HealthBundle` (MN_D1b.log:4925, 5015, 5218), `RS_ArmorBundle` (D1b:5164, 5217), `RS_CH_ShellBox`, `RS_CH_Shell`, `RS_CH_Cell`, `RS_CH_SuperShotgun`, `RS_CH_Clip`, `RS_CH_RocketAmmo`, `RS_CH_SoulSphere` (MN_D4.log MNVIA 4944-5033, 5400-5403); the Boss's last death `RS_BackPackBundle`, `RS_CH_Medikit`, `RS_CH_ShellBox` x2, `RS_HealthBundle`, `RS_ArmorBundle` (MN_D4b.log:5461-5465), `HealthPlus` 31 | `HealthPlus` 24, `ArmorShardVOX` 53, `Medikit2` 2, ammo, `RSQ_ScoreLifeCrate`, gold bits, BD gun spawners from the Boss (MN_D4b.log:5515-5535); a thrall's gun removed by Miniboss ("RSQMB thrall drop: ShotgunSpawnerReplacer removed", D1b:4889, 4957-4958) | `frames/Monsters/MN_D4b_fight_floor_boss.png` (medikit boxes and armour shards by the Boss's body) |
| Monster Set ColorfulHell, normal map, Monster Tier Common (MN_D2a.log) | bits; Champions' bundle on a champion; Colourful Hell's `RS_CH_Clip` (4806); `ShotgunSpawner` / `ChaingunSpawner` (the Doom guns their DropItem names, BD's replacements) | bits, Champions' bonuses, guns (4809-4812, 4845-4848, 4875-4878) | `frames/Monsters/MN_D2a_chmap_common_floor.png` |
| Monster Set ColorfulHell, normal map, Monster Tier Red (MN_D2b.log, MN_D5.log) | `RS_HealthBundle` -> `HealthPlus` 9 (D2b:4848, 4853), `RS_CH_ShellBox`, `RS_CH_Shell` x2, `RS_CH_SuperShotgun` (D2b:4850-4852), `RS_ArmorBundle` -> `ArmorShardVOX` 6, `RS_CH_RocketAmmo`, `RS_CH_PlasmaRifle` (D2b:4902-4907) | `HealthPlus` 9, the SSG and plasma rifle spawners, ammo, armour shards (D2b:4862-4873, 4912-4921): no Miniboss here, so the guns stay | `frames/Monsters/MN_D2b_chmap_red_floor.png` (blue health bonuses, a gun, bits) |
| Default set BD22 XMVE (MN_D3a.log) | Brutal Doom / XMVE drops (`Rifle`, `RifleSpawner`, `AmmoRocket`, `SoulAmmo`), bits, Champions' bundle; no `RS_` drop class at all (5179-5196) | `Rifle`, bits, Champions' bonuses (4862-4865, 4966-4972) | `frames/Monsters/MN_D3a_bd22xmve_floor.png` |

## F1, F2, F6

- **F1 (Monster Tier 13 in the console, Monster Set ColorfulHell, a new map): WORKS after the fix.** Before (HEAD's
  pk3): all 18 map monsters White bosses, `RS_WhiteZombie1` x11, `RS_WhiteSG2` x4, `RS_WhiteImp2` x3, plus 24
  Special Imps (MN_F1_before.log:70-78). After: all Red, `RS_RedZombie` x11, `RS_RedSG` x4, `RS_RedImp` x3, highest
  tier 10 with the setting at 13 (MN_F1.log:70-77); a later spawn Red (MN_F1.log:79).
- **F2 (a Spectre stays a Spectre): WORKS** (MN_F2.log, Extra Colours FireBlu and Abyss switched on for the test). A
  FireBlu Spectre spawned FireBlu is `RS_FireBluSpectre2`, Spectre family, stealthy (line 70), and follows the Monster
  Tier: 1 -> 2 made it the Red Spectre (Gray off, stepped past), still stealthy (76). An Abyss Spectre spawned Abyss
  (the Demon's body) is marked Spectre (71) and rose to the Black Spectre, not the Black Demon (77). A Purple Spectre
  changed to 8, 11, 12, 13: FireBlu Spectre (stealthy) -> Abyss body marked Spectre -> `RS_BlackSpectre2` ->
  `RS_WhiteSpectre2`; the Red Demon beside it went Demon all the way (99-134). First try failed for the natural Abyss
  Spectre (the gate's mark came after the spawn event: fixed by marking the returned body, spectre/RS_Spectre.zs:166).
  Frame: `MN_F_look_tint_flash_spectre.png` 6-7 (the Purple Spectre, then the FireBlu Spectre all but invisible; log
  MN_F_look.log:176, 186). Note: the Abyss, Black and White Spectre bodies are Colourful Hell's own and not stealthy.
- **F6: nothing spawns them. Confirmed.** No `MNF6 ... SPAWNED` line in any MN_ run (the probe watched all 49
  RS_MonEvents classes, `RS_CH_VoidOrb` and `RS_CH_BadItch` in every run, e.g. MN_D2a.log:5107, MN_D3a.log:5366:
  "0 spawns of the 51 watched classes"). In the code the only spawner of RS_MonEvents' classes is `RS_CH_BadItch`
  (chshared/RS_CHShared.zs:160-200), and no file spawns `RS_CH_BadItch` or `RS_CH_VoidOrb`.
- **The Void Orb's origin (asked 15:11), as the files say:** Colourful Hell's DECORATE had live lines
  `Dropitem "VoidOrb"` (MASTERMINDS.txt:3883, the Black Mastermind; :4979, the White), quoted by the port at
  zscript/monsters/mastermind/RS_Mastermind.zs:2395-2396 and :2713-2714 ("class defined NOWHERE in the CH tree.
  Itemised, not silently gutted") and RS_MastermindFX.zs:82-83. RS_CHShared.zs:294-298: "NO SUCH CLASS EXISTS ANYWHERE
  IN CH -- a case-insensitive sweep of the whole tree returns only those two DropItem lines. So in CH the drop silently
  does nothing". So they were not commented out in Colourful Hell; they named a class that does not exist, and the
  port turned them into comments. `RS_CH_VoidOrb` is "an RS build, 2026-08-06, at the owner's direction" and "AN RS
  INVENTION, NOT A CH TRANSCRIPTION" (RS_CHShared.zs:292, :314), never hooked to those lines. Colourful Hell Plus's White
  Mastermind carries the same live line, stripped by the port (tools/plus_ex/handfix.py:13, plus/RS_PlusWhiteMind.zs:51).
  Colourful Hell's source is not in this repo: the MASTERMINDS.txt lines are as the port quotes them.

## Load checks

| Load | Result | Log |
|---|---|---|
| RSQ_Controls alone | loads, MAP01 | logs/MN_load_ctl.log:62 |
| RSQ_Monsters alone | loads, 18 kit monsters | logs/MN_load_mon.log:66 |
| Monsters + Controls | loads | logs/MN_load_both.log:67 |
| Full stack + Controls | loads; no error or warning from RSQ_Monsters or RSQ_Controls (the voxeldef errors and XMVE's duplicate classes are those pk3s') | logs/MN_load_full.log:38-39, 4747 |

## How to play, row by row

README lines are Monsters/README.md as committed with Part 1 (the Spectre row added at 38).

| README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY / CAN'T TEST) |
|---|---|---|---|
| Brutal Doom loaded: its and XMVE's monsters spawn as shipped, a kit each at the Monster Tier; at Common nothing changes (16) | WORKS | MN_D1.log:4817-4834 (RifleZombie, ShotgunGuy1, Labgal ... tier 1); MN_BD1.log:4765 "18 kit monsters, world tier 1", :4842 "281 get a kit"; Common kit dm 1.00, hp = base (MN_K1.log:204) | |
| Without Brutal Doom: Doom's monsters, the same kits (17) | WORKS | MN_K1.log:123 "DoomImp family 3 entry 1 rung 1"; MN_load_mon.log:66 | |
| Set Monster Tier: within 8 tics every kit and ColorfulHell monster moves; later spawns at the new colour (18) | WORKS | set at t55, follow t56 (MN_K1.log:127); ColorfulHell map 5 -> 8: Yellow -> Red (MN_K4.log:74-82); Brutal Doom map 1 -> 4: "18 kit monsters ... follow" (MN_BD1.log:4843), a new spawn Purple (4874) | |
| The flash: 5-25 tics, every 3 tics the coming colour full bright, then the change (19) | WORKS | full bright 3 on / 3 off t57-t78, changed t79 (22 tics) (MN_K1.log:129-151); frame `MN_F_look_tint_flash_spectre.png` 3-4 (full-bright purple), 5 (purple after) | a second change during the flash (restart) not tried |
| Kit numbers: health to x2.5 at Red, damage x1.11 Green to x1.83 Red, speed not lower, flinches less (20) | WORKS | imp 60 -> 70 ... 150 (x2.5), dm 1.11 ... 1.83, pain 200 -> 106 (MN_K1.log:214, 2676) | only the imp measured (Cacodemon, Lost Soul, Arachnotron figures not); Gray's x0.8 is its own row |
| Painted frame, else the tint (21) | CAN'T TEST (painted) | the tint: frame `MN_F_look...png` 5 (a purple imp) | the painted frames are the RSQ_BDXMTiers pk3s (BDXM): not loaded, by the rule |
| A coloured kit monster's corpse, limbs, gibs keep its colour; blood etc. their own (22) | WORKS | Brutal Doom Labgal at Purple: XDeath pieces, guts, brains, gibs "-> purple" (MN_BD1.log:4887-4968); a ricochet "-> none" (5112) | log only; no frame of the gore |
| Brutal Doom fatality keeps the colour, painted fatality frames (23) | CAN'T TEST | | needs a player fatality (melee kill by hand) and the BDXM art |
| Green: acid patch, 5 a second (24) | WORKS | "Poison 5 ... via RS_BDPatch" at t227 and t262 (MN_K3.log:122-123) | the patch's 3 s not timed |
| Blue: shots 20% faster, zap 8 (25) | WORKS | ball speed 12.0 vs 10.0 at Common (MN_K3.log:131, 141); "8 Plasma" (133) | |
| Purple: one more shot (26) | WORKS | two DoomImpBall each attack (MN_K3.log:150-151, 153-154) | the 6 degrees not measured |
| Cyan: ice slows you, hop when aimed at, ice a fifth, fire / melee x1.5 (27) | PARTLY | `RS_BDIceSlow` given on a hit (MN_K1.log:1004-1006); hop: sideways 8 units a tic at t90 (MN_K6hop.log:137-147); 20 -> 4 ice, 30 fire, 30 melee (MN_K1.log:939-941) | half speed not measured (the rig's player stands still). The hop reads the weapon hand's aim, not the view: with the rig's default hand pose (aim -90) it never hopped (MN_K5.log:118-307) |
| Brown: heals 5% every 3 s, nearest gets a 2 s shield (28) | PARTLY | `RS_BDShield` spawned (MN_K1.log:1816-1818); the hurt imp 60 -> 65 of 110 (1600, 1843) | one heal seen in 230 tics, not one every 3 s |
| Yellow: flame patch, 2 fire every 10 tics, fire half, ice x1.2 (29) | WORKS | Fire 2 at t2020, 2030, 2040 ... (MN_K1.log:1964-2020); `RS_BDPatch`; 20 -> 10 fire, 24 ice (1889-1890) | |
| FireBlu: twin shots, fire a quarter, death blast 64 over 128 (30) | WORKS | two balls at one tic (MN_K1.log:2255-2256); 20 -> 5 fire (2169); 57 Fire at 72 units on its death (MN_K3.log:479) | |
| Gray: x0.8 speed, never flinches, 0.65 (explosions half) (31) | WORKS | spd 6.40/8, pain 0 (MN_K1.log:2419); 20 -> 13 (2422) | explosions not tried; grey shots not looked at |
| Red: rage at half, x1.4 speed, ice x1.4, 3-5 bolts on death (32) | WORKS | speed 14.0 at 62/150 (MN_K1.log:2888); ice 28 (2681); 3 `RS_BDBolt` (2895-2897) | |
| A summon takes the higher colour (33) | WORKS | a Purple Pain Elemental's Lost Soul is Purple (MN_K5.log:335-338) | master-linked summons not tried |
| A monster rising out of a coloured body takes its colour (34) | CAN'T TEST | | no mid-map rise staged |
| ColorfulHell monster killed with ice: no statue (35) | WORKS | RS_GreenImp killed by Ice: icecorpse 0 (MN_K3.log:1167-1168) | |
| ColorfulHell tier change: body swapped, keeps the share lost, Champions, LegenDoom, UE, Score place; no kill (36) | PARTLY | Green Imp 35/70 -> Yellow Imp 113/226 (MN_K3.log:1181-1194) | the carry of Champions / LegenDoom / UE / Score's place and "no kill" not checked here |
| A changed body stands on ladder health (37) | WORKS | FireBlu Spectre from a change 336 vs 205 spawned (MN_F2.log:70, 83) | |
| A ColorfulHell Spectre past Yellow stays a Spectre (38) | WORKS | see F2 above (MN_F2.log:70-134) | Abyss / Black / White Spectre bodies not stealthy (Colourful Hell's) |
| Boss fight: Boss and thralls from Colourful Hell at the fight's colours; no tier change in the fight (39) | WORKS | "world tier 10 -> miniboss Black(12) (RS_BlackImp1)" (MN_D1b.log:4764); `rs_retier_all 13` moved the 18 map monsters, the fight's stayed 4 / 7 (MN_BD1.log:5207-5211 vs 5252-5256) | |
| EX boss: "A chill runs down your spine" (40) | WORKS | MN_K8.log:187 (RS_WhiteArchEX) | |
| Time to die (41) | CAN'T TEST | MN_K8.log: the hit went to its minion (RS_WhiteVileResser), no steal or End of Time in 1400 tics | |
| ColorfulHell railgun: a travelling head at No More Hitscans' speed (80 without) (42) | PARTLY | `RS_TravelBeam` heads at speed 80.0 from a Red Zombie (MN_K8.log:118-122) | stepping out of its path and SlowMo not tried |
| Kill a ColorfulHell monster: Colourful Hell's bundles (43) | WORKS | see the drops table (MN_D2b.log:4848-4905; MN_D4b.log:5461-5465) | "Health Drops also sets the armour bonuses" not tried |
| Test and Debug spawn row: 160 ahead, dormant, console names it (44) | WORKS | "RSDIAG spawned C0001 RS_CommonImp (Imp)", "... dormant" (MN_K3.log:1258, 1276-1277) | distance not measured; grey rows are menu-only |
| Spawn All (45) | WORKS | 14 rows of the Imp family (MN_K3.log:1281-1294) | the 72 units not measured |
| Wake (46) | WORKS | "rs_diag_wake: 14", none dormant after (MN_K3.log:1380, 1399-1412) | |
| Diagnose (47) | WORKS | class, name, health, ladder tier (MN_K3.log:1336-1350) | |
| Remove All (48) | WORKS | "rs_diag_clear: 14", 0 living (MN_K3.log:1414, 1416) | |
| What Is It (49) | WORKS | kit: "family DoomImp, rung 10 (entry 1), tier 10" (MN_K2.log:126); ColorfulHell: "ColorfulHell family RS_ImpColourset, tier 2" (MN_K3.log:1184); "EX+2" (1099) | |
| One Tier Up: a kit passes White (EX), ColorfulHell stops at White, a fight's monster refuses (50) | PARTLY | kit rung 14, 15 "EX+2" (MN_K3.log:1097-1099); "RS_YellowPE is in a Boss fight: it keeps its tier" (MN_BD1.log:5275) | the ColorfulHell stop at White not shown (the aim took a White Imp's Special Imp, K3.log:1226); two inside one flash not tried |
| Map One Tier Up (51) | WORKS | "queued 1 monsters one tier up", rung 9 -> 10 (MN_K2.log:2510, 2513, 2542) | |
| God Mode row (52) | CAN'T TEST | | menu row (`god`, MENUDEF.txt:278); the menu was not driven |
| `rs_retier 7` (53) | WORKS | "DoomImp -> tier 7", rung 7 (MN_K2.log:2477-2478) | `rs_retier 15` gives 13 (K2.log:1796-1797), as the row says 1 to 13 |
| `rs_retier_all 9` (54) | WORKS | "queued 1 monsters for tier 9", rung 9 (MN_K2.log:2481, 2510) | |
| `rs_bdtier_dump`, `rs_bdtier_classes`, `rs_carry_dump` (55) | WORKS | dump (MN_K2.log:2542), classes "162 monster classes loaded" (2614), CARRYDUMP (2615-2616) | |
| Abyss kit: see-through 1 s, half passes, blinks, rises once 3 s on (56) | WORKS | alpha 0.35 t122-t156 after a hit (MN_K2.log:152-187); a 100 hit while see-through passed whole (MN_K3.log:492; the code passes each hit with chance 1 in 2); "blinked 752 units" (MN_K2.log:359); died t162 (193), living again at tier 11 later (632-634), no new imp spawned | the 3 s rise not timed to the tic |
| Black kit: 0.6 taken, two arrive at half, 8 bolts and a burst (57) | WORKS | 10 -> 6, 300 -> 180 (MN_K2.log:671, 714); two DoomImp at tier 10 (717-720); 8 `RS_BDBolt` (1181-1188) | the dark burst not looked at |
| White kit: as Black, blinks every 8-12 s, calls again at a quarter (58) | PARTLY | one hit to 27/276 brought 4 helpers (half and quarter calls) (MN_K5.log:353-357) | no blink seen: "found no room to blink" twice (MN_K3.log:703, 712) |
| Past White: +10% health, +5% damage a step (59) | WORKS | rung 15: hp 334 (276 x 1.1^2), dm 3.37 (3.06 x 1.05^2) (MN_K3.log:1128) | Red rage and Abyss phase on it not observed |
| Monster Set ColorfulHell: every Doom monster Colourful Hell's from the next map; Common under default caps; six projectiles (60) | WORKS | MN_D2a.log:4752 (set 3), Common bodies (4782-4949); `Rocket` -> `RS_Rocket2`, `BaronBall` -> `RS_BaronBall2`, `DoomImpBall` -> `RS_DoomImpBall2` (MN_K4.log:126-127; MN_K7.log:77) | |
| Monster Tier Cyan / FireBlu with extra colours off: Yellow / Red (61) | WORKS | tier 5 -> Yellow, tier 8 -> Red (MN_K4.log:74-82) | |
| Raise a spawn cap: the family rolls its own weights (62) | WORKS | Imp cap 13, 21 spawns: Common 6, Green 8, Blue 2, Purple 2, Yellow 1, Gray 2 (MN_K4.log:245-251) | no Black / White in 21 rolls |
| Extra Colours On: Cyan etc. spawn (63) | WORKS | Monster Tier 5 on a new map: Cyan bodies (MN_K7.log:73-76) | Half not tried |
| Black / White Boss Off (64) | WORKS | Black off: a change to 12 stays Red (MN_K4.log:299, 366); White off: 13 -> Black (374, 389) | |
| EX Bosses (65) | WORKS | Always: 3 of 3 `RS_BlackImpEX` (MN_K4.log:406); Never: 3 of 3 `RS_BlackImp1` (425) | Rare not sampled |
| Drops preset (66) | CAN'T TEST | | a menu row that writes seven settings; the menu was not driven |
| Plus boss rows (67) | WORKS | Fusion: a change to 13 gives `RS_WhiteSPFusion` (MN_K7.log:238-239); Old Black Lost Soul (294) | the Mastermind row not tried |
| Tier Icons (68) | WORKS | `RS_ColorTierIconCH3` off a Blue kit imp once a second, `CH5` off a ColorfulHell body (MN_K3.log:1433-1440) | |
| Painted Colour Art off (69) | CAN'T TEST | | needs the BDXM art pk3s (not loaded) |
| Tiers off (70) | WORKS | kit rung 10 -> 1 "counts as 1", back to 10 when on (MN_K2.log:2406-2442); ColorfulHell spawns Common at Monster Tier 7 with Tiers off (MN_K7.log:480-483) | RSQ Miniboss's step with Tiers off not tried |
| On Tier Change (71) | PARTLY | Always Full: 63/226 -> 278/278 (MN_K3.log:1197-1206) | Keep Share on an instant change not tried |
| Colourful Hell's own switches (72) | CAN'T TEST | | not staged |
| Boss From / Thralls From (73) | PARTLY | Boss From Monster Set, Thralls From Map Monsters, BD22 XMVE set: the Boss was `RS_YellowCaco`, Colourful Hell's ("Cacodemon, from outside the map"), thralls 2 x Brutal Doom `ShotgunGuy1` and Colourful Hell's `RS_YellowPE`, `RS_YellowLSoul` ("from outside the map") (MN_BD1.log:4980-4988) | Monster Set / Map Monsters hold only for a family the map has; a Boss or thrall family from outside the map comes as Colourful Hell's |

## Not BROKEN, worth knowing
- RSQ Miniboss's Rank (on by default) set a console `rsq_mon_worldtier 10` straight back to Common on MAP01 (its Rank
  Ceiling); seen once, in the overwritten first MN_D1b try.
- The Boss's lives: a forced kill goes through them (the first MN_D1 run used a forced fallback; later runs hit without it
  and the lives held, MN_D4b.log:5272, 5326).
