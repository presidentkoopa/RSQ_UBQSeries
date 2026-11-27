# RSQ Whip: where each README claim comes from

Commit read: b95023e8e (2026-11-27). Paths are inside `Whip/`. `W` is `zscript/rsqwp/whip.zs`, `L` is
`zscript/rsqwp/lash.zs`, `S` is `zscript/rsqwp/swing.zs`, `C` is `zscript/rsqwp/core.zs`, `WP` is
`zscript/rsqwp/weapon.zs`, `I` is `zscript/rsqwp/input.zs`, `B` is `zscript/rsqwp/beam.zs`; the other `.zs` files are in
`zscript/rsqwp/` and are named in full. Each line number is the line that does the thing, not the start of its function.
Speeds: the code counts room units a tic; 34 units are a metre and 35 tics a second, so one unit a tic is about 1 m/s.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | The whip is given within a second (checked once every 35 tics) while Whip and Whip in Slot 1 are on; the give never switches to it | W:695, W:702, W:704, KEYCONF.txt:3, WP:49 | RSQWP_Whip.WorldTick2; KEYCONF; RSQWP_WhipWeapon Default |
| H2 | It is an ordinary weapon in slot 1, so slot, next and previous weapon reach it; out of both hands it is flagged for the Whip In hand | WP:24, WP:38, W:1358 | RSQWP_WhipWeapon; RSQWP_Whip.WhipIn |
| H2 | In the hand the whip starts out, coiled: 21 of 25 links on the coil, 4 hanging | WP:170, W:522, W:974, W:975 | RSQWP_WhipWeapon.Tend; RSQWP_Whip.Start |
| H3 | Held in the hand Whip In does not name, it is moved by the engine hand switch, at most once a second | W:1361, W:1363, W:1365 | RSQWP_Whip.WhipIn |
| H4 | Owned and in neither hand, with Show Whip on, the coil is placed at the main hand hip | hip.zs:50, hip.zs:53, hip.zs:56, hip.zs:62 | RSQWP_HipShow.WorldTick |
| H5 | The thong is 25 links of 2.448 units (1.8 m), simulated every tic from the handle; the weapon is readied with no fire | W:35, W:37, W:786, WP:261 | RSQWP_Whip.WorldTick2; RSQWP_WhipWeapon.A_WhipReady |
| H6 | The flick: a peak of 1.6 m/s or more in the last 4 tics and now at 40% of it or less; read against the body, any direction | L:27, L:28, L:29, L:71, L:87, L:90 | RSQWP_Whip.LashTick |
| H6 | The Lash style is the default and replaces the mark and the lock each tic | L:58, W:772, CVARINFO.txt:4 | RSQWP_Whip.LashOn; RSQWP_Whip.WorldTick2 |
| H6 | The target: along the whip hand, within 4.5 m and 14 degrees, in sight, nearest the line; monsters and loose pickups | L:25, L:26, L:138, L:148, L:149, L:157 | RSQWP_Whip.LashCrack |
| H7 | A crack on a monster: the whip hit at tip speed 30 (7 of Damage 12 at default speeds), then 12 more | L:178, L:208, L:209, L:31, W:2977, W:3111 | RSQWP_Whip.LashCrack; LashArrive; Hit; CrackK |
| H7 | The crack puts the monster in its pain state (Stun) and holds it 35 tics; a boss gets no hold from a light crack | W:2995, W:2998, W:3009, W:3058, W:3059 | RSQWP_Whip.Hit; StunTics |
| H8 | A cracked pickup is thrown to the player on an arc and touched when it is within reach of the body; left after 70 tics | L:202, W:3452, W:3428, W:3431 | RSQWP_Whip.LashArrive; Fetch; FetchTick |
| H9 | Nothing in the cone: the thong flies to 4.5 m or 4 units short of the wall, and switches within 32 units are worked | L:186, L:187, L:220, W:3409 | RSQWP_Whip.LashCrack; LashArrive; UseLine |
| H10 | A shot in the cone (a missile whose target is not the player) is taken first: within 2.5 m returned, else cracked | L:147, L:155, L:166, L:167, L:168, W:3170, W:3165 | RSQWP_Whip.LashCrack; ReturnTo; CrackMissile |
| H11 | The sweep: the hand bearing turned 70 degrees over the last 8 tics, mean speed 2 m/s or more, the vertical part no more than 0.6 of the flat | L:32, L:33, L:34, L:105 | RSQWP_Whip.Sweep |
| H11 | Every monster in sight within 2.6 m and 75 degrees of the fan middle: 8 damage, a push (not at mass 1000 or DONTTHRUST), the pain state | L:35, L:36, L:118, L:120, L:123, L:125 | RSQWP_Whip.Sweep |
| H12 | A flick with the whip hand trigger down, still down on arrival, wraps the monster | WP:58, WP:95, L:177, L:210, L:212 | RSQWP_WhipWeapon.TriggerHeld; Tend; RSQWP_Whip.LashCrack; LashArrive |
| H12 | Wrapped, its feet are held where it stood, up to 105 tics; not a boss or a DONTTHRUST monster | L:43, L:228, L:270, L:276, L:278 | RSQWP_Whip.LashHold; Pin |
| H13 | Yank down at 2 m/s: 10 damage, the pain state held 70 tics, the wrap ends | L:39, L:252, L:254, L:255, L:41, L:259 | RSQWP_Whip.LashHold; Flinch |
| H14 | Pull back along the line to it at 2 m/s: the pain state held 35 tics, the wrap ends | L:251, L:262, L:264, L:42 | RSQWP_Whip.LashHold |
| H15 | Trigger up, or further than 1.4 x 4.5 m: the wrap ends | L:228, L:233 | RSQWP_Whip.LashHold |
| H16 | A free outer link moving at 0.45 x Crack Speed (9) or more through a thing stings it: up to a quarter of Damage, once per 12 tics | W:1726, W:1738, W:1756, W:2977, W:2965 | RSQWP_Whip.Collide; Hit |
| H17 | The wind-up: handle up and back with the hand no lower than 14 units under the eyes, 2 tics: the thong stiffens and the coil pays out; a forward swing follows | W:1132, W:1143, W:1053, W:1056, W:1152 | RSQWP_Whip.Deliberate; CoilTic |
| H17 | In the Lash style the physics crack is not run | W:797 | RSQWP_Whip.WorldTick2 |
| H18 | Quiet for 30 tics, the thong goes back to its rest coil | W:988, W:1061, W:1063 | RSQWP_Whip.CoilTic |
| H19 | The lasso: main hand whip only, the off grip (raw key, a grab event, or the engine two-hand latch) with the off controller within Lasso Reach (0.30 m) of the handle or a link | WP:232, W:390, W:394, W:400, W:429 | RSQWP_WhipWeapon.Tend; RSQWP_Whip.OffHandCloses; ReadOffKey |
| H19 | Refused with a gun in the other hand; needs the Lasso row (and its upgrade under Gun Bonsai VR) | WP:237, WP:238 | RSQWP_WhipWeapon.Tend |
| H19 | The held piece is laid from the handle to the off hand, the coil pays out, and the free links are helped round the hand circle | W:1559, W:1054, W:2429, W:1575 | RSQWP_Whip.Sim; CoilTic; Whirl |
| H20 | Let go at a tip speed of 6 or more: it flies flat the way the tip went to the nearest monster within 25 degrees and 4 thong lengths (7.2 m) | W:788, W:1907, W:2461, W:2468, W:2503, W:2489 | RSQWP_Whip.WorldTick2; LassoThrow; LassoReach |
| H20 | In the Lash style the arrival is the Lash crack (hit and 12 more), with no wrap | W:2539, L:170, L:216 | RSQWP_Whip.Reach; LashArrive |
| H21 | The weapon has no shot: Fire and AltFire go to Ready, and Ready allows no fire | WP:261, WP:296, WP:298 | RSQWP_WhipWeapon States |
| H22 | Whip hand alt fire only locks a gold cursor; the cursor is never worked out in the Lash style | WP:79, WP:187, S:245, S:250 | RSQWP_WhipWeapon.AltHeld; Tend; RSQWP_Whip.AimTick |
| H23 | With Lock On Controls on the Whip eats no key of the other hand | W:481, S:167, S:194 | RSQWP_Whip.AimKey; IndyOn; LockWhipOn |
| H24 | Both grips are read by raw key code, sent as a grab event and never eaten | I:31, I:44, I:50, I:51, CVARINFO.txt:48, CVARINFO.txt:49 | RSQWP_Input.GripKeys; InputProcess |
| H25 | Deselect ends the wrap and rolls the whip up; a weapon whip not tended for a tic is removed | WP:286, WP:253, WP:255, W:724, W:727 | RSQWP_WhipWeapon.PutAway; RSQWP_Whip.WorldTick2 |
| H26 | Dead, or Whip off: the whip is halted | W:719 | RSQWP_Whip.WorldTick2 |
| H27 | Whip In: Off Hand: the weapon reads the off hand buttons; the lasso needs hand 0 | W:1352, WP:53, WP:58, WP:232 | RSQWP_Whip.WhipIn; RSQWP_WhipWeapon.Hand; TriggerHeld; Tend |
| H28 | Hand on the Handle off: the weapon shows no hand model and the world handle piece is drawn | WP:273, W:3556 | RSQWP_WhipWeapon.A_WhipLook; RSQWP_Whip.Draw |
| H29 | Classic with Lock On Controls: the ray is held by the whip hand all the time; gold only on a ceiling or a wall within Whip Reach; pale otherwise | WP:112, S:264, S:302, S:341, S:407, S:410, S:139 | RSQWP_WhipWeapon.Tend; RSQWP_Whip.AimTick; DrawAim; SwingReachM |
| H30 | Classic crack: armed, the tip at Crack Speed or more, 6 or fewer links still coiled for a tic, the hand behind it; it lands at the peak | W:2814, W:738, W:2811 | RSQWP_Whip.Lash; WorldTick2 |
| H30 | It hits the nearest thing within Aim Reach (40) of the tip in sight, works switches in that reach and fetches pickups within 1.5 x it | W:3314, W:3355, W:3359, W:3362 | RSQWP_Whip.Crack |
| H31 | Lock On Controls: a trigger press latches the mark, a second press moves it on; nothing is held | WP:175, WP:179, WP:180, WP:218 | RSQWP_WhipWeapon.Tend |
| H31 | The mark: monsters and pickups within 20 degrees and Whip Reach, nearest first; keys, powerups and switches within 70 degrees first; a diamond and a gold ray | W:1901, W:1902, W:1968, W:1950, W:2025, W:1385, W:1401 | RSQWP_Whip.Mark; UpdateMark |
| H32 | A crack with a mark flies to it over 5 tics: a monster is hit as a crack, a pickup fetched, a switch worked | W:3287, W:3294, W:2573, W:2560, W:2596 | RSQWP_Whip.Crack; Reach |
| H33 | Alt fire on a gold cursor locks the spot, again unlocks; a crack then casts to it and the hook latches | WP:186, WP:189, S:485, S:494, W:2538, S:559 | RSQWP_WhipWeapon.Tend; RSQWP_Whip.SwingCast; Reach; SwingLatch |
| H34 | Crack at Gold: no lock needed; a mark wins; a living monster on the line gets an ordinary crack | S:450, S:451, S:477 | RSQWP_Whip.SwingCast |
| H35 | Catch Edges: a fast link of the outer third on an edge more than Snag Edge Height (16) above the hand, or a crack within 12 units of one, becomes the rope | W:1727, W:1768, W:3327, W:2698, W:3484, W:3489 | RSQWP_Whip.Collide; Crack; WrapNear; Snag |
| H36 | Jump starts a waiting rope: up to Jump Lift, plus Jump Push where the player faces | S:699, S:742, S:758, S:620 | RSQWP_Core.SwingStart; SwingInput |
| H37 | The grip start: an aimed rope, the off grip edge, the off hand empty and within 0.5 m of the whip hand or the rope; then the assist lift and speed | S:701, S:608, S:727, S:685, S:690 | RSQWP_Core.SwingStart; GrabAssist |
| H38 | On a rope the whip hand trigger, a fresh press, is the reel: Reel Speed a tic down to Shortest Rope | WP:131, WP:152, C:471, C:426, C:453 | RSQWP_WhipWeapon.Tend; RSQWP_Core.Swing; ReelFull |
| H39 | Jump, a fresh press on a rope not waiting on the ground, lets go; the speed is kept on landing | WP:143, WP:151, WP:156, C:134, C:132 | RSQWP_WhipWeapon.Tend; RSQWP_Core.LetGo; Carry |
| H40 | In the air on a taut rope the movement stick pushes the swing, tangent only, by Stick Lean | C:607, C:608, C:615 | RSQWP_Core.Swing |
| H41 | The arm pump: the whip hand moving away from the anchor by more than 1 a tic adds up to 0.8 along the swing | W:2862, W:2863, W:2864, W:2865 | RSQWP_Whip.ArmPump |
| H42 | Use held on a rope is the whip hand hold; a hold needs the hand within Grab Reach (16) of the rope line; the body moves by the hand step, capped at Climb Speed Cap (8) | S:630, S:637, climb.zs:41, C:802, C:828, C:829, C:601, C:792 | RSQWP_Core.SwingInput; RSQWP_Climb.HandFree; RSQWP_Core.Climb; Swing |
| H43 | A grip key down with an empty hand (nothing, a fist) in reach takes the hold; key up lets go | I:175, C:681, C:800, C:803, climb.zs:36, climb.zs:49, C:687 | RSQWP_Input.NetworkProcess; RSQWP_Core.Grab; Climb; RSQWP_Climb.HandFree |
| H44 | The touch hold: an armed, strictly empty hand in reach, 0.3 m out along the rope, under 0.4 m/s over 6 tics; let go at 2 x the reach | C:709, C:710, C:711, C:712, C:730, C:772, C:781, C:757 | RSQWP_Core.TouchTick |
| H45 | The mantle: a rope on a wall with a floor beyond; reeled or climbed to the lip, or a held hand within 20 units of the anchor; thrown up, the rope let go | W:2908, W:2928, W:2881, W:2935, W:2940, W:2947 | RSQWP_Whip.Mantle |
| H46 | The Leash: a marked crack landing with the trigger down, Leash and Whip Pulls Monsters on; too heavy is an anchor, else it slides in at 10 a tic | W:2581, W:2582, W:2583, W:2675, W:2679, W:2686, monster.zs:48, C:351 | RSQWP_Whip.Reach; Leash; RSQWP_Monster.Slide; RSQWP_Core.TooHeavy |
| H47 | Classic: a thrown lasso wraps the monster for 70 tics whatever Crack Wraps Monsters says; a lasso wrap flails | W:2586, W:2590, W:1903, W:2213, W:2333, W:2345, W:2365 | RSQWP_Whip.Reach; BeginWrap; FlailOn; Flail |
| H48 | Crack Wraps Monsters (off): on, a marked crack on a monster wraps it | W:3051, CVARINFO.txt:13 | RSQWP_Whip.CrackWraps |
| H49 | The yank: the hand going away from the monster at 1.5 or more, then slower; light flies in, medium part way, heavy swings the player | W:1904, W:2114, W:2132, W:2153, W:2154, W:2161, W:2181 | RSQWP_Whip.HoldWrap; Yank |
| H50 | Crack Fireballs (off): for 8 tics after a crack, an outer-third link passing a monster missile explodes it | W:3281, W:799, W:3129, W:3132, W:3140 | RSQWP_Whip.Crack; WorldTick2; Swat |
| H51 | Hit Stop (off): a cracked monster is frozen 3 + 3 x hardness tics | W:276, W:3020, W:3021 | RSQWP_Whip.HitStopOn; Hit |
| H52 | The rope buttons by setting: Jump Lets Go; else Fire Lets Go (trigger lets go, alt fire reels); else the trigger reels and alt fire lets go | WP:141, WP:142, WP:151, WP:152 | RSQWP_WhipWeapon.Tend |
| H53 | Lock On Controls off: the mark is held by the trigger; alt fire with it moves the mark | WP:222, WP:223 | RSQWP_WhipWeapon.Tend |
| H54 | Lock On Controls off: keys bound to +oh_altatk (whip in main) or +altattack (whip in off), and +oh_attack with a free off hand, are eaten and aim the ray from the other hand | W:482, W:483, W:485, W:492, W:496, W:476, WP:73 | RSQWP_Whip.AimKey; RSQWP_WhipWeapon.AimBy |
| H55 | The console events: rsqwp_press starts a whip in that hand with no weapon; rsqwp_release rolls it up; KEYCONF binds neither | I:71, I:94, C:96, W:351, KEYCONF.txt:5 | RSQWP_Input.ConsoleProcess; RSQWP_Core.Fire; RSQWP_Whip.NetworkProcess |
| H56 | rsqwp_reset is a console alias that sets the listed settings | KEYCONF.txt:9 | KEYCONF |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ Wheel: found by service name; while it answers IsOpen for the console player the ray, the diamond and the mark are not drawn, and their state is kept | B:83, B:88, B:95, B:43, S:406, W:1382 | RSQWP_Whip.WheelOpen; BeamHidden; BeamDots; DrawAim; UpdateMark |
| X2 | RSQ Tactical Rig: the hip coil is hidden while the Rig is on, in VR, and its service says the whip is in holster 11; RSQWP_Stowed is the coil model both use | hip.zs:40, hip.zs:33, hip.zs:35, hip.zs:69, WP:306 | RSQWP_HipShow.RigDraws; WorldTick |
| X2 | A whip that comes into a hand while still out is laid out again from that hand | WP:92, WP:171 | RSQWP_WhipWeapon.Tend |
| X3 | RSQ Distance Grab: its rsqdg_press and rsqdg_release events are taken as the rope grip (Grab Keys Grip Rope); that hold also closes the lasso | I:184, I:185, W:390 | RSQWP_Input.NetworkProcess; RSQWP_Whip.OffHandCloses |
| X4 | RSQ Grapple and RSQ Laser Sight: named only in the shared menu order; no class, service or setting of theirs is read | rsmenu.zs:89 | RSQWP_RSMenu.Rank |
| X5 | The whip weapon is flagged a melee weapon | WP:45 | RSQWP_WhipWeapon Default |
| X6 | RSQ SlowMo: its scale is read each tic; the leash slide and the flail step are multiplied by it | util.zs:133, util.zs:137, C:196, monster.zs:48, W:2348 | RSQWP_Util.WorldScale; RSQWP_Core.WorldTick; RSQWP_Monster.Slide; RSQWP_Whip.Flail |
| X7 | RSQ Gun Bonsai VR: found by service; its loaded answer and each whip upgrade level are read once a second | W:246, W:248, W:251, W:256, W:238 | RSQWP_Whip.GbRefresh |
| X7 | Whip damage is dealt inside its credit bracket for the whip weapon | fx.zs:183, fx.zs:186 | RSQWP_Perks.Hurt |
| X7 | A gated row needs its upgrade learned and the row on; the menu greys it while it is not learned; Cracked Fireballs is always greyed | W:272, service.zs:45, service.zs:47, rsmenu.zs:356, MENUDEF.txt:122, MENUDEF.txt:104 | RSQWP_Whip.Unlock; RSQWP_Service.GetIntUI; OptionMenuItemRSQWPGbOption.IsGrayed; MENUDEF |
| X7 | Its Kill Rewards bits (a class name starting rsq_kr) are never a target | S:235 | RSQWP_Whip.NotATarget |
| X8 | RSQ Score: found by service; a touch with an id is sent before the blow | W:311, W:312, L:207, W:2981, W:3025, W:2247, W:2283, W:2169, W:2173, C:403, W:3171, W:3201 | RSQWP_Whip.Touch and its callers |
| X9 | RSQ Accessibility is read only while its menu class is loaded: the colour blind palette on the ray and the mark | cb.zs:21, S:407, W:1392 | RSQWP_CB.Mode; RSQWP_Whip.DrawAim; UpdateMark |
| X9 | Cue Size on the diamond; Rumble Strength and Rumble Backup on the pulses | W:1384, W:3523, W:3633 | RSQWP_Whip.UpdateMark; Buzz; RSQWP_WhipBuzz.Tick |
| X9 | Steady Hands for the ray and the mark; Gesture Ease on the rope reach; the comfort vignette on a rope; the Off Hand Modifier; high contrast on the rope | util.zs:89, W:1942, S:298, C:731, C:216, a11y.zs:83, hook.zs:167 | RSQWP_Util.AimPos; RSQWP_Whip.Mark; AimTick; RSQWP_Core.TouchTick; WorldTick; RSQWP_A11y.Ctrl; RSQWP_Hook.DrawRope |
| X10 | RSQ Miniboss: a monster carrying its ward is held as a boss is; with its bossfor yank answer it is too heavy | W:3057, util.zs:45, util.zs:49, C:351, W:2145 | RSQWP_Whip.StunTics; RSQWP_Util.MinibossAs; RSQWP_Core.TooHeavy; RSQWP_Whip.Yank |
| X11 | RSQ VisualRewards: a service whose name holds RSQTHP_Marker answers whipped (and hooked) with 1 for a wrapped or tied monster | W:3717, W:3722, W:3728, W:3729 | RSQTHP_MarkerWhip.GetInt |
| X12 | MK Crits: with its csh_Brain class and csh_critical_enabled, a crack of hardness 0.5 or more adds the rest of its factor as Critical damage with its sound and effect | W:3063, W:3064, W:3066, W:2990, W:3094 | RSQWP_Whip.MkOn; Hit; MkCrit |
| X13 | BD22 VR and Brutal Doom: rsq_hands showing its closed fist, melee_attacks, Fist and any melee CHEATNOTWEAPON weapon are a free hand for the rope; the damage type is Whip | climb.zs:44, climb.zs:47, climb.zs:49, climb.zs:50, W:2205 | RSQWP_Climb.HandFree; RSQWP_Whip.DmgType |
| X14 | RSQ Saber and RSQ Melee: ubqs_forcehand, rsq_glove and rsq_gloveoff count as an empty hand | S:154 | RSQWP_Whip.FreeHand |
| X15 | RSQWP_Service answers by name; -1 when it has nothing | service.zs:34, service.zs:55, service.zs:255, service.zs:256, service.zs:257, service.zs:258, service.zs:259, service.zs:260, service.zs:266, service.zs:271, service.zs:272, service.zs:273, service.zs:274, service.zs:275, service.zs:276 | RSQWP_Service.GetInt; RSQWP_Events.Answer |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| M1 | KEYCONF holds one slot line and one alias; no bind, no key section | KEYCONF.txt:3, KEYCONF.txt:5, KEYCONF.txt:9 | KEYCONF |
| M2 | Whip off: nobody is given it, the weapon tends nothing, a whip out is halted | W:695, WP:87, W:719 | RSQWP_Whip.WorldTick2; RSQWP_WhipWeapon.Tend |
| M3 | Lash style: no ray, no mark, no edge snag, no physics crack (so no cast, no rope) | S:245, W:773, W:1727, W:797, W:3283 | RSQWP_Whip.AimTick; WorldTick2; Collide; Crack |
| M4 | The flick reads speed only; a lash at most every 8 tics | L:79, L:30, L:81 | RSQWP_Whip.LashTick |
| M5 | The Lash numbers are constants | L:25, L:37, L:40, L:44 | RSQWP_Whip (lash.zs) |
| M6 | A Lash crack is thrown at 30: hardness (30 - 20) / (43 - 20) = 0.43; the heavy sound, the 50 tic hold and the MK crit need 0.5 | L:178, W:3110, W:3509, W:3008, W:2990 | RSQWP_Whip.LashCrack; CrackK; Noise; Hit |
| M7 | The parry searches with a blockmap iterator; the code notes a projectile is NOBLOCKMAP and no iterator finds it | L:142, W:145 | RSQWP_Whip.LashCrack; RSQWP_Whip (field note) |
| M8 | Players are skipped as targets; hits carry no thrust unless Knockback is on | L:146, hook.zs:405, W:2986 | RSQWP_Whip.LashCrack; RSQWP_Tracer.TraceCallback; RSQWP_Whip.Hit |
| M9 | The lasso: hand 0 only, and not beside a gun | WP:232, WP:237 | RSQWP_WhipWeapon.Tend |
| M10 | Too heavy for the leash: a boss, DONTTHRUST, mass at Too Heavy From or more, dormant | C:349, C:351 | RSQWP_Core.TooHeavy |
| M11 | The rope lets go after 3 failed sight checks, when its anchor check fails, or on death | C:649, C:443, C:208 | RSQWP_Core.Swing; WorldTick |
| M12 | The sweep pushes only under mass 1000 and without DONTTHRUST | L:123 | RSQWP_Whip.Sweep |
