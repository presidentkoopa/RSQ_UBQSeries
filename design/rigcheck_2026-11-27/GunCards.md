# Rig check: RSQ Gun Cards (2026-11-27, agent A)

Rig: `rig2` with `qz_aimroll 1` (hand roll reaches the engine), `qz_hz 35`, Freedoom 2 + `TestRig/maps/rig01.wad`.
G0, G1, G3 plain Doom (`RSQ_GunCards`, in G1 also `RSQ_TacticalRig` + `RSQ_Grenade`; G0 with `RSQ_PlayLog` to read the watch
reader's angles); G2 the Brutal Doom stack (brutal22test6 + VoxelPack + BD22 VR-Reloaded 3.0rc) + `RSQ_GunCards`.
`rsqgc_debug_log 1` (`rsqgc:` lines: card builds with what they show, kills, RELOAD/0 flips) and `rsqgc_cnd_log 1/2` (`RSQGC cnd`).
**The watch pose that the reader accepts** (found in G0): the hand 0.10 m to its side, 0.20 m under and 0.25 m in front of the eyes,
yaw 60 toward the body, **roll 180** (back of the wrist up): `RSQGC watch check: ... 0 -> 2, met; the back of the wrist face 12 of 88`.
Without roll it can never be met (face 127-168 degrees), so every watch row was NEEDS ROLL before rig2.
Logs and scripts: `design/rigcheck_2026-11-27/logs/A_G0..G3.log`, `A_G*_script.txt`. Frames: `frames/GunCards/`. Rig only, not headset.
The cards are small at the rig's 480 px: numbers on the small card could not be read in any frame (g1a.jpg crops), so colour and
"+N" rows rest on the log where the mod logs them. In the Brutal Doom run (G2) the dumped frames did not show the hand following the
posed watch pose, so no card was seen there: G2 verdicts are from the log only.

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | Gun in the main hand: small card beside the wrist (12) | WORKS | g1a.jpg t85 (yellow card right of the pistol hand) | Contents unreadable at 480 px |
| 2 | Off-hand gun from a pack with RSQGCOFF: mirrored card (13) | CAN'T TEST | A_G2.log:458 (`off-hand guns with a small card (their packs' RSQGCOFF): 66`), 476 (off hand holds `RSQ_Off_BrutalPistol`) | The card itself was not seen (G2 frames, see above) |
| 3 | Magazine count green / yellow / red (14) | CAN'T TEST | | Not logged by the mod; G2 frames show no card |
| 4 | Empty magazine with reserve: RELOAD, then red 0, every 52 tics (15) | WORKS | A_G2.log:250, 281, 312 (`RELOAD at tic 126`, `0 at tic 178`, `RELOAD at tic 230`) | |
| 5 | Ammo pickup: "+N" for 52 tics (16) | CAN'T TEST | g1a.jpg t105 (card shown; digits unreadable) | Not logged; not readable |
| 6 | Watch check with either hand: watch card fades in, small card goes; stays 70 tics after (17) | WORKS | A_G1.log:210, 213 (main hand met, card built), 555 (off hand met); g1a.jpg t140 (watch card "AMMO 85 / GREN... / KILLS") | Was NEEDS ROLL; real verdict on rig2. Small card going and the 70-tic linger not measured |
| 7 | Watch check with a gun: Weapon card (MAG/AMMO, RESERVE, GRENADES, KILLS) (18) | WORKS | A_G1.log:213; g1a.jpg t140 | |
| 8 | Watch check with an empty main hand / fists: Status card (19) | PARTLY | A_G1.log:517 (watch met with the Fist); g1a.jpg t360 (a card at the frame's edge, "CND"-like top line, not readable) | The card is cut off by the frame edge; H / A / keys not read |
| 9 | Watch check with an empty off hand: Status card drawn in the world at the wrist (20) | WORKS | A_G1.log:555; g1a.jpg t395 (status card in the world: "100", keycard rows) | |
| 10 | Watch check with the saber / flare / flashlight / cigarettes: the item card (21) | WORKS (cigarettes) | A_G1.log:724, 742 (`built: RSQTR_ZippoWeapon` off hand, `built: RSQTR_CigWeapon` main hand: the item path) | Only the cigarette and Zippo were tried; the card was not framed |
| 11 | Off-hand watch while steadying the gun: does not count (22) | CAN'T TEST | A_G1.log:649 (the reader says met; the two-hand rule is applied later in the card code, not logged) | The frame fell inside the 70-tic linger of the previous check: inconclusive |
| 12 | Kill within 35 tics of a hand's shot: +1 KILLS for that gun (23) | WORKS | A_G1.log:1518 (`kill DoomImp -> main hand Pistol (1 this level)`); A_G2.log:523 (Rifle) | |
| 13 | Cooking RSQ Grenade: fuse seconds on the small card (24) | CAN'T TEST | | Not run in this pass |
| 14 | Show Cards: On Look (25) | CAN'T TEST | | Ran (G1 row13), frames deleted before being looked at: no verdict |
| 15 | Show Cards: Inspect (26) | CAN'T TEST | | Not run |
| 16 | Show Cards: On Reload (27) | CAN'T TEST | | Not run |
| 17 | Show Cards: Off (28) | CAN'T TEST | | Ran (G1), frame not looked at: no verdict |
| 18 | Watch Card: Always (29) | CAN'T TEST | A_G1.log:1224-1226 | The pose used also met the check, so Always was not separated from On Check |
| 19 | Watch Card: Off (30) | CAN'T TEST | A_G1.log:832-867 | Frames not looked at; the log does not separate the small card from the watch card |
| 20 | Watch Shows: Status (31) | WORKS | g1a.jpg t712 (the card at the wrist starts "H 10..", the Status card, with the Pistol in hand) | |
| 21 | Watch Shows: Both (32) | WORKS | A_G1.log:1096 (`built: Pistol ... shows 2`) | Contents not read |
| 22 | Gun Bonsai on Card (33) | CAN'T TEST | | Gun Bonsai not in the stack |
| 23 | Both Guns One Card (34) | CAN'T TEST | | Not run |
| 24 | Hide at Eye (35) | CAN'T TEST | | Not run |
| 25 | Tilt to Eyes (36) | CAN'T TEST | | Not run |
| 26 | Draw in World (37) | CAN'T TEST | | Not run |
| 27 | Weapon Condition: a blow over 20 wears guns in hand by 3 (38) | WORKS | A_G3.log:131 (`big hit 30 (over 20) ... main Shotgun 75 -> 72`) | |
| 28 | Worn gun's damage scaled by band (39) | WORKS | A_G2.log:514 (`cnd 75 ... band 70: x0.90 20 -> 18`); A_G3.log:167 (cnd 50: `dmg x0.90`) | |
| 29 | Fire rate follows condition (40) | WORKS | A_G3.log:167 (cnd 50: `rate x0.67`) | |
| 30 | Under 60: BACKFIRE; under 30 MISFIRE; never kills; toast (41) | WORKS | A_G2.log:559 (`BACKFIRE! ... cnd 50`), 599 (`MISFIRE! ... cnd 20`), both "toast shown" | Under god mode the damage dealt was 0; forced with the mod's own test cvar `rsqgc_cnd_force` |
| 31 | CND line on the watch card (42) | PARTLY | A_G2.log:638 (with condition on the Rifle's watch card has 50 pieces against 40 before, A_G2.log:417) | The CND bar itself was not seen |
| 32 | Steel bits (VisualRewards) restore condition (43) | CAN'T TEST | | VisualRewards not loaded |
| 33 | REPAIR at RSQ Miniboss's kiosk (44) | CAN'T TEST | | Miniboss not loaded |
| 34 | Lose Gun at 0: gun breaks and is taken (45) | WORKS | A_G3.log:255, 289 (`Shotgun broke at 0 and was taken`, then ready Pistol) | |
| 35-37 | Spot Up / Side / In, Edit Spot For, Reset (46-48) | CAN'T TEST | | Menu rows; not reached in this pass |
| 38 | Hide HUD Health / Ammo rows (49) | CAN'T TEST | | Menu rows; not reached |
| 39 | Hand Numbers (50) | CAN'T TEST | A_G1.log:1283-1298 | Ran; frame not looked at |
| 40 | `netevent rsqgc_cnd_set / _hit` with sv_cheats 1 (51) | WORKS | A_G1.log:1414 (`rsqgc_cnd_set needs sv_cheats 1` without it); A_G3.log:125, 131 (with it) | |
| 41 | Watch check with a no-ammo weapon: Weapon card with its name (52) | CAN'T TEST | | Not run |
| 42 | Melee kill credits a no-ammo weapon (53) | CAN'T TEST | | Not run |
| 43 | BD22 VR Silvergun: RESERVE = pistol pile / 3 (54) | WORKS | A_G2.log:390 (`BrutalRevolver loaded 6 reserve 33 (Ammo1 Clip1 100 ...)`) | |
| 44 | Brutal Doom Purist / NoReloading: AMMO, no reserve (55) | CAN'T TEST | | Not run |
| 45 | LAUNCHER line on BD22 VR's Rifle (56) | CAN'T TEST | A_G2.log:417 | Card built; the line not read |
