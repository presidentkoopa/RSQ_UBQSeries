# RSQ Whip: where each README claim comes from

Code read: the working tree of 2026-11-27 (the owner's two moves, over commit e2b60912e; lash.zs as committed in 402571918, which has the touch sent to RSQ Score: rows H12b and X4). Paths are inside `Whip/`.
`W` is `zscript/rsqwp/whip.zs`, `L` is `zscript/rsqwp/lash.zs`, `WP` is `zscript/rsqwp/weapon.zs`; the other `.zs` files
are in `zscript/rsqwp/` and are named in full. Each line number is the line that does the thing, not the start of its
function. Speeds: the code counts room units a tic; 34 units are a metre and 35 tics a second, so one unit a tic is
about 1 m/s.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | The whip is given within a second (checked once every 35 tics) while Whip and Whip in Slot 1 are on; the give never switches to it | W:323, W:330, W:332, KEYCONF.txt:3, WP:27 | RSQWP_Whip.WorldTick2; KEYCONF; RSQWP_WhipWeapon Default |
| H2 | It is an ordinary weapon in slot 1, so slot, next and previous weapon reach it; out of both hands it is flagged for the Whip In hand | WP:16, KEYCONF.txt:3, W:927 | RSQWP_WhipWeapon Default; RSQWP_Whip.WhipIn |
| H2 | In the hand the whip starts out, coiled: 21 of 25 links on the coil, 4 hanging | WP:48, W:199, W:558, W:559 | RSQWP_WhipWeapon.Tend; RSQWP_Whip.Start |
| H3 | Held in the hand Whip In does not name, it is moved by the engine hand switch, at most once a second | W:930, W:932, W:934 | RSQWP_Whip.WhipIn |
| H4 | Owned and in neither hand, with Show Whip on, the coil is placed at the main hand hip | hip.zs:50, hip.zs:53, hip.zs:62 | RSQWP_HipShow.WorldTick |
| H5 | The thong is 25 links of 2.448 units (1.8 m), simulated every tic from the handle; its sweeps ignore every actor; the weapon is readied with no fire | W:25, W:27, W:387, W:1196, WP:63 | RSQWP_Whip.WorldTick2; Collide; RSQWP_WhipWeapon.A_WhipReady |
| H6 | The Wide Swing's test: the hand's bearing turned 70 degrees over the last 8 tics, mean speed 2 m/s or more, the vertical part no more than 0.6 of the flat | L:29, L:30, L:31, L:142 | RSQWP_Whip.Sweep |
| H6 | Every monster in sight within 2.6 m and 60 degrees of the swing's middle: 8 damage, a push, the pain state; the light crack | L:32, L:33, L:34, L:35, L:154, L:155, L:156, L:158, L:161, L:162, L:165, W:1341 | RSQWP_Whip.Sweep; Stagger; Noise |
| H7 | A Wide Swing that hit at least one asks RSQ SlowMo for 500 ms | L:38, L:167, L:84 | RSQWP_Whip.Sweep; AskSlow |
| H8 | The Ground Crack's test: the fastest downward tic of the last 4 at 1.6 m/s or more, more down than across, the hand now at 40% of that tic's speed or less | L:24, L:25, L:26, L:186, L:188, L:189 | RSQWP_Whip.GroundCrack |
| H8 | Where it lands: the hand's line traced 4.5 m; a floor hit is the spot, else the floor straight under the line's end (4 units short of a wall) | L:28, L:200, L:203, L:207, L:210, L:212 | RSQWP_Whip.GroundCrack |
| H9 | The thong flies 5 tics and lands: the heavy crack, sparks, a ring | L:213, W:1261, W:1294, L:229, L:230, L:231, W:1342, fx.zs:23 | RSQWP_Whip.GroundCrack; Reach; GroundImpact; Noise; RSQWP_Looks.Ring |
| H9 | Living hostile monsters in sight within 3 m of the spot: up at 10 units a tic, pushed outward, the pain state; no damage is dealt | L:39, L:40, L:242, L:245, L:247, L:253, L:254, L:256 | RSQWP_Whip.GroundImpact |
| H10 | A boss, DONTTHRUST or mass 1000 or more: only the pain state | L:36, L:250, L:256 | RSQWP_Whip.GroundImpact |
| H11 | A monster with no gravity is pushed, not lifted | L:253, L:254 | RSQWP_Whip.GroundImpact |
| H12 | An impact that caught at least one asks RSQ SlowMo for 1000 ms | L:41, L:259 | RSQWP_Whip.GroundImpact |
| H12b | Each monster the shockwave catches is told to RSQ Score by name: the touch ground.crack, with the player's number (Score's 2 s and its "in the air" are Score's own: Score/zscript/rsscore/hook.zs RS_Bonus_GroundCrack) | L:237, L:249 | RSQWP_Whip.GroundImpact |
| H13 | The hand is measured in the world's axes; the tic the tracking space turned, or the pawn's angle stepped over 20 degrees, is skipped with every sample, and no move starts for 8 tics | L:102, L:42, L:108, L:110, L:111, L:123, W:481 | RSQWP_Whip.LashTick; TrackFrame |
| H14 | The wind-up: handle up and back with the hand no lower than 14 units under the eyes, 2 tics: the thong stiffens and the coil pays out; a forward swing follows | W:702, W:676, W:677, W:713, W:721, W:623 | RSQWP_Whip.Deliberate; CoilTic |
| H15 | Quiet for 30 tics, the thong goes back to its rest coil | W:570, W:631, W:633 | RSQWP_Whip.CoilTic |
| H16 | The weapon has no shot and reads no button: Fire and AltFire go to Ready, and Ready allows no fire | WP:63, WP:98, WP:100 | RSQWP_WhipWeapon States |
| H17 | Deselect ends a flight and rolls the whip up; a weapon whip not tended for a tic is removed | WP:88, WP:57, WP:58, W:346 | RSQWP_WhipWeapon.PutAway; RSQWP_Whip.WorldTick2 |
| H18 | Dead, or Whip off: the whip is halted | W:341 | RSQWP_Whip.WorldTick2 |
| H19 | Whip In: Off Hand: the weapon is kept in the off hand | W:921, W:930, WP:31 | RSQWP_Whip.WhipIn; RSQWP_WhipWeapon.Hand |
| H20 | Hand on the Handle off: the weapon shows no hand model and the world handle piece is drawn | WP:75, W:1388 | RSQWP_WhipWeapon.A_WhipLook; RSQWP_Whip.Draw |
| H21 | rsqwp_reset is a console alias that sets the listed settings | KEYCONF.txt:9 | KEYCONF |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ SlowMo: found by service name and asked "start" with the reason "whip", the milliseconds and speed 0 (its own speed row) | L:78, L:84, L:167, L:259 | RSQWP_Whip.AskSlow; Sweep; GroundImpact |
| X2 | RSQ Tactical Rig: the hip coil is hidden while the Rig is on, in VR, and its service says the whip is in holster 11; RSQWP_Stowed is the coil model both use | hip.zs:40, hip.zs:32, hip.zs:34, hip.zs:35, hip.zs:69 | RSQWP_HipShow.RigDraws; WorldTick |
| X2 | A whip that comes into a hand while still out is laid out again from that hand | WP:42, WP:49 | RSQWP_WhipWeapon.Tend |
| X3 | RSQ Gun Bonsai VR: the swing's damage is dealt inside its credit bracket for the whip weapon | fx.zs:62, fx.zs:65, L:158 | RSQWP_Perks.Hurt; RSQWP_Whip.Sweep |
| X3 | Its loaded answer and the LongThong level are read once a second; the thong is 1 + 0.25 a level long | W:129, W:135, W:143, W:183 | RSQWP_Whip.GbRefresh; LongK; Start |
| X4 | RSQ Score: the damage type is Whip; the touch ground.crack for each monster a shockwave catches; Whipped is called before the swing's damage and for each monster a shockwave catches | W:1330, L:237, L:249, L:157, L:248, service.zs:51, service.zs:56, service.zs:116 | RSQWP_Whip.DmgType; Sweep; GroundImpact; RSQWP_Events.Whipped; Answer |
| X5 | RSQ Accessibility: Rumble Strength and Rumble Backup on the pulses; the Off Hand Modifier | W:1355, W:1461, util.zs:52, a11y.zs:81 | RSQWP_Whip.Buzz; RSQWP_WhipBuzz.Tick; RSQWP_Util.Ctrl; RSQWP_A11y.Ctrl |
| X6 | RSQ VisualRewards: a service whose name holds RSQTHP_Marker answers 0 to everything | W:1473, W:1477 | RSQTHP_MarkerWhip.GetInt |
| X7 | The other mods are named only in the shared menu order; no class, service or setting of theirs is read. The whip weapon is flagged a melee weapon | rsmenu.zs:84, WP:23 | RSQWP_RSMenu.Rank; RSQWP_WhipWeapon Default |
| X8 | RSQWP_Service answers by name: whipped from the record; the fixed answers for the names of what went | service.zs:27, service.zs:110, service.zs:111, service.zs:113, service.zs:116, service.zs:117, service.zs:118 | RSQWP_Service.GetInt; RSQWP_Events.Answer |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| M1 | KEYCONF holds one slot line and one alias; no bind, no key section; the weapon is readied with no fire | KEYCONF.txt:3, KEYCONF.txt:9, WP:63 | KEYCONF; RSQWP_WhipWeapon.A_WhipReady |
| M2 | Whip off: nobody is given it, the weapon tends nothing, a whip out is halted | W:323, WP:37, W:341 | RSQWP_Whip.WorldTick2; RSQWP_WhipWeapon.Tend |
| M3 | The two moves' numbers are constants | L:24, L:29, L:38 | RSQWP_Whip (lash.zs) |
| M4 | A move at most every 8 tics, none while a flight is under way, none in the 8 tics after the whip starts in a hand | L:27, L:123, W:187 | RSQWP_Whip.LashTick; Start |
| M5 | The Ground Crack reads only the hand's speed down and its stop | L:186, L:188, L:189 | RSQWP_Whip.GroundCrack |
| M6 | The swing's level test; the fan is measured from the swing's middle | L:142, L:145, L:155 | RSQWP_Whip.Sweep |
| M7 | The shockwave: sight from the player, friendly monsters skipped; the swing's filter has no friendly test | L:247, L:242, L:152 | RSQWP_Whip.GroundImpact; Sweep |
| M8 | The swing pushes only under mass 1000 and without DONTTHRUST | L:161 | RSQWP_Whip.Sweep |
| M9 | Slow motion is asked only when the count of monsters reached is above 0 | L:167, L:259 | RSQWP_Whip.Sweep; GroundImpact |
| M10 | The thong's sweep ignores actors; both moves skip players | W:1196, L:152, L:242 | RSQWP_Whip.Collide; Sweep; GroundImpact |
