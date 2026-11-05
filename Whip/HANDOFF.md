# HANDOFF -- RSQ_Whip (PROJECT WHIP), 2026-10-30

## 2026-11-04: Swing Assist: Grab Snag (owner 19:49) -- rig only, not headset-confirmed
Owner: "once snagged, grabbing the whip with the off hand gives us vertical lift and also forward momentum as a kind of
swing assist ... grab the damn thing and be lifted up a little and moved forward at a reasonable speed, as a toggle."

### Done (measured: rig qzd17.3, SWINGTST, whp probe scen 11, `whp_scripts.py assistwall` / `gripstart` / `assistnosnag`)
- `rsqwp_swing_assist` (on; Whip page "Swing Assist: Grab Snag", under Grip Starts Swing), `rsqwp_swing_assistlift` 8
  and `rsqwp_swing_assistspeed` 10 (Test and Debug "Assist Lift" 0-20, "Assist Speed" 0-30). swing.zs core.GrabAssist:
  the grip start (once per rope, h.started) sets vel.z = max(vel.z, lift) and raises the level speed toward the point
  under the anchor to the speed (never cuts a faster run), in place of the grip's 6-unit hop; then CapSpeed (Gun Bonsai
  VR Momentum's cap). No SlowMo scaling: the player runs on real time (util.zs WorldScale), as the jump start.
- The take-up's rate cap ate it at first (core.Swing holds inward speed to 1.5 x takeRate: 12 forward -> 7.3 the next
  tic). With the assist the take-up's pace is max(GRIP_PULL, |vel| / 1.5). Assist off: unchanged (GRIP_PULL).
- Defaults from the rig: a stick run is 9.5 u/tic and a running jump rises 36 units (z 96 -> 132). Lift 8 rises 35-36.

| rig run (doom2 + Whip, SWINGTST) | off | on (8 / 10) |
|---|---|---|
| wall ahead and above (the pit's lip, 6.8 m, anchor z 210): vel the tic after the grip | (3.7 0.1 7.3) | (10.0 0.3 8.0) |
| ... rise by +8 tics / ground covered in 20 tics | 33 u / 146 u (touches down at +21) | 35 u / 225 u (no touch-down) |
| ceiling 8.8 m (gripstart): vel after / rise / 20 tics | (4.9 0.1 6.8) / 27 u / 109 u | (10.0 0.2 8.0) / 36 u / 182 u |
| no snag, same grip (assistnosnag) | -- | no START, pos and vel 0 through the grip |
Afterwards the rope runs as before (rope 72 / 288 held, pendulum swings; a let-go 34 tics on kept 15.5 flat via GRACE).
Frames: scratchpad `laneassist_frames/aw_strip_off_on.png`. Script errors: doom2 + Whip 0; doom2 + GunBonsai 0.10.6 +
all RSQ 0; full order (03 = 2.0.3v) 4, all 02_BD22_VoxelPack's voxeldef; the assist fired on both (BD's rsq_hands off hand).

### Open
- On the lip anchor one assisted run (8/10) swung far enough under the lip into the pit that the rope lost sight of its
  anchor for 3 checks and slipped (the existing corner rule, core.Swing Sees) 81 tics after the start; 8/12 held 129 tics.
- On the ceiling the assist reaches under the anchor with the rope slack and falls into the arc until it catches (the
  rope's own catch: vz -21 -> +12.7). Feel is the owner's call; Assist Lift / Assist Speed tune it.
- Not headset-tested.

## 2026-11-03: the beam wins, no bits, the off hand free while snagged, grip / jump start the swing, the reel is a climb (owner 11:20-12:06) -- rig only, not headset-confirmed
Owner: "the offhand beam ... takes precedence over any actor-lock-on ... Once snagged ... we grab the whip with the offhand
to get height and begin our swing, OR we press jump"; 11:35 "whip needs to not target bits"; 11:52 "slower whip reel in
... supposed to simulate climbing"; 12:06 "whip has to prioritize traversal / offhand target first, then actors".

### Done (measured: rig qzd17.3, SWINGTST, whp probe scen 11, `whp_scripts.py` beammon / bits / offgun / gripstart / jumpstart / reelclimb)
- **Beam Wins Over Lock-On** (`rsqwp_swing_beamwins`, on; swing.zs BeamWins). The beam is ON while held (gold or red)
  and for **35 tics (1 s)** after it is let go on a gold spot (`BEAM_MEMORY`; a beam whose last tic was red forgets).
  While on, every actor path stands down: the trigger's mark (Mark, also while the thong flies), the LOCKED crack
  (Crack), the edge snag (Crack WrapNear, Collide Snag), the crack's own target round the tip and its fetch (Crack:
  no actor at all), a thrown lasso (flies into the air), the thong's lash/sting hits (Collide), and a monster still
  wrapped lets go (Lash: a wrap blocks every crack). Gold: the crack casts to the spot; red: a plain crack (a switch
  it lands on still throws). Off: the old 6-tic grace, no stand-down. Why it lost before: the cast took the ray only
  6 tics after the release; a wind-up + crack takes longer, so a let-go beam fell through to the mark / lock.
- **Not a target**: Kill Rewards bits by name (`NotATarget`: any class starting "RSQ_KR") in Mark, Lock, Crack's
  target, Fetch, LassoThrow, Throw. Whip still loads alone.
- **Off Hand Free While Snagged** (`rsqwp_swing_offfree`, on): nothing in Whip released on an off-hand switch (the
  engine's PendingWeapon switch only drops that hand's weapon, player.zs CheckWeaponChange; Wheel's equipInstantly and
  TacticalRig's DrawOff/QueueOff touch only the off hand). The switch now gives the old/strict choice: off = a gun
  coming into the off hand lets an aimed swing's rope go (core.SwingWatch). An off-hand gun's fire is never eaten.
- **The start waits**: an aimed latch FROM THE GROUND no longer hops or takes up by itself while a start is on (the
  take-up is kept for the start). In the air it swings at once. One start per rope.
  - **Grip** (`rsqwp_swing_grip`, on): aimed rope, off hand empty (OffFree), its grip pressed (raw key `rsqwp_keys_off`
    or a grab bind) within **0.5 m of the whip hand or the rope**. Rope taken up the arc's need + **24 units (one
    pull, 0.7 m) at 6 a tic**, hop 6; that press never becomes a climbing hold.
  - **Jump** (`rsqwp_swing_jump`, on; any whip rope, any off hand): BT_JUMP's press. vel.z = max(vel.z, **Jump Lift
    10**) -- the engine's floor jump that tic (JumpZ 8, already in vel) is never stacked on. **Jump Push 8** along where
    you FACE, its part away from the anchor removed and the push kept whole along the rest, ADDED to the velocity you
    had. Facing, because standing at a lip there is no tangent yet and you look where you mean to go.
- **The reel is a climb**: `rsqwp_reel_climb` **3** a tic (~3 m/s; was `rsqwp_reel_speed` 12, renamed so a saved 12 in
  the ini does not stay), eased in over 6 tics, slider 1-30. The perk factor is 1 (fx.zs); no Gun Bonsai node boosts
  the reel. Fixed on the way: a reel now ends the launch's pay-back (rig: letting go of the trigger paid the whole
  climb back out at 8 a tic).
- Menu rows (after Aim With Off-Hand Fire): Beam Wins Over Lock-On, Off Hand Free While Snagged, Off-Hand Grip Starts
  Swing, Jump Starts Swing, Jump Lift (0-20), Jump Push (0-20); Reset All 64 cvars (gen_reset.py).

