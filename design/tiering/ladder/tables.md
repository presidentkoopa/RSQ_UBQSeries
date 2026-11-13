# ColorfulHell ladder, per family (generated from tiers.json)

CI = challenge index (RS_CommonImp = 1). EHP = HP + summoned HP + heals + raises over 20 s. DPS = expected damage to the player per second (base, before Black Metal x1.5), fight average incl. closing to melee and summons. Speed = ground speed while chasing, map units per tic, FastMonsters on.

## Arachnotron

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonSP1 | 500 (QuestZDoom 17.3 zscript/actors/doom/arachnotron.zs:10) | 128 | 500 | 21.3 | 6.4 | 3.75 | 7.71 |  |
| 2 | Green | RS_GreenSP1 | 600 (spider/RS_Spider.zs:319) | 100 | 600 | 57.4 | 24.0 | 4.13 | 14.82 |  |
| 3 | Blue | RS_BlueSP1 | 700 (spider/RS_Spider.zs:435) | 80 | 700 | 35.3 | 10.8 | 4.54 | 12.34 |  |
| 4 | Purple | RS_PurpleSP1 | 800 (spider/RS_Spider.zs:550) | 20 | 800 | 25.8 | 13.5 | 5.24 | 12.62 | hitscan |
| 5 | Cyan | RS_CyanSP2 | 777 (spider/RS_Spider.zs:1078) | 128 | 777 | 86.0 | 30.9 | 9.94 | 25.18 | strafes (A_FastChase); ice damage; homing projectiles |
| 6 | Brown | RS_BrownSP2 | 600 (spider/RS_Spider.zs:931) | 32 | 1200 | 15.0 | 5.1 | 7.92 | 12.26 | heals others (A_RadiusGive Health) |
| 7 | Yellow | RS_YellowSP1 | 777 (spider/RS_Spider.zs:671) | 150 | 777 | 17.6 | 6.9 | 8.61 | 11.12 | railgun |
| 8 | FireBlu | RS_FireBluSP2 | 999 (spider/RS_Spider.zs:1211) | 150 | 999 | 71.6 | 35.0 | 5.26 | 23.25 |  |
| 9 | Gray | RS_GraySP2 | 600 (spider/RS_Spider.zs:1349) | 12 | 600 | 0.0 | 117.0 | 4.3 | 17.95 |  |
| 10 | Red | RS_RedSP1 | 1000 (spider/RS_Spider.zs:807) | 68 | 1000 | 112.1 | 57.4 | 5.18 | 29.22 | homing projectiles |
| 11 | Abyss | RS_AbyssSP2 | 1850 (spider/RS_Spider.zs:1506) | 24 | 1850 | 193.8 | 45.9 | 8.0 | 52.69 | railgun; ice damage |
| 12 | Black | RS_BlackSP2 | 5342 (spider/RS_Spider.zs:1716) | 24 | 5342 | 265.0 | 209.1 | 6.91 | 133.54 | fire damage; hops/leaps; homing projectiles |
| 12 | Black EX | RS_BlackSPEX | 12000 (spider/RS_Spider.zs:1871) | 24 | 12000 | 314.4 | 228.9 | 10.48 | 237.77 | hops/leaps; railgun; fire damage; homing projectiles |
| 13 | White | RS_WhiteSP11 | 7000 (spider/RS_Spider.zs:2165) | 32 | 7108 | 20.8 | 10.9 | 9.25 | 46.74 | summons (RS_MiniSP1); hops/leaps; railgun; homing projectiles; summons (RS_WhiteSpidegg) |

## Arch-Vile

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonArch | 700 (QuestZDoom 17.3 zscript/actors/doom/archvile.zs:11) | 10 | 1075 | 21.8 | 19.2 | 7.48 | 16.34 | resurrects corpses (A_VileChase) |
| 2 | Green | RS_GreenArch | 750 (archvile/RS_Archvile.zs:1140) | 8 | 1125 | 11.7 | 10.9 | 7.99 | 12.61 | resurrects corpses (A_VileChase) |
| 3 | Blue | RS_BlueArch | 860 (archvile/RS_Archvile.zs:1239) | 6 | 1235 | 20.7 | 18.1 | 8.5 | 17.59 | resurrects corpses (A_VileChase); homing projectiles |
| 4 | Purple | RS_PurpleArch | 1001 (archvile/RS_Archvile.zs:1356) | 4 | 1569 | 21.4 | 20.3 | 8.98 | 20.83 | summons (RS_SpecialRev); resurrects corpses (A_VileChase); buffs others (RS_GrowRaisin) |
| 5 | Cyan | RS_CyanVile | 1200 (archvile/RS_Archvile.zs:441) | 10 | 1575 | 16.7 | 16.5 | 10.49 | 23.24 | resurrects corpses (A_VileChase); hops/leaps; strafes (A_FastChase); buffs others (RS_GrowRaisin); summons (RS_CyanLSoul2) |
| 6 | Brown | RS_BrownVile | 1400 (archvile/RS_Archvile.zs:259) | 12 | 2861 | 23.9 | 9.3 | 6.36 | 24.18 | summons (RS_BrownBoiVile); buffs others (RS_ShieldUpVile); heals others (A_RadiusGive Health); buffs others (RS_GrowRaisin); summons (RS_ArchRingHelp) |
| 7 | Yellow | RS_YellowArch | 1333 (archvile/RS_Archvile.zs:1484) | 4 | 1809 | 16.8 | 14.7 | 9.0 | 19.45 | summons (RS_ArchSpawnerOrb); resurrects corpses (A_VileChase); summons via RS_ArcRing2 (RS_ArchRingHelp); buffs others (RS_GrowRaisin) |
| 8 | FireBlu | RS_FireBluArch2 | 1000 (archvile/RS_Archvile.zs:923) | 4 | 1592 | 20.3 | 17.7 | 9.49 | 20.31 | resurrects corpses (A_VileChase); summons via RS_FireBluSG (RS_FireBluSG2); summons via RS_FireBluCGuy (RS_FireBluCGuy2); summons via RS_FireBluRevenant (RS_FireBluRevenant2); summons via RS_FireBluHK (RS_FireBluHK2) |
| 9 | Gray | RS_GrayArch2 | 1400 (archvile/RS_Archvile.zs:769) | 16 | 1950 | 0.0 | 0.0 | 9.46 | 1.63 | resurrects corpses (A_VileChase); summons via RS_GrayDemon (RS_GreyDemon2); summons via RS_GrayCGuy (RS_GrayCGuy2); summons via RS_GrayRevenant (RS_GrayRevenant2); summons via RS_GrayHK (RS_GrayHK2) |
| 10 | Red | RS_RedArch3 | 3200 (archvile/RS_Archvile.zs:1783) | 3 | 3264 | 11.4 | 6.3 | 7.48 | 18.7 | summons (RS_SpecialVile); fire damage; summons (RS_ArchSpawnerOrb); summons via RS_ArcRing2 (RS_ArchRingHelp) |
| 11 | Abyss | RS_AbyssVile | 2500 (archvile/RS_Archvile.zs:603) | 32 | 3760 | 72.1 | 32.7 | 11.83 | 65.73 | resurrects corpses (A_VileChase); summons via RS_SplashAbyssVile (RS_ArchRingHelp); summons via RS_SplashAbyssVile2 (RS_ABVileTentacle); ice damage; summons (RS_AbyssPortalVile) |
| 12 | Black | RS_BlackVile | 7750 (archvile/RS_Archvile.zs:1938) | 8 | 8517 | 19.5 | 16.1 | 16.98 | 52.59 | summons via RS_BVileCloud (RS_ArchRingHelp); fire damage; summons (RS_CommonRevenant); summons (RS_MrBones); summons via RS_DarkFlameVile (RS_DarkFlameTrailVile) |
| 13 | White | RS_Whitevile | 13000 (archvile/RS_Archvile.zs:2105) | 64 | 13000 | 8.5 | 3.1 | 38.34 | 47.74 | summons (RS_WhiteVileResser); strafes (A_FastChase); summons (RS_WvileSpot); buffs others (RS_WVEyeGo) |

