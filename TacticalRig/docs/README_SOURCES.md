# RSQ Tactical Rig: where each README claim comes from

Commit read: 13e1ae4b9 (2026-11-27). Paths are inside `TacticalRig/`. The script files are in `zscript/rsqtr/`:
`R` is `rig.zs`, `C` is `cig.zs`, `B` is `body.zs`, `K` is `keyring.zs`, `HK` is `hooks.zs`, `G` is `ghost.zs`,
`M` is `mirror.zs`, `MB` is `mirrorbody.zs`, `V` is `vest.zs`, `D` is `dualkey.zs`, `GC` is `gestcopy.zs`,
`A` is `a11y.zs`, `CB` is `cb.zs`, `F` is `fit.zs`, `VN` is `vanilla.zs`. Other files are named in full. Each line
number is the line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | The six gun holsters; a ring shows within 2.5 radii, only to a hand that could act there, the nearest full and the others at 35%; inside it is a size larger in the "inside" colour; entering ticks the hand | R:876, R:3634, R:3641, R:3653, R:3654, R:3900, R:3901, R:2685, CVARINFO.txt:10 | RSQTR_Rig.IsGunRegion; RingMode; HandAlpha; RingAlpha; DrawMarkers; WorldTick |
| H2 | The grip arrives as raw key codes and is sent as an event; grip or Use is a press; it counts once the hand has been inside Press Delay tics; a gun in the main hand is filed in the holster and assigned to it; the hand gets its empty-hand weapon; one pulse and the holster sound | R:732, R:736, R:2694, R:2695, R:2756, R:2765, R:3417, R:2386, R:2387, R:925, R:2404, R:953, R:2406, CVARINFO.txt:5, CVARINFO.txt:6, CVARINFO.txt:29 | RSQTR_Rig.InputProcess; WorldTick; Press; Holster; Assign; StoreDrawFeel |
| H3 | An empty main hand at a full holster draws its gun; the holster is emptied; one pulse and the draw sound | R:3420, R:3422, R:2444, R:2448, R:952, R:2451 | RSQTR_Rig.Press; Draw; StoreDrawFeel |
| H4 | The off hand holsters the gun it holds or draws into itself; an off hand gun is one moved there or BD22 VR's off hand version; the emptied off hand goes to the pack's hands weapon or nothing | R:3399, R:3401, R:3404, R:3406, R:2063, R:2117, R:2119, R:1913, R:1915, R:1935 | RSQTR_Rig.Press; HolsterOff; DrawOff; IsMovedGun; EmptyOff |
| H5 | Use presses for the off hand only while the main hand is in no place | R:2695 | RSQTR_Rig.WorldTick |
| H6 | The grip key is never eaten | R:738 | RSQTR_Rig.InputProcess |
| H7 | Quick Swap: a gun in the hand at a full holster skips the press delay; a gun assigned elsewhere goes into its own holster and this holster's gun comes to the hand; a streak runs to the home holster | R:2758, R:2759, R:2345, R:2347, R:1411, R:2352, R:1404, CVARINFO.txt:106 | RSQTR_Rig.WorldTick; Holster; LockedHome |
| H8 | An unassigned gun at another gun's full holster, mode To Wheel: the holster's gun comes to the hand, the held gun is filed nowhere | R:2309, R:2333, R:2335, R:996, CVARINFO.txt:105 | RSQTR_Rig.Holster; SwapMode |
| H9 | An assigned gun at another, empty holster goes home; nothing comes out, the hand goes empty | R:2345, R:1411, R:2360 | RSQTR_Rig.Holster; LockedHome |
| H10 | An unassigned gun at an empty holster another gun owns takes it over: the ring shows the assignment and the old owner's assignment is replaced | R:910, R:2312, R:2317, R:2387, R:926, R:927 | RSQTR_Rig.MayTakeOver; Holster; Assign |
| H11 | An empty hand at an empty holster: the refusal, a double pulse and the use-fail sound | R:3425, R:1106, R:958, R:959, B:787, B:788 | RSQTR_Rig.Press; EmptyRefused; RefuseFeel; RSQTR_Buzzer.Refuse |
| H12 | A press in an empty gun holster whose gun is in no hand and not coming arms the hold; held 35 tics, the holster is unassigned with a white flash and the old owner's picture; a carried gun in no hand is put back by the HOME rule, so only a gun no longer carried leaves its holster empty | R:2750, R:2752, R:2840, R:2847, R:2853, R:2854, R:1392, R:1849, R:1856 | RSQTR_Rig.WorldTick; FreeTick; WebUnassign; ReconcileTick |
| H13 | An assigned gun that is owned, in neither hand, not coming and in no holster goes back into its own empty holster after 10 tics | R:1810, R:1849, R:1853, R:1856 | RSQTR_Rig.ReconcileTick |
| H14 | A holster whose gun is settled in a hand lets go of it after 3 tics; the assignment stays | R:1811, R:1834, R:1836, R:1839 | RSQTR_Rig.ReconcileTick |
| H15 | A press in no place counts at the shoulder holster the hand was in within the last 10 tics | R:2760, R:2787, R:2796, R:2805 | RSQTR_Rig.WorldTick; ShoulderGrace |
| H16 | With the ring showing, a full holster has a light: green half a magazine or more, yellow low or empty with reserve, red nothing, the red one pulsing; an arc in twelfths shows the fill | R:3919, R:3921, R:3509, R:3510, R:3932, R:3555, R:3588, CVARINFO.txt:108 | RSQTR_Rig.DrawMarkers; AmmoState; DrawAmmoArc |
| H17 | A stored gun is drawn only if the fit table has it; hips muzzle down, chest cross-draw, shoulders on the back | R:3961, R:3981, R:3995, R:4187, R:4189, R:4191, CVARINFO.txt:11 | RSQTR_Rig.DrawMarkers; Hang |
| H18 | The grenade spot is live with a grenade weapon and Grenade Spot on; a press by either hand sends the grenade to the main hand; none left is refused; the light counts 2+, 1, 0; a grenade hangs there | R:3244, R:1472, R:1475, R:3289, R:1524, R:3292, R:3921, R:4166, CVARINFO.txt:109 | RSQTR_Rig.RegionLive; NadeWeapon; Press; Nade; DrawMarkers; DrawNade |
| H19 | With the grenade in the main hand, the press brings back the gun held before | R:1511, R:1517 | RSQTR_Rig.Nade |
| H20 | With Keyring on and a key carried, up to 8 keys hang in a fan from a ring at place 8 and sway; the keyring's side is toward the off hand | K:264, K:268, K:14, K:280, K:294, K:277, R:305, CVARINFO.txt:114 | RSQTR_Keyring.WorldTick; RSQTR_Rig.Settings |
| H21 | Main hand within 0.08 m of the pocket: its grip, or Use with none out, takes a cigarette (a weak tick with none left); the count drops, the cigarette is raised in the main hand and the Zippo queued for the off hand; the pocket is on the layout's left chest | C:438, C:442, C:443, C:874, C:884, C:885, C:246, C:69, C:70, C:71, CVARINFO.txt:77 | RSQTR_Cig.WorldTick; NetworkProcess; Pocket |
| H22 | The main grip at the pocket with the cigarette in the hand puts it back and refunds it | C:446, C:973 | RSQTR_Cig.WorldTick; PutBack |
| H23 | Use with the cigarette in the mouth zone, or within 10 tics of leaving it, puts it in the mouth; the main hand gets its gun; entering the zone gives a tick and a sound | C:88, C:91, C:93, C:465, C:468, C:912, C:915, C:916, C:515, C:516 | RSQTR_Cig.WorldTick; NetworkProcess |
| H24 | Use with the cigarette in the hand anywhere else flicks it | C:468, C:923 | RSQTR_Cig.WorldTick; NetworkProcess |
| H25 | While a cigarette is out the engine's use is held off and the rig's Use press is off | C:888, C:1024, R:2621 | RSQTR_Cig.NetworkProcess; Steps; RSQTR_Rig.WorldTick |
| H26 | Off hand fire with the Zippo in the hand and the flame not at the tip flicks it open or shut | C:503, C:506, C:930 | RSQTR_Cig.WorldTick; NetworkProcess |
| H27 | Off hand fire with the flame within 0.10 m of the mouth cigarette lights it; the smoke lasts Smoke Time; then it is spat; on that tic the SlowMo pulse is sent with Slow Mo Time and Slow Mo Speed, if Smoke Slows Time is on | C:104, C:502, C:506, C:961, C:962, C:1071, C:1185, C:527, C:531, CVARINFO.txt:78, CVARINFO.txt:79, CVARINFO.txt:81 | RSQTR_Cig.WorldTick; NetworkProcess; Steps; Spit |
| H28 | Use while smoking spits it now, with the slow time | C:476, C:480, C:951 | RSQTR_Cig.WorldTick; NetworkProcess |
| H29 | The main grip with the main hand at the mouth and an unlit cigarette in it takes it back into the hand | C:484, C:487, C:943, C:944 | RSQTR_Cig.WorldTick; NetworkProcess |
| H30 | Unlit in the mouth for Unlit Time: it drops, is not refunded, no slow time | C:1078, C:1079, C:1082, C:1085, CVARINFO.txt:87, CVARINFO.txt:88 | RSQTR_Cig.Steps |
| H31 | A key whose binding holds weapnext, weapprev, switchhand or "slot " ends the ritual; so does any hand switch; so does a grip at a place; unlit goes back, lit is spat with slow time; next and previous are worked out from the gun held before | C:617, C:627, C:631, C:1051, C:1056, C:1058, C:818, C:819, C:699, R:3272, R:3274 | RSQTR_Cig.InputProcess; Steps; EndBySwitch; NextFrom; RSQTR_Rig.Press |
| H32 | A butt from the mouth smoulders; it lies 10 to 30 seconds and alerts monsters to itself every second | C:1164, C:1527, C:1543 | RSQTR_Cig.Flick; RSQTR_ButtLying.BeginPlay; Tick |
| H33 | Both hands within 0.20 m of a point 0.12 m forward and 0.30 m under the eyes for 14 tics, with no grip, Use, fire or alt fire held, recenters: the body's yaw is the head's, a click and a tick in both hands | R:3065, R:3066, R:3067, R:3068, R:3081, R:3090, R:3091, R:3093, R:3096, R:3104, R:3106, R:3107, CVARINFO.txt:37 | RSQTR_Rig.RecenterTick; DoRecenter |
| H34 | Recenter Torso is an alias for a network event with no default bind; the event recenters | KEYCONF.txt:3, KEYCONF.txt:5, R:789 | KEYCONF alias; RSQTR_Rig.NetworkProcess |
| H35 | The body's yaw moves by the tracking space's turn; with snap turning, by the snap | B:87, B:512, B:516 | RSQTR_Body.Update; RSQTR_TurnKeeper.Step |
| H36 | With Torso Catches Up off the head's yaw alone never turns the body; the nod is taken out of the anchor | B:98, B:340, B:342, B:330, CVARINFO.txt:33, CVARINFO.txt:35 | RSQTR_Body.Update; NeckShift; At |
| H37 | Head more than 45 degrees off the torso for 52 tics, no hand busy or reaching, not looking down past Ignore Looking Down: the torso eases to the head | B:147, B:148, B:90, B:166, B:173, B:178, B:184, B:187, CVARINFO.txt:36 | RSQTR_Body.Update; RoomFollow |
| H38 | Eye height unset, standing profile, not seated, head within 2 cm for 70 tics: the calibration event is sent; the scale is the eye height over 1.62 m, clamped 0.7 to 1.3 | R:2873, R:2875, R:2878, R:2879, R:2882, R:774, R:452 | RSQTR_Rig.AutoHeight; NetworkProcess; BodyScale |
| H39 | The menu's Measure Height sends the same event; a headset height of 0.8 to 2.3 m is stored and printed, else "stand up straight" | MENUDEF.txt:76, R:765, R:772, R:775, R:777 | MENUDEF command; RSQTR_Rig.NetworkProcess |
| H40 | The torso shows with Torso on; style 0 is the marine; blue skin for blue armour; it thins from 12 degrees of pitch to 0.53; under Low Health Glow a red copy pulses | V:34, V:42, V:56, V:66, V:101, V:106, CVARINFO.txt:95, CVARINFO.txt:96, CVARINFO.txt:100, CVARINFO.txt:101 | RSQTR_Torso.WorldTick |
| H41 | With the rig and the torso on, the pawn's sprite is hidden in mirrors and each modelled weapon layer gets a mirror-only copy; the helmet is mirror-only and worn with the marine | MB:97, MB:104, MB:131, MB:179, V:77, V:171, CVARINFO.txt:102 | RSQTR_MirrorBody.WorldTick; RSQTR_HeldShow; RSQTR_Torso.WorldTick; RSQTR_HelmetPart |
| H42 | Until a gun has been holstered by hand: after 70 tics holding a gun, a ghost hand loops to a target holster (the main hand's hip first) and its ring is forced visible; without the hand mesh only the ring; a gun put in by hand ends it for good | G:27, G:53, G:56, G:65, G:86, G:91, G:128, G:129, G:155, G:183, R:799 | RSQTR_Ghost.Tick; Target; ForceRing; ByHand; RSQTR_Rig.NetworkProcess |
| H43 | At tic 350 of a map, once ever, with Recenter by Hands on, the recentre tip prints for 5 seconds | R:2887, R:2894, R:2896, R:2897 | RSQTR_Rig.RecentreTip |
| H44 | Three misses on one place in 210 tics: its ring shows full for 105 tics, at most 3 hints a map | R:2909, R:2910, R:2911, R:2912, R:2986, R:2996, R:3883 | RSQTR_Rig.StruggleMove; DrawMarkers |
| H45 | A new map, a loaded save and a respawn unprime the body; an unprimed body takes the head's yaw | R:4285, R:4373, R:3115, B:83 | RSQTR_Rig.WorldLoaded; OnRegister; PlayerRespawned; RSQTR_Body.Update |
| H46 | Every holster's content and owner are copied to a static handler each tic and taken back on a new level with Keep Between Levels on; a holster's content counts only while the gun is owned | R:4326, R:4309, R:4313, R:4314, R:1763, CVARINFO.txt:107 | RSQTR_Rig.TickLoadout; RestoreLoadout; Content |
| H47 | Dead: the rig is off and everything is hidden; a cigarette out is ended with no refund | R:2610, R:2614, C:1026, C:1032, C:1033 | RSQTR_Rig.WorldTick; RSQTR_Cig.Steps |
| H48 | The menu's Save and Load send profile events; Save writes every place's four numbers and sets the active profile; Load sets them back and sets it; the idle ring frame follows the active profile | MENUDEF.txt:250, MENUDEF.txt:258, R:783, R:829, R:830, R:853, R:858, R:3596, R:3901 | MENUDEF commands; RSQTR_Rig.NetworkProcess; Profile; MarkerFrame; DrawMarkers |
| H49 | Saber spots are live only with RSQ Saber's class; the main saber's spot is on the main hand's side and answers the main hand only; the saber held goes in, else the saber there is drawn | R:3243, R:521, R:561, R:3366, R:3368, R:3431, R:3443 | RSQTR_Rig.RegionLive; Owned; SaberHome; Press |
| H50 | The second saber's spot is the other one, while the Saber's own switches allow a second saber; its press sends the Saber's own in or out event | R:520, R:576, R:3378, R:3381 | RSQTR_Rig.Owned; SecondSaberAllowed; Press |
| H51 | A saber at an empty place that is not its own is sent to its own spot | R:3352, R:3356, R:3358, R:3344, R:3346 | RSQTR_Rig.Press |
| H52 | The whip holster is live with RSQ Whip and Whip Holster on; only the whip's hand works it, draw or put away; the whip's hand is the one holding it, else the Whip's own setting; a whip at an empty gun holster goes home | R:3246, R:3453, R:3455, R:3460, R:1876, R:1885, R:638, R:641, R:3324, R:3326, CVARINFO.txt:61 | RSQTR_Rig.RegionLive; WhipPress; WhipApply; WhipHand; Press |
| H53 | The flare holster is live with RSQ FnF and Flare Holster on; off hand only; an unlit flare goes back, none carried is refused, else one is taken | R:3247, R:621, R:3470, R:3478, R:3483, R:3485, R:3490, CVARINFO.txt:62 | RSQTR_Rig.RegionLive; FlareHolsterOn; FlarePress |
| H54 | A lit flare in the off hand: that hand's press at any place is refused | R:3300, R:3302 | RSQTR_Rig.Press |
| H55 | A press in the pouch returns with no action; the pouch is live with Ammo Pouch on and BD22 VR's hands class; it eases at most 0.035 m toward the off hand | R:3313, R:663, R:392, R:413, R:423, CVARINFO.txt:65, CVARINFO.txt:66 | RSQTR_Rig.Press; PouchOn; PouchReach |
| H56 | With Keys Open Doors on: a grip within the keyring's radius takes the keys into that hand until the grip has been up 5 tics; the main hand within 0.12 m of a locked line sends the door event; the door is activated as a use, in reach of the body | K:94, K:104, K:106, K:114, K:26, K:129, K:133, K:253, K:254, CVARINFO.txt:117 | RSQTR_Keyring.KeysTick; NetworkProcess |
| H57 | Keys bound to +oh_attack and +oh_altatk are read by binding text and eaten while the off hand holds the keys; off hand fire uses the nearest locked line within 0.25 m | K:55, K:56, K:63, K:64, K:118, K:43, K:181, K:185 | RSQTR_Keyring.InputProcess; KeysTick; OffKeys |
| H58 | Off hand alt fire at a locked line starts a lift: through Distance Grab's events when it is loaded and the door is one it lifts, else a raise of 0.12 m sends the door event | K:190, K:196, K:201, K:217, K:44, K:221, K:224 | RSQTR_Keyring.OffKeys |
| H59 | A grip press outside every place, with Throw Guns on and the hand's ground speed at Throw Speed or more, throws the gun: it is dropped as a pickup, its holster's assignment cleared unless Boomerang Gun, the hand emptied | R:2712, R:2713, R:2719, R:203, R:1568, R:1570, R:1560, R:1562, CVARINFO.txt:111, CVARINFO.txt:112 | RSQTR_Rig.WorldTick; SwingPeak; ThrowGun |
| H60 | The main hand also throws on a Use press with Throw With Use on | R:2712, CVARINFO.txt:113 | RSQTR_Rig.WorldTick |
| H61 | A thrown gun is watched for 70 tics; a hit does speed squared times weight times 0.2 times the multiplier, 1 to 60; pain, at least 3 frozen tics, a shove; the gun's speed is cut to -0.2 | R:1621, R:1624, R:1671, R:1673, R:1677, R:1678, R:1680, R:1688, CVARINFO.txt:115 | RSQTR_Rig.ArmThrown; ThrownTick |
| H62 | Swap At Holster on Take Holster: the held gun is assigned to the holster reached and goes in; the gun there comes to the hand | R:2308, R:2324, R:2378, R:2396, MENUDEF.txt:50 | RSQTR_Rig.Holster |
| H63 | With Move Gun at Watch on: a hand's watch check answer of 2 is noted; a Use press within 8 tics, with no hand in a place, moves that hand's gun across, or swaps | R:2141, R:2202, R:2203, R:2205, R:2210, R:2230, R:2248, R:2257, R:2262, CVARINFO.txt:7 | RSQTR_Rig.WatchMove; WatchMoveApply |
| H64 | Seated on: the rig's anchor is the seated eye, the highest the headset has been lately | B:275, B:278, B:279, B:329, CVARINFO.txt:39 | RSQTR_Body.UpdateSeat; At |
| H65 | Save and Load set the active profile; with profile 3 or 4 active, the hips and belt spots still at their standing defaults take the seated defaults; the seated note prints once ever | R:830, R:858, R:319, R:130, R:327, R:329, R:3042, R:3046 | RSQTR_Rig.Profile; SeatedDefaults; SeatedTip |
| H66 | With Move Holsters by Hand on, a press in a place carries it with the hand; release saves its three offsets and prints them; the loop skips every other press; the rings are drawn as Always | R:2729, R:2733, R:2734, R:2738, R:2741, R:3226, R:3229, R:3633, CVARINFO.txt:25 | RSQTR_Rig.WorldTick; SaveEdit; RingMode |
| H67 | The mirror shows with mode 2, or mode 1 while Move Holsters by Hand is on; it stands Mirror Distance ahead; view 2 shows front and back side by side; it copies each ring, each stored item and both hands | M:254, M:256, M:257, M:272, M:289, M:129, M:130, M:157, CVARINFO.txt:26, CVARINFO.txt:27, CVARINFO.txt:28 | RSQTR_Mirror.WorldTick; RSQTR_MirrorView.Update |
| H68 | With Ammo Count on and the ring showing, the gun's rounds are drawn as digits above the ring | R:4250, R:4252, R:4260, CVARINFO.txt:118 | RSQTR_Rig.AmmoCount |
| H69 | With Quick Swap off the swap waits the Press Delay like any press | R:2756, R:2758, R:2765, CVARINFO.txt:106 | RSQTR_Rig.WorldTick |
| H70 | Head and Hands Turn passes its switch to the keeper; Torso Catches Up reads Body Turn Angle and Body Turn Delay and eases the yaw | B:93, B:98, B:99, B:100, B:118, B:120, B:123, CVARINFO.txt:34, CVARINFO.txt:35 | RSQTR_Body.Update |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ Wheel: assign and unassign events carry the gun's name; an assigned gun in a hand stays there, else it is filed in the holster; the unassign clears owner and content | R:796, R:797, R:1354, R:1359, R:1392, R:1393 | RSQTR_Rig.NetworkProcess; WebAssign; WebUnassign |
| X1 | The rig answers the Wheel: the gun's holster, the holster's owner, and the mirror drawn on the web's panel | HK:148, HK:175, HK:214, HK:233, M:237 | RSQTR_RigService.GetInt; GetString; RSQTR_Mirror.WebShow |
| X2 | RSQ ShieldSaw (class SSQ_ShieldSaw, its mount spot 0, Shoulder for Shield on): the off shoulder is its holster; a gun there is refused; a gun that had it loses it; the web cannot assign it; while the shield is stowed there the place is claimed | HK:57, HK:58, HK:62, HK:63, R:2303, R:1382, R:1343, HK:41, HK:80, R:3250 | RSQTR_Hooks.ShieldHolster; Claimed; ShieldOnShoulder; RSQTR_Rig.Holster; ShieldTick; WebAssign; RegionLive |
| X2 | The body's heading and a recenter are answered by name | B:750, B:759, B:760 | RSQTR_BodyService.GetDouble |
| X3 | RSQ Saber (class UBQS_Saber): the spots are live; its dual switches gate the second saber; its Show setting hides stored sabers | R:3255, R:575, R:576, R:3977 | RSQTR_Rig.SaberLoaded; SecondSaberAllowed; DrawMarkers |
| X4 | RSQ Whip (class RSQWP_WhipWeapon): the whip is no gun to the holsters; its hand setting is read; its stowed model shows by its own Show setting | R:614, R:626, R:1898, R:640, R:4064, R:4066 | RSQTR_Rig.HomeWhip; HoldsGun; WhipHand; DrawStowed |
| X5 | RSQ FnF (class RSQFF_Held, its on switch, its service): take and back events; the rig answers that the flares' home is the holster, and where the flashlight clip hangs; rings at the pocket and clip FnF reports | R:616, R:622, R:655, R:3478, R:3490, R:502, HK:99, R:496, HK:200, R:3748, R:4029 | RSQTR_Rig.FlareLoaded; FlareHolsterOn; FlareAsk; FlarePress; FlareHome; TorchAt; ClutterPass; DrawFnFMarkers; RSQTR_RigService |
| X6 | RSQ Grenade (class RSQGN_Grenade, ammo RSQGN_Ammo): handed out when Brutal Doom's is absent, or stands down for it; the light takes the kind's colour | R:1470, R:1475, R:1477, R:1483, R:1426, R:3935, R:3939 | RSQTR_Rig.NadeWeapon; NadeAmmo; KindColour; DrawMarkers |
| X7 | Brutal Doom: HandGrenades and GrenadeAmmo at the spot; a Dual weapon goes in as its single gun | R:1435, R:1436, R:1474, R:2287, R:2299, R:2473 | RSQTR_Rig.NadeWeapon; Holster; SingleOf |
| X8 | BD22 VR Reloaded: RSQ_Hands is the empty off hand; RSQ_BD22OffhandService names a copy's gun | R:2502, R:1922, R:1924 | RSQTR_Rig.OffEmptyName; MainOf |
| X8 | The pouch is live with RSQ_Hands; the axe's empty holster hands out an axe while the count has a spare, and is unassigned at 0 | R:663, R:1010, R:1025, R:1027, R:1067, R:1083, R:1091 | RSQTR_Rig.PouchOn; HandsBack; HomeGun; AxePool; AxeTick |
| X8 | A launcher open for loading takes the grenade spot's press; the Dual key's token is caught when only the off hand holds a gun, and the main hand is given the gun | R:3282, R:686, D:44, D:47, D:60, D:121, D:122 | RSQTR_Rig.Press; LauncherLoading; RSQTR_DualCatch.HandlePickup; DoEffect; Apply |
| X9 | RSQ SlowMo: the pulse event and the smoke's own event with the full speed flag | C:531, C:536 | RSQTR_Cig.WorldTick |
| X9 | DOWN is asked by name; a low view height squeezes the places above the floor; a revive gives one cigarette up to the carry | R:2929, R:368, R:369, R:381, HK:250, HK:263 | RSQTR_Rig.IsDown; DownLift; RSQTR_RSQDownJoin.GetInt |
| X10 | RSQ Score: its score earns cigarettes by Score Per Cigarette; Gun Toss and Boomerang touches; the draw tic and class are answered | C:359, C:362, C:366, R:1674, R:1750, HK:123, HK:239, CVARINFO.txt:84 | RSQTR_Cig.CigEarn; RSQTR_Rig.ThrownTick; Arrive; RSQTR_RigService |
| X11 | RSQ Miniboss: a dead monster it calls a boss gives one cigarette; its call-in takes the watch press | C:388, C:393, C:394, R:2161, R:2217 | RSQTR_Cig.WorldThingDied; RSQTR_Rig.BossfightCallReady; WatchMove |
| X12 | Gun Bonsai VR: levels asked once a second; Smoker adds 2 s a level and invulnerability; Chain Smoker adds to the pack | R:243, R:244, R:249, R:252, C:1188, C:1192, C:1202, C:179 | RSQTR_Rig.GbRefresh; RSQTR_Cig.Spit; SmokeSecs; WorldLoaded |
| X12 | Gun Toss multiplies the hit and lengthens the freeze; Boomerang Gun keeps the holster at the throw, returns the gun after a hit, to a holster or (level 2) the main hand | R:1670, R:1671, R:1678, R:1549, R:1558, R:1687, R:1728, R:1739, R:1743 | RSQTR_Rig.ThrownTick; ThrowGun; StartReturn; Arrive |
| X13 | RSQ Accessibility is found by its class RSQA_Menu; Handedness sets the layout's side | A:27, B:372, B:375, C:246, R:305, R:4183 | RSQTR_A11y.Cv; RSQTR_Body.LayoutLeft; RSQTR_Cig.Pocket; RSQTR_Rig.Settings; Hang |
| X13 | Seated Play; Rumble Strength and Rumble Backup; Text Size; colour blind ring frames; photosensitive ember and flame | B:275, A:104, B:798, A:95, B:822, R:4258, A:61, R:3600, R:3602, C:1362, C:1421 | RSQTR_Body.UpdateSeat; RSQTR_Buzzer.Start; Tick; RSQTR_Rig.AmmoCount; MarkerFrame; RSQTR_CigProp.SetLit; RSQTR_ZippoProp.Tick |
| X13 | The watch check is asked of RSQG_Service first | R:2146, R:2148 | RSQTR_Rig.GestureInspect |
| X14 | RSQ Gun Cards' copy of the reader is asked next, then the rig's own, which stands down while RSQG_Service exists | R:2150, R:2151, R:2153, GC:154 | RSQTR_Rig.GestureInspect; RSQTR_GCopy.WorldTick |
| X15 | RSQ Distance Grab: a hand holding one of its doors is busy; the keys drive its door grab, lift and release events | HK:139, HK:141, K:196, K:201, K:217, K:167 | RSQTR_RigService.GetInt; RSQTR_Keyring.OffKeys; EndLift |
| X16 | RSQ VisualRewards: a short message is offered as a toast first | R:141, R:143, R:3293 | RSQTR_Rig.Toast; Press |
| X17 | RSQTR_NadeService: its nade.weapon and nade.ammo are asked first | R:1448, R:1456, R:1491 | RSQTR_Rig.NadeService; NadeWeapon; Grenades |
| X18 | Every lump named RSQTRFIT and RSQTRLAY is read | F:27, MB:44 | RSQTR_Fit.Load; RSQTR_LayerTable.Load |

## What the rig answers

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| S1 | rig.region: the hand's place, the local player only | HK:93, R:273 | RSQTR_RigService.GetInt; RSQTR_Rig.HoverRegion |
| S2 | rig.busy: in a place, at the cigarette pocket, the cigarette in the main hand, the off hand while one is out, a door held | HK:125, HK:128, HK:132, HK:136, HK:137, HK:141 | RSQTR_RigService.GetInt |
| S3 | rig.holster: the whip's own place while home; else the place whose content is that gun, read through its main name | HK:163, HK:169, HK:173, HK:175 | RSQTR_RigService.GetInt |
| S4 | rig.locked, rig.lockable, rig.profile | HK:145, HK:148, HK:150, HK:154, HK:157, HK:161 | RSQTR_RigService.GetInt |
| S5 | rig.drawtic and rig.drawn, per hand | HK:120, HK:123, HK:237, HK:239 | RSQTR_RigService.GetInt; GetString |
| S6 | pouch.at, nade.at, flare.home | HK:103, HK:107, HK:113, HK:117, HK:96, HK:99, R:668, R:680 | RSQTR_RigService.GetInt; RSQTR_Rig.PouchAt; NadeAt |
| S7 | rig.regionname and the thirteen names; rig.owner; rig.claim; mirror.web | HK:206, R:32, HK:208, HK:214, HK:218, HK:222, HK:229, HK:233 | RSQTR_RigService.GetString |
| S8 | region.x / .y / .z and torch.x / .y / .z, 1e9 when unknown | HK:188, HK:192, HK:194, HK:196, HK:199, HK:201 | RSQTR_RigService.GetDouble |
| S9 | RSQTR_BodyService: body.yaw and body.recenter, 999 when unknown | B:746, B:750, B:753, B:759, B:760 | RSQTR_BodyService.GetDouble |
| S10 | RSQTR_GCopyService: reader, inspect, inspect.tics, inspect.any; -1 while the series reader is loaded | GC:292, GC:298, GC:300, GC:302, GC:303, GC:304 | RSQTR_GCopyService.GetInt |
| S11 | RSQTR_RSQDownJoin: down.revive | HK:246, HK:250, HK:263 | RSQTR_RSQDownJoin.GetInt |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | The rig runs only alive, with Tactical Rig on and real hand poses; otherwise all is hidden and the hands' places are forgotten | R:2610, R:2614 | RSQTR_Rig.WorldTick |
| L2 | The local loop is the console player's; rig.region answers only for that player | R:2601, HK:92, HK:93 | RSQTR_Rig.WorldTick; RSQTR_RigService.GetInt |
| L3 | The empty-hand weapon is no gun; an off hand weapon counts only if not an off hand weapon by default, or a BD22 VR copy | R:1899, R:1900, R:1913, R:1915 | RSQTR_Rig.HoldsGun; IsMovedGun |
| L4 | Things with their own home are never assigned and may not enter a gun holster | R:895, R:896, R:897, R:914, R:924 | RSQTR_Rig.OwnHome; MayEnter; Assign |
| L5 | A stored gun not in the fit table is not drawn; the rig carries rows and holders for Doom's own guns | R:3961, F:71, VN:15, VN:22 | RSQTR_Rig.DrawMarkers; RSQTR_Fit.Find; RSQTR_VH classes |
| L6 | The grip key codes are settings with defaults 446 and 443 436; the note about 446 | R:727, R:728, CVARINFO.txt:8, CVARINFO.txt:9 | RSQTR_Rig.InputProcess |
| L7 | weapnext and weapprev are read in one place, the cigarette's key handler | C:627, C:629 | RSQTR_Cig.InputProcess |
| L8 | In edit mode the hand loop continues before any holster press | R:2741 | RSQTR_Rig.WorldTick |
| L9 | The keyring is hovered only in edit mode; its grip is read only with Keys Open Doors on | R:2650, K:94 | RSQTR_Rig.WorldTick; RSQTR_Keyring.KeysTick |
| L10 | The queued off hand raise waits for the two-hand latch and for the main hand's switch | R:2550, R:2558, R:2563 | RSQTR_Rig.TickPairs |
| L11 | A pocket found on a new level is topped up only with Refill Each Level; a new pocket takes what was left | C:181, C:186, C:1677, CVARINFO.txt:86 | RSQTR_Cig.WorldLoaded; RSQTR_CigKeep.Left |
| L12 | A thrown gun is tracked 70 tics; players are skipped outside deathmatch | R:1624, R:1642, R:1656 | RSQTR_Rig.ArmThrown; ThrownTick |
| L13 | The short lines print only with Messages on | R:3293, R:1110, R:3439, R:3487, R:3109, CVARINFO.txt:18 | RSQTR_Rig.Press; EmptyRefused; FlarePress; DoRecenter |
| L14 | The key section has one key and no default bind | KEYCONF.txt:3, KEYCONF.txt:4, KEYCONF.txt:5 | KEYCONF |
