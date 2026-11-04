# RSQ Glow In The Dark: what was shown on the rig (2026-11-03)

Rig only (QuestZDoom 17.3 rig, simulated headset, software GL), **not headset-confirmed**. doom2.wad unless said.
Scripts: `tools/rigtest/` (batch_port.sh, batch_final.sh, errcheck.sh, grids.sh; test-only, never shipped).
Console test triggers (in the mod, for the rig and for trying reactions alone): `netevent rsqgd_test_mb 1|0`,
`rsqgd_test_wave`, `rsqgd_test_combo N`, `rsqgd_test_slowmo P`, `rsqgd_test_flare`, `rsqgd_test_reroll`.

## Frames (docs/frames)
| file | shows |
|---|---|
| port_m02/m09/m11w/m22/m25.png | the port next to the old 1.1 pk3 (random and fixed grey): same wall glow; with "own colour" on, nukage/lava/water/blood/slime glow their own colour where 1.1 painted the room colour over them; "own colour off" = 1.1 exactly |
| v2_default_vs_old.png | v2's default (Classic 1.1) next to the old pk3 |
| v2_miniboss_ddz.png | miniboss tint + darkening; DarkDoomZ alone, + glow, + miniboss (ddz_postgain 0 -> -48, restored after); the REAL RSQ Miniboss (`netevent rsqmb_choose`) tinting MAP02 |
| v2_wave_combo_slowmo.png | level-up wave at 18/28 tics (and from the REAL Gun Bonsai: `netevent bonsai-debug,w-xp 600000` -> "ready to level up" -> wave), combo chain 10, slow motion drain (test trigger and the REAL RSQ SlowMo `netevent rsqsm_start:test 4000 25 0`) |
| v2_liquids.png | lava still / living / splash flare; PCVR lights Normal vs Subdued vs Quest (none) |
| v2_locked_doors.png | MAP04 red locked door: things off / on / key held (`give all`) |
| v2_rerolls.png | Every Map: two loads, two colourings (seeds 125668571 / 1577653); On Each Death: killed, map restarted, new seed (71190178 -> 104295347) |
| v2_profiles_roomB.png, v2_profiles_nukage.png | 12 + 3 profiles in the same rooms (fixed seed) |

## Logs (rsqgd_debug 2)
- RSQ Miniboss real: `mb 0.85`, light 112 -> 64 (no DarkDoomZ: per-sector offset, given back exactly).
- RSQ SlowMo real: `sm 0.24` while slowed. Gun Bonsai real: `wave 1` on "Your Pistol is ready to level up!".
- RSQ Score: `kill monsters` kills are not credited to the player by Score, so the chain was shown with the test trigger only.
- DarkDoomZ found by name (`darkdoomz 1`); its post-gain lowered by 48 during the tint and put back.
- Lights: Quest preset 0 live; PCVR preset 10 live (4 over pools + 6 on items), Normal and Subdued.

## Cost (MSTimeF around the whole WorldTick, x86 rig; Quest's interpreter will be slower)
freedoom2 MAP12, 863 sectors, 8 samples each:
- still look (Classic): avg 0.08 ms/tic, max 0.19 ms.
- animated profile (Aurora) + miniboss tint + combo, Quest budget 128: avg 0.46 ms, max 0.62 ms (~200 plane writes/tic).
- same, PCVR budget 512: avg 1.0 ms, max 1.4 ms. One-off peaks (map start, the darkening pass): 1.2-3.6 ms.
- doom2 MAP02/MAP11 (97/143 sectors) animated: 0.1-0.3 ms.

## Script errors
0 from this mod in: doom2 + it alone; + DarkDoomZ; doom2 + the full BD order (01-07, 03 = 2.0.3q) + Gun Bonsai +
every RSQ pk3 + it; the same + DarkDoomZ. The only errors in the full order are BD_VoxelPack's own (4 voxeldef
lines + 1 sphere.txt "DeathSphere not found"). (At 20:5x the working tree's pk3/RSQ_Grenade.pk3 did not compile:
another lane's work in progress; the run was repeated with the committed one.)

## Not shown
Headset, real Score chain, item pickup glow up close, hazards/secret/teleporter glows (code paths ran, no frame),
the menu pages (compiled; not opened on the rig).
