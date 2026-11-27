# RSQ Monsters: where each README claim comes from

Commit read: 678a73284 (2026-11-27). Paths are inside `Monsters/` unless they start with another mod's folder.
Short names: `R` zscript/monsters/RS_Retier.zs, `B` zscript/monsters/RS_BDTier.zs, `D` zscript/monsters/RS_BDTierData.zs,
`O` zscript/monsters/RS_Roster.zs, `C` zscript/monsters/RS_Carry.zs, `A` zscript/monsters/RS_BDArt.zs,
`S` zscript/monsters/RS_ScoreReadout.zs, `G` zscript/monsters/RS_Diagnostics.zs, `MR` zscript/monsters/RSQ_MonsterRows.zs,
`P` zscript/monsters/plus/RS_PlusEX.zs, `T` zscript/monsters/chshared/RS_TravelBeam.zs, `ZF`
zscript/monsters/zombieman/RS_ZombiemanFX.zs, `M` MENUDEF.txt, `V` CVARINFO.txt, `VP` CVARINFO.plusex. Each line number
is the line that does the thing.

What was read: every definition lump (MAPINFO, CVARINFO, CVARINFO.plusex, MENUDEF, RSQBIGBS, CREDITS, TRNSLATE,
TRNSLATE.plusex, TEXTCOLO, the SNDINFO.plusex header) and, whole, every system file: rsqmn_lookup.zs, RS_Act.zs,
RSQ_QuakeFeel.zs, RS_Roster.zs, RS_Retier.zs, RS_BDTier.zs, RS_BDTierData.zs, RS_Carry.zs, RS_BDArt.zs,
RS_ScoreReadout.zs, RS_Diagnostics.zs, RSQ_MonsterRows.zs, RSQ_MonsterMenu.zs (the shared menu copy), chshared/RS_CHShared.zs,
plus/RS_PlusEX.zs, and the heads of chshared/RS_MonEvents.zs and chshared/RS_TravelBeam.zs (its Fire and speed code).
The 34 family files and the nine Plus body files (about 80,000 lines of Colourful Hell's monsters, ported state by state)
were read by their class tables (every class, its Tag, Health and parent, by script), their spawn dials and gate stubs,
and every line that names a setting, a service or another mod; not every attack state. So the README names each
ColorfulHell monster and its health but does not describe each one's attacks. Not read: MonsterRecolour/, any BDXM file,
tools/, docs/ (owner's rule and the brief).

## Intro

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| I1 | Thirteen colours by strength, 1 Common .. 13 White | R:23, R:39, O:149 | RS_TierLadder.MaxTier; RS_RosterHandler.TierOf |
| I2 | Monster Set: Vanilla 0, BD22 XMVE 1 (default), ColorfulHell 3 | V:23, M:31, O:315, O:329 | RS_RosterHandler.CheckReplacement |
| I3 | Monster Tier is `rsq_mon_worldtier`, menu Common to Red | V:44, M:207, M:226, B:682 | RS_BDTierHandler.WorldTier |
| I4 | 17 families x 13 colours; the EX bosses; Plus bodies | R:38, R:65, P:10, P:22 | RS_TierLadder.ClassFor |

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | BD22 XMVE with Brutal Doom: no replacement; Brutal Doom found by three class names | O:315, O:317, O:252 | RS_RosterHandler.CheckReplacement; BDLoaded |
| H1 | Each monster with a family gets a kit at entry + Monster Tier - 1; at entry nothing changes | B:1119, B:1129, B:1133, B:1141, B:1146, B:87, B:220 | RS_BDTierHandler.WorldThingSpawned; RS_BDKit.Active; Look |
| H2 | Without Brutal Doom: Vanilla (the id class, replacement null) | O:318, O:329, O:332 | RS_RosterHandler.CheckReplacement |
| H3 | Every 8 tics the change is seen; kits move by the difference through RequestKit (flash); ColorfulHell bodies by their rung through Request | B:1302, B:1305, B:1325, B:1343, B:1344 | RS_BDTierHandler.WorldTick |
| H3 | New monsters take the map's tier | B:1141, R:1040 | RS_BDTierHandler.WorldThingSpawned; RS_Retier.WorldTier |
| H4 | Wait random 5..25 tics; every 3 tics the coming colour full bright, then its own; a new target restarts the wait | R:953, R:1207, R:1209, R:1210, R:1213, R:1179, R:946, R:977 | RS_Retier.Request; RS_RetierJob.Tick; FlashTrans; RequestKit |
| H5 | Health: even rise to min(family's tier-10 value, 2.5) at Red; family values Cacodemon 2.08, Lost Soul 2.4, Arachnotron 2.0 | B:142, B:145, B:146, B:148, D:14, D:15, D:21 | RS_BDKit.HPCurve |
| H5 | Damage table 1.11 Green .. 1.83 Red | B:181, D:83 | RS_BDKit.Apply; RS_BDTierData.Dmg |
| H5 | Speed never under x1, family table (x1.0 to x1.5 at Red); pain chance by family table | B:198, B:199, B:207, D:33, D:58 | RS_BDKit.Move |
| H6 | Painted frame by full path `rsrecolour/<colour>/<LUMP>.png`, else the tint; Painted Colour Art row | A:239, A:240, A:438, A:164, V:48, M:230 | RS_BDArt.Art; Tick; On |
| H7 | Pieces of a coloured body get its hue: master, maker, nearest removed or dead body | B:1047, B:962, B:965, B:974, B:1061 | RS_BDTierHandler.Carry; TintFrom |
| H7 | Blood, smoke, fire, sparks, casings, puffs, pickups keep their own look | B:834, B:846, B:862, B:865, B:1052 | KeepsOwnLook; OwnLookName; Carry |
| H8 | Fatality: GoFatality on the player; the last kill's colour; the player's frames from the art only | B:1264, B:1271, B:1276, B:1277, B:981, A:90, A:392 | Fatalities; TintFrom; RS_BDFatalHue; RS_BDArt.Tick |
| H9 | Green: shot mark kind 2, patch 105 tics; a hit leaves a patch, one a second; 5 poison a second within 48 + radius | B:1161, B:606, B:571, B:1202, B:586, B:587, B:581 | Shot; RS_BDShotMark.DoEffect; RS_BDPatch.Put; Tick; WorldThingDamaged |
| H10 | Blue: shot x1.2 speed; zap 8 plasma within 48 + radius, sight from the spot | B:1165, B:1164, B:614, B:615 | Shot; RS_BDShotMark.DoEffect |
| H11 | Purple: one twin 6 degrees off, once per attack tic | B:1169 | Shot; Twin |
| H12 | Cyan: ice-tinted shot; hit gives RS_BDIceSlow (35 tics, x0.5); hop every 20 tics, aim within 6 degrees, 1536 units, 40 in 100; ice x0.2, fire and melee x1.5 | B:1171, B:1204, B:523, B:524, B:313, B:380, B:378, B:381, B:240 | Shot; WorldThingDamaged; RS_BDIceSlow; DoEffect; Hop; ModifyDamage |
| H13 | Brown: every 105 tics, same side within 512: +full/20 health; nearest gets RS_BDShield 70 tics, half damage; tan sparks | B:314, B:399, B:401, B:405, B:414, B:489, B:496 | DoEffect; SupportPulse; RS_BDShield |
| H14 | Yellow: flame patch 70 tics; hits ignite: 2 fire every 10 tics for 70 tics; fire x0.5, ice x1.2 | B:1172, B:571, B:588, B:1205, B:636, B:511, B:241 | Shot; RS_BDPatch; RS_BDFx.Ignite; RS_BDBurn; ModifyDamage |
| H15 | FireBlu: blue twin 4 degrees off; fire x0.25; death blast 64 over 128 | B:1173, B:242, B:1237 | Shot; ModifyDamage; WorldThingDied |
| H16 | Gray: speed 0.8, pain 0, explosions x0.5, rest x0.65, grey shot | B:200, B:208, B:243, B:1174 | Move; ModifyDamage; Shot |
| H17 | Red: rage at half health or in Pain; x1.4 speed, pain 0, missile chance at most 0.125, red particles; ice x1.4; 3..5 bolts of damage 3 | B:90, B:318, B:201, B:208, B:211, B:324, B:245, B:1239, B:535 | RS_BDKit.Rage; DoEffect; Move; ModifyDamage; WorldThingDied; RS_BDBolt |
| H18 | A summon takes the higher of its colour and its master's; a Lost Soul within 128 of a kit Pain Elemental | B:358, B:367, B:370 | SummonerLink |
| H19 | Rising out of a body mid-map: the body's rung | B:1031, B:1144, B:1145 | BodyRung; WorldThingSpawned |
| H20 | Every RS_ monster: NOICEDEATH | R:1315, R:1316 | RS_RetierHandler.WorldThingSpawned |
| H21 | ColorfulHell change swaps the class; wound share; Champions, LegenDoom, UE carried; Score census moved; no kill counted | R:1059, R:1074, R:1076, R:1100, R:1106, R:1110, R:1132, C:87, C:400 | RS_Retier.Swap; ScoreHandOver; RS_Carry.Take; RS_CarryLast.Carried |
| H21 | On Tier Change default 1: full only on an instant change; the flash path is not instant | V:34, R:998, R:1002, R:1231 | RS_Retier.FullHealth; RS_RetierJob.Tick |
| H22 | Ladder health for a body from a change or a tier above Common; Black and White keep their own (0) | R:1022, R:1026, R:1080, R:1343, D:159, D:162 | RS_Retier.LadderHealth; RS_BDTierData.Envelope |
| H23 | A Boss fight's monsters: no change (RSQMB_Thrall, RSQMB_Ward with "miniboss", RSQMB_Called while landing) | R:825, R:831, R:837, R:844, R:916, R:965, B:1320, B:1342 | RS_FightHold.Bound; RS_Retier.Request; RequestKit; RS_BDTierHandler.WorldTick |
| H23 | Boss From default ColorfulHell, Thralls From default As Boss | V:29, V:30, M:244, M:246 | CVARINFO; MENUDEF |
| H24 | "A chill runs down your spine" in each of the 16 EX bodies' first states | zscript/monsters/zombieman/RS_Zombieman.zs:1881, zscript/monsters/chaingunner/RS_Chaingunner.zs:1667, zscript/monsters/shotgunner/RS_Shotgunner.zs:2141, zscript/monsters/imp/RS_Imp.zs:1617, zscript/monsters/cacodemon/RS_Cacodemon.zs:1808, zscript/monsters/lostsoul/RS_LostSoul.zs:1960, zscript/monsters/hellknight/RS_HellKnight.zs:1927, zscript/monsters/revenant/RS_Revenant.zs:2307, zscript/monsters/fatso/RS_Fatso.zs:1724, zscript/monsters/spider/RS_Spider.zs:1932, zscript/monsters/plus/RS_PlusSpectreEX.zs:64, zscript/monsters/plus/RS_PlusBlackArchEX.zs:62, zscript/monsters/plus/RS_PlusWhiteArchEX.zs:98, zscript/monsters/plus/RS_PlusBlackCybieEX.zs:83, zscript/monsters/plus/RS_PlusWhiteCybieEX.zs:86, zscript/monsters/plus/RS_PlusWhiteSpiderEX.zs:75 | the EX classes' Scripted states |
| H25 | Time to die: Steal of Time under 12,500 health or from act 2; armour steal: white blend, all armour, 20 damage, speed 0.25 for 10 s | zscript/monsters/plus/RS_PlusWhiteArchEX.zs:346, zscript/monsters/plus/RS_PlusWhiteArchEX.zs:351, P:141, P:143, P:144, P:145, P:258, P:259, zscript/monsters/RS_Act.zs:18 | StealofTime; RS_PlusEX.WVileArmorSteal; RS_WVileEXSpeedNerf; RSQMN_Act.At |
| H25 | End of Time (16 in 256 from ShouldI): the 300 s count, its lines, clock, quakes; at 10,500 tics invulnerable and TIMESUP (target held, velocity 0); killed: the count halts | zscript/monsters/plus/RS_PlusWhiteArchEX.zs:368, zscript/monsters/plus/RS_PlusWhiteArchEX.zs:385, P:194, P:195, P:221, P:223, P:224, P:233, P:237, P:244, P:218, zscript/monsters/plus/RS_PlusWhiteArchEX.zs:392, zscript/monsters/plus/RS_PlusWhiteArchEX.zs:394 | ENDOFTIME; RS_PlusWVileTimer.Start; Tick; TIMESUP |
| H26 | Travelling beam: the monster's own wind-up, head at nmh_projspeed (80), only the head deals the rail's damage; a real missile | T:96, T:182, T:183, T:184, T:186, T:361, T:591 | RS_TravelBeam.Fire; Tick; RS_TravelBeamTracer |
| H27 | ColorfulHell drops: bundles by rs_ch_*drops; RS_ArmorBundle reads rs_ch_healthdrops; weapon / powerup / armour gates; medikit under extradrops | ZF:164, ZF:236, ZF:397, zscript/monsters/chshared/RS_CHShared.zs:263, zscript/monsters/chshared/RS_CHShared.zs:274, zscript/monsters/chshared/RS_CHShared.zs:285, ZF:580 | RS_HealthBundle; RS_ArmorBundle; RS_DropBaseAmmo; RS_DropBaseWeapon / Powerup / Armor |
| H28 | Spawn rows: 160 units ahead, facing you, dormant unless Spawn Hostile; console line; missing rows grey | G:112, G:115, G:118, G:119, G:120, MR:128, MR:136 | RS_DiagHandler.SpawnRow; OptionMenuItemRSQMNDiagRow |
| H29 | Spawn All: the family's rows 72 units apart | G:147, G:152 | NetworkProcess |
| H30 | Wake: Activate, target you, See state | G:169 | NetworkProcess |
| H31 | Diagnose: class, tag, health, ladder tier | G:172 | NetworkProcess |
| H32 | Remove All: ClearCounters, Destroy | G:166 | NetworkProcess |
| H33 | What Is It: Describe; aim by the view's ray, else AimLineAttack in a 35-degree cone | R:1394, R:1398, R:1477, R:1384, R:1387 | RS_RetierHandler.NetworkProcess; Describe; AimedAt |
| H34 | One Tier Up: one up from where it is going; a kit passes White (EX); a ColorfulHell body stops at 13; a fight's monster refused | R:1407, R:1453, R:1460, R:1461, R:1468, R:1469, R:1406 | StepUp; NetworkProcess |
| H35 | Map One Tier Up: StepUp on every living monster | R:1433, R:1441 | NetworkProcess |
| H36 | God Mode row runs `god` | M:278 | MENUDEF |
| H37 | `rs_retier N`, `rs_retier_all N` | R:1414, R:1416, R:1419, R:1427 | NetworkProcess |
| H38 | `rs_bdtier_dump`, `rs_bdtier_classes`, `rs_carry_dump` | B:1359, B:1385, C:419 | RS_BDTierHandler.NetworkProcess; RS_CarryLast.NetworkProcess |
| H39 | Abyss: Phase and Blinks at tier 11; translucent 35 tics; half passes through while phased; blink every 6..10 s behind / beside (8 tries, teleport fog); rises once 105 tics on if it can | B:91, B:92, B:249, B:263, B:265, B:334, B:429, B:430, B:436, B:1241, B:1246, B:1298 | ModifyDamage; BeginPhase; DoEffect; Blink; WorldThingDied; WorldTick |
| H40 | Black: x0.6 taken, pain 0; at half two of its class beside it, marked helpers; their kit at the map's tier; death 8 bolts and a dark burst | B:244, B:208, B:89, B:342, B:461, B:467, B:1135, B:1141, B:1240 | ModifyDamage; Move; DoEffect; CallHelp; WorldThingSpawned; WorldThingDied |
| H41 | White: blink every 8..12 s; second call at a quarter | B:92, B:334, B:343 | DoEffect |
| H42 | Past White: Tier stays 13, each EX step x1.10 health, x1.05 damage; Rage and Phase both | B:85, B:86, B:160, B:90, B:91 | RS_BDKit.Tier; Ex; Apply |
| H43 | ColorfulHell set: the dials; caps default 1 (Common only), then raised by the Monster Tier; six projectile swaps | O:348, O:352, O:364, O:380, O:381, O:290, O:344, V:72 | CheckReplacement; CHProjectile |
| H44 | The colour switches step a switched-off colour past, upward for a raise; never into Black / White unless asked | R:735, R:760, R:769, R:771, O:381, V:94 | RS_TierLadder.Gated; ExtraOff |
| H45 | A cap above 1: the family's own dial weights up to the cap; 13 = the whole dial | O:191, O:203, O:211, O:353, O:397 | BuildCHFamily; CheckReplacement |
| H46 | Extra Colours writes the five gates; Half leaves FireBlu and Gray on | MR:71, MR:75, MR:76, MR:77, MR:78 | OptionMenuItemRSQMNGroup.Apply |
| H47 | Black Boss off: Black to Red; White Boss off: White to Black (Red with both); in gates, tier changes and set.class | R:767, R:768, zscript/monsters/zombieman/RS_Zombieman.zs:166, zscript/monsters/zombieman/RS_Zombieman.zs:208, S:298 | Gated; RS_BlackZombie / RS_WhiteZombie gates; RS_BossfightPick.SetClass |
| H48 | EX roll: 1 = 24 in 256, 2 = half, 3 = always, else never; menu Never is 4 | P:69, P:74, S:326, M:65, V:104, zscript/monsters/zombieman/RS_Zombieman.zs:169 | RS_PlusEX.RollEX; SetClassEX; the gate stubs |
| H49 | Drops writes seven settings; Custom when none match | MR:84, MR:91, MR:56, MR:45 | Apply; DropValue; Draw; GetSelection |
| H50 | The three Plus boss rows and their bodies; a tier change gives the same pick (no EX roll) | P:92, P:103, P:111, P:123, VP:7, VP:9, VP:12, R:1059 | WhiteSpiderType; BlackSoul; WhiteMind; LadderBody; Swap |
| H51 | Tier Icons: gem frame by tier, shows 30 tics; kits once a second; ColorfulHell bodies from their loops | ZF:123, ZF:128, B:299, B:302, ZF:66, ZF:72, P:59 | RS_ColorTierIconCH; RS_BDKit.DoEffect; RS_Zom.TierIcon; RS_PlusEX.Icon |
| H52 | Painted Colour Art off: every painted frame back to the tint | A:349, A:357 | RS_BDArt.Tick |
| H53 | Tiers off: kits to entry, held rung; World Tier counts 1 (also for ColorfulHell spawns); on again: back plus the steps; no kit for spawns while off | B:1311, B:1323, B:1324, B:746, R:1043, B:1104 | RS_BDTierHandler.WorldTick; EffWorld; RS_Retier.WorldTier; WorldThingSpawned |
| H53 | RSQ Miniboss does not step the tier with Tiers off | Miniboss/zscript/rsqmb/tierup.zs:61, Miniboss/zscript/rsqmb/tierup.zs:62 | RSQMB TuWorld |
| H54 | On Tier Change 0 / 2 | R:1002, B:176 | FullHealth; Apply |
| H55 | Colourful Hell's switches read in the family files (dodge in 8 families, lead shot in 3, red form, orange revenant, rocket type, abyss markers) | zscript/monsters/archvile/RS_Archvile.zs:499, zscript/monsters/hellknight/RS_HellKnight.zs:1065, zscript/monsters/cyberdemon/RS_CyberdemonFX.zs:1344, ZF:801 | the family states |
| H56 | Boss From / Thralls From read by RSQ Miniboss | Miniboss/zscript/rsqmb/fight.zs:409, Miniboss/zscript/rsqmb/fight.zs:413 | RSQMB ApplyFrom |

## The ColorfulHell ladder

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| K1 | Each family's 13 classes | R:65 to R:355 | RS_TierLadder.ClassFor |
| K2 | Names and health: each class's Tag and Health (by script over the class table); Common classes are Doom's (no Health of their own) | e.g. zscript/monsters/zombieman/RS_Zombieman.zs:1040 (RS_GreenZombie), zscript/monsters/zombieman/RS_Zombieman.zs:927 (RS_CommonZombie) | the classes' Default blocks |
| K3 | The Spectre's FireBlu and Abyss are the Demon's bodies | R:331, R:334 | ClassFor |
| K4 | Ladder health where higher | R:1026 | LadderHealth |
| K5 | No Tag: RS_BrownZombie2, RS_AbyssBaron2, RS_FireBluCybie2 | zscript/monsters/zombieman/RS_Zombieman.zs:217, zscript/monsters/baron/RS_Baron.zs:630, zscript/monsters/cyberdemon/RS_Cyberdemon.zs:952 | their Default blocks |
| K6 | The 16 EX bodies, their Tag and Health; EX of the gate by name | zscript/monsters/zombieman/RS_Zombieman.zs:1824, zscript/monsters/chaingunner/RS_Chaingunner.zs:1616, zscript/monsters/shotgunner/RS_Shotgunner.zs:2068, zscript/monsters/imp/RS_Imp.zs:1557, zscript/monsters/cacodemon/RS_Cacodemon.zs:1747, zscript/monsters/lostsoul/RS_LostSoul.zs:1893, zscript/monsters/hellknight/RS_HellKnight.zs:1865, zscript/monsters/revenant/RS_Revenant.zs:2232, zscript/monsters/fatso/RS_Fatso.zs:1644, zscript/monsters/spider/RS_Spider.zs:1863, zscript/monsters/plus/RS_PlusSpectreEX.zs:4, zscript/monsters/plus/RS_PlusBlackArchEX.zs:4, zscript/monsters/plus/RS_PlusWhiteArchEX.zs:4, zscript/monsters/plus/RS_PlusBlackCybieEX.zs:4, zscript/monsters/plus/RS_PlusWhiteCybieEX.zs:4, zscript/monsters/plus/RS_PlusWhiteSpiderEX.zs:4, R:681 | the classes; RS_TierLadder.IsEXName |
| K7 | Everlasting White Spidey 20000; Fusion 4000; Big Boss pool lump | zscript/monsters/plus/RS_PlusWhiteMind.zs:13, zscript/monsters/plus/RS_PlusWhiteMind.zs:61, zscript/monsters/plus/RS_PlusWhiteSpiderFusion.zs:10, RSQBIGBS.txt:4, RSQBIGBS.txt:5 | the classes; RSQBIGBS |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | Miniboss reads rsq_mon_worldtier and rsq_mon_bdtier; thralls world + 1, Boss world + 2; steps the tier on a win / loss; Rank writes it at a new game | Miniboss/zscript/rsqmb/tierup.zs:61, Miniboss/zscript/rsqmb/tierup.zs:63, Miniboss/zscript/rsqmb/fight.zs:427, Miniboss/zscript/rsqmb/rank.zs:493, Miniboss/zscript/rsqmb/rank.zs:494 | RSQMB TuWorld; ApplyFrom; the new-game handler |
| W1 | Miniboss asks set.class, set.class.ex, class.set, class.tier, tier.next, retier | Miniboss/zscript/rsqmb/fight.zs:368, Miniboss/zscript/rsqmb/fight.zs:441, Miniboss/zscript/rsqmb/fight.zs:363, Miniboss/zscript/rsqmb/bigboss.zs:157, Miniboss/zscript/rsqmb/fight.zs:183, Miniboss/zscript/rsqmb/fight.zs:187 | RSQMB fight / bigboss |
| W1 | The Big Boss pool: EX classes and RSQBIGBS lumps | Miniboss/zscript/rsqmb/bigboss.zs:157, Miniboss/zscript/rsqmb/bigboss.zs:162, RSQBIGBS.txt:4 | RSQMB bigboss |
| W1 | Held monsters by Miniboss's tokens and RSQMB_Service; the act chooses a phase | R:828, R:832, R:840, R:848, zscript/monsters/RS_Act.zs:13, zscript/monsters/RS_Act.zs:21 | RS_FightHold; RSQMN_Act |
| W2 | Score asks the roster service; census.take / census.add on a swap; headshot passed on | Score/zscript/rsscore/svc.zs:30, R:1143, R:1144, S:100 | RS_Retier.ScoreHandOver; RS_ScoreReadout.Headshot |
| W3 | VisualRewards asks "tier" | VisualRewards/pk3/zscript/rsqthp/handler.zs:167, VisualRewards/pk3/zscript/rsqthp/handler.zs:169 | RSQTHP TierOf |
| W4 | Grenade asks "tier" for Kill Colour | Grenade/zscript/rsqgn/explosions.zs:725, Grenade/zscript/rsqgn/explosions.zs:726 | RSQGN OnKill |
| W5 | SlowMo: the beam is a missile; particles ask RSQSM_Service "scale" | T:186, T:236, T:238 | Fire; WorldScale |
| W6 | Brutal Doom by class name; 193 rows, 24 exempt, 3 health only; parents and replacees | O:252, D:99, D:103, D:150, B:711, B:723, B:731, B:1134, B:178, B:1264 | BDLoaded; Resolve; Apply; Fatalities |
| W7 | Champions: record moved, revive called; tint taken off | C:110, C:281, B:288, C:486 | RS_Carry.Take; RS_CarryFirst; RS_BDKit.DoEffect; RS_LookKeep |
| W8 | LegenDoom: its item; risen again; share of legendary health; its health cvars | C:402, C:403, C:198, C:211, C:61 | RS_CarryLast.Carried; RS_CarryRec.Tick; LDMult |
| W9 | Universal Entropy: size and Shifter; spawn colour taken off | C:380, C:390, C:357, C:359 | Carried; RS_CarryLast.WorldThingSpawned |
| W10 | Legion of Bones' names never take a colour | B:893, B:913 | OtherModName |
| W11 | nmh_projspeed | T:183, T:184 | Fire |
| W12 | The art pk3s by path and sprites.txt | A:15, A:187, A:239 | ReadLists; Art |
| W13 | RSQ Accessibility asked still: Rumble Backup and RSQA_Service "buzz"; RSQA_Menu and rsqa_photosafe for the flash | zscript/monsters/RSQ_QuakeFeel.zs:18, zscript/monsters/RSQ_QuakeFeel.zs:20, R:1206 | RSQMN_QuakeFeel.Felt; RS_RetierJob.Tick |
| W14 | One Radiant Silvergun Options entry | M:10, M:18, M:23 | MENUDEF |
| W15 | The service and its requests | S:48, S:53, S:61, S:67, S:70, S:71, S:72, S:73, S:74, S:75, S:82, S:83, S:85, S:86, S:54 | RSQMN_RosterService |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | The tier tops at Red; the rest only by an asked change or Test and Debug | B:682, M:218, R:917, R:1461 | WorldTier; Request; StepUp |
| L2 | Monster Set read at each spawn | O:312, O:313 | CheckReplacement |
| L3 | Kept in a save: server cvar (the code's own rig note); the handler keeps a save's tier | V:40, V:41, B:760 | CVARINFO; RS_BDTierHandler.WorldLoaded |
| L4 | A kit needs a family; otherwise only a body's colour | B:1121, B:1125 | WorldThingSpawned |
| L5 | Painted frames for the console player's view | A:31, A:345 | RS_BDArt.Tick |
| L6 | ColorfulHell rows touch only ColorfulHell bodies | O:340, ZF:164, O:209 | CheckReplacement; the bundles |
| L7 | Caps default 1 | V:72, O:352 | CheckReplacement |
| L8 | The six projectile swaps, any source | O:290, O:309, O:344 | CHProjectile; CheckReplacement |
| L9 | Only ColorfulHell bodies call RS_TravelBeam.Fire | T:23 | (54 call lines, all in zscript/monsters/) |
| L10 | Plus darkening stubbed; Colourful Hell's events dormant | P:49, P:50, zscript/monsters/chshared/RS_MonEvents.zs:13, zscript/monsters/chshared/RS_CHShared.zs:87 | header notes; nothing spawns them |
| L11 | A fight's monster: What Is It works, One Tier Up refuses | R:1394, R:1406 | NetworkProcess |
| L12 | Logs reach the screen | P:149, P:150 | PlusLog |
| L13 | No KEYCONF | (no KEYCONF lump in Monsters/) | |
