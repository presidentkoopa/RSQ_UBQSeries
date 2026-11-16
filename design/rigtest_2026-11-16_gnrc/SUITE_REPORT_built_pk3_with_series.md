# GNRC_Reloaded rig suite

Tree dd2fbdc68ee9b93d, pk3 /home/claude/scratch_gnrc/GNRC_Reloaded_0.8_built.pk3, with RSQ_Accessibility.pk3 RSQ_DistanceGrab.pk3 RSQ_FnF.pk3 RSQ_GlowInTheDark.pk3 RSQ_Grapple.pk3 RSQ_Graveyard.pk3 RSQ_Grenade.pk3 RSQ_GunCards.pk3 RSQ_GunCards_Grenade.pk3 RSQ_LaserSight.pk3 RSQ_Melee.pk3 RSQ_Monsters.pk3 RSQ_Saber.pk3 RSQ_Score.pk3 RSQ_ShieldSaw.pk3 RSQ_SlowMo.pk3 RSQ_TacticalRig.pk3 RSQ_VisualRewards.pk3 RSQ_Wheel.pk3 RSQ_Whip.pk3. NOT PASSED.

QuestZDoom 17.3 rig, Freedoom 2 MAP01, god + notarget, controllers driven as cvars. Raw logs: out/suite/<class>.log.

## RSQGW_Knuckle

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_Knuckle 1 owned 1 |
| raise | pass | PROBE t45 ready RSQGW_Knuckle off rsq_hands |
| fire: the trigger is free (no blow from the weapon) | pass | 0 shots, Fire state entered |
| alt: none (free) | pass | 0 shots, rounds -1 -> -1 |
| quick kick | pass | STATE t288 RSQGW_Knuckle DoKick |

## RSQGW_ModChainsaw

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_ModChainsaw 1 owned 1 |
| raise | pass | PROBE t46 ready RSQGW_ModChainsaw off rsq_hands |
| fire: the running bar cuts by contact | pass | 8 cuts by RSQGW_SawCut |
| alt: none (free) | pass | 0 shots, rounds -1 |
| quick kick | pass | STATE t365 RSQGW_ModChainsaw DoKick |

## RSQGW_Beretta

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_Beretta 1 owned 1 |
| raise | pass | PROBE t52 ready RSQGW_Beretta off rsq_hands |
| fire | pass | 1 shots (hitscan/round), rounds 11 -> 10 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 3 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| rate of fire held: 5-6 a second | pass | 5.83 a second (6 shots, tics 265 271 277 283 289 295) |
| alt (burst / slug / both barrels) | pass | 3 shots, rounds 5 -> 2 |
| quick kick | pass | STATE t437 RSQGW_Beretta DoKick |
| stock reload | pass | rounds 0 -> 10 (want 0 -> 10) |
| hand reload (robot, mag) | pass | rounds 0 -> 10 (want 0 -> 10) |
| flick reload (BD22 VR: a gun in each hand) | pass | rounds 0 -> 10 (want 0 -> 10) |
| dual: off-hand copy in the off hand, fires on the off trigger | pass | off hand RSQ_Off_RSQGW_Beretta; off rounds 11 -> 10; 1 shots |

## RSQGW_ARifle

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_ARifle 1 owned 1 |
| raise | pass | PROBE t45 ready RSQGW_ARifle off rsq_hands |
| fire | pass | 1 shots (hitscan/round), rounds 31 -> 30 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 5 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt: switches to 3-round burst (a long pull fires 3 and stops) | pass | 3 shots, rounds 31 -> 28 |
| quick kick | pass | STATE t395 RSQGW_ARifle DoKick |
| stock reload | pass | rounds 0 -> 30 (want 0 -> 30) |
| hand reload (robot, mag) | pass | rounds 0 -> 30 (want 0 -> 30) |
| flick reload (BD22 VR: a gun in each hand) | pass | rounds 0 -> 30 (want 0 -> 30) |
| dual: off-hand copy in the off hand, fires on the off trigger | pass | off hand RSQ_Off_RSQGW_ARifle; off rounds 31 -> 30; 1 shots |