| rig run | result |
|---|---|
| (a) imp (can't walk) 100 ahead under the beam line, whip trigger marking it, beam let go 15 tics before the crack: switch OFF (old) | MARK DoomImp; `CRACK LOCKED -> DoomImp`, WRAP |
| (a) same, switch ON (doom2; GB + all RSQ; full order) | MARK dropped at the beam; `CAST -> ceiling (546 519 188) 8.7 m (beam let go 16-20 tics ago)`, LATCH, imp untouched by the flight |
| (a) beam held through the crack, full order | CAST (beam held), LATCH |
| (a) red beam (floor) + marked imp: OFF / ON | LOCKED -> DoomImp / `plain crack, target None` (doom2 and full order) |
| (f) no beam, trigger marking the imp | LOCKED -> DoomImp, WRAP (as today) |
| (b) bits at 150-170, Clip 230, imp 260, trigger held: HEAD / new (GB + all RSQ; full order) | MARK RSQ_KRHealthBit, flown to and taken / MARK Clip, Clip fetched; an ammo bit 5 units from the Clip stays |
| (b) plain crack with 3 bits + a Stimpack round the tip: HEAD / new | fetched 4 (all bits taken) / fetched 1 (the Stimpack) |
| (c) snag, Pistol into the off hand at t60 (engine switch / Wheel instant), jump, off trigger t95-150 | `SNAGGED off hand now Pistol: the rope holds`; rope held t51-t198 (hook phase 1 every tic), pistol 50 -> 46 rounds while swinging; same on GB + all RSQ and full order |
| (c) same, Off Hand Free While Snagged off | lets go at the switch (t60) |
| (d) snag + left hand beside the right (0.09-0.10 m) closes | `START by GRIP: take-up 312 -> 288, vel.z 6`; swings, bottoms 17.6 / 15.6 (doom2; full order the same). Off hand 0.99 m away: "grip not taken" |
| (e) snag + jump from the lip | `START by JUMP: vel (0 0 8.0) [engine's jump] -> (8.0 0 10.0)`; bottom 24.3 (step-off start: 18.9); let go t108 at 21.0 flat: landed x 1841 (986 flat), the step-off landed on M x 1066 (321) |
| (e) jump in mid-swing (stepped off first) | vel (15.5 0.4 -9.3) 18.0, flat 15.5 -> (23.5 0.4 10.0) 25.5, flat 23.5: flat kept 100% + 8 |
| reel (trigger held on the rope t130-t230) | rope 298 -> 32 at **3.0 a tic** after the ease (18 per 6 tics), ~3.1 m/s; stays 32 after the release (was paid back out) |
| starts off (`ceil`, grip 0 jump 0) | hop 6 at the latch as before; swing, landed on M 403 on |

Snag (`snag`, no beam): HEAD snagged the lintel 3 of 5 runs, new 0 of 8 -- every HEAD snag had a dropped rig frame
during the forward swing (frame -> maptime map skips 2 tics, `whp_F`), the swing arriving faster; with clean frames HEAD
did not snag either (rsqwp_debug 4: the same link hits, edge 1, below the speed). The no-beam path is unchanged code.

Frames (rig, first person; m = maptime), scratchpad `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/`:
`strip_beamwins_cast.png` (diamond on the ceiling over the imp, no mark on it, the thong goes up), `strip_offgun.png`,
`strip_grip.png`, `strip_jump.png`, and the chase-camera strips listed in the commit.
Logs: scratchpad `whp/logs/` (bm_*, B_*, G_*, bits_*, offgun*, grip*, jump*, reel*, snag*).

Script errors: doom2 + Whip 0 (MAP01 and SWINGTST). doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0. Full order (01, 02, 03
2.0.3p, 04-07, GunBonsai, all RSQ): 4, all 02_BD22_VoxelPack's voxeldef. Every run.

### Not done / open
- Not headset-tested. Feel guesses: memory 1 s, grip reach 0.5 m, grip pull 24 at 6, Jump Lift 10, Jump Push 8, reel 3
  with a 6-tic ease.
- On SteamVR the off grip as a raw key (`rsqwp_keys_off` 443 436) is the Quest lasso's; not run there.
- One jump swing does not reach B (x 1920) on SWINGTST; it clears M. The chain still crosses.
- A jump in the air replaces a downward vel.z with the lift (the flat speed is kept whole).

## 2026-11-03: Aim With Off-Hand Fire, and the ray that vanished (owner 10:26) -- rig only, not headset-confirmed
Owner: "when offhand is empty / fist, holding offhand fire casts out a beam marking where we will snag ... also the beam
is bugged, it disappears instantly instead of staying drawn on offhand fire."

### The bug (measured)
`aimBtn` (the eaten alt-fire key) is one per player; `AimTick` runs per hand and cleared it when "this hand's weapon is
gone". The hand without the whip is never tended, so every tic its slot cleared the whip hand's key: the ray lived 1
tic after the press. The 0332cad6f proof drove the ray with the console's `+oh_altatk` (a button, not the key), so it
never took the key's road; its one key run (`aimkey`) shows the ray held 1 tic of 165 in its own log. BEFORE (git
archive HEAD, key route qz_rgrip + qz_ltrigger -> KEY_LALT): key held t269-t319, ray drawn 1 tic. AFTER: 51 tics.
Fix: cleared only when neither hand has the whip weapon (swing.zs AimTick).

### Done
- swing.zs `OffFree` (empty off hand: none, Fist, RSQ_Hands, UBQS_ForceHand, Melee_Attacks, RSQ_Glove/RSQ_GloveOff,
  any name with "fist": Saber FistOff/IsBareHand, GunCards EmptyHand, TacticalRig OffEmptyName) and `OffFireAims`
  (whip in the main hand, off free, `rsqwp_swing_ohfire` and `rsqwp_swing` on). whip.zs AimKey eats `+oh_attack`
  (QZD posts the off trigger as KEY_LSHIFT, Quest and SteamVR) press + release when OffFireAims, sends
  `rsqwp_aimkey 1 1`; `aimFire[pn]`. weapon.zs `AimBy`: 2 off fire (key or BT_OFFHANDATTACK), 1 alt (as before).
  A gun in the off hand: its fire is never eaten; the alt-fire route aims as before.
- Menu "Aim With Off-Hand Fire" (`rsqwp_swing_ohfire`, server, on) after Whip Swing Reach; Reset All (58 cvars).
- `rsqwp_debug 5`: a `T_WPW <i> RAY t<n> drawn by ...: GOLD/RED <why>, m, dots, diamond` line every tic drawn.
- Rig kit: whp_scripts.py `ohold` / `ohceil` / `ohgun` (the off trigger by `qz_ltrigger`, the real key road; OFFW=
  fist|gun, OHF=0/1, WDBG); probe `whp_O` line a tic; whp.sh uses a private ini copy (other lanes share the rig) and
  PROBE= for a baseline probe.

