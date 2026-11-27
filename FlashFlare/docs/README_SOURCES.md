# RSQ FnF (Flash and Flare): where each README claim comes from

Commit read: 50f608e63 (2026-11-27). Paths are inside `FlashFlare/` unless they start with another mod's folder. `H` is
`zscript/rsqff/handler.zs`, `T` is `zscript/rsqff/torch.zs`, `B` is `zscript/rsqff/burn.zs`, `F` is
`zscript/rsqff/fire.zs`, `G` is `zscript/rsqff/geo.zs`, `I` is `zscript/rsqff/items.zs`, `Y` is
`zscript/rsqff/battery.zs`, `S` is `zscript/rsqff/stowed.zs`, `D` is `zscript/rsqff/ddzlight.zs`, `C` is `CVARINFO.txt`,
`M` is `MENUDEF.txt`; other files are named in full. Each line number is the line that does the thing, not the start of
its function.

## The paragraph above the table

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| P1 | Both items are off-hand weapons; the handler, not the weapon, reads the hand (no fire of their own) | I:74, I:88, T:55, T:64 | RSQFF_Held Default; A_RSQFFReady; RSQFF_Torch Default; A_RSQFFTorchReady |
| P2 | The grip is the key codes in rsqff_keys_off (default "443 436"), sent as the event rsqff_grip | H:183, H:184, H:193, H:197, C:31 | RSQFF_Handler.InputProcess |
| P3 | The trigger is the off hand attack button in the command or the original command, or a key whose bind text contains +oh_attack | H:475, H:476, H:174, H:175, H:178, T:654, T:291, T:292 | RSQFF_Handler.Hands; InputProcess; RSQFF_Torches.Hands; InputProcess |
| P4 | Neither press is eaten: both input handlers return false | H:198, T:293 | RSQFF_Handler.InputProcess; RSQFF_Torches.InputProcess |
| P5 | Distances are real metres (map units over vr_vunits_per_meter, height by the pixel stretch) | G:43 | RSQFF_Geo.Metres |

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| R1 | A player who enters, or respawns, is topped up to rsqff_start (2) flares; only while Flares is on | H:729, H:730, H:740, H:744, H:745, C:14 | RSQFF_Handler.PlayerEntered; PlayerRespawned; Equip |
| R2 | A box gives 6; 24 is the most carried | I:35, I:15 | RSQFF_Box Default; RSQFF_Ammo Default |
| R2 | Boxes in Levels: beside each lying item a roll of 0 to 125, 0 to 5 drops a box (6 in 126), up to rsqff_boxes (2) | H:822, H:823, H:838, H:839, C:15, C:16 | RSQFF_Handler.Scatter |
| R3 | A flare is drawn at the pocket while Flares and Show Flare are on and at least one is carried | S:40, S:41, S:45, C:25 | RSQFF_Shown.WorldTick |
| R3 | The flashlight is drawn at the clip while Flashlight and Show Flashlight are on and it is not in a hand | S:49, S:50, S:54, C:26 | RSQFF_Shown.WorldTick |
| R4 | The off hand within rsqff_pocket_r (0.11 m) of the pocket, grip pressed, a flare carried: the take event | H:490, H:496, H:502, H:504, C:30 | RSQFF_Handler.Hands |
| R4 | The pocket: 0.12 m forward, 0.15 m toward the main hand's side, 0.28 m under the eyes, hung from the neck on the body's yaw | G:84, G:85, G:86, G:88, G:89, G:91, C:27, C:28, C:29 | RSQFF_Geo.Pocket |
| R4 | The take: one flare off the count, the held flare raised in the off hand unlit, a sound, a buzz of 0.25 for 3 tics | H:231, H:235, H:236, H:239, H:240 | RSQFF_Handler.Take |
| R5 | The take waits while the engine's two-hand steadying is on, and is done the tic it is off | H:216, H:382 | RSQFF_Handler.NetworkProcess; Keep |
| R5 | Waiting longer than TAKE_WAIT (6 seconds) drops the take with a buzz of 0.5 for 6 tics | H:118, H:383, H:386 | RSQFF_Handler.Keep |
| R6 | No flares: "No flares left" as a toast or a mid-screen print; nothing sent | H:507 | RSQFF_Handler.Hands |
| R7 | Unlit, grip at the pocket: the back event; the count goes up by one; the off hand gets back what it had | H:520, H:217, H:249, H:250 | RSQFF_Handler.Hands; NetworkProcess; Back |
| R7 | What the off hand gets back: the weapon it held, else RSQ_Hands, else nothing | H:334, H:339, H:342, H:344 | RSQFF_Handler.OffBack |
| R8 | Unlit, trigger pressed, Light It By not Strike: the light event | H:521, H:522, C:19 | RSQFF_Handler.Hands |
| R8 | Lighting: the light spawned at the burning end, a burn of rsqff_burn seconds with SPUTTER (24 tics), the strike sound, a buzz of 0.6 for 6 tics | H:261, H:266, H:107, H:270, H:271 | RSQFF_Handler.Light |
| R8 | While it sputters: a flicker step every 2 tics and 3 sparks a tic | B:114, B:118, B:156 | RSQFF_Burner.Lamp; Particles |
| R9 | The strike: Light It By not Trigger, more than 8 tics after the take, the downward speed at least rsqff_strike (1.4 m/s) and at least 0.6 of the whole speed | H:536, H:539, H:540, H:541, H:546, C:20 | RSQFF_Handler.Hands |
| R10 | The light: a point light at the flare, radius rsqff_radius (140) times the flicker step, red with green 45 to 95 | B:122, B:131, B:132, C:4 | RSQFF_Burner.Lamp |
| R10 | A flicker step every rsqff_flicker (4) tics; a flame puff every tic; a spark every third tic; a looping crackle | B:114, B:152, B:156, B:48, C:6 | RSQFF_Burner.Lamp; Particles; Ignite |
| R10 | The burn is rsqff_burn (60) seconds, counted one tic a tic, kept when the flare leaves the hand; the last 2 seconds the light shrinks and dims | H:158, B:91, B:54, B:125, B:126, B:127, C:8 | RSQFF_Handler.BurnTics; RSQFF_Burner.BurnTick; TakeOver; Lamp |
| R10 | The held light is kept at the drawn burning end each tic | H:413 | RSQFF_Handler.Keep |
| R11 | Lit: the trigger let go with the hand at rsqff_throw_min (2.2 m/s) or more sends the throw | H:562, H:564, H:567, H:569, H:48, C:21 | RSQFF_Handler.Hands |
| R11 | The speed is the fastest 2-tic window of the last 7 tics that goes ahead of where the body faces, else the fastest of all | H:106, H:717, H:721, H:723, H:59 | RSQFF_Handler.Peak; RSQFF_Fling.Ahead |
| R11 | Leaves at GAIN 4 times Throw Strength (1.0), capped at 30 m/s; Arc (0.35) of the ground speed added upward; the pawn's velocity added | H:46, H:47, H:66, H:590, H:591, H:592, C:22, C:23 | RSQFF_Fling.Mult; RSQFF_Handler.LaunchVel |
| R11 | The thrown flare takes over the held light's burn; the off hand gets back what it had; a buzz of 0.4 for 4 tics | H:221, H:303, H:309, H:310 | RSQFF_Handler.NetworkProcess; Release |
| R12 | A let-go under the threshold does nothing | H:567, H:572 | RSQFF_Handler.Hands |
| R13 | The grip is read only with no flare (take) and with an unlit one (back); the lit branch reads the trigger's let-go alone | H:502, H:520, H:564 | RSQFF_Handler.Hands |
| R14 | Gravity 0.5; Doom bounce off floors (0.35), walls (0.3) and actors | B:226, B:228, B:229, B:230, B:231 | RSQFF_Flare Default |
| R14 | It tumbles in the air; lying, its speed is cut to 0.8 a tic and stopped under 0.12; its light is 12 units above it | B:300, B:308, B:310, B:273 | RSQFF_Flare.Tick; LightZ |
| R15 | A flying flare's first touch of each monster, moving faster than 2 units a tic, is a hit; lit or spent | B:246, B:247, B:250 | RSQFF_Flare.SpecialMissileHit |
| R15 | The hit is HIT_DMG (4) | F:19, F:76 | RSQFF_Fire.Hit |
| R16 | Burn time over: spent. In the hand, the spent flare is released and the off hand gets back what it had | B:90, H:416, H:303, H:309 | RSQFF_Burner.BurnTick; RSQFF_Handler.Keep; Release |
| R16 | A spent flare is removed HUSK (10) seconds later | B:212, B:313 | RSQFF_Flare.Tick |
| R17 | At most rsqff_cap (3) give light; the first one not in a hand goes dark first; dark over 15 tics; one freed, the last to go dark lights again | H:424, H:432, H:435, H:438, H:447, H:449, B:67, C:5 | RSQFF_Handler.Budget; RSQFF_Burner.GoDark |
| R17 | A dark flare keeps its flame and sparks (only the light is off) | B:111, B:105 | RSQFF_Burner.Lamp; BurnTick |
| R18 | The held flare no longer in the off hand, or the player dead: unlit goes back, lit is released where the light was with the pawn's velocity | H:402, H:403, H:406, H:407 | RSQFF_Handler.Keep |
| R19 | A held flare with no state (a new map): lit is used up, unlit goes back to the count | H:397, H:398 | RSQFF_Handler.Keep |
| R20 | The off hand within rsqff_fl_clip_r (0.08 m) of the clip, not in a Rig place, grip pressed: the take event | T:666, T:667, T:669, T:672, C:49 | RSQFF_Torches.Hands |
| R20 | The clip without the Rig: 0.10 m forward, 0.17 m toward the off hand's side, 0.22 m under the eyes | T:697, T:698, T:699, T:700, C:46, C:47, C:48 | RSQFF_Torches.Clip |
| R20 | The take: needs Flashlight on; raised in the off hand; a sound; a buzz; switched on at once (a click) | T:312, T:320, T:322, T:323, T:325, T:360, C:33 | RSQFF_Torches.Take; SetOn |
| R21 | A trigger press with the flashlight out toggles it; a click and a buzz of 0.15 for 2 tics | T:677, T:306, T:350, T:360, T:361 | RSQFF_Torches.Hands; NetworkProcess; SetOn |
| R22 | One spot light at the lens, turned along the flashlight, its intensity the range | T:457, T:499, T:503, T:504, T:509 | RSQFF_Torches.Beam |
| R22 | Quest range 448; Medium 10 and 22 degrees; Warm White FFDCA8 | T:240, T:235, T:257, C:34, C:35, C:36 | RSQFF_Torches.Range; SizeAngles; Rgb |
| R22 | The cone is Beam Length (4 m) long, cut at what one trace meets first (walls, solid actors); Show Cone off removes it | T:559, T:564, T:610, T:541, C:37, C:42 | RSQFF_Torches.Beam; Trace |
| R23 | Grip at the clip with it out: the back event; put away, lights off, the off hand gets back what it had, a sound | T:676, T:305, T:331, T:333, T:334, T:335 | RSQFF_Torches.Hands; NetworkProcess; Back |
| R24 | Taking a flare remembers the weapon the off hand held (the flashlight) and gives it back when the flare leaves | H:230, H:334, H:342 | RSQFF_Handler.Take; OffBack |
| R24 | The flashlight not in the hand any more: put away, remembering whether it was on; back in the hand: as it was | T:440, T:431, T:432 | RSQFF_Torches.Keep |
| R25 | The flashlight's take is refused while the flare handler holds a flare | T:314 | RSQFF_Torches.Take |
| R26 | Capacity rsqff_fl_batt (3) minutes; on, one tic of charge a tic | Y:38, Y:113, C:43 | RSQFF_Battery.CapTics; Tick |
| R26 | The meter: 10 steps, drawn as an overlay on the flashlight while the battery is in use; the last step blinks | Y:57, Y:66, T:77, T:82, T:83 | RSQFF_Battery.Step; Shown; RSQFF_Torch.A_RSQFFTorchReady |
| R26 | Over half: full. Under it the light dims; at steps 1 and 2 the spot's angles narrow and are re-rolled every 5 to 17 tics | Y:128, Y:130, Y:133, Y:134, Y:138, Y:139, Y:142, T:492, T:493, T:494 | RSQFF_Battery.Tick; RSQFF_Torches.Beam |
| R26 | Empty while on: switched off (the click) | Y:119, Y:122 | RSQFF_Battery.Tick |
| R27 | Off, in the hand or on the clip: one tic of charge back a tic | Y:111, Y:114 | RSQFF_Battery.Tick |
| R27 | Under one second of light left it does not switch on: the click alone | Y:45, T:343, T:345, T:347 | RSQFF_Battery.Empty; RSQFF_Torches.SetOn |
| R28 | A monster that counts as a kill, killed by a player whose flashlight is on, inside the beam's reach and outer angle and in sight: KILL_REFILL (5%) | Y:28, Y:185, Y:192, Y:198, Y:199, T:404 | RSQFF_Battery.Died; RSQFF_Torches.WorldThingDied |
| R29 | The charge is stored on the player each tic and a map starts from it | Y:85, Y:115, Y:109, Y:77 | RSQFF_Battery.Store; Tick; Stored |
| R29 | A flashlight in the hand on a new map: in the hand, off | T:429, T:431, T:432 | RSQFF_Torches.Keep |
| R30 | Brutal Doom is the class BDWeaponSpawner or BrutalPistol | F:27 | RSQFF_Fire.BrutalDoom |
| R30 | With it the hit is Fire damage, and a monster that may burn is set burning | F:76, F:74, F:78 | RSQFF_Fire.Hit |
| R30 | The kinds: ZombieMan, ShotgunGuy, ChaingunGuy, WolfensteinSS, DoomImp by class, parent or what it replaces; else a walking monster of radius 21, height 64, 100 health at most | F:46, F:52, F:56 | RSQFF_Fire.Kind |
| R30 | The burn: 175 tics, 3 Fire damage every 6 tics, two flame puffs a tic | F:20, F:21, F:22, F:92, F:137, F:141 | RSQFF_Fire.Ignite; RSQFF_OnFire.DoEffect |
| R30 | A legendary or champion burns only under rsqff_boost_pct (25) percent of its spawn health | F:38, F:63, F:64, C:13 | RSQFF_Fire.Boosted; CanBurn |
| R31 | Light It By: Strike (0): the trigger does not light | H:522 | RSQFF_Handler.Hands |
| R32 | Light It By: Trigger (1): the flick is not read | H:536 | RSQFF_Handler.Hands |
| R33 | Shoot Out Flares on: a burning flare nothing holds is shootable; any damage spends it and it takes none | B:292, B:293, B:258, B:261, B:264, C:12 | RSQFF_Flare.Tick; DamageMobj |
| R34 | Refill Each Level on: at a new map, not a save or a revisited map, each player is topped up to rsqff_pocket_n (4) | H:805, H:807, H:809, H:811, C:17, C:18 | RSQFF_Handler.WorldLoaded |
| R35 | Battery Never Drains on, or Battery (min) 0: the battery is not in use; no drain, no meter | Y:36, Y:104, Y:64, C:44 | RSQFF_Battery.InUse; Tick; Shown |
| R36 | Beam Colour: Random (98): at each switch-on one of the six, never the one it had | T:351, T:355, T:246, C:35 | RSQFF_Torches.SetOn; Six |
| R37 | PCVR range 640, High 896; the two-layer cone and dust on PCVR and High | T:240, T:567, T:574, C:36 | RSQFF_Torches.Range; Beam |
| R38 | Beam Hotspot on: a sprite where the trace lands; the trace runs to 2.5 times the range and the sprite fades past the range | T:582, T:584, T:525, T:593, C:38 | RSQFF_Torches.Beam |
| R39 | Beam Look: DarkDoomZ (1) replaces the colour, angles and range with the type's; Halogen is the default type | D:51, T:484, T:487, D:58, D:67, D:68, C:39, C:40 | RSQFF_DdzLight.On; RSQFF_Torches.Beam; RSQFF_DdzLight.Get |
| R39 | The spill light is a second spot light, with the spill row on; off, one light at the average | D:52, T:513, T:515, D:95, C:41 | RSQFF_DdzLight.Spill; RSQFF_Torches.Beam; RSQFF_DdzLight.Main |
| R39 | Beam Size and Beam Colour are greyed under the DarkDoomZ look | M:48, M:50 | MENUDEF RSQFF_Options |
| R40 | Bones Drop Battery Bits on, a Legion of Bones monster by class name: 8 in 100 one bit, 3 when boosted, asked of RSQ VisualRewards | Y:203, Y:205, Y:30, Y:31, Y:210, Y:159, Y:166, C:45 | RSQFF_Battery.Died; LobLoaded; IsLob |
| R40 | A bit adds 15%: VisualRewards asks "battery.add" with its own share | T:758, VisualRewards/pk3/zscript/rsqvr/batterybit.zs:26 | RSQFF_TorchService.GetInt; RSQ_KRBatteryBit.TryPickup |
| R40 | Only while the battery is in use | Y:185 | RSQFF_Battery.Died |
| R41 | Flares off: the hands are not read; nothing given; nothing scattered or refilled; no flare drawn; a held flare is put away | H:357, H:740, H:805, S:40, H:403, C:3 | RSQFF_Handler.WorldTick; Equip; WorldLoaded; RSQFF_Shown.WorldTick; RSQFF_Handler.Keep |
| R41 | The flashlight has its own switch and its hands are read by its own handler | T:419, T:217 | RSQFF_Torches.WorldTick; FlOn |
| R42 | Flashlight off: its hands are not read; one in the hand is put away | T:419, T:438, T:443 | RSQFF_Torches.WorldTick; Keep |
| R43 | Off Grip Keys: the codes in the text are the grip; the same event drives the pocket and the clip | H:190, H:191, H:197, H:214, T:302, M:123 | RSQFF_Handler.InputProcess; NetworkProcess; RSQFF_Torches.NetworkProcess |
| R44 | The pocket's place and reach, and the clip's, are read from their rows | G:84, G:85, G:86, H:496, T:697, T:698, T:699, T:667, M:129, M:131, M:133, M:135, M:139, M:141, M:143, M:145 | RSQFF_Geo.Pocket; RSQFF_Handler.Hands; RSQFF_Torches.Clip; Hands |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | Tactical Rig "flare.home" 1: the pocket takes nothing, no flare is drawn there, no zone is answered | G:108, G:109, H:495, H:496, S:26, S:27, H:873 | RSQFF_Geo.RigFlareHome; RSQFF_Handler.Hands; RSQFF_Shown.RigHolster; RSQFF_Service.GetDouble |
| W1 | The pocket's rows and the clip's three place rows grey from the Rig's answers | H:362, H:365, H:933, M:129, M:139 | RSQFF_Handler.WorldTick; OptionMenuItemRSQFFRigSlider.IsGrayed |
| W1 | The Rig's flare holster sends this mod's take and back events and refuses a lit flare (the Rig's code) | TacticalRig/zscript/rsqtr/rig.zs:3478, TacticalRig/zscript/rsqtr/rig.zs:3490, TacticalRig/zscript/rsqtr/rig.zs:3300 | RSQTR_Rig.FlarePress; the Rig's grip handling |
| W1 | The clip hangs where the Rig's "torch.x/y/z" says; Reach is still this mod's | G:124, G:126, T:695, T:696, T:667 | RSQFF_Geo.RigTorch; RSQFF_Torches.Clip; Hands |
| W1 | The body's yaw is the Rig's "body.yaw" when it answers | H:625, H:626, T:724, T:725 | RSQFF_Handler.BodyYaw; RSQFF_Torches.BodyYaw |
| W1 | The off hand in a Rig place ("rig.region"): no pocket, no clip | H:612, H:491, H:497, T:713, T:669 | RSQFF_Handler.RigHasHand; Hands; RSQFF_Torches.RigHasHand; Hands |
| W1 | With the Rig loaded a strike waits STRIKE_HOLD (3) tics and is dropped if the hand is in a Rig place | H:108, H:528, H:529, H:535, H:544, H:545 | RSQFF_Handler.Hands |
| W1 | Answers: "flare.phase", "flare.count", "pocket.*" and "clip.*" | H:905, H:906, H:871, H:877 | RSQFF_Service.GetInt; GetDouble |
| W2 | Distance Grab's rule names RSQFF_Flare; the flare is in the blockmap | DistanceGrab/zscript/rsqdg/policy.zs:251, B:235 | RSQDG policy; RSQFF_Flare Default |
| W2 | Its throw asks "flare.hit"; this mod ignites only (no damage of its own) | DistanceGrab/zscript/rsqdg/throw.zs:561, H:895, H:900 | RSQDG throw; RSQFF_Service.GetInt |
| W3 | Gun Cards asks "flare.count", "flare.phase", "torch.phase", "battery" | GunCards/zscript/rsqgc/items.zs:39, GunCards/zscript/rsqgc/items.zs:42, GunCards/zscript/rsqgc/items.zs:77, GunCards/zscript/rsqgc/items.zs:83, H:905, H:906, T:755, T:761 | RSQGC items; RSQFF_Service.GetInt; RSQFF_TorchService.GetInt |
| W4 | "No flares left" goes to RSQVR_Service "toast" first | H:102, H:507 | RSQFF_Handler.Toast; Hands |
| W4 | Battery bits are RSQVR_Service "kr.battery"; a picked-up bit asks "battery.add" | Y:210, T:758, VisualRewards/pk3/zscript/rsqvr/batterybit.zs:26 | RSQFF_Battery.Died; RSQFF_TorchService.GetInt |
| W5 | The Wheel's own icons for RSQFF_Held and RSQFF_Torch; this mod names the same two as inventory icons | Wheel/zscript/wheel/zscript.zs:5513, Wheel/zscript/wheel/zscript.zs:5514, Wheel/zscript/wheel/zscript.zs:5528, Wheel/zscript/wheel/zscript.zs:5529, I:73, T:54 | wr ownBases; ownLump; RSQFF_Held Default; RSQFF_Torch Default |
| W6 | rsqa_rumble_scale scales each buzz; with rsqa_rumble_backup set, RSQA_Service "buzz" is asked as a buzz starts | I:143, I:144, I:150, I:163, I:167, I:177 | RSQFF_Buzzer.Start; RumbleBackup; Tick |
| W7 | The burn asks RSQSM_Service "scale" each tic and runs its clock, damage and flames by it | F:115, F:127, F:128, F:129, F:140 | RSQFF_OnFire.W; DoEffect |
| W8 | RSQ_Hands, by name, when the off hand held nothing before | H:337, H:339, T:381, T:383 | RSQFF_Handler.OffBack; RSQFF_Torches.OffBack |
| W8 | The hand meshes are drawn in model slot 7 with BD22 VR's off-hand Scale and Offset | MODELDEF.txt:18, MODELDEF.txt:20, MODELDEF.txt:21, MODELDEF.torch:15, MODELDEF.torch:17, MODELDEF.torch:18 | MODELDEF RSQFF_Held; RSQFF_Torch |
| W8 | The trigger also from original_cmd | H:475, T:654 | RSQFF_Handler.Hands; RSQFF_Torches.Hands |
| W8 | No Brutal Doom flashlight or key is read: the only bind text matched is +oh_attack, and there is no KEYCONF | H:175, T:292 | RSQFF_Handler.InputProcess; RSQFF_Torches.InputProcess |
| W9 | Brutal Doom: Fire damage and the burn; without it neither | F:27, F:61, F:76 | RSQFF_Fire.BrutalDoom; CanBurn; Hit |
| W10 | LegenDoom and Champions by their token classes; burn under the percent; 3 bits | F:38, F:64, Y:204, Y:205 | RSQFF_Fire.Boosted; CanBurn; RSQFF_Battery.Died |
| W11 | Legion of Bones by LOBDoomImp or ConqCube, its monsters by class name | Y:159, Y:166, Y:203 | RSQFF_Battery.LobLoaded; IsLob; Died |
| W12 | The throw numbers are this mod's own class; the flare's gravity is set on the actor | H:44, H:46, H:47, H:48, B:226 | RSQFF_Fling; RSQFF_Flare Default |
| W13 | The DarkDoomZ look is this mod's file and names no class of DarkDoomZ or Glow In The Dark | D:51, D:54 | RSQFF_DdzLight.On; Get |
| W13 | No row of the page is a Gun Bonsai VR upgrade | M:4 | MENUDEF header |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No KEYCONF in the pk3; the lumps are the event handlers of MAPINFO, CVARINFO and MENUDEF | MAPINFO.txt:5 | GameInfo AddEventHandlers |
| L2 | Out of VR, or dead, the hands' code returns before any take, light, throw or switch | H:484, T:661, G:19 | RSQFF_Handler.Hands; RSQFF_Torches.Hands; RSQFF_Geo.InVR |
| L3 | The only inputs read: the grip keys and the off hand attack (button and bind text) | H:193, H:175, H:475, T:292, T:654 | InputProcess; Hands (both handlers) |
| L4 | Both input handlers return false | H:198, T:293 | InputProcess (both handlers) |
| L5 | Both are off-hand weapons; one of the two at a time | I:74, T:55, T:314 | Defaults; RSQFF_Torches.Take |
| L6 | A lit flare leaves the hand only by the throw, burning out, or the hand being taken or the player dying | H:569, H:416, H:407 | RSQFF_Handler.Hands; Keep |
| L7 | A let-go under the threshold: the only thing done is a debug line | H:566, H:567 | RSQFF_Handler.Hands |
| L8 | The held flare alerts nothing; the thrown flare's own damage is 0; the only damage is the hit and the burn | I:75, B:225, F:76, F:141 | RSQFF_Held Default; RSQFF_Flare Default; RSQFF_Fire.Hit; RSQFF_OnFire.DoEffect |
| L9 | The toggle is tested after the clip tests and needs no place | T:677 | RSQFF_Torches.Hands |
| L10 | Backpack amount 0, backpack maximum 24 | I:16, I:17 | RSQFF_Ammo Default |
| L11 | Scatter spawns RSQFF_Box only; not on a save or a reopened map | H:839, H:805 | RSQFF_Handler.Scatter; WorldLoaded |
| L12 | Further than 96 units from the body's middle: from the body; a wall between: from where the trace stops | H:285, H:292 | RSQFF_Handler.Release |
| L13 | The launch adds the lift and has no cap on the angle | H:591, H:592 | RSQFF_Handler.LaunchVel |
| L14 | The weapon the off hand held before is a field of the handler, which MAPINFO makes per map; with none, RSQ_Hands or nothing | H:116, T:188, MAPINFO.txt:5, H:339, H:344 | RSQFF_Handler; RSQFF_Torches; OffBack |
| L15 | The battery recharges whenever the flashlight is not on; the only other refills are the kill and the bits | Y:114, Y:199, T:758 | RSQFF_Battery.Tick; Died; RSQFF_TorchService.GetInt |
| L16 | The clip's place is read from this machine's settings, for every player | T:697, T:220, S:54 | RSQFF_Torches.Clip; LNum; RSQFF_Shown.WorldTick |
| L17 | SlowMo's speed is asked only by the monster's burn; a flare's burn counts one tic a tic | F:115, B:91 | RSQFF_OnFire.W; RSQFF_Burner.BurnTick |
| L18 | One spot light a flashlight, a spill light under DarkDoomZ; one point light a flare; no shadow maps | T:499, T:515, T:122, D:120, B:132 | RSQFF_Torches.Beam; RSQFF_TorchSpot Default; RSQFF_TorchSpill Default; RSQFF_Burner.Lamp |
