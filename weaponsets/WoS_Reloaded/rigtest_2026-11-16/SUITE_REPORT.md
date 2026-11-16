# WoS_Reloaded 0.8 rig suite

Tree 87f1f959f4d57663. ALL PASSED.

QZD 17.3 rig. The rig's doom2.wad is now Doom II; the suite was written on Freedoom 2 MAP01, and three checks depend on that map
(the Saturn V lock-on target, the door line): those three runs are on Freedoom 2 MAP01, the rest on Doom II MAP01.
The same three fail on Doom II with the pre-change pack too (RSQ_WeaponsOfSaturn_0.1.0.pk3), so they are the map, not the pack.

## RSQWS_Knuckles (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_Knuckles 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_Knuckles off rsq_hands |
| fire: the trigger is free (no blow from the weapon) | pass | 0 shots, Fire state not entered |
| alt: none (free) | pass | 0 shots, rounds -1 -> -1 |
| quick kick | pass | STATE t288 RSQWS_Knuckles DoKick |

## RSQWS_Motorsaw (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_Motorsaw 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_Motorsaw off rsq_hands |
| fire: the running bar cuts by contact | pass | 12 cuts by RSQWS_SawCut |
| alt: none (free) | pass | 0 shots, rounds -1 -> -1 |
| quick kick | pass | STATE t365 RSQWS_Motorsaw DoKick |

## RSQWS_Beretta (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_Beretta 1 owned 1 |
| raise | pass | PROBE t50 ready RSQWS_Beretta off rsq_hands |
| fire | pass | 1 shots (hitscan/round), rounds 11 -> 10 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 3 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt: none (free) | pass | 0 shots, rounds 11 -> 11 |
| quick kick | pass | STATE t359 RSQWS_Beretta DoKick |
| stock reload | pass | rounds 0 -> 10 (want 0 -> 10) |
| hand reload (robot, mag) | pass | rounds 0 -> 10 (want 0 -> 10) |
| flick reload (BD22 VR: a gun in each hand) | pass | rounds 0 -> 10 (want 0 -> 10) |
| dual: off-hand copy in the off hand, fires on the off trigger | pass | off hand RSQ_Off_RSQWS_Beretta; off rounds 11 -> 10; 1 shots |

## RSQWS_1911 (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_1911 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_1911 off rsq_hands |
| fire | pass | 1 shots (hitscan/round), rounds 8 -> 7 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 3 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt: none (free) | pass | 0 shots, rounds 8 -> 8 |
| quick kick | pass | STATE t359 RSQWS_1911 DoKick |
| stock reload | pass | rounds 0 -> 7 (want 0 -> 7) |
| hand reload (robot, mag) | pass | rounds 0 -> 7 (want 0 -> 7) |
| flick reload (BD22 VR: a gun in each hand) | pass | rounds 0 -> 7 (want 0 -> 7) |
| dual: off-hand copy in the off hand, fires on the off trigger | pass | off hand RSQ_Off_RSQWS_1911; off rounds 8 -> 7; 1 shots |

## RSQWS_MP40 (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_MP40 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_MP40 off rsq_hands |
| fire | pass | 1 shots (hitscan/round), rounds 32 -> 31 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 3 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt: none (free) | pass | 0 shots, rounds 32 -> 32 |
| quick kick | pass | STATE t359 RSQWS_MP40 DoKick |
| stock reload | pass | rounds 0 -> 32 (want 0 -> 32) |
| hand reload (robot, mag) | pass | rounds 0 -> 32 (want 0 -> 32) |
| flick reload (BD22 VR: a gun in each hand) | pass | rounds 0 -> 32 (want 0 -> 32) |
| dual: off-hand copy in the off hand, fires on the off trigger | pass | off hand RSQ_Off_RSQWS_MP40; off rounds 32 -> 31; 1 shots |

## RSQWS_MachineRifle (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_MachineRifle 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_MachineRifle off rsq_hands |
| fire | pass | 1 shots (hitscan/round), rounds 31 -> 30 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 5 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt: underbarrel loaded by hand, then fired | pass | 1 grenades out;  pull 10.7 hand 1: took a round; rsm t883 pull 10.7 hand 2: round in the breech; rsm t917 pull 10.7 hand 0: round home; rsm t940 pull 10.7 hand 0: took the tube; rsm t955 pull 0.0 hand 0: shut: loaded |
| quick kick | pass | STATE t1749 RSQWS_MachineRifle DoKick |
| stock reload | pass | rounds 0 -> 30 (want 0 -> 30) |
| hand reload (robot, mag) | pass | rounds 0 -> 30 (want 0 -> 30) |
| flick reload (BD22 VR: a gun in each hand) | pass | rounds 0 -> 30 (want 0 -> 30) |
| dual: off-hand copy in the off hand, fires on the off trigger | pass | off hand RSQ_Off_RSQWS_MachineRifle; off rounds 31 -> 29; 2 shots |