## Baron

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonBaron | 1000 (QuestZDoom 17.3 zscript/actors/doom/bruiser.zs:10) | 50 | 1000 | 18.7 | 12.5 | 2.62 | 10.57 |  |
| 2 | Green | RS_GreenBaron | 1170 (baron/RS_Baron.zs:1210) | 40 | 1170 | 10.2 | 10.4 | 2.95 | 9.57 | homing projectiles |
| 3 | Blue | RS_BlueBaron | 1309 (baron/RS_Baron.zs:1343) | 30 | 1309 | 12.8 | 4.5 | 3.62 | 9.77 | homing projectiles |
| 4 | Purple | RS_PurpleBaron | 1500 (baron/RS_Baron.zs:1464) | 30 | 1500 | 74.7 | 48.7 | 3.62 | 27.92 | fire damage |
| 5 | Cyan | RS_CyanBaron2 | 1666 (baron/RS_Baron.zs:366) | 64 | 1666 | 71.9 | 47.0 | 8.94 | 39.83 | strafes (A_FastChase); ice damage; homing projectiles; hops/leaps |
| 6 | Brown | RS_BrownBaron2 | 2250 (baron/RS_Baron.zs:232) | 20 | 2250 | 82.3 | 24.7 | 3.42 | 31.39 | homing projectiles; summons via RS_BrownBaronSpiral (RS_ReflectorBBaron) |
| 7 | Yellow | RS_YellowBaron | 1888 (baron/RS_Baron.zs:1605) | 20 | 1888 | 40.5 | 16.4 | 4.98 | 23.04 | strafes (A_FastChase); fire damage; homing projectiles |
| 8 | FireBlu | RS_FireBluBaron2 | 2300 (baron/RS_Baron.zs:973) | 32 | 2300 | 57.4 | 27.9 | 6.59 | 33.39 | homing projectiles |
| 9 | Gray | RS_GrayBaron2 | 2000 (baron/RS_Baron.zs:827) | 6 | 2000 | 48.2 | 21.9 | 1.33 | 18.92 | homing projectiles |
| 10 | Red | RS_RedBaron3 | 2100 (baron/RS_Baron.zs:1923) | 20 | 2100 | 90.4 | 30.8 | 4.87 | 35.26 | fire damage; spawns monsters on death (RS_RedBaron2) |
| 11 | Abyss | RS_AbyssBaron2 | 3333 (baron/RS_Baron.zs:635) | 24 | 3708 | 37.3 | 12.8 | 4.63 | 35.7 | resurrects corpses (A_VileChase); summons (RS_ArchRingHelp); hops/leaps; homing projectiles; summons via RS_AbyssBaronHandFire3 (RS_AbyssBaronSoul) |
| 12 | Black | RS_BlackBaron2 | 8907 (baron/RS_Baron.zs:2244) | 42 | 11240 | 119.0 | 99.5 | 2.32 | 91.0 | summons (RS_RoseTentacle); summons (RS_DeepTentacle); railgun; homing projectiles |
| 13 | White | RS_WhiteBaron2 | 13069 (baron/RS_Baron.zs:2649) | 42 | 13069 | 62.9 | 25.0 | 5.52 | 85.03 | strafes (A_FastChase); turns invisible; fire damage; homing projectiles; charges (skull attack) |

## Cacodemon

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonCaco | 400 (QuestZDoom 17.3 zscript/actors/doom/cacodemon.zs:10) | 128 | 400 | 11.0 | 2.9 | 2.51 | 4.64 |  |
| 2 | Green | RS_GreenCaco | 450 (cacodemon/RS_Cacodemon.zs:924) | 110 | 450 | 11.5 | 3.9 | 2.55 | 5.2 |  |
| 3 | Blue | RS_BlueCaco | 480 (cacodemon/RS_Cacodemon.zs:1033) | 100 | 480 | 17.7 | 5.5 | 3.19 | 6.97 |  |
| 4 | Purple | RS_PurpleCaco | 528 (cacodemon/RS_Cacodemon.zs:1148) | 90 | 528 | 27.6 | 15.6 | 3.52 | 11.19 | charges (skull attack); fire damage; homing projectiles |
| 5 | Cyan | RS_CyanCaco2 | 500 (cacodemon/RS_Cacodemon.zs:335) | 110 | 500 | 62.4 | 26.2 | 11.75 | 19.25 | strafes (A_FastChase); ice damage |
| 6 | Brown | RS_BrownCaco2 | 500 (cacodemon/RS_Cacodemon.zs:219) | 64 | 500 | 10.3 | 3.6 | 5.88 | 6.41 | buffs others (RS_SpeedBuffPE); buffs others (RS_BrownImpCommand); heals others (A_RadiusGive Health) |
| 7 | Yellow | RS_YellowCaco | 720 (cacodemon/RS_Cacodemon.zs:1271) | 80 | 900 | 10.9 | 3.6 | 2.98 | 8.12 | fire damage; summons (RS_VoidField) |
| 8 | FireBlu | RS_FireBluCaco2 | 800 (cacodemon/RS_Cacodemon.zs:726) | 110 | 800 | 14.6 | 5.7 | 4.13 | 8.98 |  |
| 9 | Gray | RS_GrayCaco2 | 650 (cacodemon/RS_Cacodemon.zs:615) | 90 | 650 | 71.2 | 25.7 | 2.89 | 17.71 | charges (skull attack) |
| 10 | Red | RS_RedCaco | 830 (cacodemon/RS_Cacodemon.zs:1413) | 64 | 830 | 39.6 | 18.9 | 6.31 | 17.25 |  |
| 11 | Abyss | RS_AbyssCaco2 | 1100 (cacodemon/RS_Cacodemon.zs:455) | 64 | 1998 | 79.0 | 42.9 | 9.86 | 43.2 | buffs others (RS_SpeedBuffPE); ice damage; homing projectiles; heals others (A_RadiusGive Health) |
| 12 | Black | RS_BlackCaco2 | 5000 (cacodemon/RS_Cacodemon.zs:1570) | 32 | 6660 | 49.1 | 25.5 | 5.7 | 53.81 | summons (RS_RedCaco); hitscan |
| 12 | Black EX | RS_BlackCacoEX | 10000 (cacodemon/RS_Cacodemon.zs:1756) | 32 | 11150 | 93.0 | 61.9 | 9.17 | 112.98 | summons (RS_RedSpikeCacoEX); railgun; hitscan |
| 13 | White | RS_WhiteCaco2 | 5000 (cacodemon/RS_Cacodemon.zs:1986) | 128 | 5000 | 45.0 | 18.5 | 9.0 | 48.22 | spawns monsters on death (RS_WhiteCacoREAL) |