| run (SWINGTST, rsqwp_debug 5) | result |
|---|---|
| doom2, off hand empty, off trigger held t5-t75 then sky t120-t160 | RAY 70 tics GOLD Ceiling 6.2 m (18 dots, diamond), gone on release, 40 tics RED Sky |
| doom2, Doom's Fist in the off hand, switch on / off | ray 70 + 40, Fist never in Fire / switch off: no ray, Fist punches (Fire 90 + 56 tics) |
| BD order (2.0.3p), RSQ_Hands off, rsq_punch 1, switch on / off | ray 70 + 40, no MeleeStrike / off: MeleeStrikeNormal at t7 and t122 (it punched) |
| full order + GunBonsai + all RSQ (off hand = UBQS_ForceHand) | ray 70 + 40, ForceHand never in Fire |
| ohceil (crack while gold) | CAST t216 ceiling 8.7 m, flies 5; SWING LATCH rope 312, hop 6 (same as the alt-fire `ceil`) |
| ohgun (OFFW=gun: Pistol in the off hand) | off trigger: pistol fired 5 rounds (70 -> 65), by 0, no ray; alt key (main grip + off trigger) t100-t150: ray 51 tics |

Frames (rig, first person; m = maptime), scratchpad `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/`:
`strip_oh_empty_hold.png`, `strip_oh_fist_hold.png` (Doom Fist), `strip_oh_bdfists_hold.png` (BD order, RSQ_Hands),
`strip_oh_fullset_forcehand_hold.png`: before the press none, ray in every frame across the 2 s hold, gone after the
release, red into the sky. `strip_oh_ceil_cast.png`: ray, crack, thong to the ceiling, swing. `strip_oh_gun.png`: no
ray while the off pistol fires (the pistol is out of the pitched-up view; the ammo count is the proof), ray on alt.
Logs `whp/logs/` (ohold, ohold_fist, ohceil, ohgun, bd_ohold, full_ohold), `whpF0`, `whpBD0`, `whpB` (BEFORE).

Script errors: doom2 + Whip 0 (MAP01 and SWINGTST). doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0. Full order (01,
02, 03 2.0.3p, 04-07, GunBonsai, all RSQ): 4, all 02_BD22_VoxelPack's voxeldef.

### Not done / open
- Not headset-tested. On SteamVR the off trigger is KEY_LSHIFT as on Quest (gl_openvr.cpp 2021), not run there.
- On the full set the empty off hand is RSQ Saber's UBQS_ForceHand; with the whip in the main hand its fire now aims
  the ray, so the off trigger no longer holds the Force (the whip already took its alt-fire in 0332cad6f). Owner's
  call; the switch off gives it back.
- A rig ini with `vr_secondary_button_mappings=false` posts no KEY_LALT for main grip + off trigger; `ohgun` sets it.
- Off fire by the console's `+oh_attack` (a button, not the key) also aims but is not eaten: the fist would punch too.


## 2026-11-03: Crack Knocks Enemies Back (owner's headset report 07:05) -- rig only, not headset-confirmed
Owner: "Cracking an enemy and their not dying seems to cause them to be flung about the room, I'd like this disabled or
put into an on/off switch."

### The cause (measured: rig qzd17.3, probe whp scen 12, `tools/rigtest/knock_runs.sh` + `knock_metrics.py`)
The probe logs the summoned monster every tic (`whp_V`: pos, vel, hp); in scen 12 it has Speed 0, so it cannot walk.
- **A marked crack wraps the monster** (the whip weapon with the trigger held: Mark -> Crack LOCKED -> Reach -> Hit ->
  BeginWrap). The flail then PLACES it each tic at the rope's length on the arm's yaw, and the next arm move back
  counts as the pull and yanks it. Arm swaying +-40 deg after the crack (crackhitm, BEFORE = HEAD): the imp swept 95
  units side to side (up to ~17 a tic, by TryMove, so its vel reads 0), then a 45% yank threw it 74 units toward you
  at 11 a tic, 58 units up. Same on the full order (VoidDarkImp, mass 105). This is the fling. It is NOT core's rope,
  lasso or snag: the wrap is whip.zs's own (BeginWrap/HoldWrap/Flail/Yank).
- **The engine's damage thrust** (Hit -> Hurt -> DamageMobj, player as inflictor): 0 with the whip weapon in the
  main hand (its Kickback 0; ApplyKickback reads ReadyWeapon). With the Whip (Off) bind and a gun in the main hand it
  is the gun's kickback: 1.5-1.9 a tic on an imp, ~9-12 units of slide on the full order. Small, but the same switch.
- Not the cause: Gun Bonsai VR asks (none fired; GB on: no move), BD pain states (the BD imps' own -5 / -6.5 a tic
  dodges show with the switch off too and without a hit).

### Done
- `rsqwp_whip_crackknock` (server bool, **off**), menu "Crack Knocks Enemies Back" (after Lasso), in Reset All
  (gen_reset.py). Off: Hit passes DMG_THRUSTLESS (fx.zs Hurt has a flags argument now), and a crack's wrap (a marked
  crack, Assist's) is not flailed: no placing it round you with the arm, no Pain pin. It still takes the damage, pain,
  hit-stop, sparks and sound, still wraps, and **a pull back still yanks it** (the mark, the yank, Yank Grace and RSQ
  Miniboss's Can't Be Yanked work as before). On: exactly the old code.
- **The line drawn** (first cut stopped the marked crack wrapping at all; the coordinator/Miniboss lane: the deliberate
  yank must stay): what is gone with the switch off is only what moves the monster without you asking -- the
  engine's push and the arm dragging it round. A thrown LASSO's wrap (`wrapLas`) still flails. Not touched: the swing
  kick, the flail smash, the fireball knock, the aimed swing, the Leash.