## RSQWS_Minigun (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_Minigun 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_Minigun off rsq_hands |
| fire | pass | 20 shots (hitscan/round), rounds 120 -> 104 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 26 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 66 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt: RSQWS_RotaryPlasma | pass | 25 RSQWS_RotaryPlasma |
| quick kick | pass | STATE t470 RSQWS_Minigun DoKick |
| stock reload | pass | rounds 0 -> 120 (want 0 -> 120) |
| hand reload (robot, mag) | pass | rounds 0 -> 120 (want 0 -> 120) |

## RSQWS_NovaRifle (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_NovaRifle 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_NovaRifle off rsq_hands |
| fire | pass | 3 shots (RSQWS_Plasma), rounds 60 -> 57 |
| alt: RSQWS_NovaBall | pass | 1 RSQWS_NovaBall |
| quick kick | pass | STATE t305 RSQWS_NovaRifle DoKick |
| stock reload | pass | rounds 0 -> 60 (want 0 -> 60) |
| hand reload (robot, mag) | pass | rounds 0 -> 60 (want 0 -> 60) |

## RSQWS_TITAN (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_TITAN 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_TITAN off rsq_hands |
| fire | pass | 1 shots (RSQWS_Nova), rounds 160 -> 155 |
| alt: RSQWS_HyperNova | pass | 1 RSQWS_HyperNova |
| quick kick | pass | STATE t326 RSQWS_TITAN DoKick |
| stock reload | pass | rounds 0 -> 160 (want 0 -> 160) |
| hand reload (robot, mag) | pass | rounds 0 -> 160 (want 0 -> 160) |

## RSQWS_Riotgun (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_Riotgun 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_Riotgun off rsq_hands |
| fire, then a pull pumps it itself (no hand), then it fires again | pass | 14 shots (hitscan/round), rounds 9 -> 7 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 2 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 16 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt (slug / both barrels) | pass | 1 shots, rounds 9 -> 8 |
| quick kick | pass | STATE t790 RSQWS_Riotgun DoKick |
| stock reload | pass | rounds 0 -> 9 (want 0 -> 9) |
| hand reload (robot, pump) | pass | rounds 0 -> 9 (want 0 -> 9) |
| Shotgun Shells Per Insert = 4: the tube fills in 3 inserts | pass | 3 shells pushed home |

## RSQWS_Coachgun (Doom II MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_Coachgun 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_Coachgun off rsq_hands |
| fire | pass | 9 shots (hitscan/round), rounds 2 -> 1 |
| RS Ballistics impact / flash effects, True Bullets on | pass | 1 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| RS Ballistics impact / flash effects, True Bullets off (hitscan) | pass | 19 effect actors (RSQ_Flash / RSQ_ImpactLight / RSQ_Debris) |
| alt (slug / both barrels) | pass | 20 shots, rounds 2 -> 0 |
| quick kick | pass | STATE t359 RSQWS_Coachgun DoKick |
| stock reload | pass | rounds 0 -> 2 (want 0 -> 2) |
| hand reload (robot, break) | pass | rounds 0 -> 2 (want 0 -> 2) |
| flick reload (BD22 VR: the lone SSG) | pass | rounds 0 -> 2 (want 0 -> 2) |

## RSQWS_SaturnV (Freedoom 2 MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| pickup | pass | PICKUP RSQWS_SaturnV 1 owned 1 |
| raise | pass | PROBE t60 ready RSQWS_SaturnV off rsq_hands |
| fire | pass | 1 shots (RSQWS_SaturnRocket), rounds 12 -> 11 |
| alt: lock-on, release fires the salvo | pass | 1 Saturn rockets after release |
| quick kick | pass | STATE t385 RSQWS_SaturnV DoKick |
| stock reload | pass | rounds 0 -> 12 (want 0 -> 12) |
| hand reload (robot, mag) | pass | rounds 0 -> 12 (want 0 -> 12) |

## BASICS (Freedoom 2 MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| quick grenade: thrown, goes off in Doom's explosion | pass | 1 thrown, 1 Doom explosions |
| barrels take the blast twice | pass | barrel health 20 -> -8, one hit [14] |
| jab, main hand | pass | RSQB punch t257: jab, hand 0 |
| hook, main hand | pass | RSQB punch t315: hook, hand 0 |
| jab, off hand | pass | RSQB punch t347: jab, hand 1 |
| a jab lands on a monster | pass | DMG t257 DoomImp by rsqb_punch 6 |
| uppercut kicks a barrel up and away, no damage | pass | RSQB uppercut kicks ExplosiveBarrel: up 7.9, no damage (health 20) |
| pistol whip lands | pass | DMG t512 DoomImp by rsqb_punch 14 |
| a door lifted by hand (the palm against it) | pass | ceiling -64.0 -> -46.3 -> -21.5 |

## BASICS_WITH_SERIES (Freedoom 2 MAP01)

| check | result | detail |
|---|---|---|
| no script error / VM abort | pass | none |
| with RSQ Grenade: the basic grenade stands down, RSQ Grenade throws | pass | basic 0, RSQ Grenade 1 |
| with RSQ Melee: the basic punches stand down | pass | 0 basic punches |
| with Distance Grab: the basic door lift stands down, Distance Grab lifts it | pass | basic voice 0, ceiling -64.0 -> -46.3 -> -21.5 |