## Chaingunner

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonCGuy | 70 (QuestZDoom 17.3 zscript/actors/doom/possessed.zs:138) | 170 | 70 | 9.4 | 4.4 | 2.47 | 1.83 |  |
| 2 | Green | RS_GreenCGuy | 85 (chaingunner/RS_Chaingunner.zs:976) | 150 | 85 | 20.1 | 8.1 | 2.48 | 2.89 | hitscan |
| 3 | Blue | RS_BlueCGuy | 105 (chaingunner/RS_Chaingunner.zs:1083) | 150 | 105 | 11.0 | 3.2 | 2.52 | 2.29 | railgun; hitscan |
| 4 | Purple | RS_PurpleCGuy | 120 (chaingunner/RS_Chaingunner.zs:1211) | 150 | 120 | 30.9 | 28.4 | 2.5 | 4.99 | fire damage; homing projectiles |
| 5 | Cyan | RS_CyanCGuy2 | 125 (chaingunner/RS_Chaingunner.zs:331) | 88 | 125 | 37.5 | 15.5 | 5.34 | 6.99 | strafes (A_FastChase); hops/leaps; ice damage |
| 6 | Brown | RS_BrownCGuy2 | 250 (chaingunner/RS_Chaingunner.zs:203) | 102 | 2828 | 5.5 | 2.1 | 1.39 | 7.49 | summons (RS_BrownSandBagCGuy); hitscan; fire damage |
| 7 | Yellow | RS_YellowCGuy | 200 (chaingunner/RS_Chaingunner.zs:1330) | 135 | 200 | 76.5 | 24.9 | 2.38 | 8.32 | strafes (A_FastChase); railgun |
| 8 | FireBlu | RS_FireBluCGuy2 | 450 (chaingunner/RS_Chaingunner.zs:765) | 135 | 450 | 77.1 | 33.6 | 4.27 | 15.1 | strafes (A_FastChase); fire damage |
| 9 | Gray | RS_GrayCGuy2 | 275 (chaingunner/RS_Chaingunner.zs:617) | 135 | 275 | 9.7 | 8.9 | 2.29 | 4.14 | hitscan |
| 10 | Red | RS_RedCGuy | 300 (chaingunner/RS_Chaingunner.zs:1503) | 88 | 300 | 43.0 | 10.7 | 3.22 | 8.8 | hitscan |
| 11 | Abyss | RS_AbyssCGuy2 | 500 (chaingunner/RS_Chaingunner.zs:492) | 80 | 500 | 67.6 | 51.4 | 1.93 | 13.53 | ice damage |
| 12 | Black | RS_BlackCGuy2 | 4500 (chaingunner/RS_Chaingunner.zs:1769) | 25 | 4944 | 73.2 | 31.0 | 3.3 | 45.52 | reflects projectiles (phase); homing projectiles |
| 12 | Black EX | RS_BlackCGuyEX | 8999 (chaingunner/RS_Chaingunner.zs:1625) | 12 | 8999 | 336.5 | 194.6 | 6.63 | 165.06 | strafes (A_FastChase); fire damage; homing projectiles; hitscan |
| 13 | White | RS_WhiteCguy2 | 7777 (chaingunner/RS_Chaingunner.zs:1886) | 20 | 13650 | 142.0 | 42.9 | 4.17 | 106.82 | strafes (A_FastChase); summons (RS_VolativeCaco); summons (RS_SlimyWorm); summons (RS_SpliceBaron) |

## Cyberdemon

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonCybie | 4000 (QuestZDoom 17.3 zscript/actors/doom/cyberdemon.zs:11) | 20 | 4000 | 140.8 | 54.3 | 5.31 | 63.1 |  |
| 2 | Green | RS_GreenCybie | 5000 (cyberdemon/RS_Cyberdemon.zs:1186) | 16 | 5000 | 168.5 | 70.6 | 5.3 | 78.06 | fire damage |
| 3 | Blue | RS_BlueCybie | 5800 (cyberdemon/RS_Cyberdemon.zs:1276) | 12 | 5800 | 143.0 | 63.5 | 5.95 | 80.42 | homing projectiles |
| 4 | Purple | RS_PurpleCybie | 6400 (cyberdemon/RS_Cyberdemon.zs:1458) | 16 | 6400 | 89.8 | 73.8 | 4.31 | 69.37 | summons (RS_SpecialHK); fire damage; homing projectiles |
| 5 | Cyan | RS_CyanCybie2 | 8083 (cyberdemon/RS_Cyberdemon.zs:474) | 32 | 8083 | 245.1 | 76.2 | 7.63 | 138.62 | strafes (A_FastChase); ice damage |
| 6 | Brown | RS_BrownCybie2 | 7557 (cyberdemon/RS_Cyberdemon.zs:296) | 12 | 7557 | 68.7 | 23.9 | 5.63 | 60.63 | buffs others (RS_BrCybCheck) |
| 7 | Yellow | RS_YellowCybie | 7777 (cyberdemon/RS_Cyberdemon.zs:1608) | 0 | 9775 | 56.8 | 24.9 | 6.33 | 66.69 | fire damage; homing projectiles; summons (RS_YellowHK) |
| 8 | FireBlu | RS_FireBluCybie2 | 7777 (cyberdemon/RS_Cyberdemon.zs:957) | 16 | 7777 | 52.6 | 15.9 | 6.29 | 59.82 | charges (skull attack); fire damage; homing projectiles |
| 9 | Gray | RS_GrayCybie2 | 8888 (cyberdemon/RS_Cyberdemon.zs:823) | 0 | 8888 | 35.4 | 11.6 | 4.75 | 44.89 |  |
| 10 | Red | RS_RedCybie | 10000 (cyberdemon/RS_Cyberdemon.zs:1745) | 15 | 10073 | 41.9 | 20.9 | 5.37 | 56.97 | fire damage; homing projectiles; summons (RS_SummonPortalCybie) |
| 11 | Abyss | RS_AbyssCybie2 | 12000 (cyberdemon/RS_Cyberdemon.zs:634) | 8 | 12000 | 58.8 | 24.0 | 4.52 | 68.38 | railgun; ice damage; fire damage; homing projectiles |
| 12 | Black | RS_BlackCybie2 | 14500 (cyberdemon/RS_Cyberdemon.zs:2065) | 16 | 20562 | 112.9 | 64.9 | 5.96 | 154.62 | summons (random: RS_PortalSummons); fire damage; reflects projectiles (phase); charges (skull attack); turns invisible |
| 13 | White | RS_WhiteCybie2 | 21000 (cyberdemon/RS_Cyberdemon.zs:2396) | 20 | 28333 | 598.8 | 346.3 | 6.33 | 463.43 | strafes (A_FastChase); summons (RS_RomeroBaronsCH); turns invisible; summons (RS_IDShieldWalk); hops/leaps |