## RSQGW_Minigun

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_Minigun 1 owned 1 |
| raise | pass | PROBE t45 ready RSQGW_Minigun off rsq_hands |
| fire | pass | 16 shots (hitscan/round), rounds 150 -> 134 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 16 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 48 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt: none (free) | pass | 0 shots, rounds 150 -> 150 |
| quick kick | pass | STATE t433 RSQGW_Minigun DoKick |
| stock reload | pass | rounds 0 -> 150 (want 0 -> 150) |
| hand reload (robot, mag) | pass | rounds 0 -> 150 (want 0 -> 150) |

## RSQGW_Rlauncher

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_Rlauncher 1 owned 1 |
| raise | pass | PROBE t45 ready RSQGW_Rlauncher off rsq_hands |
| fire | pass | 1 shots (RSQGW_Rocket2), rounds 5 -> 4 |
| alt: none (free) | pass | 0 shots, rounds 4 -> 4 |
| quick kick | pass | STATE t289 RSQGW_Rlauncher DoKick |
| stock reload | pass | rounds 0 -> 5 (want 0 -> 5) |
| hand reload (robot, mag) | pass | rounds 0 -> 5 (want 0 -> 5) |

## RSQGW_PlasRifle

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_PlasRifle 1 owned 1 |
| raise | pass | PROBE t46 ready RSQGW_PlasRifle off rsq_hands |
| fire | pass | 1 shots (RSQGW_Plasma), rounds 60 -> 59 |
| alt: the rail, 20 cells from the magazine | pass | rounds 59 -> 39 |
| quick kick | pass | STATE t288 RSQGW_PlasRifle DoKick |
| stock reload | pass | rounds 0 -> 60 (want 0 -> 60) |
| hand reload (robot, mag) | pass | rounds 0 -> 60 (want 0 -> 60) |

## RSQGW_BFG9K

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_BFG9K 1 owned 1 |
| raise | pass | PROBE t45 ready RSQGW_BFG9K off rsq_hands |
| fire: one BFGBall, 40 cells from the reserve (no magazine) | **FAIL** | 1 shots, cells 300 |
| alt: none (free) | pass | 0 shots, rounds -1 -> -1 -> -1 |
| quick kick | pass | STATE t289 RSQGW_BFG9K DoKick |

## RSQGW_Riotgun

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_Riotgun 1 owned 1 |
| raise | pass | PROBE t45 ready RSQGW_Riotgun off rsq_hands |
| fire, then a pull pumps it itself (no hand), then it fires again | pass | 14 shots (hitscan/round), rounds 8 -> 6 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 2 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 16 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt (burst / slug / both barrels) | pass | 1 shots, rounds 8 -> 7 |
| quick kick | pass | STATE t790 RSQGW_Riotgun DoKick |
| stock reload | pass | rounds 0 -> 8 (want 0 -> 8) |
| hand reload (robot, pump) | pass | rounds 0 -> 8 (want 0 -> 8) |
| Shotgun Shells Per Insert = 4: the tube fills in 2 inserts | pass | 2 shells pushed home |

## RSQGW_DoubleSG

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQGW_DoubleSG 1 owned 1 |
| raise | pass | PROBE t45 ready RSQGW_DoubleSG off rsq_hands |
| fire | pass | 9 shots (hitscan/round), rounds 2 -> 1 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 19 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt (burst / slug / both barrels) | pass | 20 shots, rounds 2 -> 0 |
| quick kick | pass | STATE t360 RSQGW_DoubleSG DoKick |
| stock reload | pass | rounds 0 -> 2 (want 0 -> 2) |
| hand reload (robot, break) | pass | rounds 0 -> 2 (want 0 -> 2) |
| flick reload (BD22 VR: the lone SSG) | pass | rounds 0 -> 2 (want 0 -> 2) |
