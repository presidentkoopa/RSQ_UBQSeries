# Performance: what is waiting on the owner (2026-11-27)

**Decided 2026-11-27 (owner):** #1 tier icons DONE, #47 + #48 Titan aura every 4 tics and grey shadows DONE, #4 ceiling
watcher DONE (exact: plain sector fields checked every tic), #3 gore system: design in design/GORE_SYSTEM_DESIGN.md.
#65 Dakka dots: measure first (slow-mo + True Bullets scenario).

Everything here CHANGES something (a look, a timing, a behaviour, or what other mods see), so none of it is done.
The behaviour-identical fixes are made separately (see README.md, "Windows rig, 2026-11-27"). Savings are estimates
from reading the code unless marked measured. **R** = my recommendation.

## The big ones

| # | Mod | What | Saves | What changes | R |
|---|---|---|---|---|---|
| 1 | Monsters (all families) | Tier icons: every monster's Spawn/See loop spawns an icon actor (1,440 call sites); with icons off (the default) it removes itself on its first tic, so nothing shows. Skip the spawn when icons are off, still drawing the same random numbers. | ~400-600 spawns/s at 200 monsters | Other mods' spawn hooks stop seeing an invisible icon actor | Do it |
| 2 | Miniboss (Mikk-'s champions) | Titan aura: 3 inventory actors per nearby monster per tic, even when only refreshing the buff | measured 806 spawns/s in a 100-monster fight | (a reader is on it; an identical version may be possible) | Do it |
| 3 | Gore (BD22 + XMVE classes) | A high-performance gore system as our own pk3 replacing BD's gore classes: particles/decals for blood and mist, capped recycled gibs that stop thinking when landed, one pool per body, headshots by hit height (no helper actors), a gore budget | ~400 gore spawns/s measured, plus permanent residue (nothing in BD cleans up gore) | It is a rewrite; the look must be matched | Design next |
| 4 | Grenade | Ceiling watcher refits up to 512 explosion/smoke actors every tic; refit only when something changed | ~0.3-1 ms/tic in fights | A moving ceiling followed a tic late | Do it |

## Look / feel changes

| # | Mod | What | Saves | What changes |
|---|---|---|---|---|
| 5 | Laser Sight | Grenade arc: simulate every 2nd tic or trace 2-tic chords | ~half of up to 280 traces/tic while an arc shows | Landing point may shift slightly |
| 6 | Graveyard | Candle lights re-attached every tic per stone; every 2nd tic or quantised flicker | half the light rebuilds | Flicker less smooth |
| 7 | Graveyard | gy_living_debug read per stone per tic; use the cached copy | up to 200 lookups/tic | Debug toggle takes up to 1 s |
| 8 | Gun Cards | Bake the watch card's fixed words (MAG, RESERVE, KILLS...) as single pieces | half to two thirds of the card's draw calls | Needs a re-bake |
| 9 | Gun Cards | Draw in the World (off by default): reuse strip actors | 2+ spawns per shot while on | - |
| 10 | Grapple | Chain links: about a third as many | ~300 spawns per hook use, ~0.1 ms/tic hooked | The approved chain look |
| 11 | Accessibility | Wake cues walk every monster every 2 tics even when off | small | Re-seed on enable |
| 12 | Accessibility | Quiet() asks 3 old Grapple names that Grapple 2.0 always answers -1 | small | Only matters for an old Grapple |
| 13 | Accessibility template | Per-tic cache in tools/a11y_template.zs (class-by-name + cvar per call) | ~0.02-0.04 ms | Template change, all copies |
| 14 | Grenade | Count Flip lights toward LIGHT_CAP | lights | More lights capped |
| 15 | VisualRewards | Kill-reward bits: fewer per death (cap 100) | engine movement of each bit | Fewer bits |
| 16 | VisualRewards | Magnet scan once per player instead of per bit | ~0.01-0.03 ms | Order bits are touched |
| 17 | VisualRewards | HP-bar parts pooled instead of destroyed/respawned | small | - |
| 18 | VisualRewards | DnDriver reads SlowMo speed only while numbers exist | 1 service call/tic | - |
| 19 | VisualRewards | IsDyingBody cached per class (needs a handler to hold it) | string walks per damage | - |
| 20 | Whip | Mark under Lock-On Controls: scan every 2nd tic | ~half | Mark updates a tic later |
| 21 | Whip | WhipTip sound carriers think 90 tics; shorten | small | Could cut sounds |
| 22 | Distance Grab | Missile tracking only while a shield-capable thing is held | ~15-25 µs/tic | Missiles fired before the grab not stopped |
| 23 | GlowInTheDark | Spread BuildNear (walks every sector once a second) over the second | removes a 0.5-1 ms spike on big maps | Which rooms count as near, per tic |
| 24 | Saber | Swing trail and return bolt as full-bright particles | up to ~280+ spawns/s | Trail look |
| 25 | Saber | One reused sound emitter per saber instead of a UBQS_Ping per contact | spawns per contact | - |
| 26 | Saber | Force outline search only while the Force is raised (or every 6 tics) | most box searches | Outline timing |
| 27 | Saber/SlowMo | Ask SlowMo's speed once per tic in one place, not per effect actor | many service calls | (needs a comparator) |
| 28 | Wheel | Inspect trace limited to inspect reach (~1.7 m) instead of 512 units, or every other tic | ~0.02-0.04 ms/tic | A far actor no longer blocks the off-hand check |
| 29 | Wheel | Open-ring card light re-attached only on change | 1 light/tic while open | - |
| 30 | Melee | Club pose events only while a club/VR punch is up; fold RSQML_cs into RSQ_hs | ~0.03 ms/tic | One-tic pose delay after a switch |
| 31 | Gun Bonsai VR | Skip pure effects in InheritProvenance | ~0.05-0.15 ms/tic | XP attribution |
| 32 | Melee | Shove pulse gives an item to every monster within 2048 | burst of spawns | - |
| 33 | Score | Decide crits on the player's item, give the stun item only on a crit | ~2 spawns per monster, ~280 VM calls/tic | Crit multiplier applies before the monster's protections |
| 34 | Score | Merge CritBrain and CritController into one item | half the items | Class names |
| 35 | Score | Skip non-shootable "monsters" (BD helpers) | items on helpers | Those can never crit |
| 36 | Score | Take crit items off corpses after the stun, give back if raised | per-tic calls on corpses | Raised monster's item order |
| 37 | Score | Refresh JustStunned in place | 1-3 spawns/s | Other mods' hooks stop seeing it |
| 38 | Monsters | Black vile eyes: particles instead of a dummy actor every tic | ~70 spawns/s per vile | - |
| 39 | Monsters | Halve the worst projectile trails (SoundWave, Hidi Zap2, STracer puffs, Volcano smoke, Hades zappers, FrostWing) | 50% of each | Trail density |
| 40 | Monsters | Cap death bursts (CGBigEx 255 -> ~30, Zap7 352 -> ~60, penta fires one damage actor per line, Zap2 9 -> 3) | huge bursts | Burst look |
| 41 | Monsters | Deep tentacle dirt once instead of every 10 idle tics (looks like a bug); cap wraith count/lifetime | spawns | - |
| 42 | Monsters | Yellow caco idle look every 10 tics instead of 1 | 35 spawns/s per idle yellow caco | Wakes slightly slower |
| 43 | Monsters | Walking abyss splashes 1-2 per loop instead of 6-18 | ~17-28/s each | Splash look |
| 44 | Tactical Rig | Cigarette smoke/embers after a smoke (lying butt every 2 tics for 10-30 s, ~17 actors/s) | small | Smoke look |
| 45 | Tactical Rig | Rule flash: reuse its 25 actors (picture + 24 glow copies) instead of spawning and destroying them | 25 spawns per flash, a few a minute | Nothing visible (needs a check) |
| 46 | Tactical Rig | Rumble Buzzer actors live 40 tics after a 3-6 tic pulse | small | Last quake could be cut short |
| 47 | Miniboss champions | Titan aura: the remaining third (the AggroEffect give itself, ~270 spawns/s in the wave fight): give every 4 tics (the buff lasts 350) | ~270 spawns/s | DamageFactor updates every 4 tics, not every tic |
| 48 | Miniboss champions | GreyShadowSpawner resets its age on ANY item picked up: near a Titan a grey champion trails shadows forever (1 spawn a tic) | 35 spawns/s per grey near a Titan | Fixes the never-ending trail (looks like a bug); Score's crit delayer has the same pattern |
| 49 | Miniboss champions | Creep: skip SetOrigin when already at floorz+1 (~20 alive per creep champion) | re-links per creep per tic | Blockmap/sector list order only |
| 50 | Miniboss champions | Creep spawn rate / lifetime; bundle drop caps (up to 25 items per drop, lie all level) | spawns, live actors | Creep look, drop amounts |
| 51 | Miniboss champions | Gold (midas) gives one item per monster every other tic, even monsters already gold | spawns | Same as #2 pattern |
| 52 | Miniboss champions | Silver/Cyan A_RadiusThrust every tic; Undying Heart A_Chase every tic | small | Timing |
| 53 | Miniboss (LD Lite) | Pentagram: every other tic with double particle life, or fewer points (~700 particle calls a tic for ~140 tics per transformation) | ~half of 0.2-0.4 ms/tic per pentagram | Look; its own random sequence |
| 54 | Miniboss (kiosk) | Rebuild only the changed letter line, not all ~60 letter actors, when gold/lives change | ~60 spawns per change | Nothing visible |
| 55 | Miniboss (LD Lite) | Under Light, skip the Lite ghosts the handler hides anyway | ~17 spawns/s per legendary | Nothing visible (extending Light to coloured ghosts would change the look) |
| 56 | Miniboss (LD Lite) | Alternator item -> a field (edit tools/gen_ldlite.py, main.txt is generated) | ~17 spawns/s per non-champion legendary | - |
| 57 | Miniboss (boss FX) | Trail beads as pooled VisualThinkers (as fx.zs does) | 100-200 warps a tic in a fight | - |
| 58 | Miniboss (LD Lite) | Map-start legendary roll in ZScript instead of 64 A_RadiusGive at radius 16384 | 8-12 spawns per monster at tic 1 (and every 60 s with Over Time) | The order monsters get their rolls |
| 59 | Miniboss (boss bar) | Cache the boss name per fight instead of rebuilding every frame (Big Bosses allocate an object per frame) | ui per frame | - |
| 60 | Monsters (Plus) | Romero EX beam: count the Dewzan tokens in place instead of up to 5,500 token gives + 5,500 explodes per attack | thousands of spawns per attack | Spawn RNG stream; other mods' spawn hooks |
| 61 | Monsters | Black troop SitRep stance in state code (~20 spawns/s per troop); drop the do-nothing RS_RevSpeedBuff radius gives; drop gives of tokens nobody holds; drop 7 duplicate Icon calls in Plus Tick overrides | spawns | Spawn RNG stream |
| 62 | Monsters | Forever-thinkers (RS_BLSoulAss, RS_SkullWSoulEX1/2 after the boss dies, RS_DarkChannelWhiteRev): orphan check or lifetime | live thinkers | They end |
| 63 | Monsters | Cap/throttle the Abyss trails (AbyssMind2 walk 100+/s, abyss spider ~43/s), CrackedAbyssMind 768 Zap88 per fall, Beam3 chain | spawns | Look |
| 64 | Monsters | Brown zombie: one BlockThingsIterator pass instead of 5x A_CheckProximity every 24 tics | full-level scans | Only when two targets tie on distance |

| 65 | BD22 VR Reloaded | Dakka dots: one RSQ_DakkaDot actor per 12 units of every True Bullets round (on by default), up to 600 alive, plus puff + 4 sparks per impact; draw as textured particles | likely hundreds of spawns/s | Near-identical look; spawn RNG draws |
| 66 | BD22 VR Reloaded | Items re-given while already held: counters' pouch token every tic, RSR/RSB/RSP tick messengers during reloads, BD22's HasPlasmaWeapon / Dragonslayer gives, axe grip gives | 35 spawns/s each | Spawn RNG draws; spawn hooks |
| 67 | BD22 VR Reloaded | BD22 weapon effect volume (ASG ~280 actors/s, Unmaker 700-1000/s, SSG, BFG, Incendiary, dual Minigun) | large | Look |
| 68 | BD22 VR Reloaded | hit.zs actor per bullet impact; flash.zs a dynamic light per hand per firing tic | spawns, lights | Look |
| 69 | BD22 VR Reloaded | HandTone: keep the parsed class list for the whole session (the parse now runs fast, but every map) | one parse per map | Adds a class |
| 70 | BD22 VR Reloaded | BUG: hands.zs saves raw sprite indices in savegames; make them transient | - | Correctness after a mod update |

| 71 | Load order | LegenDoom 3.0 (third party, 0.99-LegenDoom_3.0.pk3) gives every legendary a new LDLegendaryMonsterVisualEffectMaker item every tic plus a coloured afterimage: measured ~240-260 spawns/s in a Miniboss fight. RSQ Miniboss's own LegenDoom Lite does the same job and its maker churn is fixed (one maker per legendary, run in place). Use Lite instead (take LegenDoom 3.0 out of the rotation) | ~240-260 spawns/s in boss fights | LegenDoom 3.0's features vs Lite's |

**Scenario measurements (2026-11-27, rig, script time):** Miniboss fight 5.30 -> 4.25 ms/tic, worst single tic 20.2 ->
2.3 ms; slow-mo 30 s at 25% with the Minigun 4.41 -> 4.01 ms/tic (SlowMo's clock still 0.34-0.38 ms/tic: its per-actor
slowing). The scripted slow-mo Minigun produced almost no Dakka dots (ricochets/puffs instead), so #65 needs a rerun with a
weapon confirmed to fire True Bullets; the boss fight with every weapon showed 57-77 Dakka dots a second.

**#1 update (both Monsters readers):** the icon gate can keep the random stream exact too: skip the spawn, keep the
three random() argument draws AND make the spawn's own draw on the engine's spawn stream (random[SpawnActor]). Then the
only difference is that no mod's spawn hook sees the invisible icon (Accessibility's sound cues stop drawing false
"incoming" arrows for them). Ready patch: scratchpad agents\monstersB\apply_tiericon_gate.py. Series-wide ~150-600
spawns/s depending on monster count.

## Not performance, found on the way

- SlowMo: its rumble actor (RSQSM_Buzz) is spawned only on the local machine (harmless while QuestZDoom has no netplay).
- Score: gold.zs PlayerDied keys the kept gold on consoleplayer (a co-op bug if netplay ever comes).
- Monsters: the "unreachable HBeastSmoke" comments in RS_Fatso.zs (~674, 681, 1568) are wrong; A_Jump(81) reaches them.
- Gun Bonsai VR: rsq/zscript/a11y.zs is a stale generated copy (raw lookup, not hot); regenerate when convenient.

- BD22 VR Reloaded: hands.zs saves raw sprite indices in savegames (#70).
- Grenade: RSQA_Handler's single 21 ms tic: nothing in Accessibility's own code scales; likely a garbage-collection step
  or a first sound playback landing in it.

All 23 mods (22 in RSQ_UBQSeries + BD22 VR Reloaded) were read in full on 2026-11-27, ~330k lines, by 15 readers.