## Demon

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonDemon | 150 (QuestZDoom 17.3 zscript/actors/doom/demon.zs:10) | 150 | 150 | 18.1 | 16.7 | 9.78 | 6.01 |  |
| 2 | Green | RS_GreenDemon | 170 (demon/RS_Demon.zs:1056) | 130 | 170 | 28.4 | 26.6 | 10.81 | 8.25 |  |
| 3 | Blue | RS_BlueDemon | 205 (demon/RS_Demon.zs:1176) | 110 | 205 | 63.0 | 36.4 | 12.79 | 13.97 | charges (skull attack) |
| 4 | Purple | RS_PurpleDemon | 260 (demon/RS_Demon.zs:1293) | 80 | 260 | 56.7 | 36.3 | 14.83 | 15.79 | charges (skull attack) |
| 5 | Cyan | RS_CyanDemon2 | 270 (demon/RS_Demon.zs:460) | 64 | 270 | 13.1 | 5.5 | 11.81 | 6.8 | ice damage; charges (skull attack) |
| 6 | Brown | RS_BrownDemon2 | 420 (demon/RS_Demon.zs:295) | 33 | 540 | 24.7 | 5.3 | 14.71 | 11.73 | summons (RS_BrownDemonGhost); fire damage |
| 7 | Yellow | RS_YellowDemon | 325 (demon/RS_Demon.zs:1408) | 75 | 325 | 17.3 | 16.6 | 14.15 | 10.54 | charges (skull attack) |
| 8 | FireBlu | RS_FireBluDemon2 | 205 (demon/RS_Demon.zs:595) | 180 | 205 | 21.9 | 8.2 | 2.36 | 5.04 | charges (skull attack) |
| 9 | Gray | RS_GreyDemon2 | 700 (demon/RS_Demon.zs:847) | 32 | 700 | 15.1 | 5.1 | 5.26 | 10.59 | warps to the player; self-heal; charges (skull attack) |
| 10 | Red | RS_RedDemon | 400 (demon/RS_Demon.zs:1528) | 30 | 400 | 8.3 | 2.6 | 11.25 | 5.69 | fire damage |
| 11 | Abyss | RS_AbyssDemon2 | 600 (demon/RS_Demon.zs:716) | 128 | 600 | 23.2 | 22.3 | 18.82 | 16.19 | fire damage; homing projectiles |
| 12 | Black | RS_BlackDemon3 | 4500 (demon/RS_Demon.zs:1641) | 68 | 4702 | 29.1 | 13.8 | 8.52 | 43.32 | hops/leaps; charges (skull attack); summons (RS_WHOLETTHEDOGSOUT) |
| 13 | White | RS_WhiteDemon2 | 8000 (demon/RS_Demon.zs:1877) | 16 | 10555 | 21.1 | 7.6 | 6.56 | 55.95 | charges (skull attack); invulnerable phase; hops/leaps; warps to the player |

## Hell Knight

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonHK | 500 (QuestZDoom 17.3 zscript/actors/doom/bruiser.zs:69) | 50 | 500 | 13.3 | 4.5 | 2.6 | 5.64 |  |
| 2 | Green | RS_GreenHK | 600 (hellknight/RS_HellKnight.zs:1029) | 50 | 600 | 17.0 | 9.9 | 2.94 | 7.83 |  |
| 3 | Blue | RS_BlueHK | 666 (hellknight/RS_HellKnight.zs:1157) | 50 | 666 | 28.7 | 8.2 | 3.26 | 9.91 |  |
| 4 | Purple | RS_PurpleHK | 730 (hellknight/RS_HellKnight.zs:1275) | 50 | 730 | 36.0 | 17.2 | 3.6 | 12.77 | homing projectiles; fire damage |
| 5 | Cyan | RS_CyanHK2 | 700 (hellknight/RS_HellKnight.zs:380) | 80 | 700 | 45.2 | 18.7 | 6.07 | 18.74 | strafes (A_FastChase); hops/leaps; ice damage |
| 6 | Brown | RS_BrownHK2 | 700 (hellknight/RS_HellKnight.zs:238) | 50 | 875 | 10.6 | 6.4 | 3.92 | 8.07 | fire damage; homing projectiles; summons (RS_BrownHKShield) |
| 7 | Yellow | RS_YellowHK | 999 (hellknight/RS_HellKnight.zs:1407) | 50 | 999 | 15.2 | 5.9 | 3.26 | 9.18 | fire damage |
| 8 | FireBlu | RS_FireBluHK2 | 900 (hellknight/RS_HellKnight.zs:716) | 0 | 900 | 49.6 | 21.5 | 4.33 | 17.17 |  |
| 9 | Gray | RS_GrayHK2 | 800 (hellknight/RS_HellKnight.zs:826) | 16 | 800 | 21.3 | 9.4 | 4.96 | 11.0 | fire damage |
| 10 | Red | RS_RedHK | 1300 (hellknight/RS_HellKnight.zs:1531) | 50 | 1300 | 15.5 | 6.4 | 3.62 | 12.05 | summons (RS_SpecialImp); homing projectiles |
| 11 | Abyss | RS_AbyssHK2 | 1850 (hellknight/RS_HellKnight.zs:548) | 64 | 1850 | 91.8 | 35.8 | 4.93 | 40.88 | hops/leaps; ice damage |
| 12 | Black | RS_BlackHK2 | 5555 (hellknight/RS_HellKnight.zs:1692) | 30 | 5555 | 99.9 | 48.8 | 1.98 | 50.73 | fire damage |
| 12 | Black EX | RS_BlackHKEX | 11000 (hellknight/RS_HellKnight.zs:1873) | 30 | 11000 | 78.5 | 56.2 | 5.03 | 85.77 | fire damage; homing projectiles; railgun |
| 13 | White | RS_WhiteHK3 | 5000 (hellknight/RS_HellKnight.zs:2168) | 50 | 6400 | 21.4 | 8.2 | 4.3 | 30.96 | summons (RS_WHITEHK2); strafes (A_FastChase); summons (RS_SpecialSpectre2) |

