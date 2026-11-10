# Handoff: session of 2026-11-09, evening (stood down 19:27)

Load order for every check: doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4e > LOB > Champions > GunBonsai > all
RSQ pk3s. The owner must REMOVE his separate DarkDoomZ pk3 (it is built into Glow In The Dark; both loaded is fatal).
All pk3s in `pk3/` match `~/Desktop/PK3TEST` as of 19:30.

## Done, shown on the rig (rig only, not headset-confirmed)
Evidence: `design/rigtest_2026-11-09/` (A-J) and `design/rigtest_2026-11-09/followup/` (K-O).
- Grenade throw: trigger only, alt fire only, cook then throw; also with Replace BD's Grenade on.
- PCVR laser stays on between shots (pistol, shotgun pump).
- Reload slow-mo modes, including the 10 s cap.
- Dual press with an empty main hand gives the main-hand weapon.
- Ammo pouch: bigger, moved, reach assist slides up to 3.5 cm toward the hand.
- Two-handing and grenade throws never count toward "Grip inside the ring".
- Own-home items (grenade, flashlight, ...) refused by the holsters.
- DOWN: grey eases in, slow fall, DarkDoom Black on and the player's own mode back, targets' small rooms stay in
  colour, everything restored after revive and after save / load. Under DarkDoom Black the darkness now reads deep red
  (sector fade colour), tint 1.0 stronger than 0.6, nothing changes with DarkDoomZ off.
- DarkDoomZ in GITD: darker map, settings under GITD, live relight.
- One flashlight (FnF): Beam Look FnF = 1 light, DarkDoomZ = 2 with spill, 1 without; DDZ's own flashlight gone.
- Arrival beams: each starts its own sound (rsqvr/beam/v1..v4) on its first tic; nothing on the reveal.

## Done, code only (not run)
- Trail chevrons in colour while grey: the frame is now a particle behind the colour particles (plate.zs). The
  previous try (particles nudged toward the eye) FAILED on the rig: translucent particles write no depth.
- Entrance Size slider (1-3x): the limit is now 94% of the eye's width (it was 94% of the HUD canvas, so in VR every
  size came out the same and smaller than the panel at rest).
- Fog Colour row (default Blood Red; Ember, Toxic Green, Deep Blue, Violet, Bone White, Random, Complementary to GITD):
  colours both the tint and the darkness.
- "Grip inside the ring" never while DOWN, nor for 1 s after (TacticalRig asks RSQSM_Service "down" by name).

## Not done / open
- DOWN's own sounds: never seen in a log; the owner is wiring DOWN's sounds himself now (19:27). Don't touch them.
- DOWN's open items from the owner's notes: a new name for DOWN; the hard cut on revive, the instant world freeze,
  too much in the first second, the hard 75-degree arrow / trail flip; full-bright flat targets in big rooms.
- Miniboss rework: designed (design/MINIBOSS_REWORK.md), not built beyond the arrival and Miniboss From / Thralls
  From. ONPARE6 (rsqvr/beam/hit) is reserved for the thrall segment break, and only that.
- Boss bar; retier contexts outside the Bossfight.
- The Big Four: Score pruning (names too), GBOVR pruning, Monster Assembly, the arcade (design/HANDOFF_ARCADE_2026-11-09.md).
- Arrival beam art: V3 / V4 use frames cut from the Z-Fighter effects sheet (a rip): credit or redraw before release.
