# HANDOFF -- RSQ_Whip (PROJECT WHIP), 2026-10-30

Not run on the owner's headset. Rig: QZD 17.3 (RSQ_WeaponDepot tools/rig/bin), freedoom2 MAP01 and WHIPTEST
(tools/rigtest/mkwhipmap.py: a ledge, a pit, a beam over it, a 96-unit block, a switch pillar). Hands driven per tic by
tools/rigtest/whipprobe (the rig's qzt_rhand), runner tools/rigtest/whip.sh (BD=1 the owner's BD order, GRAPPLE=1 also
loads pk3/RSQ_Grapple.pk3).

## Owner's picks 2026-10-31 (6, 7, 9 yes; 8, 10 options, off) -- rig only, not headset-confirmed
All on doom2 + brutal22test6 + BD_VoxelPack + BD22 VR-Reloaded 2.0.3h + hotfix + RSQ_Whip, the whip weapon in hand, map
WHIPTEST (`map WHIPTEST` after `-warp 1`). Only BD_VoxelPack's 4 voxeldef script errors. Scenarios: whipprobe `wpr_scen`
10 (flail) / 11 (lasso), `wpr_ballat` (an imp ball each cycle), `wpr_slow`, `wpr_log 4` keys / 5 monsters.

### Done (measured)
| pick | built | rig log |
|---|---|---|
| 6 crack damage by tip speed (apply/08 3.1, apply/01 2.4) | crack = damage x (0.25 + 0.75k), k from the crack speed (20) to `rsqwp_whip_fullcrack` (50, the top of whipsim's measured overhead/side-arm range); `rsqwp_whip_damage` is the top. Stings now stay under the softest crack (a quarter x speed/crack speed); the old half-damage sting out-hurt a soft crack (6 against 3). Assist: always the top | MAP01 motion 3: tip 21.2 -> 3, 24.9 -> 4, 47.8 -> 11, 101.8 -> 12 |
| 7 Quest lasso (apply/01 5.2) | the off grip key read raw (`rsqwp_keys_off` "443 436", DG's codes; never eaten) or a grab bind, with the off controller within `rsqwp_lasso_reach` 0.30 m of the handle or the inner thong; kept while the grip is down | `vr_two_handed_weapons 0`: key 443 down, "off hand 0.11 m from the thong", LASSO on by the off hand, whirl, let go at tip 30.9, roped an imp. Frames: BD's left hand holds the whirling thong |
| 7 latch kept | WF_TWOHANDSTABILIZED still turns it on | default settings: "LASSO on by the two-hand latch" on the OpenXR rig |
| 9 flail (apply/01 4.2) | wrapped/lassoed monster held at the wrap distance from the whip hand, on its bearing off the hand's yaw; placed by TryMove (cap `rsqwp_max_speed`, half for over `rsqwp_whip_light`; heavy = no swing); light ones pinned in Pain (re-pinned every tic, put back on unwrap); a monster it is stopped by takes Grapple's (speed-8)x0.8 (max 40), forced Pain and a shove, the swung one half. Trigger held keeps hold. `rsqwp_whip_flail` | marked crack: imp swung from bearing 0 to -52 deg, SMASH into both side imps (speed 11-12, dmg 2-3, stagger). Lasso: 8 SMASHes at speed 28-30, dmg 15-17 |
| 8 fireball (option, 06_GRAB 4.6, 01_MELEE 4.11) | in a crack's lash, a fast outer link's sweep within radius+4 of a monster missile's path -> ExplodeMissile. Missiles listed on spawn (PROJECTILE is NOBLOCKMAP: no iterator finds one) | 2 DoomImpBalls cracked (t494, t630); a BD PlasmaSmoke (no shooter) was popped before the monster-shooter filter, not after |
| 10 hit-stop (option, 01_MELEE 3.6) | freezetics 3 + 3k | freeze 5 -> 3 -> 1 -> 0, state tics held at 2 |
| fixes found on the way | no crack while the lash flies out to a target (a lasso throw cracked at 108 on the way); the thong no longer stings the monster it is wrapped round; `gen_reset.py` handles noarchive and string cvars (Reset All checked: keys back to "443 436") |  |
| cost | rsqwp_debug 3, desktop, BD order | 0.16-0.20 ms out, 0.26 whirling, 0.39 mean / 0.86 max flailing into 8 imps |

### Owner's answers 2026-10-31 (later): lock the mark (yes), yank grace (option), cracked rockets (choice) -- rig only
Same order (doom2 + BD + VR-Reloaded + hotfix), doom2 MAP01, whipprobe; only BD_VoxelPack's voxeldef script errors.
| pick | built | rig log |
|---|---|---|
| lock the mark (`rsqwp_whip_marklock`, on) | Mark: the hand no longer points at the marked thing -> it stays marked while it is alive / untaken, within 512 and in sight (StillMarkable). Alt-fire still moves it; alt-fire with nothing else in the cone keeps it | scen 10, imp 200 ahead. Before: t88 "MARK -> RifleZombie" on the lift. After: "t88 MARK kept on DoomImp (2 other candidates there)", CRACK #1 t112 LOCKED -> DoomImp. Alt-fire: t80 DoomImp -> RifleZombie, then kept through the lift, cracked and wrapped the zombie at 335 |
| yank grace (`rsqwp_whip_yankgrace`, option off) | HoldWrap: no pull counts for YANK_GRACE 12 tics after BeginWrap, nor a pull still under way when it ends (the hand must stop first) | probe motion 9 (K3's crack + the arm snapping back 0.4 m in 6 tics). Off: WRAP t143 -> YANK t152 (23%), WRAP t220 -> YANK t222. On: WRAP t139, "YANK held off" t146..t151 (pull 2.0-2.1), grace over t152, next yank t206 (the next lift); WRAP t915 held off t916..t921 |
| cracked rockets (`rsqwp_whip_fireball_knock`, 0 default) | 0 = ExplodeMissile at the crack (as before). 1 = Knock: velocity along the struck link's sweep, part toward you removed (>= 0.3 away), pitch clamped -15..+30, speed max(its speed, Speed), target = you (it no longer hits you, can hit its shooter), tracer cleared | probe `wpr_ballcls Rocket`, `wpr_ballat "220 0 40 10"`, motion 3. 0: 5 rockets exploded 64-81 from you. 1: knocked at speed 20, blew up 180-335 from the crack, 254-414 from you (3 of 3 logged) |

### Not done / open
- The knocked rocket climbs at the clamp's 30 deg on the rig's overhead crack (the link sweeps up after the crack)
  and burst on the ceiling at z 256 on MAP01 (other crack styles not measured). Feel not headset-confirmed.
- Not on a headset. Feel: full crack 50, lasso reach 0.30 m, flail speed cap 30, smash damage is Grapple's thrown-body formula.
- The teardown's "SteamVR only" for the latch is wrong for this engine: QZD's own Quest input sets it (VrInputDefault.cpp
  130-141, off grip within 0.50 m, `vr_two_handed_weapons` true by default), and the rig latched. The position route
  covers the setting off, and a hand more than 0.50 m away that closes on the thong.
- (Fixed by the owner's answers above: the lift moving the mark; the follow-through yank, as the Yank Grace option.)
- A fireball explosion near you (a rocket) still hurts you; the missile keeps its shooter.

History: built inside RSQ_Grapple first (commit cc32dbc), then split out on the owner's word (10-30: "Grapple should stay
intact"): RSQ_Grapple is back to exactly what it was before; this mod carries its own copy of the line.

## What it is
- Thong: 20 links, Verlet, 8 sub-steps x 6 constraint passes a tic (3 sub-steps at rest), room units (map z x 1.2), mass
  falling to ~1/30 at the popper. A 24 cm rigid handle. Constants searched in tools/whipsim.py on rig-recorded hand paths.
- CRACK = the tip's speed passing rsqwp_whip_crack (20 room units/tic) with the hand having driven it lately; at the speed's
  peak. Fast outer links sting; the crack and its 8-tic lash land rsqwp_whip_damage and the Pain stun.
- Snag only on EDGES (lintel/beam underside, ledge lip, 3D floor top): a fast link striking one, or a crack within 12 units
  of one. The anchor goes on the corner; the existence check traces the struck face (hook.struck).
- Lock: the whip hand's +altattack (swallowed in InputProcess while a whip is out) holds a lock from the other hand
  (512 units, 7 deg); the crack flies there in 5 tics; bind held on a monster = leash (the line bites; slide to you).
- Line (forked core): swing, reel, stick pump, arm pump, climb, tap to let go with keepmomentum, mantle over a lip.

## Measured (standalone RSQ_Whip.pk3)
| what | result |
|---|---|
| slow motions | sweep +-40 deg over 4 s: 0 cracks; slow lift: 0 |
| thrown motions | overhead (4 throws): 6 cracks, crack hit imp 60 -> 48 + Pain; side-arm: 10 cracks, 1 hit |
| snag + mantle | WHIPTEST block from 30 units: snag on the lip, MANTLE from z 34 onto 96 |
| lock + leash | imp at 300: LOCKED crack 283 units, hit 60 -> 48 + Pain, LEASH, pulled in (13 pull logs) |
| with RSQ_Grapple + BD order | both load; whip cracks and hits; Grapple's off-hand hook fires, bites, pulls; only BD_VoxelPack's 4 voxeldef script errors |
| cost | 0.13-0.16 ms/tic out and still, 0.23-0.26 lashing (sim 0.12, sweeps 0.03, draw 0.03), desktop, BD order |
| measured before the split (same code, in Grapple) | beam swing kept on the corner anchor; arm pump +0.27 u/tic a haul; Assist hit/air crack; switch thrown by Assist and by Lock; save/load twice replays the same cracks |

## Open
- Feel, headset: crack speed 20, handle 24 cm, length 3.8 m, lock cone 7 deg, arm pump 0.12, mantle.
- Snag reach: scripted throws are chaotic (the same throw caught the block's lip from 30 units, not from 50+).
- Quest cost (Debug Log = Cost).
- No Gun Bonsai / RSQ_Score / TopHPBars hooks (RSQ_Grapple's service and perks were not forked): add a service if wanted.
- Left-handed mirror and the SteamVR two-hand latch not run.