## Imp

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonImp | 60 (QuestZDoom 17.3 zscript/actors/doom/doomimp.zs:10) | 200 | 60 | 3.6 | 1.2 | 2.46 | 1.0 |  |
| 2 | Green | RS_GreenImp | 70 (imp/RS_Imp.zs:966) | 180 | 70 | 9.9 | 2.7 | 2.48 | 1.75 | homing projectiles |
| 3 | Blue | RS_BlueImp | 83 (imp/RS_Imp.zs:1078) | 170 | 83 | 9.0 | 3.0 | 2.8 | 1.92 |  |
| 4 | Purple | RS_PurpleImp | 105 (imp/RS_Imp.zs:1192) | 150 | 105 | 10.2 | 3.7 | 3.11 | 2.39 | fire damage |
| 5 | Cyan | RS_CyanImp2 | 125 (imp/RS_Imp.zs:352) | 84 | 125 | 21.9 | 8.4 | 4.93 | 5.18 | strafes (A_FastChase); hops/leaps; ice damage |
| 6 | Brown | RS_BrownImp2 | 215 (imp/RS_Imp.zs:203) | 128 | 794 | 2.5 | 1.1 | 2.81 | 3.26 | buffs others (RS_BrownImpCommand); summons (RS_BrownImpShieldMini) |
| 7 | Yellow | RS_YellowImp | 145 (imp/RS_Imp.zs:1313) | 120 | 145 | 8.8 | 2.8 | 3.18 | 2.58 | strafes (A_FastChase); fire damage |
| 8 | FireBlu | RS_FireBluImp2 | 125 (imp/RS_Imp.zs:648) | 150 | 125 | 28.8 | 9.2 | 2.8 | 4.19 |  |
| 9 | Gray | RS_GrayImp2 | 265 (imp/RS_Imp.zs:764) | 100 | 265 | 3.3 | 1.3 | 2.59 | 2.08 |  |
| 10 | Red | RS_RedImp | 200 (imp/RS_Imp.zs:1443) | 100 | 200 | 47.2 | 45.6 | 4.54 | 9.36 | fire damage; homing projectiles |
| 11 | Abyss | RS_AbyssImp2 | 300 (imp/RS_Imp.zs:521) | 120 | 300 | 22.3 | 8.3 | 4.53 | 7.89 | ice damage; hops/leaps; strafes (A_FastChase) |
| 12 | Black | RS_BlackImp1 | 3800 (imp/RS_Imp.zs:1746) | 28 | 3800 | 25.9 | 11.5 | 3.97 | 25.04 | fire damage |
| 12 | Black EX | RS_BlackImpEX | 8600 (imp/RS_Imp.zs:1563) | 28 | 8600 | 51.4 | 41.7 | 4.72 | 62.06 | railgun; fire damage; homing projectiles |
| 13 | White | RS_WhiteImp2 | 6666 (imp/RS_Imp.zs:2097) | 24 | 7684 | 43.8 | 24.0 | 8.93 | 58.71 | summons (random: RS_SpecialImp2); strafes (A_FastChase); homing projectiles; fire damage |

## Lost Soul

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonLSoul | 100 (QuestZDoom 17.3 zscript/actors/doom/lostsoul.zs:10) | 256 | 100 | 2.2 | 1.1 | 1.09 | 1.0 | charges (skull attack) |
| 2 | Green | RS_GreenLSoul | 120 (lostsoul/RS_LostSoul.zs:820) | 200 | 120 | 2.5 | 1.2 | 1.12 | 1.17 | charges (skull attack) |
| 3 | Blue | RS_BlueLSoul | 145 (lostsoul/RS_LostSoul.zs:894) | 175 | 145 | 3.8 | 2.2 | 1.28 | 1.7 | charges (skull attack); hitscan |
| 4 | Purple | RS_PurpleLSoul | 150 (lostsoul/RS_LostSoul.zs:981) | 192 | 150 | 6.5 | 2.8 | 1.45 | 2.22 | charges (skull attack) |
| 5 | Cyan | RS_CyanLSoul2 | 80 (lostsoul/RS_LostSoul.zs:333) | 192 | 80 | 40.2 | 14.3 | 7.84 | 5.98 | charges (skull attack) |
| 6 | Brown | RS_BrownLSoul2 | 125 (lostsoul/RS_LostSoul.zs:234) | 0 | 500 | 12.4 | 5.4 | 2.5 | 6.42 | resurrects corpses (A_VileChase); charges (skull attack); spawns monsters on death (RS_ArchRingHelp) |
| 7 | Yellow | RS_YellowLSoul | 180 (lostsoul/RS_LostSoul.zs:1062) | 120 | 180 | 13.6 | 7.2 | 3.88 | 4.65 | charges (skull attack) |
| 8 | FireBlu | RS_FireBluLSoul2 | 175 (lostsoul/RS_LostSoul.zs:697) | 0 | 175 | 3.5 | 1.5 | 2.5 | 2.01 | charges (skull attack) |
| 9 | Gray | RS_GrayLSoul2 | 50 (lostsoul/RS_LostSoul.zs:614) | 0 | 698 | 68.5 | 0.0 | 0.25 | 9.95 | hops/leaps; summons (RS_BlackLSoul2) |
| 10 | Red | RS_RedLSoul | 240 (lostsoul/RS_LostSoul.zs:1153) | 88 | 240 | 20.3 | 11.9 | 3.65 | 6.57 | charges (skull attack) |
| 11 | Abyss | RS_AbyssLSoul2 | 380 (lostsoul/RS_LostSoul.zs:423) | 32 | 380 | 1.4 | 1.0 | 7.99 | 3.34 | hops/leaps; charges (skull attack); warps to the player; self-heal |
| 12 | Black | RS_BlackLSoul3 | 1500 (lostsoul/RS_LostSoul.zs:1388) | 128 | 1725 | 27.4 | 3.7 | 6.01 | 19.62 | summons (RS_BlackLSoul2); strafes (A_FastChase); homing projectiles |
| 13 | White | RS_WhiteLSoul2 | 4500 (lostsoul/RS_LostSoul.zs:1695) | 22 | 4707 | 47.2 | 28.0 | 6.28 | 46.53 | homing projectiles; fire damage; summons (RS_RevEgg); summons (RS_HKEgg); summons via RS_ArcRing2 (RS_ArchRingHelp) |
| 13 | White EX | RS_WhiteLSoulEX | 12500 (lostsoul/RS_LostSoul.zs:1909) | 32 | 12500 | 41.5 | 23.2 | 6.26 | 70.28 | summons (RS_SkullWSoulEX1); summons (RS_SkullWSoulEX2); fire damage; homing projectiles; summons via RS_ArcRing2 (RS_ArchRingHelp) |

## Mancubus

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonFatso | 600 (QuestZDoom 17.3 zscript/actors/doom/fatso.zs:10) | 80 | 600 | 23.7 | 9.4 | 1.9 | 7.78 |  |
| 2 | Green | RS_GreenFatso | 750 (fatso/RS_Fatso.zs:1000) | 70 | 750 | 36.3 | 13.3 | 1.93 | 10.7 |  |
| 3 | Blue | RS_BlueFatso | 850 (fatso/RS_Fatso.zs:1117) | 60 | 850 | 57.6 | 27.4 | 1.7 | 14.44 |  |
| 4 | Purple | RS_PurpleFatso | 950 (fatso/RS_Fatso.zs:1252) | 20 | 950 | 66.2 | 26.7 | 1.48 | 15.42 | fire damage; hitscan |
| 5 | Cyan | RS_CyanFatso2 | 720 (fatso/RS_Fatso.zs:383) | 70 | 720 | 82.5 | 44.3 | 3.54 | 23.4 | strafes (A_FastChase); hops/leaps; ice damage; charges (skull attack) |
| 6 | Brown | RS_BrownFatso2 | 850 (fatso/RS_Fatso.zs:244) | 70 | 850 | 44.1 | 36.9 | 2.65 | 15.75 |  |
| 7 | Yellow | RS_YellowFatso | 1250 (fatso/RS_Fatso.zs:1373) | 14 | 1250 | 75.2 | 35.7 | 1.49 | 19.35 | fire damage; homing projectiles |
| 8 | FireBlu | RS_FireBluFatso2 | 1400 (fatso/RS_Fatso.zs:635) | 45 | 1400 | 44.9 | 23.8 | 2.29 | 17.95 |  |
| 9 | Gray | RS_GrayFatso2 | 1000 (fatso/RS_Fatso.zs:766) | 70 | 1000 | 50.1 | 19.9 | 1.21 | 13.06 |  |
| 10 | Red | RS_RedFatso | 1600 (fatso/RS_Fatso.zs:1513) | 34 | 1600 | 84.5 | 44.7 | 2.9 | 27.92 | fire damage |
| 11 | Abyss | RS_AbyssFatso2 | 2150 (fatso/RS_Fatso.zs:538) | 12 | 2150 | 166.5 | 85.7 | 3.63 | 47.82 | ice damage |
| 12 | Black | RS_BlackFatso2 | 9001 (fatso/RS_Fatso.zs:1911) | 24 | 9001 | 62.9 | 42.9 | 4.27 | 66.0 | fire damage |
| 12 | Black EX | RS_BlackFatsoEX | 18000 (fatso/RS_Fatso.zs:1651) | 32 | 18000 | 223.0 | 138.3 | 5.64 | 184.91 | fire damage; homing projectiles |
| 13 | White | RS_WhiteFatso2 | 15000 (fatso/RS_Fatso.zs:2131) | 32 | 15000 | 199.6 | 18.1 | 4.29 | 122.37 | railgun; fire damage |

