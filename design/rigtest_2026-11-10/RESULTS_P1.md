# Rig 2026-11-10, group P1 (Melee): M1-M9, N6

Rig only, not headset-confirmed. Linux QuestZDoom 17.3 rig, the owner's order **without RSQ_GunBonsaiVR** (`run_nogbvr.sh`:
with Gun Bonsai VR the moves are upgrades that must be learned first; without it each Melee row plays its move at level 1),
plus a P1 copy of the r10 probe (`evidence/P1_generators/p1probe_zscript.txt`). Eight launches, A to H (scripts, logs and
generators in `evidence/P1_*`). Every launch: zero script errors from our packs (BD_VoxelPack's 4 voxeldef errors only).
Melee's hands came up from **Start With Melee Hands** (`rsqml_gloves 1`, then `map MAP01`). `rsqml_debug 1` throughout.

| Check | Result | What was shown | Evidence |
|---|---|---|---|
| M1 punch, tap, hand models | SHOWN | Frames: Ermac's hand fist and open, the FBX hand open and fist, both hands. The trigger tap (`+attack` / `+oh_attack`, 3 tics) logged `hand R: open palm`, `hand L: open palm`, then `hand R: fist`, `hand L: fist`. Punches on a held imp (launch B): `punch lands: jab, 5.30 m/s` (16 damage), `hook, 3.47 m/s` (12), off-hand `uppercut, 3.55 m/s` (13): `launched up 7.8, back 3.7`, the imp's z 56 -> 88 and back down. Frames at 160 px: the fist in the imp, the uppercut's stars, the blood burst. Hand Model Auto picked the FBX hand (BD22 VR is loaded) | P1_M1_hand_models_fist_open.jpg, P1_M1_punches_160px.jpg, P1_C_log.txt, P1_B_log.txt |
| M2 boxing gloves | SHOWN, owner to judge the look | Boxing Gloves on: both hands are the glove. A trigger tap in gloves logs nothing (gloves stay fists, as designed). **The glove draws in three flat colours (green, white, dark grey; its texture `models/rsqml/glove.png` is a 100x100 three-colour image) and much bigger than the hands in view** | P1_M2_M7_boxing_gloves_guard.jpg |
| M3 Headlock | SHOWN | The grip sent as its own event (`netevent rsqml_hgrip 1`; the real grip key cannot be pressed on the rig). `headlock: holding RS_CommonImp`, the imp moved to the hand and frozen (freeze 1, 38 units off). Three main-hand jabs on it: `punch 1/2/3 on RS_CommonImp, extra blood` (13, 20, 13 damage). The throw (launch D, a free imp): `[RSQDG] Headlock (RSQ Melee): threw RS_CommonImp at 6.6 m/s (counted as 30 kg of its 100; hand 5.3 m/s)`; it flew 130 units ahead and dropped to the lower floor. Frames: the imp held at the off hand (480 px), held and punched (160 px). Not shown: the Distance Grab impact (nothing stood in its path) | P1_M3_headlock_hold.jpg, P1_M3_headlock_held_punched_160px.jpg, P1_B_log.txt, P1_D_log.txt |
| M4 open-palm swat | SHOWN (fireball in frames; bullet in the log only) | Main hand opened, swept side to side at 1.75 m/s on the fireball's line; an imp's fireball (launched by the probe at t603 from 200 units): `swat: RS_DoomImpBall2 knocked aside (76 degrees off its way), palm 1.8 m/s`; frames show it coming, then knocked to the left with the swat spark. A zombieman's bullet (fired by the probe, twice): `bullet swat: RS_CommonZombie's 3-damage shot knocked away (hand 3.3 m/s, 10.9 from its path, reach 13.1)`, player hp 100 -> 100 both times. No spark was caught in the bullet frames | P1_M4_swat_fireball_160px.jpg, P1_B_log.txt |
| M5 off-hand fist beside a gun; barrel kick, then shot | SHOWN | Shotgun in the main hand, Melee's off glove stays in the off hand (`ready Shot_Gun off RSQ_GloveOff`): off-hand jab `punch lands: jab, 6.97 m/s`, 19 damage. Uppercut Kicks Barrels on: `uppercut kicks RSQGN_Barrel: where you punched, up 9.0, forward 9.0, no damage (health 20)`, its flight logged tic by tic (target BDoomer), frames of it flying up and away. Then the shotgun at it where it landed (rig02, launch F): `RSQGN_Barrel took 13 (Shotgun) from BDoomer`, `DIED t414 RSQGN_Barrel by BDoomer`. (RSQ Grenade's barrel stands in for ExplosiveBarrel) | P1_M5_barrel_kick.jpg, P1_B_log.txt, P1_E_log.txt, P1_F_log.txt |
| M6 Ground Pound, Clear Out | SHOWN | By gesture (both hands swung down 3.5 m/s; both palms thrust 3.5 m/s, read by RSQ Accessibility's reader): `ground pound: level 1 at 3.71 m/s, 85 units round, 30 each, 3 hit`; `clear out: level 1 at 3.60 m/s, 85 units, 15 each, 2 shoved`. Frames (the move sent as its own event `rsqg_pair`, 480 px): the rainbow pixel ring rolling out along the floor (t671-688), Clear Out's burst and two Force Push rings rolling out in front (t739-752). The shove moved a free imp 158 units in 12 tics (rig02, launch F: -250 -> -92); the side imps of a pound were thrown outward 2.9 a tic | P1_M6_pound_clearout_rings.jpg, P1_C_log.txt, P1_B_log.txt, P1_D_log.txt, P1_F_log.txt |
| M7 Guard | SHOWN | Gloves on, both fists at the face, a 20 blow from in front: `guard: UP`, `soaked 20 -> 12`, the guard flash; a 40 blow: `BROKEN by 40`, full 40 taken; up again 17 tics later and `soaked 20 -> 12`. Bare hands (Boxing Gloves off), same pose: no guard, 20 taken. Gloves on, hands down at the chest: no guard, 20 taken | P1_C_log.txt, P1_M2_M7_boxing_gloves_guard.jpg |
| M8 Slappers Only | SHOWN, with a BUG (below) | Before: Shotgun, Pistol, Rifle, both sabers, the ShieldSaw, the whip, grenades. On: `RSQ_SlapperStash RSQ_GloveOff RSQ_Glove rsq_hands Melee_Attacks`, gloves in both hands. A Shotgun given later: gone within 12 tics. **The saber comes back**: RSQ Saber's Start With Saber gives it again every 5 tics and Slappers Only strips it every 8, so it flickers in and out of the inventory (launch B, the inventory read 16 times in 16 tics). Off: every gun back, but the saber was in the main hand, not the Shotgun that was there | P1_A_log.txt, P1_B_log.txt (P1 INV tags 100-115) |
| M9 glove icons | NOT SHOWN | In the Wheel (1080 px), the gloves held: the centre card reads MELEE HANDS with no picture (the centre card draws no picture for any weapon). With a gun held, no glove card was found on either ring (the gloves are probably folded into slot 1's fan; not opened). From the code: the Wheel draws its own WRIGLOVE for RSQ_Glove and RSQ_GloveOff before any item icon (Wheel zscript.zs:5206), so Melee's new RMICA0 / RMICB0 are not what the Wheel shows. No HUD in the set draws an item's Icon | P1_M9_wheel_glove_cards_1080.jpg |
| N6 Rumble Backup from Melee | SHOWN | `rsqa_debug 1`, Rumble Backup on, Quake Haptics 0: `RSQA_BACKUP t420 RSQML right controller (main hand)` and the left on the Guard's soak; on every landed punch (`RSQA_BACKUP t90 RSQML right ...`, `t220 RSQML left ...`), the swat, the pound and Clear Out | P1_C_log.txt, P1_B_log.txt |

## Bugs found (not fixed)

1. **Slappers Only and RSQ Saber's Start With Saber fight over the saber.** With Slappers Only on, Melee strips it every 8
   tics (`Melee/zscript/rsqml/slappers.zs:120`) and the Saber gives it back every 5 (`QuestSaber/zscript.txt:6975`, `:7015`,
   `ubqs_start` on by default), with its second saber. The saber is in the inventory most of the time, and turning Slappers
   Only off put the saber in the main hand instead of the gun that was there. A one-line stand-down in the Saber (no start
   give while `rsqml_slappers` is on, read by name) would end it; not applied: it is the Saber's code, under test by P2 tonight.
2. **The Wheel does not show Melee's glove icons.** Melee's README says "The hands' item icon (the Wheel shows it)" with
   RMICA0; the Wheel draws its own WRIGLOVE (a different red glove) for both gloves. The owner decides which picture is the
   glove's.

## For the owner

- The boxing glove's look (flat colours, size in view): see P1_M2_M7_boxing_gloves_guard.jpg.
- M9: which glove picture the Wheel should use (above).

## Rig notes (for the batch)

- **Settings leak between agents' launches.** run.sh puts the rig's qzdoom.ini back only after the lock is released, so the
  next queued launch starts from the last launch's saved settings. Launch B ran with `rsqml_guard` and `rsqml_heavyhands`
  on, which P1 never set (another group's Gun Bonsai VR "Add All" turns those rows on): `guard: UP at t1179` and
  `heavy hands: frozen 4 tics` in P1_B_log.txt. From launch D on, P1 set every Melee row it relies on at the start.
- `use RSQ_Glove` from the console did not raise the main glove (the Rifle stayed; `use RSQ_GloveOff` worked). Start With
  Melee Hands did. Not followed further.
- Clear Out looked like it shoved nothing in launches B to E: the probe had spawned the two imps 31.6 units apart, under
  their 40 units of radii, so each blocked the other. One imp alone is shoved (launch F). Not a Melee fault.
- The 160 px launches rendered about two tics in three; swings still read, but a 3-tic barrel kick drawn as one 0.75 m jump
  passed over the barrel (launch D). At 72-90 Hz in a headset a hand never jumps that far in a tic.
