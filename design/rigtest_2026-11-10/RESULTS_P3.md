# Rig group P3 (Fights), 2026-11-10 night: results (rig only, not headset-confirmed)

Linux QuestZDoom 17.3 rig, the owner's order (doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4f > LOB > Champions >
GunBonsai > every RSQ pk3) + rig02.wad (TestRig/bossfight_rig) + the P3 probe (evidence/P3_probe: a copy of the r10 probe plus
p3.zs: readouts, a scripted miniboss fight, the B1 blocker, the menu scroller). Four launches, 13 map loads in all:

- **P3A** (the miniboss fight and everything around it; Miniboss as at HEAD 11ba1a90): fight 1, three more landings for
  the Graves Rise modes, the map change with the music on, the classic pick, the fog, both menus (row dumps), barrels, remote.
- **P3B** (720 px: menu frames, the remote's deflects, landings with the first fix).
- **P3C** (960 px, `i_timescale` 0.15 / 0.25 for frames: the landing's life bars, the classic stack, the barrel chain; five
  landings with the final fix).
- **P3D** (B4 only: the owner's order + LegenDoom 3.0, the owner's upload; LegenDoom is not in the owner's order).

Every launch: zero script errors from our packs (BD_VoxelPack's 4 voxeldef errors only).

| Check | Result | Evidence |
|---|---|---|
| B1 failed landing retries quietly | SHOWN. A TechPillar put on the miniboss's spot as the landing began (probe): `miniboss 0 blocked by TechPillar ... did not fit`, `failed to land: tries again` t89; the retry failed once more on its own (t136, a thrall on the spot: see the bug below) and landed on the third try (bound t232). Across the three tries: ONE `RSQ_SlowMo: trigger bossfight` (t43), ONE `scene track rsqvr/music/boss1 started` (t43, faded in once, t43-t112), ONE `[RSQGD] drop darkness` (t43, over t196). The retries sent none of them again | P3A_log.txt (P3A_FIGHT1_CALLIN to t232) |
| B2 life bars count inherited lives during the landing | SHOWN. Probe gave each landing thrall a DarkRed token. The HUD's own count (`StackParts`, logged from the probe's RenderOverlay): `life bars 3 (arrPhase 1)` while landing = 3 lives + 1 inherited - 1; bound `lives 4`. Without a DarkRed the same landing shows `life bars 2` (P3C landings 2, 4, 5). Frame: during the landing the stack draws 3 life bars under the miniboss bar, before it there are none | P3C_log.txt, P3A_log.txt, P3_B2_landing_life_bars.jpg |
| B3 classic pick shows the HUD bars | SHOWN. `rsqmb_classic 1`: the map's classic miniboss bound at load (RS_CommonBaron, 3 thralls, not called); `HUDSTACK shown 1 segs 3 life bars 2 (arrPhase 0)`; frame: thrall row, skull + bar + tier gem, 2 life bars under Score | P3C_log.txt (P3C_B3_CLASSIC), P3_B3_classic_stack.jpg |
| B4 Legendary Thralls off | SHOWN with LegenDoom 3.0 added (not the owner's order). On: every thrall and the miniboss carry `LDLegendaryMonsterToken` ("powers [..., Legendary]", LegenDoom's own health). Off (`rsqmb_legend_thralls 0`): no LD item on any thrall, each at 1.5x spawn health (the plain boost: 30/20, 45/30), the miniboss not legendary either | P3D_log.txt, P3D_script.txt |
| B5 Graves Rise, all four modes | SHOWN (5 stones placed by the probe; radius 400). One Per Stone (map): `wakes 5 tombstones (the whole map): 5 undead (1 a stone)`; One Per Stone (radius): `1 tombstone (within 400): 1 undead`; Thralls Per Stone (map): `5 tombstones: 15 undead (3 a stone)`; Thralls Per Stone (radius): `1 tombstone (within 400): 3 undead (3 a stone)`. Each followed by its RISES lines | P3A_log.txt (P3A_STONES_MODE0, MODE1, MODE2, MODE3) |
| B6 the kill drops no life crate, no x3 bits | SHOWN. Miniboss death t920: `bossfight drop: gun BrutalPistol`, `award "Miniboss Called"`; Kill Rewards `RS_BlueImp (83 hp, miniboss as boss) burst into 25 bits of 25 rolled` = 83 x 3 (Boss Fountain) / 10, no further x3; the probe's spawn watch logged no `RSQ_ScoreLifeCrate` in the whole run | P3A_log.txt |
| S1 window broken early ends the slow and the bar | SHOWN. Thrall killed t253, window open, `trigger miniboss t255 ... pulse until t359`; hit 8 tics in, `segment 0 BROKEN in the window` t261; SlowMo's pulse gone t262 (97 tics early), `countdown bar: gone` t272 | P3A_log.txt (P3 SLOW lines t255-t272) |
| S2 Fog Tint Strength row | SHOWN. SlowMo menu row 89 `Fog Tint Strength` (row dump), frame: the slider at 0.60 | P3A_log.txt (P3 MENU RSQSM_Options), P3_S2_fog_tint_strength_row.jpg |
| S3 the fog off part of P14 | SHOWN. `ddz_fog 64`: GITD on, 2 of 2 sectors fog 64; `rsqgd_enabled 0`: 0 sectors with fog, player's sector 0; on again: 64 | P3A_log.txt (P3 FOG lines) |
| S4 Training Remote trigger | SHOWN. Three bolts sent back (probe, the bolt lives until it reaches the remote): each `trigger saber.remote ... started 300 ms at 35%`, pulse 11 tics; the fourth hit downed it: `started 1500 ms`, pulse 53 tics | P3B_log.txt (P3B_S4_REMOTE) |
| V1 miniboss music stops at a map change | SHOWN. Landed fight, the track in and playing (channel 32765 playing 1 from t43); `map MAP01` at t262: on the new map `WORLDLOADED ... channel 32765 playing 0`, tracks 0, music volume 1.0, and no track again until the next call-in | P3A_log.txt (P3A_V1_MAPCHANGE_WITH_MUSIC) |
| V2 music volume set only while fading | SHOWN. The probe logged every change of VisualRewards' last-set volume: fight 1 changed it on t43-t112 (fade in) and t921-t991 (fade out) only; untouched in the 800-odd tics between | P3A_log.txt (P3 MUSIC lines) |
| R1 Monster Set saved as 2 reads as ColorfulHell; retier | SHOWN. `rsq_monster_set 2` + map load: every monster an RS_ ColorfulHell class with a tier (R10 MON tag 1); the fight's tier-ups swapped bodies (`tier swap followed: RS_GreenImp (the miniboss)`, then `RS_BlueImp`) | P3A_log.txt |
| R2 Score's menu without MG rows | SHOWN. Row dump of RSQSC_Options (50 rows): roster rows Tiers and The Roster only, no MeatGrinder section, no Gang War / Mixed Bag; frames of the roster rows and the menu end | P3A_log.txt (P3 MENU RSQSC_Options), P3_R2_score_menu_no_MG_rows.jpg |
| G2 barrels | SHOWN. Replaced by default: `ExplosiveBarrel -> RSQGN_Barrel` and BD's `ExplosiveBarrel1 -> RSQGN_Barrel` (rsqgn_barrel_replace_bd 1). A chain of 9 (alternating the two classes): links 1-5, blast radius 128, 128, 160, 192, 224, blink 10, 8, 6, 6, 4, scale 1.0, 1.25, 1.0, 1.2, 1.4; the finale flipbook at link 3 (mega) and link 5 (mushroom; RSQGN_Flip spawned); SlowMo's Chain Reaction slow. Frames: the line of barrels, the chain, the big blasts | P3C_log.txt, P3B_log.txt, P3_G2_chain_mega_blast.jpg |
| N3 Graveyard's riser search | SHOWN. A TechPillar on stone 0 (-200 150): `SkullZombieSpawn RISES at -210 189 from a tombstone ..., 40 map units from its planned spot`; Thralls Per Stone also logged a riser 40 units out. "Given up after 5 tries" not run | P3A_log.txt |

## Bug found and fixed (Miniboss, bossfight.zs Land, the move-aside)
A Bossfight's FIRST landing failed and re-landed in most fights on rig02, with no blocker: the thralls land first and one stands on the
miniboss's spot; "moved aside" pushed it (radius + radius + 8) along the line between them, but actors collide as axis-aligned
squares, so on a diagonal it still overlapped the miniboss, and straight out was often another thrall. P3A: the mode 1 and
mode 2 landings failed their first try (`miniboss 0 blocked by RS_CommonSG ... did not fit`) and fight 1's retry failed after
the pillar was gone; only mode 3 landed first time. A retry may bring a different miniboss class.
The player sees the thralls land, vanish and land again.
Fix (Miniboss/zscript/rsqmb/bossfight.zs, Land, ~line 945): push to clear the box (divide by the larger of |cos|, |sin|) and
try the eight directions round the miniboss, nearest the thrall's own first; a debug line when none fits. P3B (box only): 4 of
8 tries still failed (`could not be moved aside (RS_CommonZombie)`). P3C and P3D with the eight directions: 7 of 7 landings
first try, 4 with `moved aside`. RSQ_Miniboss.pk3 rebuilt with tools/build_all.py (pk3 not committed).

## Not shown / notes
- B4 needs LegenDoom, not in the owner's order: shown with LegenDoom 3.0 added. LegenDoom_BD22VR_Patch.pk3 next to it does
  not load (`RSLDP_Service already exists`): the LegenDoom 3.0 upload already holds the patch (its RSLD line prints).
- The rig ignored the probe's player angle (the VR view follows the HMD); G2's first runs faced away; P3C turned the HMD.
- `i_timescale` slows the rig's game clock (frames per tic up), not the game logic: used only for frames.
- P3A's B6/scan lines tagged 1, 3, 4 ran on the next map (a netevent just before `map` is processed after the load).