## Mastermind

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonMind | 3000 (QuestZDoom 17.3 zscript/actors/doom/spidermaster.zs:10) | 40 | 3000 | 33.1 | 15.4 | 3.94 | 25.29 |  |
| 2 | Green | RS_GreenMind | 4200 (mastermind/RS_Mastermind.zs:1430) | 40 | 4200 | 30.4 | 14.4 | 3.96 | 28.79 |  |
| 3 | Blue | RS_BlueMind | 5600 (mastermind/RS_Mastermind.zs:1552) | 25 | 5600 | 70.8 | 35.2 | 5.95 | 56.62 | ice damage; homing projectiles |
| 4 | Purple | RS_PurpleMind | 6666 (mastermind/RS_Mastermind.zs:1727) | 20 | 6695 | 66.1 | 31.8 | 3.98 | 53.8 | summons (RS_SpecialSpider1); fire damage; hitscan |
| 5 | Cyan | RS_CyanMind2 | 7777 (mastermind/RS_Mastermind.zs:670) | 10 | 7777 | 330.3 | 140.0 | 7.0 | 168.32 | strafes (A_FastChase); teleports; ice damage; homing projectiles |
| 6 | Brown | RS_BrownMind2 | 8858 (mastermind/RS_Mastermind.zs:448) | 64 | 8858 | 46.5 | 18.7 | 7.49 | 59.15 | fire damage; homing projectiles; summons via RS_WindBlastMasterMind (RS_ReflectorBBaron); buffs others (RS_EatableMind); buffs others (RS_ShieldUpMind) |
| 7 | Yellow | RS_YellowMind | 7777 (mastermind/RS_Mastermind.zs:1888) | 10 | 10885 | 68.0 | 60.4 | 6.0 | 87.06 | summons (RS_YellowSP1); fire damage; homing projectiles |
| 8 | FireBlu | RS_FireBluMind2 | 8007 (mastermind/RS_Mastermind.zs:1304) | 40 | 8007 | 64.5 | 44.1 | 6.92 | 71.16 | fire damage; homing projectiles |
| 9 | Gray | RS_GrayMind2 | 8007 (mastermind/RS_Mastermind.zs:1138) | 40 | 8007 | 79.0 | 54.8 | 2.93 | 63.72 | summons (RS_BrainPainGray); hitscan; homing projectiles; fire damage |
| 10 | Red | RS_RedMind | 10000 (mastermind/RS_Mastermind.zs:2087) | 1 | 10346 | 24.8 | 23.7 | 9.0 | 57.73 | strafes (A_FastChase); railgun; homing projectiles; fire damage; summons (RS_RedMindBomb) |
| 11 | Abyss | RS_AbyssMind2 | 12222 (mastermind/RS_Mastermind.zs:872) | 48 | 12222 | 57.3 | 21.0 | 7.48 | 76.12 | summons (RS_WvileSpot) |
| 12 | Black | RS_BlackMind2 | 11111 (mastermind/RS_Mastermind.zs:2363) | 45 | 13177 | 237.8 | 67.4 | 12.48 | 203.95 | homing projectiles; summons (random: RS_PortalSummons2); teleports |
| 13 | White | RS_WhiteMind2 | 15000 (mastermind/RS_Mastermind.zs:2667) | 40 | 15869 | 105.5 | 36.3 | 13.8 | 163.24 | hitscan; hops/leaps; homing projectiles; fire damage; charges (skull attack) |

## Pain Elemental

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonPE | 400 (QuestZDoom 17.3 zscript/actors/doom/painelemental.zs:10) | 128 | 1990 | 4.8 | 2.3 | 2.53 | 7.41 | summons (RS_CommonLSoul); summons (LostSoul) |
| 2 | Green | RS_GreenPE | 500 (painelemental/RS_PainElemental.zs:873) | 112 | 1495 | 0.0 | 2.7 | 2.54 | 3.96 | summons (RS_GreenLSoul); summons (LostSoul) |
| 3 | Blue | RS_BluePE | 610 (painelemental/RS_PainElemental.zs:977) | 100 | 2102 | 40.5 | 13.6 | 2.53 | 21.01 | summons (RS_BlueLSoul); homing projectiles; summons (LostSoul) |
| 4 | Purple | RS_PurplePE | 790 (painelemental/RS_PainElemental.zs:1081) | 128 | 3128 | 31.9 | 15.2 | 1.89 | 22.23 | summons (RS_PurpleLSoul); homing projectiles |
| 5 | Cyan | RS_CyanPE2 | 963 (painelemental/RS_PainElemental.zs:342) | 128 | 1338 | 18.9 | 7.7 | 10.11 | 18.2 | resurrects corpses (A_VileChase); strafes (A_FastChase); ice damage; homing projectiles; hops/leaps |
| 6 | Brown | RS_BrownPE2 | 800 (painelemental/RS_PainElemental.zs:195) | 128 | 1571 | 10.1 | 4.3 | 5.9 | 12.68 | summons (RS_BrownLSoul2); spawns monsters on death (RS_BrownLSoul2) |
| 7 | Yellow | RS_YellowPE | 900 (painelemental/RS_PainElemental.zs:1175) | 128 | 2715 | 43.9 | 20.1 | 5.34 | 31.31 | summons (RS_YellowLSoul); fire damage; summons (LostSoul) |
| 8 | FireBlu | RS_FireBluPE2 | 800 (painelemental/RS_PainElemental.zs:719) | 110 | 800 | 141.8 | 52.9 | 6.67 | 34.32 | charges (skull attack); summons via RS_BoomPEBlu (RS_FireBluLSoul2); fire damage |
| 9 | Gray | RS_GrayPE2 | 1450 (painelemental/RS_PainElemental.zs:605) | 24 | 9717 | 66.7 | 28.4 | 0.99 | 47.37 | summons (RS_GrayLSoul2); summons (RS_GreyDemon2); summons (RS_GraySpectre2); spawns monsters on death (RS_BlackLSoul2) |
| 10 | Red | RS_RedPE | 1111 (painelemental/RS_PainElemental.zs:1265) | 42 | 3781 | 129.7 | 52.3 | 3.61 | 61.87 | summons (RS_RedLSoul); charges (skull attack) |
| 11 | Abyss | RS_AbyssPE2 | 1600 (painelemental/RS_PainElemental.zs:461) | 80 | 1862 | 31.7 | 30.5 | 6.67 | 27.02 | buffs others (RS_SpeedBuffPE); homing projectiles; summons (RS_AbyssBaronSoul) |
| 12 | Black | RS_BlackPE2 | 5000 (painelemental/RS_PainElemental.zs:1385) | 20 | 5000 | 140.4 | 53.3 | 4.63 | 71.32 | summons via RS_BEESHOT (RS_BlackLSoul2); fire damage |
| 13 | White | RS_WhitePE2 | 5000 (painelemental/RS_PainElemental.zs:1562) | 128 | 12724 | 431.9 | 122.9 | 13.57 | 251.93 | summons (RS_MiniSentinelPE); summons (RS_HealthFountainWhitePE); railgun; spawns monsters on death (RS_WhitePE3) |

