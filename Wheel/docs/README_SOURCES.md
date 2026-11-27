# RSQ Wheel: where each README claim comes from

Commit read: 1a846b85c (2026-11-27). Paths are inside `Wheel/`. `Z` is `zscript/wheel/zscript.zs`, `W` is
`zscript/wheel/wr_web.zs`, `S` is `zscript/wheel/wr_q_shim.zs`; other files are named in full. Each line number is the
line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Open Wheel is the left stick click; pressing it opens the ring on the Opens On hand | KEYCONF:35, Z:818, Z:1090 | KEYCONF defaultbind; wr_Rig.NetworkProcess; wr_Rig.pressWheel |
| H1 | Letting go of the key takes nothing; the ring stays up | Z:1094, Z:1098 | wr_Rig.pressWheel |
| H2 | Taking a slot card opens the slot and the ring stays up; BACK returns | Z:10640, Z:3898, Z:10676 | wr_Rig.pressWheel; wr_Rig.navigate; wr_Rig.gatherWeaponCards; wr_Rig.commit |
| H4 | A press while the ring is up closes it; with a slot open it goes back to the slots | Z:1085, Z:1072, Z:1076 | wr_Rig.pressWheel |
| H5 | A second press within the double tap time closes the ring and gives the last picking hand its earlier gun | Z:1083, Z:1086, Z:1177, CVARINFO.txt:128 | wr_Rig.pressWheel; wr_Rig.swapToPrevious |
| H5b | With the ring up, Use and the grenade keys (+use, +user1, rsqgn_quickthrow) are taken and do nothing | Z:964, Z:966 | wr_Rig.InputProcess |
| H5c | The stick lights no card | Z:9171 | wr_Rig.WorldTick |
| H5d | The data sheet shows the gun for the pointing hand when either hand picks | Z:1498 | wr_Rig.refreshSheet |
| H5e | No reach in, no pull, no throw back: the touch radius is 0 and tickPhysical is not called | Z:9210, Z:9238 | wr_Rig.WorldTick |
| H6 | Opening stops the world while Time While Open is Frozen (the default); closing starts it again | Z:4773, Z:4774, Z:4776, Z:4785, CVARINFO.txt:102 | wr_Rig.bulletTime |
| H7 | The player is frozen while the ring is up | S:1260, Z:1307, Z:1405 | wr_VR.SuppressVRInput; wr_Rig.openRig; wr_Rig.holdStill |
| H8 | Either hand points: a ray from the hand finds the card; the other hand takes over when it is on a card and the first is not | Z:9147, Z:9131, Z:9133 | wr_Rig.WorldTick |
| H8 | The lit card grows, steps toward the eye and ticks in the pointing hand | Z:7393, Z:7421, Z:10430 | wr_Rig.layout; wr_Rig.updateHover |
| H9 | Fire of either hand on a lit card takes it into the pointing hand; the press is consumed | Z:1002, Z:1003, Z:1037, Z:867, Z:11043 | wr_Rig.InputProcess; wr_Rig.NetworkProcess; wr_Rig.commitAs |
| H17 | Off hand alt fire on a card picks it for the off hand and keeps the ring up, always (no switch since 2026-11-27); it goes by the off hand's own beam | Z:9159, Z:979, Z:982, W:369, W:370, Z:11058 | wr_Rig.WorldTick; wr_Rig.InputProcess; wr_Rig.webAlt; wr_Rig.commitAs |
| H18 | Main hand alt fire on a card without the Rig's service is a dull tick | W:339, W:341 | wr_Rig.webAlt |
| H19 | The fist card gives the picking hand its own fist, and gives the fist if the player had none | Z:10823, Z:10880, Z:5632 | wr_Rig.resolvePick; wr_Rig.commitAs; wr_Rig.ensureFistCards |
| H20 | A gun with nothing loaded, in reserve or for alt fire is not taken: dry click, ring closes | Z:10887, Z:10891, Z:1156 | wr_Rig.commitAs; wr_Rig.noAmmo |
| H21 | Picking the other hand's gun (or BD22 VR's version of it there: the same card, cardOf) takes a free numbered copy, else swaps the two hands, each in that hand's version; an empty hand hands over its fist (rig 2026-11-27) | Z:11010, Z:11013, Z:11038, Z:11052 | wr_Rig.commitAs |
| H22 | Fire or alt fire on the data sheet is consumed and sends a page event that does nothing with one page | Z:1014, Z:1016, Z:1017, Z:754 | wr_Rig.InputProcess; wr_Rig.pageCount |
| H23 | With nothing lit the ring counts down from Folds After, fades and ticks once inside the warning time, then closes | Z:1298, Z:9041, Z:9045, Z:9048, Z:9050, Z:7374 | wr_Rig.openRig; wr_Rig.WorldTick; wr_Rig.layout |
| H24 | Turned more than Ring Follows Past from the ring, the ring swings round | Z:7145, Z:7150, CVARINFO.txt:86 | wr_Rig.layout |
| H25 | A key whose binding is exactly weapnext or weapprev (with " 1": off hand) steps that hand through its guns with ammo, in slot order | W:305, W:309, W:312, W:314, W:443, W:512, Z:949 | wr_Rig.webCycleKey; wr_Rig.webCycle; wr_Rig.webCycleTick; wr_Rig.InputProcess |
| H25b | Skip Holstered Guns on: a gun with a holster is left out of next / prev, and the cards it reaches wear the gold light; off, no card wears it | W:196, W:208, W:209, CVARINFO.txt:110, MENUDEF.txt:143 | wr_Rig.webInRotation; wr_Rig.webState |
| H26 | Ring closed: a hand pointed at a floor weapon within Inspect Within for the rest time shows its sheet at that hand | Z:7893, Z:7929, Z:7933, Z:7948, Z:7988, Z:8048 | wr_Rig.tickInspect |
| H27 | Death and level exit close the ring at once | Z:3594, Z:3593, Z:9008 | wr_Rig.PlayerDied; wr_Rig.WorldUnloaded; wr_Rig.WorldTick |
| H28 | With fans on, 7 tics on a card, or Use at range, opens the slot's fan | Z:3854, Z:10375, Z:10382, Z:988, Z:992, Z:11054 | wr_Rig.gatherWeaponCards; wr_Rig.updateHover; wr_Rig.InputProcess |
| H29 | Fire held on a fan card drags it; moved onto another place the slot order is saved; not moved, it is a pick | Z:1039, Z:1041, Z:837, Z:4183, Z:4202, Z:855 | wr_Rig.InputProcess; wr_Rig.NetworkProcess; wr_Rig.tickDrag; wr_Rig.dragTo |
| H31 | Wrist card pose: hand 5 to 17 units from the eye, within 35 degrees of the view, pointing more than 55 degrees off it, held for the dwell, ring closed, Wrist Card on | zscript/wheel/wr_q_watch.zs:44, :47, :50, :66, :71, CVARINFO.txt:115 | wr_Watch.watching; wr_Watch.WorldTick |
| H32 | With Two Hands Compare on, the other hand's ray on a different gun's card swaps the sheet for the comparison | Z:9368, Z:9403, CVARINFO.txt:119 | wr_Rig.tickTwoHand |
| H33 | Wrist roll times Wrist Roll Spin is added to every card's bearing | Z:7206, Z:7404, CVARINFO.txt:234 | wr_Rig.layout |
| H34 | Opens On chooses the hand the ring opens on | Z:1189, Z:1090, CVARINFO.txt:262 | wr_Rig.opensOnHand; wr_Rig.pressWheel |
| H35 | With Either Hand off the hand does not switch and the gun goes to the ring's hand | Z:1184, Z:9118, Z:10680 | wr_Rig.eitherHand; wr_Rig.WorldTick; wr_Rig.commit |
| H36 | Time While Open on Slow asks RSQ SlowMo; with no SlowMo service the ring stops the world instead; on Normal nothing is done | Z:4773, Z:4799, Z:4805, Z:4810, Z:4825, Z:4826 | wr_Rig.bulletTime |
| H37 | Open at Level Start opens the ring on the first live tic of a map | Z:8947, Z:8953, CVARINFO.txt:231 | wr_Rig.WorldTick |
| H38 | The four toggle aliases have no key; each opens the ring or closes it | KEYCONF:38, KEYCONF:39, KEYCONF:40, KEYCONF:46, Z:809, Z:810, Z:811, Z:813, Z:1209 | KEYCONF aliases; wr_Rig.NetworkProcess; wr_Rig.toggle |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X2 | RSQ SlowMo (RSQSM_Service): rsm_on on open, rsm_off on close, only with Time While Open on Slow; Close Ends Slow Time decides for slow time already running | Z:4799, Z:4805, Z:4810, Z:4815 | wr_Rig.bulletTime |
| X3 | RSQ Tactical Rig (RSQTR_RigService): HOLSTER row | Z:1803, Z:1806, Z:1807 | wr_Rig.seriesRows |
| X3 | Holster web: opens on main hand alt fire, assign and unassign events, Mirror view, draw wins over next / prev | W:353, W:406, W:415, W:680, W:856, W:496 | wr_Rig.webAlt; wr_Rig.webPick; wr_Rig.webOpenFor; wr_Rig.webLayout; wr_Rig.webCycleTick |
| X4 | Gun Bonsai rows from RSQGB_Service, else RSQ_MeleeUpgradeService | zscript/wheel/wr_q_bonsai.zs:50, :53, :60, :62, Z:1819, Z:1821, Z:1809 | WR_Bonsai.Entry; wr_Rig.bonsaiRows; wr_Rig.seriesRows |
| X5 | RSQ Gun Cards: card colour setting, weapon condition, watch card stands the Wheel's down | zscript/wheel/wr_q_gunlook.zs:48, Z:5903, zscript/wheel/wr_stats.zs:321, :326, Z:2685, Z:2689, zscript/wheel/wr_q_watch.zs:59, :60 | wr_GunLook.GunColour; wr_Rig.cardColorFor; wr_Stats.GunCardsCondition; wr_Rig.statRows; wr_Watch.WorldTick |
| X6 | RSQ Laser Sight: with the ring up every hand points from the hand itself (ringRay), never Laser Sight's line, and the ring draws its own beam on every hand | Z:8921, Z:9147, Z:9163, S:1320 | wr_Rig.ringRay; wr_Rig.WorldTick; wr_VRState.WorldTick |
| X7 | RSQ Grenade (RSQGN_Service, class RSQGN_Grenade): fan of kinds, kind set on pick, main hand home | Z:4420, Z:4497, Z:4532, Z:10868, Z:10760 | wr_Rig.GrenadeKinds; wr_Rig.expandSlot; wr_Rig.commitAs; wr_Rig.homeHandOf |
| X8 | RSQ ShieldSaw (class SSQ_ShieldSaw): off hand home, drawn through its ssq-draw event, icon and prop; it can ask when the Wheel last filled the off hand | Z:10757, Z:11037, Z:5528, Z:194 | wr_Rig.homeHandOf; wr_Rig.commitAs; wr_Rig.ownBases; wr_RigService.GetInt |
| X8 | On the holster assignment screen the ShieldSaw's card is sent only to the ring the Rig allows for it ("rig.lockable" asked for SSQ_ShieldSaw), by the same assign event; Clear sends the unassign event | W:387, W:390, W:406, W:415 | wr_Rig.webPick |
| X9 | RSQ Saber (UBQS_Saber, UBQS_SaberBase, UBQS_ForceHand): main hand home, icons, saber prop | Z:10758, Z:5526, Z:5531, Z:10127 | wr_Rig.homeHandOf; wr_Rig.ownBases; wr_Rig.spawnOwnProp |
| X10 | RSQ Whip (RSQWP_WhipWeapon): main hand home, icon | Z:10759, Z:5527 | wr_Rig.homeHandOf; wr_Rig.ownBases |
| X11 | RSQ Melee (RSQ_Glove, RSQ_GloveOff): gloves on the fist card, the hand's glove first, Melee's icon, glove or fist prop | Z:5515, Z:5597, Z:5598, Z:5579, Z:10131 | wr_Rig.isFistWith; wr_Rig.fistFor; wr_Rig.ownIconOf; wr_Rig.spawnOwnProp |
| X12 | RSQ FnF (RSQFF_Held, RSQFF_Torch): the Wheel's icons | Z:5529, Z:5530 | wr_Rig.ownBases |
| X13 | RSQ Score (RS_ScoreService): the web's ring numbers in its combo digits | W:679, W:710 | wr_Rig.webOpenFor; wr_Rig.webNumTex |
| X14 | BD22 VR Reloaded: RSQ_BD22OffhandService pairs a gun with its off hand version; one card; off hand gets the version | Z:10768, Z:10778, Z:4037, Z:10834, Z:10835 | wr_Rig.offSvc; wr_Rig.mainOfCopy; wr_Rig.slotWeapons; wr_Rig.resolvePick |
| X14 | RSQ_Hands is the off hand's fist; RSV_ MODELDEF blocks are read for voxel sizes | Z:5502, Z:9492, zscript/wheel/wr_q_vox.zs:77 | wr_Rig.isFistClass; wr_Rig.fileAway; wr_VoxSize.ReadAll |
| X15 | Brutal Doom: Melee_Attacks is a fist; its DRYFIRE lump gives the dry click; its head hits count | Z:5512, Z:1163, zscript/wheel/wr_stattracker.zs:478, :494, :799, Z:2581 | wr_Rig.isFistWith; wr_Rig.dryClick; wr_StatEvents.bdHeadshot; wr_StatTracker.HeadshotsOf; wr_Rig.buildSheetRows |
| X16 | RS_Headshots: HS_Marker spawns count as headshots | zscript/wheel/wr_stattracker.zs:639, :649 | wr_StatEvents.WorldThingSpawned |
| X17 | LegenDoom: rarity from owned token classes, colour on the card, rarity, name and effect rows | zscript/wheel/wr_compat_legendoom.zs:107, :125, :188, Z:5892, Z:1934, Z:1941, Z:2016 | wr_CompatLegenDoom.RarityOf; wr_CompatLegenDoom.EffectsOf; wr_Rig.cardColorFor; wr_Rig.buildSheetRows |
| X18 | LegenDoom x BD22 VR patch (RSLDP_Service): the token prefix for a stand-in gun | zscript/wheel/wr_compat_legendoom.zs:90, :94 | wr_CompatLegenDoom.PrefixOf |
| X19 | A service with GunModeService in its name: FIRE MODE row | zscript/wheel/wr_stats.zs:337, :341, Z:2695, Z:2696 | wr_Stats.FireMode; wr_Rig.statRows |
| X20 | ModelSwapper (RS_WeaponArchetypeService): MODEL row for a gun in a hand | zscript/wheel/wr_compat_modelswapper.zs:73, :84, Z:2545, Z:2549 | wr_CompatModelSwapper.msService; wr_CompatModelSwapper.StateOf; wr_Rig.buildSheetRows |
| X21 | RS_Main (RS_TierColorService): tier colour | Z:5926 | wr_Rig.rsTierLookup |
| X22 | Parked readers: Parked() is true unless wr_unpark_mods; each reader's gate | zscript/wheel/wr_modsupport.zs:12, zscript/wheel/wr_compat_drla.zs:73, zscript/wheel/wr_compat_doomablo.zs:66, zscript/wheel/wr_compat_pandemonia.zs:39, zscript/wheel/wr_compat_pandemonia_anarchy.zs:33, zscript/wheel/wr_compat_pandemonia_insurrection.zs:48, zscript/wheel/wr_compat_guncaster.zs:31, zscript/wheel/wr_compat_metadoom.zs:25, zscript/wheel/wr_compat_borderdoom.zs:91, zscript/wheel/wr_compat_doominfinite.zs:92, zscript/wheel/wr_compat_combinedarms.zs:59, zscript/wheel/wr_compat_finaldoomer.zs:41, zscript/wheel/wr_compat_lithium.zs:58, CVARINFO.txt:860 | wr_ModSupport.Parked; each wr_Compat reader's gate |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No opening while not alive, or with no cards | Z:1227, Z:1254 | wr_Rig.openRig |
| L2 | The engine's total freeze is set on the player while the ring is up | S:1260, Z:1307 | wr_VR.SuppressVRInput; wr_Rig.openRig |
| L2b | While the ring is up (Hold Still While Open), a snap (a one-tic view turn of vr_snapTurn) or a smooth stick turn (both hands repeat the view's turn the next tic, two tics running) is handed back: the angle goes back and player.resetDoomYaw resyncs QuestZDoom's view (rig 2026-11-27) | Z:1453, Z:9036 | wr_Rig.holdTurn; WorldTick |
| L3 | The buttons read: +attack, +oh_attack, +altattack, +oh_altatk, +use, and weapnext / weapprev by binding text; no grip | Z:954, Z:988, Z:1002, Z:1003, Z:1005, W:305 | wr_Rig.InputProcess; wr_Rig.webCycleKey |
| L4 | Weapon Wheel off blocks the open events and the next / prev handling | Z:797, Z:818, Z:813, W:304 | wr_Rig.NetworkProcess; wr_Rig.webCycleKey |
| L5 | One page; the inventory page was removed | Z:752, Z:754 | wr_Rig.pageCount |
| L6 | A pickup with no voxel size keeps the flat icon; the series' hand weapons use their own prop | Z:10081, Z:10086, Z:10043 | wr_Rig.spawnCardModels |
| L7 | A shot is counted from an ammo drop; the KILLS row needs a counted shot | zscript/wheel/wr_stattracker.zs:380, :705, Z:2564 | wr_StatEvents.trackFire; wr_StatTracker.BasicsOf; wr_Rig.buildSheetRows |
| L8 | 28 row billboards; a row past the pool is dropped | Z:11302, Z:3041 | wr_Rig.sheetRow |
| L9 | The font set is fixed to Score | zscript/wheel/wr_q_look.zs:96 | wr_LookState.Refresh |
| L10 | The floor sheet needs the ring closed and the weapon within Inspect Within | Z:7893, Z:7948 | wr_Rig.tickInspect |
| L11 | Built on the console player; other players' events are dropped | Z:763, S:42 | wr_Rig.NetworkProcess |
| L12 | The room effects are empty functions | S:1417, S:1422, S:1433 | wr_FX |
