# Round 2 fixes, re-checked with the owner's own load order (2026-11-27 17:00-17:30)

The owner's rotation folder (D:\SteamLibrary\steamapps\Common\DooM VR\__CurrentRotationDONOTDELETE), copied read-only:
every file but the 12 RSQ_BDXMTiers pk3s (not read) and, for the scripted runs, the TUD map wad (the scripts' places are
Doom II MAP01's / the probe room's). RSQ pk3s: the rebuilt ones from main. One engine launch per run; logs in
rigcheck_round2/logs (not in the repo).

| Item | Run | Result |
|---|---|---|
| ShieldSaw lock-on, the owner's own 13:22 pk3 | LOCKON_OWNER | main fire (old design) rings 5 imps: the code ran; the owner's complaint was the design |
| ShieldSaw: off hand's trigger locks on | LOCKON_OFF3 | main fire 0 rings; off fire 3 rings, kept after release; throw "locks 3" |
| ShieldSaw: a late pose cleared every ring | LOCKON_OFF2 | "4 rings cleared ... fresh 0" mid-sweep; fixed (a late tic paints nothing) |
| Load check, all rebuilt pk3s | LOADCHK | MAP01; no script error but the voxel pack's own 4 voxeldef lines |
| Graveyard: stones kept on load | ALL1 | after save/load: "1 stone in the store, 1 kept standing, 0 removed" |
| Void Orb | ALL1 | RS_BlackMind2 killed: 1 RS_CH_VoidOrb |
| Tactical Rig grenade light | ALL1 | hand near: 3 green (frame 0), 1 yellow (frame 1), 0 red (frame 2, shown) |
| Score: BD22's Chain_saw (the owner's chainsaw) | ALL2 | ~50 cuts on a 450-health Hell Knight, no crit line; kill paid Rip and Tear 0.500 |
| SlowMo lean | ALL2 | 12 cm lean: "leaned out of a NMH_HitscanReplacer (lean 4.0, passed 4.1 off centre)" |
| Grenade Stun (Gun Bonsai VR's stagger in this load order) | ALL3 | imp held in pain at one spot ~100 tics, then walks |
| Grenade Smoke | ALL3 | imps lose their target the tic it starts and stay blind |
| Score Pop! | POP2 | melee kill of a balloon champion: Pop! 0.300 |
| Gun Cards Tilt to Eyes | - | NOT fixed (off by default) |