## Revenant

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonRevenant | 300 (revenant/RS_Revenant.zs:889) | 100 | 300 | 26.2 | 24.9 | 4.89 | 8.66 | fire damage; homing projectiles |
| 2 | Green | RS_GreenRevenant | 360 (revenant/RS_Revenant.zs:1012) | 88 | 360 | 35.8 | 27.9 | 5.37 | 10.85 | homing projectiles |
| 3 | Blue | RS_BlueRevenant | 420 (revenant/RS_Revenant.zs:1150) | 77 | 420 | 66.4 | 29.4 | 5.87 | 16.16 | strafes (A_FastChase); charges (skull attack) |
| 4 | Purple | RS_PurpleRevenant | 515 (revenant/RS_Revenant.zs:1313) | 66 | 515 | 41.1 | 32.8 | 4.23 | 14.48 | strafes (A_FastChase); charges (skull attack); homing projectiles; railgun |
| 5 | Cyan | RS_CyanRevenant2 | 480 (revenant/RS_Revenant.zs:342) | 120 | 480 | 40.5 | 19.9 | 6.79 | 15.52 | strafes (A_FastChase); hops/leaps; ice damage; homing projectiles |
| 6 | Brown | RS_BrownRevenant2 | 666 (revenant/RS_Revenant.zs:224) | 120 | 666 | 22.4 | 23.4 | 5.79 | 12.75 | buffs others (RS_RevSpeedBuff); homing projectiles |
| 7 | Yellow | RS_YellowRevenant | 666 (revenant/RS_Revenant.zs:1576) | 30 | 666 | 32.0 | 25.8 | 1.37 | 9.99 | summons (RS_SpecialSoul); fire damage; homing projectiles |
| 8 | FireBlu | RS_FireBluRevenant2 | 720 (revenant/RS_Revenant.zs:619) | 12 | 720 | 11.1 | 9.4 | 2.99 | 7.52 | fire damage |
| 9 | Gray | RS_GrayRevenant2 | 660 (revenant/RS_Revenant.zs:765) | 0 | 660 | 42.9 | 9.9 | 9.0 | 16.73 | charges (skull attack) |
| 10 | Red | RS_RedRevenant | 830 (revenant/RS_Revenant.zs:1797) | 22 | 830 | 57.1 | 43.6 | 6.98 | 22.11 | fire damage; homing projectiles |
| 11 | Abyss | RS_AbyssRevenant2 | 1000 (revenant/RS_Revenant.zs:480) | 76 | 1000 | 139.7 | 116.6 | 10.87 | 47.58 | ice damage; homing projectiles; hops/leaps |
| 12 | Black | RS_BlackRevenant3 | 4500 (revenant/RS_Revenant.zs:1954) | 64 | 5625 | 95.2 | 59.3 | 3.29 | 64.98 | summons (RS_RevShieldWalk); fire damage; charges (skull attack); homing projectiles; spawns monsters on death (RS_BlackRev2) |
| 12 | Black EX | RS_BlackRevenantEX | 7500 (revenant/RS_Revenant.zs:2243) | 32 | 9375 | 145.0 | 79.1 | 4.63 | 110.04 | summons (RS_RevShieldWalk2); summons (RS_RevShieldWalk); fire damage; homing projectiles; charges (skull attack) |
| 13 | White | RS_WhiteRevenant2 | 8866 (revenant/RS_Revenant.zs:2688) | 255 | 9241 | 41.5 | 16.9 | 7.66 | 63.25 | summons via RS_EvilShadeWhiteRev2 (RS_ArchRingHelp); summons via RS_EvilShadeWhiteRev (RS_ArchRingHelp); homing projectiles; ice damage; hops/leaps |

## Shotgunner

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonSG | 30 (QuestZDoom 17.3 zscript/actors/doom/possessed.zs:74) | 170 | 30 | 7.0 | 3.6 | 2.48 | 1.05 |  |
| 2 | Green | RS_GreenSG | 45 (shotgunner/RS_Shotgunner.zs:932) | 160 | 45 | 18.6 | 10.5 | 2.48 | 2.14 |  |
| 3 | Blue | RS_BlueSG | 55 (shotgunner/RS_Shotgunner.zs:1046) | 150 | 55 | 2.8 | 8.6 | 2.78 | 1.52 | railgun |
| 4 | Purple | RS_PurpleSG | 75 (shotgunner/RS_Shotgunner.zs:1163) | 150 | 75 | 30.1 | 0.9 | 2.83 | 3.24 | charges (skull attack); fire damage |
| 5 | Cyan | RS_CyanSG2 | 60 (shotgunner/RS_Shotgunner.zs:344) | 128 | 60 | 28.3 | 9.9 | 4.38 | 3.91 | strafes (A_FastChase); hops/leaps; hitscan; ice damage |
| 6 | Brown | RS_BrownSG2 | 155 (shotgunner/RS_Shotgunner.zs:216) | 102 | 155 | 45.0 | 12.8 | 2.88 | 6.38 | charges (skull attack); hitscan |
| 7 | Yellow | RS_YellowSG | 85 (shotgunner/RS_Shotgunner.zs:1282) | 128 | 85 | 26.2 | 15.1 | 2.12 | 3.36 | strafes (A_FastChase); hitscan |
| 8 | FireBlu | RS_FireBluSG2 | 225 (shotgunner/RS_Shotgunner.zs:733) | 110 | 225 | 65.8 | 29.0 | 2.99 | 9.04 | fire damage |
| 9 | Gray | RS_GraySG2 | 155 (shotgunner/RS_Shotgunner.zs:482) | 150 | 155 | 20.4 | 18.0 | 2.51 | 4.57 | hitscan; railgun |
| 10 | Red | RS_RedSG | 150 (shotgunner/RS_Shotgunner.zs:1423) | 110 | 150 | 24.2 | 8.2 | 2.24 | 4.01 | fire damage; hitscan |
| 11 | Abyss | RS_AbyssSG2 | 300 (shotgunner/RS_Shotgunner.zs:614) | 168 | 300 | 40.1 | 12.7 | 6.91 | 11.52 | ice damage; hitscan; hops/leaps |
| 12 | Black | RS_BlackSG3 | 1950 (shotgunner/RS_Shotgunner.zs:1549) | 96 | 3402 | 56.5 | 54.8 | 5.21 | 43.74 | summons (RS_BlackSG2); strafes (A_FastChase); hitscan; fire damage |
| 13 | White | RS_WhiteSG2 | 5000 (shotgunner/RS_Shotgunner.zs:1955) | 8 | 5000 | 36.3 | 15.7 | 14.0 | 48.73 | strafes (A_FastChase); fire damage; hitscan |
| 13 | White EX | RS_WhiteSGEX | 12537 (shotgunner/RS_Shotgunner.zs:2090) | 14 | 15154 | 486.6 | 225.5 | 15.45 | 321.76 | strafes (A_FastChase); summons (RS_ShotgunShrine); hitscan; fire damage |

