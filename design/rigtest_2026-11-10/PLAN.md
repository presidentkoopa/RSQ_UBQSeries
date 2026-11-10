# Batched rig test, 2026-11-10 (proposed; owner to OK before it runs)

Load order: doom2 > brutal22test6 > BD_VoxelPack > BD22 VR 2.0.4e > LOB > Champions > GunBonsai > the RSQ pk3s.
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

## Miniboss
B1 failed landing retries quietly (log: one slow/dark/music)   B2 life bars count inherited lives during the landing
B3 classic pick shows the HUD bars (frame)   B4 Legendary Thralls off: a Bossfight's thralls not legendary (log)
B5 Graves Rise, all four modes (log counts)   B6 the kill drops no life crate, no x3 bits (log)

## VisualRewards
V1 Bossfight music stops at a map change (log)   V2 music volume set only while fading (log)

## Monsters / Score
R1 Monster Set saved as 2 reads as ColorfulHell; retier works (log)   R2 Score's menu without MG rows (frame)

## LaserSight (pistol, rifle, shotgun)
L1 beam stays on between shots (frames), hides during a reload and a switch (frames)
L2 Which Laser with M8F's Laser Sight built from mmaulwurff/laser-sight: each choice shows one laser (frames)
L3 greyed rows (menu frames)   L4 Glow Intensity 1 vs 3 (frames)   L5 Map Units readout on a steep shot (log)

## Saber
A1 second saber lit on its first draw (frame)   A2 Force Pull refused with the Force off / not Force Sensitive (log)
A3 training remote: distance, +25 on a knock-down, the slow (log)

## ShieldSaw
H1 a ricochet: rings stay on their targets (frames + log)   H2 a far zombie's bullet on the plate reads as a shot (log)

## Distance Grab (from the 11-09 batch)
D1 heavy throw kg logged   D2 Palm Gate off counts only with Button on