| run (knock_metrics.py, 60 tics after each hit; scen 12 monster can't walk) | BEFORE (HEAD) | switch ON | switch OFF |
|---|---|---|---|
| doom2, marked crack on an imp, arm sways +-40 deg | WRAP, flail swept it 95.3 | WRAP, 95.3 | WRAP, moved 0.0 |
| ... then the arm winds up for the next crack (reads as a pull) | YANK 45%, 73.8 at 11.04/tic | same | YANK 47%, 81.3 at 11.14 (the yank is kept) |
| full order, same (BD imps) | WRAP, swept 95.3; yank 74.8 at 11.04 | swept 95.3; yank 74.8 | WRAP, no sweep (its only moves: BD's own imp leap, 10/tic, seen with no whip too) |
| doom2, Whip (Off) + Pistol, plain crack: engine thrust | 1.50 / 1.88 a tic | 1.88 / 1.88 | 0.00 |
| full order, Whip (Off) + BD fists | slid 8.8 / 11.6 | slid 12.5-22.8 | moved 0.0 |
| yank scenario (mark, crack, pull back 0.6 m), doom2 / full | YANK 100% pulled | YANK 100% pulled | YANK 100% pulled, both |
| RSQ Miniboss imp, Can't Be Yanked on / off (its whip_yank_noyank1/0.txt) | -- | -- | "heavy: you swing to it" / "light: pulled" |
| doom2, lasso thrown at an imp | -- | WRAP, lifted (flail) | WRAP, lifted (flail) |
- Scripts: `tools/rigtest/knock_runs.sh` (crackhitm, crackhito, lasso1i, switch 0/1, doom2 + full order),
  `knock_runs2.sh` (yank 0/1, Miniboss noyank), `knock_metrics.py` (reads whp_V). Logs: scratchpad `whp/logs/`
  B_* (HEAD), A_* (first cut), C_* (final).
- Script errors: doom2 + Whip: 0. doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0. doom2 + RSQ_Miniboss + Whip: 0. Full
  order (01, 02, 03 2.0.3p, 04-07, GunBonsai, all RSQ): 4, all 02_BD22_VoxelPack's voxeldef. Every run.

### Not done / open
- Not headset-tested: whether this was the owner's case (he may have held the trigger while cracking, which marks).
- With the switch off, an arm moving back after a marked crack (a wind-up for the next one) still counts as the pull
  and yanks it (81 units at 11/tic on the rig). If that is what he felt, Yank Grace (option) or a stricter pull is
  the next step: his call.
- On the full order the rig's lasso never gripped (grip key seen, no LASSO, with the switch on or off, the off
  weapon UBQS_ForceHand): not caused by this change; not looked into.

## 2026-11-03: the aimed swing anchor (owner, approved 11-03) -- rig only, not headset-confirmed

### Done (measured on the rig: qzd17.3 tools/rig17, doom2 + SWINGTST from tools/rigtest/mkswingmap.py, whp probe scen 11)
- **swing.zs** (new, `extend class RSQWP_Whip`). The other hand's alt-fire is held while the whip weapon is in hand: in
  weapon.zs Tend, from the button, or from its key (whip.zs AimKey eats `+oh_altatk`, or `+altattack` with the whip
  in the off hand, plus its release, and sends `rsqwp_aimkey`). That casts a ray (LineTrace, TRF_ABSPOSITION |
  TRF_THRUACTORS) as long as Whip Swing Reach (`rsqwp_swing_reach` 9 m, 3-20, room metres). It is drawn as a dotted
  line of full-bright particles and the series' diamond: gold valid, red refused.
  - Valid: a wall or a ceiling. Refused: out of reach, sky (a ceiling of the sky flat, or a sky upper wall), a
    floor, NumPortals > 0 or a line portal, a polyobject (WALLF_POLYOBJ), a 3D middle texture, and "no room" (the
    anchor point lands outside the open space).
  - Normal (surveys/05 3.1): ceiling plane normal; for a wall, the line's right-hand normal, negated on the back.
    Then it is checked against the hand: every rig hit logged "the survey's sign faces the hand", so it was never
    flipped.
  - The anchor sits 4 units off a ceiling (anchorPlane 2, it follows the plane). For a wall it is the body's radius
    + 4 out, with the rope still drawn to the face. core.UpdateAnchor's wall check traces along -normal from struck.
- **Cast:** Crack -> SwingCast, which runs first. The ray must be held and gold, or have been let go within 6 tics
  with a gold spot. Reach then flies the thong there in 5-8 tics (`casting`), and SwingLatch builds core's hook
  (`aimed`, `launch`, `fullLen`, `autoLen`). A crack with the ray red is an ordinary crack ("CAST refused: Sky").
  The edge snag is off while the ray is gold, and while the thong is on its way.
- **core.zs:**
  - LAUNCH: the rope follows the body in until it first pulls in the air, so the hop or a step does not drop him
    slack. Without it there was 200 units of free fall.
  - Then the length it took in is paid back out at 8 a tic, on the way down only.
  - TAKE-UP: only when the arc's bottom would not clear the floor under the anchor.
  - GRACE: on a player's let-go in the air, the fastest of the last 3 tics' velocities (vHist).
  - A wall rub gives back the speed lost along the wall it hangs from.
- **Chain:** weapon.zs Tend. When an aimed rope (or any rope with the ray held) starts retracting, the hook is
  dropped and the whip restarts uncoiled at once (`outNow`).
- **Fix found on the way:** whip.zs RenderOverlay now also sends rsqwp_hp0/1 while roped. Without them, ArmPump read
  AttackPos.z (the interpolated eye) and logged "haul 10.7" with the hand still, pumping a 22 swing to the 30 cap.
  This applies to snag ropes too.
- Menu: "Aimed Swing (other hand's alt-fire aims)" (`rsqwp_swing`, on) and "Whip Swing Reach (m)", both in Reset All
  (gen_reset.py: 56 cvars).

| rig run (whp_scripts.py, swing_metrics.py) | result |
|---|---|
| aim | ceiling VALID 3.5 m; floor INVALID; level east INVALID out of reach (9.0 m); south wall VALID 7.2 m, normal (0 1 0); sky yard INVALID Sky |
| aimkey (the key route: qz_rgrip + qz_ltrigger -> KEY_LALT -> +oh_altatk) | "aim key down", ray valid, cmd.buttons 0 (eaten: the off hand's alt-fire never reached the game) |
| ceil | cast 8.7 m, latch rope 312, hop 6; arc bottom 22.9 a tic (z -158); let go t93 at 22.6 (grace 21.6 -> 22.5, from 2 tics back); landed on M 467 units on, flat 22.2 kept on landing (22.2 20.2 18.3 ... friction) |
| wallanchor | wall anchor 6.4 m beside-ahead; sideways arc along the wall, bottom 20.5 flat, back 12.3, 7.4; one rub 17.7 -> 9.2 |
| chain (3 swings, 45 m pit) | ropes at x 684 / 1252 / 1660; each re-cast caught 16 tics (0.46 s) after the let-go; bottoms 22.9 / 19.1 / 14.3; let-go 20.5 / 16.2 / 14.2; landed on B at x 1932, 1554 units from the start |
| refuse | ray on the sky + crack: "CAST refused: Sky", ordinary crack 45.3; floor + crack: refused, crack 44.8; no rope |
| snag (WHIPTEST beam, no ray), BEFORE (git archive HEAD) / AFTER | SNAG t213 at (536 504 71), 29 above the hand / identical |
| whp_metrics swing, wall, yank BEFORE / AFTER | cracks 42.5, 36.5 / 42.5, 36.4; wall 36.8, 37.4 / same; yank crack 42.3, WRAP t207, YANK t250 / same; KE, lerr, peaks equal |

Frames, scratchpad `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/`:
- `strip_aim.png`: gold on the ceiling, red to the floor, red out of reach, gold on the wall, red into the sky.
- `strip_ceil_cast.png`: the ray, the wind-up, the thong flying up.
- `strip_ceil_swing.png`: chase camera from t60: the rope to the ceiling and the arc.
- `strip_wall.png`, `strip_chain.png`, `strip_refuse.png`.

Script errors:
- doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0 (ceil ran the same; landing speed 0 there because Gun Bonsai VR makes
  momentum a node).
- Full order (01, 02, 03 2.0.3o from the BD22 repo, 04-07, GunBonsai 0.10.6, all RSQ): 4, all 02_BD22_VoxelPack's
  voxeldef. The chain ran identically there.

### Not done / open
- Not headset-tested. Feel guesses: reach 9, hop 6, offsets, take-up 10, payout 8, grace 3, aim grace 6.
- Rope wrapping round corners: planned (README), not built.
- Portal, 3D-midtex and polyobject refusals were never run (no test map has them). The netplay aim is local-pose
  only.
- The rig needs PITCH_FIX 30 (its controller pitch reads about 30 degrees low) in whp_scripts.py lpose.
- A chase camera (`chase`) moves the hand poses on the rig; turn it on only after the aim.

## 2026-11-02 (GBOVR pass): the recode reviewed, the owner's seven decisions -- Windows QZD 17.3 headless, not the rig
A read-only review of the recode (MIT length) found numbers sized for the old 6.4-unit links. The owner decided all
seven (11-02). Tested on the owner's Windows QZD 17.3 with the series probe (`GunBonsaiOffhandVR/tools/fistsprobe`,
`fp_wp`), which calls the whip's own functions; that engine cannot move a VR hand, so **no swing was run** (the Linux
rig's `qz_rhand` cvars are not on that build). With no tracked hand the whip holds the handle at the eyes, so
Assist's throw and Reach's flight do run.
- **Reach's speed bookkeeping fixed** (`Reach`): the link's last sub-step is set a sixteenth of the tic's move
  behind, so the sim reads the move as a per-tic speed. Assist's throw: the sim read 3-11 room/tic while the tip
  moved 10-25 a tic (was 100-490).
- **Hardest crack 50 -> 43**, and the cvar renamed `rsqwp_whip_hardcrack` (every archived cvar is written to the ini,
  so a saved 50 would have stayed). Damage by tip speed 20/30/35/43/50: 3/7/9/12/12 (was 3/6/8/10/12).
- **A crack with the last links still paying out** (`CRACK_COILED` 6: 19 of 25 out, 1 tic): about 6 tics into the
  payout, not ~10. Probed: 5 links coiled -> ready; 7 -> not. Whether a fast real throw now cracks: headset.
- **The lasso's catch reach** = 4x the whip's length (`LassoReach`, `LASSO_REACH_K`): 7.2 m (was 2x: 3.6 m).
- **The lasso's held piece** = the links between the handle's tip and where the off hand took hold (`LassoHeld`, 3 to
  `LASSO_K` 13 = 0.94 m, the old piece): 0.3 m -> 4 links, 0.6 m -> 8, 1.2 m -> 13. The grip may take the thong
  anywhere along it. A fixed 5 (0.36 m now) stretched links 1-5 toward an off hand further out.
- **`GRAZE_U` 6 -> 2.3** map units (about a link, as 6 was for 6.4-unit links).
- Comment nits from the review (handSpd's merged comment, COIL_A's side, "21 links in").
Not changed: Assist's throw reach (`Throw`: 1.1x the length, ~2 m, not in the decisions).
- **Snag and the rope re-tested** (owner: before the Rope branch) on WHIPTEST: a crack just under the beam's edge
  (z 72, 37 above the hand) became core's rope; stepped off the lip, you swung out to x 560 and back onto the ledge
  (fell 17, not 512). A still player on the ground is stopped dead by QZD, so the probe put you just past the lip.

### The Gun Bonsai VR Whip tree (GBOVR_TREES.md 4.4), built the same day
`whip.zs` GbRefresh / Gb / Unlock (the levels by name once a second, -1 without the patch); `core.zs` Carry, CapSpeed,
Comfort and Tarzan; `weapon.zs` the lasso. Probed headless (`fp_wt*`), numbers in GBOVR_TREES.md 4.4 BUILT. Fields
renamed for ZScript's case-blind names: Bola's tied monsters are `tied[]`, not `bola[]`. Not run: a real swing, Mantle
2 (a swing up to a lip), Lasso 2's longer hold in a real throw. Found on the way, not changed: a fetched pickup flies on
an arc meant to land on you, and an item is picked up only when the player moves into it (QZD); in the probe the
fetched items stopped 40-60 units short on MAP01. Headset: does a fetched pickup reach you and get taken.

## 2026-11-02 (latest): MIT's length, held coiled, uncoils for the attack -- rig only, not headset-confirmed
Owner (headset): "That whip looks hella long dude, almost like a noodle ... we hold it coiled ... shorten the length
of it and extend it during the attack?" Decisions: length = MIT's exactly; coiled at rest; ramped uncoil/reel.

### Done (whip.zs; measured on the rig, qzd17.3, doom2 MAP01, BEFORE = 9c32f28a8 via `git archive`, same probe)
- **Length = the reference's** (parsed from 3D_model_w_whip.xml): 25 links x 0.072 m = 1.8 m (was 20 x 6.4 room =
  3.76 m). LINK = 0.072 x 34 = 2.448 room units. The joint's omega^2 = 114 / 2.448^4 = 3.175 /tic^2 = the reference's
  k/(m l^2) = 3890 /s^2; c/k 13.31 tics. **Leather Damping default x1 (the reference; was x0.25).** The Whip Length
  slider and rsqwp_whip_reach are gone. `LenMult()` (1) is the one place a "super whip" would double the links.