## Spectre

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonSpectre | 150 (QuestZDoom 17.3 zscript/actors/doom/demon.zs:10) | 150 | 150 | 18.2 | 16.8 | 9.8 | 6.03 | shadow (spoils aim) |
| 2 | Green | RS_GreenSpectre | 175 (spectre/RS_Spectre.zs:660) | 130 | 175 | 30.5 | 28.8 | 11.78 | 8.88 | shadow (spoils aim) |
| 3 | Blue | RS_BlueSpectre | 210 (spectre/RS_Spectre.zs:751) | 110 | 210 | 65.3 | 39.9 | 13.77 | 14.82 | charges (skull attack); shadow (spoils aim) |
| 4 | Purple | RS_PurpleSpectre | 250 (spectre/RS_Spectre.zs:850) | 80 | 250 | 66.4 | 42.8 | 15.81 | 17.05 | charges (skull attack); shadow (spoils aim) |
| 5 | Cyan | RS_CyanSpectre2 | 270 (spectre/RS_Spectre.zs:348) | 64 | 270 | 7.1 | 3.1 | 8.78 | 4.68 | strafes (A_FastChase); ice damage; charges (skull attack) |
| 6 | Brown | RS_BrownSpectre2 | 300 (spectre/RS_Spectre.zs:236) | 33 | 300 | 30.1 | 26.7 | 8.43 | 10.47 | buffs others (RS_BrownImpCommand); buffs others (RS_SpeedBuffPE); heals others (A_RadiusGive Health) |
| 7 | Yellow | RS_YellowSpectre | 320 (spectre/RS_Spectre.zs:951) | 60 | 320 | 13.6 | 13.1 | 14.06 | 8.42 | shadow (spoils aim) |
| 8 | FireBlu | RS_FireBluDemon2 | 205 (demon/RS_Demon.zs:595) | 180 | 205 | 21.9 | 8.2 | 2.36 | 5.04 | charges (skull attack) |
| 9 | Gray | RS_GraySpectre2 | 450 (spectre/RS_Spectre.zs:497) | 128 | 450 | 13.7 | 12.2 | 6.35 | 8.06 | homing projectiles |
| 10 | Red | RS_RedSpectre | 394 (spectre/RS_Spectre.zs:1055) | 30 | 394 | 36.3 | 34.4 | 11.07 | 14.32 | fire damage; shadow (spoils aim) |
| 11 | Abyss | RS_AbyssDemon2 | 600 (demon/RS_Demon.zs:716) | 128 | 600 | 23.2 | 22.3 | 18.82 | 16.19 | fire damage; homing projectiles |
| 12 | Black | RS_BlackSpectre2 | 3000 (spectre/RS_Spectre.zs:1160) | 100 | 3000 | 12.0 | 4.8 | 14.84 | 23.84 | warps to the player; fire damage; teleports |
| 13 | White | RS_WhiteSpectre2 | 7500 (spectre/RS_Spectre.zs:1326) | 32 | 8978 | 38.2 | 13.9 | 4.36 | 46.5 | invulnerable phase; homing projectiles; summons (RS_Wakawaka) |

## Zombieman

| # | Colour | Class | HP (file:line) | Pain | EHP | DPS@256 | DPS@512 | Speed | CI | Main threats |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Common | RS_CommonZombie | 20 (QuestZDoom 17.3 zscript/actors/doom/possessed.zs:11) | 200 | 20 | 2.3 | 1.1 | 1.55 | 0.43 | summons (RS_ThePlanBoner) |
| 2 | Green | RS_GreenZombie | 40 (zombieman/RS_Zombieman.zs:1045) | 180 | 40 | 2.5 | 1.2 | 2.0 | 0.68 |  |
| 3 | Blue | RS_BlueZombie | 60 (zombieman/RS_Zombieman.zs:1176) | 140 | 60 | 6.4 | 2.5 | 2.09 | 1.31 | strafes (A_FastChase); hitscan |
| 4 | Purple | RS_PurpleZombie | 95 (zombieman/RS_Zombieman.zs:1322) | 120 | 95 | 9.0 | 3.4 | 2.36 | 2.0 | strafes (A_FastChase); hitscan; homing projectiles |
| 5 | Cyan | RS_CyanZombie2 | 30 (zombieman/RS_Zombieman.zs:414) | 40 | 30 | 20.4 | 4.6 | 4.46 | 1.87 | strafes (A_FastChase); ice damage |
| 6 | Brown | RS_BrownZombie2 | 100 (zombieman/RS_Zombieman.zs:222) | 128 | 100 | 2.1 | 1.0 | 1.21 | 1.04 | hops/leaps; strafes (A_FastChase) |
| 7 | Yellow | RS_YellowZombie | 140 (zombieman/RS_Zombieman.zs:1480) | 100 | 140 | 12.8 | 6.5 | 3.08 | 3.24 | strafes (A_FastChase); hitscan; fire damage |
| 8 | FireBlu | RS_FireBluZombie2 | 70 (zombieman/RS_Zombieman.zs:513) | 255 | 70 | 0.0 | 0.0 | 5.58 | 0.27 | fire damage |
| 9 | Gray | RS_GrayZombie2 | 110 (zombieman/RS_Zombieman.zs:642) | 40 | 110 | 20.3 | 6.6 | 0.78 | 2.41 |  |
| 10 | Red | RS_RedZombie | 186 (zombieman/RS_Zombieman.zs:1643) | 100 | 186 | 19.3 | 17.2 | 3.87 | 5.44 | hitscan; railgun |
| 11 | Abyss | RS_AbyssZombie2 | 200 (zombieman/RS_Zombieman.zs:829) | 18 | 200 | 29.1 | 9.5 | 7.28 | 6.79 | changes others (RS_CHAbyssMark); strafes (A_FastChase); ice damage |
| 12 | Black | RS_BlackZombie1 | 2500 (zombieman/RS_Zombieman.zs:2047) | 16 | 2500 | 22.2 | 24.0 | 6.44 | 25.47 | strafes (A_FastChase); hitscan |
| 12 | Black EX | RS_BlackZombieEX | 5000 (zombieman/RS_Zombieman.zs:1829) | 16 | 5000 | 100.3 | 69.7 | 6.95 | 84.52 | strafes (A_FastChase); hops/leaps; hitscan |
| 13 | White | RS_WhiteZombie1 | 2800 (zombieman/RS_Zombieman.zs:2444) | 16 | 2800 | 108.7 | 35.0 | 2.48 | 37.45 | buffs others (RS_CHBoner); strafes (A_FastChase); summons via RS_ShoveZM (RS_MrBones) |
