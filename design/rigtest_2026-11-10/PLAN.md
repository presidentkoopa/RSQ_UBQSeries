# Batched rig test, 2026-11-10 (owner greenlit the batch 11-10 22:35: "Let's make sure RSQ UBSQ works")

Load order: doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4f (one throw; built for this test) > LOB > Champions > GunBonsai > the RSQ pk3s.
Every check ends in frames or a log of the behaviour itself. "Rig only, not headset-confirmed" for anything VR.

## Melee (frames with the hand models visible: the owner has seen none of these)
M1 punch -> tap trigger -> open hand, Ermac's hand and the FBX hand (frames of each pose)
M2 boxing gloves on (Boxing Gloves row), both hands, frames
M3 headlock: grab an imp with the off hand, hold, punch, throw (frames + log)
M4 open-palm swat of an imp fireball, and of a zombie bullet (log + frames)
M5 off-hand fist with a gun in the main hand: punch lands; uppercut a barrel (Uppercut Kicks Barrels on) then shoot it
M6 Ground Pound's rainbow pixel shockwave (frames over its 18 tics); Clear Out's Force Push ring (frames)
M7 Guard: gloves on = soaks; bare hands = no guard (log)
M8 Slappers Only: every weapon stashed incl. sabers/ShieldSaw; gloves only (log of the inventory)

## Grenade
G1 Quick Grenade on BD22's +user1 and on the Quick Grenade key: pin t7, toss t15, out t17, velocity vs BD22's own
   toss measured the same way (log both); SlowMo's Quick Grenade slow 8 tics out (log)
G2 Barrels: BD barrels replaced by default; a chain of 6+ barrels (incl. BD-placed ones) grows; the mega blast (P18)

## SlowMo
S1 Miniboss window broken early: the slow and the bar end with it (log)   S2 Fog Tint Strength row (menu frame)
S3 fog off part of P14   S4 Training Remote trigger: deflect 0.3 s, down 1.5 s (log)
S5 Be Quick or Be Dead: the plate's name with its four breathing letters (frames over 2 s), the menu header (menu frames);
   Photosensitive Mode: still (frames)

## Miniboss
B1 failed landing retries quietly (log: one slow/dark/music)   B2 life bars count inherited lives during the landing
B3 classic pick shows the HUD bars (frame)   B4 Legendary Thralls off: a Bossfight's thralls not legendary (log)
B5 Graves Rise, all four modes (log counts)   B6 the kill drops no life crate, no x3 bits (log)
B7 the rename: menus say Miniboss; SlowMo's landing line MINIBOSS INCOMING (frame); the called-in kill pays ONE Score
   row, Miniboss, at 3x (log)   B8 the stack: tier gem + Champion icons right of the miniboss's bar; the new shield (frames)

## VisualRewards
V1 miniboss music stops at a map change (log)   V2 music volume set only while fading (log)
V3 tier gem + Champion icon + mutation beside the HP bar: left, and right when markers are on the left; Champions' own
   icon hidden, and back with the option off (frames, ColorfulHell + Champions)

## Monsters / Score
R1 Monster Set saved as 2 reads as ColorfulHell; retier works (log)   R2 Score's menu without MG rows (frame)
R3 Tier Icons Above Monsters on: the gems float up (frames)   R4 Score's Champion rows carry their icons (frames)

## LaserSight (pistol, rifle, shotgun)
L1 beam stays on between shots (frames), hides during a reload and a switch (frames)
L2 Which Laser with M8F's Laser Sight built from mmaulwurff/laser-sight: each choice shows one laser (frames)
L3 greyed rows (menu frames)   L4 Glow Intensity 1 vs 3 (frames)   L5 Map Units readout on a steep shot (log)
L6 Beam Sparkle (Quest) on: sparks on the beam, faint (frames, several)

## Saber
A1 second saber lit on its first draw (frame)   A2 Force Pull refused with the Force off / not Force Sensitive (log)
A3 training remote: distance, +25 on a knock-down, the slow (log)
A4 the wrist panel (layout B): :30 counting, pips lighting per hit, round and streak; Score's digits hidden while it is
   out (frames); the clock running out ends the training (log)
A5 one throw: a synthetic swing at 2.0 / 3.0 m/s releases: no throw / throw (log), for the saber

## ShieldSaw
H1 a ricochet: rings stay on their targets (frames + log)   H2 a far zombie's bullet on the plate reads as a shot (log)
H3 one throw: 2.0 / 3.0 m/s releases: stow / throw (log)

## Distance Grab (from the 11-09 batch)
D1 heavy throw kg logged   D2 Palm Gate off counts only with Button on
D3 a full gun you carry: AMMO FULL over it, dropped at your feet (frames + log)

## BD22 VR 2.0.4f
X1 one throw: the axe and the grenade at 2.0 / 3.0 m/s: no throw / throw (log); a thrown axe flies as before

## Melee (new)
M9 the glove icons, main and off hand (Wheel or HUD frame)

## Tactical Rig
T1 rig clutter, all four (as 11-08) still in: rings only for what the hand can use, the nearest bright (frames)

## Today's builds, code only until shown (added 11-10 22:35)
N1 Gun Cards item card: saber LIT/OFF, flare count, flashlight battery on the watch (frames)
N2 Whip and Gun: the cursor drawn only when gold; no red dots (frames, gold then red aim)
N3 Graveyard: a riser that does not fit finds a nearby spot (log: RISES moved/try)
N4 Wheel: Opens On Main / Off opens the ring on that hand (frames or log)
N5 Monsters: Tier Icons Above Monsters is on the options page and turns the gems on (menu frame, frames)
N6 Rumble Backup route from another mod (Melee or ShieldSaw): RSQA_BACKUP log line
N7 Accessibility Seated Auto: a standing player is never called seated; a 0.5 m drop after standing is (log)

## The packed batch (one agent per group; the rig lock runs one game at a time)
Each group packs its checks into as few map loads as it can, uses a log line wherever a log proves the point, and saves
frames only for what an eye must judge (hands, HUD, words, menus). Results go to RESULTS_<group>.md, merged into
RESULTS.md at the end.
- **P1 Melee:** M1-M9, N6 (Melee's rumble route).
- **P2 Hands and throws:** Saber A1-A3, ShieldSaw H1-H3, BD22 VR X1, Distance Grab D1-D3, N1.
- **P3 Fights:** Miniboss B1-B6, SlowMo S1-S4, VisualRewards V1-V2, Monsters R1-R2, Grenade G2, N3.
- **P4 Looks and menus:** LaserSight L2-L5, Tactical Rig T1, N2, N4, N5, N7.

## After the batch: Graveyard README GIFs (owner 11-10 22:52, all four picked)
G-GIF1 stones return on reload (pop-in, candles light and breathe)   G-GIF2 a gold stone for a spent life beside a grey one
G-GIF3 Graves Rise: thralls climbing out of your stones in a miniboss fight   G-GIF4 the obituary on Use
Filmed on the rig once P1-P4 free it; short loops into Graveyard/docs/readme/, linked from Graveyard/README.md.