- **The coil** (`cp` links coiled, rate `cps`, goal `cgoal`; CoilTic, CoilAt, LayOut, Sim): at rest 21 links lie on a
  30 cm loop hung from the handle's tip (facing you, inward, stepped along the heading), pinned to it; a 4-link tail
  (0.29 m) is simulated. Goal 0 (all out) on the wind-up (windTics >= 2), a swing, the lasso grip, a wrap, a flight,
  Assist; back to rest after 30 quiet tics (tip < 3, handle tip < 1.2, nothing going on); NN when put away (then
  Halt). The rate accelerates toward the goal and slows to land on it: payout max 3.5 links/tic, 1.0/tic^2 (~10
  tics); reel max 1.2, 0.25/tic^2 (17 tics measured). Payout unpins the coil's last link (it was moving with the
  coil, so it goes on at that speed); reel draws the next free link onto its loop place over one link's reel time.
  While reeling, free links are capped at 5 room/tic. The wind-up guide's line starts at the coil's end. The crack
  needs 2 tics fully out. Collide/Mend/Carry skip the coil's links.
- **Lasso:** uncoils on the grip; the off hand's 5-link piece is taken over 6 tics once the thong is out (`lb`).
- Fixes found on the way: Relax 12 passes, alternating (short links); a link floor-lifted by under 3 units is no
  longer held fixed in the relax (it left a link 7x long at MAP01's lip: swing lerr max 632% -> 61%); a tracking-space
  turn now needs BOTH controllers turned (one hand's yaw noise passed as sub-degree turns and cancelled the jitter
  run's crack).

| run (whp_metrics.py) | BEFORE 9c32f28a8 | AFTER |
|---|---|---|
| idle t>=30: tip max / KE max | 0.3 / 0.1 | 0.0 / 0.0 |
| walk 3 s, hand still: tip max / KE / jerk max / link-in-wall tics / tip max dev (body frame) | 38.2 / 632 / 26.4 / 195 / 80.8 | 0.0 / 0.0 / 0.0 / 0 / 0.1 |
| snap x4: tip max / KE / dev | 0.1 / 2.0 / 9.9 | 0.0 / 0.0 / 0.1 |
| jitter, noisy hold t30-157: tip max / KE / jerk RMS | 0.3 / 1.7 / 0.43 | 0.8 / 2.9 / 0.36 |
| sway: tip max / KE | 0.3 / 2.5 | 0.6 / 3.0 |
| swing (2 wind-ups): cracks, peaks | 2, 87 / 80 (1 peak each) | 2, 43 / 44 (1 peak each, heavy, k 0.74) |
| swing: lerr mean / max | 1.64 / 75% | 1.41 / 61% |
| jitter whole (noisy swing): cracks | 1 | 1 (peak 43) |
| wall (2 swings): cracks | 2 | 2 (37 / 37, 1 peak each) |
| yank: mark, crack, wrap, yank | yes | crack 42 -> DoomImp 60->50, WRAP, YANK light (no BD token) |
| lasso0..7: thrown / whirl mean / cracks after | (HEAD: 8/8, 28.5) | 8/8, 25.6-26.8, 0; let-go 26.4-27.4, all round |
| lasso grip: tip speed first tics | 41 jolt | 1.3, ramps to 21 by t40 |
| two whips, ms/tic mean | 0.79-0.92 | 1.02-1.08 |
- Coil run (`whp_scripts.py coil`): wind-up t70 -> UNCOIL, tip under 13.7 while paying out (no crack); crack t87 at
  42.5; quiet -> REEL t172, tip max 8.4 while reeling (26 before the reel cap), coiled by t189.
- Frames (chase camera behind, `coilv`: the arm 0.25 m further out), scratchpad
  `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/`: `strip_coil_idle.png` (coil + tail
  still, frames 150-190), `strip_coil_uncoil.png` (205-217: the coil rises with the hand and pays out behind),
  `strip_coil_crack.png` (218-226), `strip_coil_reel.png` (305-345: the thong drawn back, the coil re-forms).
- Script errors: doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0. Full order (01, 02, 03 2.0.3n from the BD22 repo,
  04-07, GunBonsai 0.10.6, all RSQ): 4, all 02_BD22_VoxelPack's voxeldef. Every scenario run: 0.

### Not done / open
- Not headset-tested. Feel guesses: tail 0.29 m, coil 30 cm, payout 0.3 s, quiet 0.86 s, reel 0.5 s, reel cap 5.
- A swing without the wind-up never uncoils, so never cracks (owner's spec: the wind-up pays out).
- The 1.8 m crack is about half the old tip speed; damage and the heavy/light split still use 20 / 50 (heavy at 43).
- The lasso's held piece is not on its line while the coil pays out (6-10 tics); probe "inner stretch" 20% mean.
- Not re-run: snag/rope, flail into others, Assist style, left-handed (the coil hangs inward per hand).

## 2026-11-02 (later still): the lasso whirls fast and throws from anywhere -- rig only, not headset-confirmed
Owner: make the lasso fun "regardless of cost to us". After the physics rebuild it whirled at 6.5 room units/tic
(was 22.5) and a let-go at a slow point dropped it.

### Done (measured; rig qzd17.3, doom2 MAP01, BEFORE = 9c32f28a8 via `git archive`, same probe)
- **Whirl help** (whip.zs `Whirl`, Sim, `LassoThrow`): the off hand's circle is tracked each tic (its centre is the
  hand's path averaged, its angular velocity is the hand around that centre, smoothed). How round and fast the
  circle is gives a target 0..1, and `lw` ramps toward it (+0.15 a tic in, -0.25 out). Per sub-step x lw: every
  free link is eased toward turning with the circle (WHIRL_G 0.5/tic, the loop at 1.25x the hand, tip capped at
  32), and the bend damper and the drag are eased off by 60%. At lw 0 the model is exactly 9c32f28a8's.
- **Let-go:** along the circle's tangent at the tip, at max(tip speed, lw x the whirl's smoothed tip speed).
  The drop rule (LASSO_MIN 6) is unchanged for a lasso that was not whirled.
- **No crack from a thrown lasso:** BEFORE, a lasso thrown into the air cracked where it landed: Reach's per-tic
  move is read as a sub-step speed, 156 room/tic. It also does so AFTER (491) without this fix. A throw now
  disarms the crack until the thong calms.
- Rig: scenario `lasso0..lasso7` (whp_scripts.py: the 0.30 m overhead circle, 14 tics a turn, started k x 45 deg
  on, so the t150 let-go is at 8 points of the circle); `tools/rigtest/lasso_metrics.py` reads them.

| | BEFORE | AFTER |
|---|---|---|
| whirl tip speed, t40-149, mean (min), 8 runs | 2.5-6.3 (0.2-1.0) | 28.5-28.8 (20.1-25.2) |
| let-go at 8 points: thrown | 5 of 8 (3 dropped at 2.4, 5.1, 5.6) | 8 of 8, at 30.8-31.7 |
| throw direction (deg off facing) | not logged | -172, 123, 86, 46, 15, -20, -59, -111 (all round) |
| tip out after let-go, max flat | 22-145 | 145-157 (the thong is 128 + handle) |
| cracks after the let-go | 5 of 8 runs | 0 |
| imp 220 ahead, let go at 15 deg | dropped (4.8) | thrown -> DoomImp, hit 6, WRAP, pinned |
| Leather Damping x1 | lasso could not lift (2.7) | whirl 28.5, thrown |

Ramp-in (lasso0, tip speed from the grip): 7.5 8.1 8.3 8.8 9.4 10.3 11.0 ... 18.1 25.4 25.0 22.1 ... 25.3 (no step).
The 41 room/tic in the first tics after the grip comes from the latch pinning links 1-5. It was the same BEFORE.

Unchanged (whp_metrics.py, BEFORE -> AFTER identical to the printed digit unless noted): idle, sway, snap
(t>=30), walk, swing (2 cracks, peaks 87/80, one each), wall (2 cracks, 68/67): every column the same except ms.
Jitter: lerr 0.63 -> 0.62%, wall tics 75 -> 78, KE 25035 -> 25038, same peaks and 1 crack. That is run-to-run noise:
lw stays 0 there, so the code path is the same.

Frames (chase camera, behind), scratchpad `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/
scratchpad/`: `strip_A_whirl.png` (frames 236-248, one turn: the loop flat and out, sweeping round overhead) vs
`strip_B_whirl.png` (the thong hangs by the body); `strip_A_throw.png` (288-304: the let-go, the loop flies out to
the imp ahead) vs `strip_B_throw.png` (dropped).

Script errors: doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0. Full order (01, 02, 03 2.0.3n, 04-07, GunBonsai 0.10.6,
all RSQ): 4, all 02_BD22_VoxelPack's own voxeldef. Every scenario run: 0.

### Not done / open
- Not headset-tested. Feel guesses: the 32 m/s cap, loop 1.25x the hand, help from 1 turn in 3 s (full at 1.1 s)
  and a 6-15 cm circle, ramps 7/4 tics. Only the rig's perfect circle was tested; a real wobbly circle was not.
- Reach's flight still reads a per-tic move as a sub-step speed (tip 100-490 room/tic in flight, BEFORE too).
  The lasso no longer cracks from it. Not changed for the marked crack.
- Cost while whirling not measured separately (about 15 extra vector ops per link per sub-step).


## 2026-11-02 (later): the thong's physics rebuilt on a research whip -- rig only, not headset-confirmed
Owner (headset): "The whip is erratic ... i can't describe it more than that." He approved a rebuild on a validated
whip model. Reference: Moses C. Nah, MIT Newman Lab, "Whip Project - Targeting with a Whip"
(MosesAndLily/whip-project-targeting, BSD-3; models/3D_model_w_whip.xml): 25 nodes x 0.012 kg, 0.072 m links,
2-DOF hinges k 0.242 N m/rad, c 0.092 N m s/rad, first joint free; MuJoCo 1e-4 s Euler.

Rig: qzd17.3 (tools/rig17 engine), doom2 MAP01 (its start platform has a 50-unit drop just ahead: the thong lands
over that lip in several runs, a good stress case). Probe `tools/rigtest/whp` with `whp_metric 1` (a `whp_M` line a
tic; `2` dumps the chain), scenarios `whp_scripts.py idle sway walk snap swing jitter wall two`, metrics
`whp_metrics.py` (`--from 30` for the static ones: the whip is drawn at t0 and falls ~15 tics). BEFORE = `git
archive HEAD Whip`, same probe.

### What made it erratic (measured, BEFORE)
- **Regime switches.** Sim picked its damping (calm 0.96 / active 0.9995 / settle 0.80 a sub-step), its speed cap
  (1.2 / 11 / 2.5 a sub-step) and its sub-steps (3 / 8) from the hand's speed every tic. Logged per tic: 10 switches
  in the swing run, 33 in the jitter run (the hand's noise flipped calm/active 10+ times while just held), 22 in the
  wall run. Entering the wind-up regime took the tip from 0.3 to 29.2 room units a tic in one tic; after the wall
  hits the sub-steps flipped 3/8 every few tics with tip-speed jumps of x20-45. 3 -> 8 sub-steps also multiplied
  every link's speed by 8/3 (Verlet keeps a per-sub-step move).
- **No bend stiffness.** Only the wind-up's pull to the handle line; the chain had no shape of its own, so the
  rigid rod either held (swing run: the thong a straight rod, frames) or flopped.
- **The geometry response.** Collide stopped a link dead where the tic's straight sweep met a wall, floor or
  ceiling, though the sub-steps' path was curved: the wall run ended stretched 30% on average (max 724%).
- Per-tic hand jumps, linearly interpolated over the sub-steps: the handle's speed jumped at every tic's edge.

### The new model (zscript/rsqwp/whip.zs Sim; prototype tools/whipsim_xpbd.py)
- XPBD, **16 sub-steps x 2 length passes a tic, always** (no rest/active modes). Per sub-step: the handle moves
  along its path; links integrate (air drag, gravity 0.2723 = 9.81 x 34 / 35^2 room/tic^2, the speed cap 150
  room/tic, always on); the wind-up guide; the bend springs/dampers; lengths; floor/ceiling (each link's from its
  last Collide, sliding keeps 0.6 of its speed a tic); a wall the link rests on (below).
- **Bend (the reference):** C = p[j+1] - 2p[j] + p[j-1] at every joint. A driven free chain depends only on EI/lam
  and c/k: EI = k l = 0.01742 N m^2, lam = 0.1667 kg/m, EI/lam = 0.1045 m^4/s^2 = **114.0 room^4/tic^2** (x 34^4 /
  35^2); c/k = 0.3802 s = **13.31 tics**. Ours keeps the visible length (rsqwp_whip_reach 128 = 3.76 m + the 8-unit
  handle) and 20 links of 6.4: a joint's omega^2 = 114 / 6.4^4 = 0.068 /tic^2. Uniform mass as the reference (the old
  1 -> 1/34 taper is gone). The handle joint has the same spring (the reference's free first joint is its hand; ours
  is the end of a rigid handle the thong is set into). Stiffness never above the full whip's (an uncoiling short
  thong was a rigid rod).
- **Damping default x0.25 of the reference** (rsqwp_whip_bend_damp): at x1 the off-hand lasso could not lift the
  thong (whirl tip 2.7 room/tic, let-go 0.1: it dropped); x0.5 6.9, x0.25 7.6, x0.1 8.9 (the old model 22.5). Crack
  and noisy hold were as clean at x0.25 as at x1; x0.1 began to double-peak a swing. The owner may set x1.
- **Hand smoothing:** the hand followed critically damped (omega = 2 / rsqwp_whip_smooth, default 0.8 tics),
  integrated per sub-step from last tic's raw pose to this tic's. Measured lag: **0.70 tics** (swing, sway, wall),
  0.65 (jitter) -- under 1.
- **One damping model** = the bend damper + linear air drag (rsqwp_whip_drag 1/s). CALM/SETTLE/MAXSTEP/WIND_STEP
  and settle[] are gone. A length change (uncoil, roll up, reach, wrap) rescales the chain with its last places.
- **Wind-up guide:** each link pulled to its place on the handle's line as an XPBD spring of 1.5 x stiff rad/tic
  (less toward the tip), critically damped against the line's own motion (it was a per-sub-step fraction).
- **Geometry, continuous:** a wall hit keeps the move along the wall (speed into it removed, along it x0.6) and the
  link then RESTS on that wall: every sub-step keeps it on this side (WallSet/WallClear: the line, its normal, the
  height band a two-sided line blocks; dropped 4 units clear or past the line's ends). Floor/ceiling crossings go to
  the floor clamp, which removes speed into the floor. After Collide's stops, Carry's lifts (a turn or step put links
  under a floor) and Mend's fixes, the chain is relaxed to length with links moving with their last places (Relax).
  OpenAt: a link on a step's line takes the lowest floor round it. Mend: walls only; a segment bent round a lip or
  corner by up to 6 units is left alone (Graze); a mended link is pushed out along the wall's normal.
- New sliders (Tuning and Debug, Reset All): Leather Stiffness 1, Leather Damping 0.25, Whip Air Drag 1, Hand Smoothing 0.8.

### Before -> after (rig, final code)
| run | link error mean/max | tip max (room/tic) | flips/s | tip jerk RMS/max | KE max | mend tics | cracks |
|---|---|---|---|---|---|---|---|
| idle (t>=30) | 2.55/13.7% -> 0.04/0.04% | 0.3 -> 0.3 | 0 -> 0 | 0.00/0.06 -> 0.00/0.00 | 0.6 -> 0.1 | 0 -> 0 | 0 -> 0 |
| sway (t>=30) | 0.66/1.4% -> 0.04/0.04% | 0.3 -> 0.3 | 0 -> 0 | 0.08/0.31 -> 0.10/0.43 | 2.8 -> 2.5 | 0 -> 0 | 0 -> 0 |
| walk 3 s, hand still | 8.2/390% -> 0.19/7.6% | 35.2 -> 38.2 (one sub-step at a mend, MAP01 stairs) | 0.21 -> 0.21 | 4.69/62.6 -> 2.16/26.4 | 1322 -> 632 | 6 -> 1 | 0 -> 0 |
| snap x4, hand still (t>=30) | 1.2/1.2% -> 0.05/0.05% | 0.3 -> 0.1 | 0 -> 0 | 0.00 -> 0.00 | 0.0 -> 2.0 | 0 -> 0 | 0 -> 0 |
| swing (2 wind-up + crack) | 11.4/146% -> 1.6/76% | 112 -> 88 | 1.05 -> 0.26 | 16.8/111 -> 10.2/69.5 | 46668 -> 25303 | 1 -> 0 | 2 -> 2 |
| jitter: noisy hold t30-157 | ~/17% -> 0.31% | 0.30 -> 0.26 | 0 -> 0 | 0.32/0.81 -> 0.43/1.08 | 10.3 -> 1.7 | 0 -> 0 | 0 -> 0 |
| jitter: whole (+ noisy swing) | 6.2/80% -> 0.63/75% | 112 -> 91 | 0.62 -> 0.31 | 11.2/113 -> 7.5/77.3 | 46738 -> 25025 | 0 -> 0 | 1 -> 1 |
| wall (40 units, 2 swings) | 35.7/724% -> 0.93/95% (stretch 30.4/724 -> 0.12/7.5%) | 165 -> 68 | 0.10 -> 0.31 | 9.3/61.6 -> 6.7/69.6 | 12013 -> 20584 | 2 -> 0 | 3 -> 2 |
- **One crack per swing, one tip-speed peak:** swing windows BEFORE 2 peaks each (112 then 60, 6 tics apart),
  AFTER 1 peak each (87, 80: heavy, CrackK >= 0.5); the noisy swing 2 maxima (91, 59) and one crack. Wall BEFORE 3
  cracks (an extra 101 against the wall), AFTER 2. Yank BEFORE cracked again right after the yank; AFTER crack ->
  wrap -> yank, once. Lasso: AFTER let go at 9.1, thrown (BEFORE 11.1); whirl tip mean 6.5 (BEFORE 22.5).
- No energy blow-up (fastest node 82 room/tic, under the cap); no Straighten in the final runs.
- Link-error maxima AFTER are links folded short where the thong piles at a wall or lip, and the 1-2 tics a crack's
  tip falls past MAP01's start-platform lip (stretch, the long side, is the honest number).
- The noisy hold's jerk RMS is a little higher (0.43 vs 0.32) because the old model clamped every link to 1.2 room
  units a sub-step while calm; its tip still moves less (0.26 vs 0.30) and KE is 1.7 vs 10.3. An earlier run where
  the thong lay on the floor gave 0.12 (where it lands at the draw varies run to run).
- **Cost** (rsqwp_debug 3, desktop rig): one whip 0.40-0.45 ms/tic mean (before 0.24-0.35); **two whips** (weapon +
  Whip (Off), both swinging) **0.79-0.92 ms mean, max 1.2-2.3** (before 0.48-0.72); sim 0.45-0.54 of it.
- **Frames** (chase camera, behind): scratchpad `strip_B_windup.png`, `strip_B_crack.png` (before) and
  `strip_A_windup.png`, `strip_A_crack.png` (after); windup t62-80, crack t81-94. Before: the thong a straight rod
  through the crack. After: a loop rolls out along it (t83) and the tip whips over. The wind-up is above/behind the
  chase camera and barely shows in either.
- Script errors: doom2 + GunBonsai 0.10.6 + all 18 RSQ pk3s: 0. Full order (01, 02, 03 2.0.3m, 04-07, GunBonsai
  0.10.6, all RSQ): 5, all 02_BD22_VoxelPack's own (4 voxeldef + DeathSphere_Vox). Every scenario run: 0.

### Not done / open
- Nothing headset-tested. Feel is the owner's call: reference leather, damping x0.25, smoothing 0.8, drag 1, guide 1.5.
- **No crack without the wind-up** on the rig: the scripted sidearm/overhead snaps start with 2.5 m of thong on the
  floor and peak 3-15 room/tic (prototype); the old tapered thong cracked them. The deliberate wind-up cracks.
- (Fixed in the section above: the lasso whirled slower than before and could drop.)
- A Mend while walking (MAP01 stairs) still gives one sub-step jolt (38 internal).
- Cost ~1.3x the old per whip; Quest not measured. tools/whipsim.py is the old model; whipsim_xpbd.py the new.
- Not re-run after the rebuild: flail into others, snag/rope, Assist style, left-handed.

## 2026-11-02: the owner's headset report, fixed on the rig (not headset-confirmed)
Rig: qzd17.3 (tools/rig17 engine, /home/claude/g9/rig), probe `tools/rigtest/whp/` + `whp.sh` + `whp_scripts.py`
(one tic per `wait 1` at vid_maxfps 35). The probe logs `whp_` lines. BEFORE = `git archive HEAD Whip`, AFTER =
this tree. doom2 MAP01. "BD" = the owner's order with every committed RSQ pk3 except GunBonsaiVR.

### Done (measured)
| item | cause | fix | before -> after |
|---|---|---|---|
| snap turn fires it | the chain was simulated in the world: a snap swung the hand and handle 45 deg round the body in one tic | `Carry` moves and turns every node with the body. `TrackFrame` finds the tracking-space turn from both controllers: same yaw change, both turned round the pawn. The pawn's angle on the rig took the snap a tic before the controllers. Lash skips a turning tic | 4 snaps, hand still: cracks 5 -> 0, tip max speed 45.3 -> 0.3, tip drift (body frame) 166 -> 0.7 room units |
| walking goes insane | the world-space chain was dragged along. AttackPos.z also follows the interpolated eye, view bob and the step dip (a still hand moved 33..52 over the pawn on MAP01's stairs) | `Carry`. `BodyHand`: the hand is measured per frame against that frame's eye (RenderOverlay -> rsqwp_hp0/1) and put back on `SteadyEye` (ViewHeight + crouchviewdelta). Calm damping 0.96 a sub-step and a step cap of 1.2 while the hand is calm | walk 3 s down and up stairs, hand still: cracks 1 -> 0, tip max deviation 139.9 -> 18.8 (the thong lying on the steps), link-in-wall tics 35 -> 0 |
| deliberate attack | nothing scripted. After a crack it re-armed at 70% of the crack speed, so one throw cracked 2-3 times | `Deliberate`: wound up (handle >= 27 deg up, not forward, hand >= eye-14) for 2 tics, then the thong is guided to a line out of the handle (GUIDE 0.30, less toward the tip). The swing drives it like a rod and releases at 55% of peak. No crack while wound up. It re-arms only when calm or on a new wind-up | 2 scripted wind-up + swings: cracks 5 -> 2 (one per swing, tip 112 / 136) |
| yank -> BD melee -> stuck | the whip's DamageType 'Melee': BD's monsters answer it with their stealth kill (Pain/Death.Melee -> StealthKill -> GoFatality, GoSpecial and SK<monster> given to the player). Also HoldWrap moved links without their Verlet history (flung on unwrap), and nothing got a link back out of a wall | `DmgType()` = 'Whip'. `Mend` traces the chain link to link each tic and puts any link past a wall back on this side. Stuck for 6 tics: `Straighten`; again within 35 tics: re-coil. HoldWrap moves wp and wq together. EndWrap settles for 12 tics | whip kill on an idle BD imp: GoFatality+SKImp+GoSpecial and the player jumps to his fatality state -> no token. Yank run (BD): link-in-wall tics 78 -> 0. Mended links: 152 -> 0 tics |
| off-hand twirl jank | the inner piece was pinned at both hands and length-solved between them, so the solver fought itself | links 1..5 are laid straight from the handle to the off hand; only the thong beyond is solved | whirl 135 tics: link-3 accel mean 3.30 -> 1.86, max 12.8 -> 9.6. Let-go tip speed 28.3 -> 8.5 (still over LASSO_MIN 6; watch it) |
| two whips | SwitchWeaponHand sets the hand pointers and skips Deselect, so PutAway never ran and the old hand's whip went on | `tendTic`: a weapon whip that its weapon no longer tends is halted. `WhipIn` + `rsqwp_whip_hand` (user, menu "Whip In", Main/Off, in Reset All) | switchhand 1: 2 whips for good -> 1 (at most a 2-tic overlap). Off Hand: 1 whip in the off hand for 300 tics on the BD order (BD's rsq_hands did not take it back) |
| lock icon | particle rings | `RSQWP_LockRing` (WPKR, AddShaded, CB HAVE over gold FFD040) + `RSQWP_LockCentre` (WPKC), 0.35 x Cue, 4 frames x 3 tics, grAb 24,24 | frames: white diamond in a gold ring over the marked imp |
| cost | | | swing run mean 0.19-0.38 ms/tic (before 0.20-0.35) |
Script errors: plain doom2 0. BD order: only BD_VoxelPack's 4 voxeldef.

### Not done / open
- Nothing headset-tested. Not measured: the real arm's wind-up angles, real smooth turn, left-handed, Quest cost.
- The exact owner trigger for "BD melee" was not reproduced in his words (an ALERTED monster yanked to you). The
  'Melee' -> fatality hand-off was reproduced and is gone; whether it was his case: headset.
- BD's off-hand fist (RSQ_Hands, fists.zs) still punches on a forward jab of the off hand during the lasso if
  rsq_punch is on: that is BD's, not touched.


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
