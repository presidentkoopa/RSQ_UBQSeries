# RSQ Wheel: where each README claim comes from

Commit read: 1a846b85c (2026-11-27). Paths are inside `Wheel/`. `Z` is `zscript/wheel/zscript.zs`, `W` is
`zscript/wheel/wr_web.zs`, `S` is `zscript/wheel/wr_q_shim.zs`; other files are named in full. Each line number is the
line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Open Wheel is the left stick click; pressing it opens the ring on the Opens On hand | KEYCONF:33, Z:817, Z:1072 | KEYCONF defaultbind; wr_Rig.NetworkProcess; wr_Rig.pressWheel |
| H1 | Letting go after the hold time takes the card under the pointing hand, then closes; over no card it only closes | Z:1080, Z:1094, Z:1097, Z:10647 | wr_Rig.pressWheel; wr_Rig.commit |
| H2 | Letting go on a slot card opens the slot and the ring stays up; so does any take of it; BACK returns | Z:1086, Z:10607, Z:3892, Z:10643 | wr_Rig.pressWheel; wr_Rig.navigate; wr_Rig.gatherWeaponCards; wr_Rig.commit |
| H3 | A press shorter than the hold time leaves the ring up | Z:1100, CVARINFO.txt:75 | wr_Rig.pressWheel |
| H4 | A press while the ring is up closes it; with a slot open it goes back to the slots | Z:1067, Z:1054, Z:1058 | wr_Rig.pressWheel |
| H5 | A second press within the double tap time closes the ring and gives the last picking hand its earlier gun | Z:1065, Z:1068, Z:1178, CVARINFO.txt:125 | wr_Rig.pressWheel; wr_Rig.swapToPrevious |
| H6 | Opening stops the world while Time While Open is Frozen (the default); closing starts it again | Z:4767, Z:4768, Z:4770, Z:4779, CVARINFO.txt:102 | wr_Rig.bulletTime |
| H7 | The player is frozen while the ring is up | S:1260, Z:1307, Z:1405 | wr_VR.SuppressVRInput; wr_Rig.openRig; wr_Rig.holdStill |
| H8 | Either hand points: a ray from the hand finds the card; the other hand takes over when it is on a card and the first is not | Z:9126, Z:9103, Z:9105 | wr_Rig.WorldTick |
| H8 | The lit card grows, steps toward the eye and ticks in the pointing hand | Z:7387, Z:7415, Z:10397 | wr_Rig.layout; wr_Rig.updateHover |
| H9 | Fire of either hand on a lit card takes it into the pointing hand; the press is consumed | Z:984, Z:985, Z:1019, Z:866, Z:11000 | wr_Rig.InputProcess; wr_Rig.NetworkProcess; wr_Rig.commitAs |
| H10 | The movement stick's direction lights the nearest card and beats the beam | Z:4675, Z:9140, Z:9141, S:1275 | wr_Rig.stickPick; wr_Rig.WorldTick; wr_VR.GetRawStickMove |
| H11 | The stick held at its rim on a slot card or BACK for 6 tics opens it or goes back | Z:4724, Z:4726, Z:4728, Z:11157 | wr_Rig.tickStickPush |
| H12 | A fingertip carried ahead of the hand, inside a card, selects it over beam and stick | Z:9183, Z:9188, Z:9194, CVARINFO.txt:220 | wr_Rig.WorldTick |
| H14 | A hand in a card moving away from the ring faster than Pull a Card Out takes that card | Z:9421, Z:9429, CVARINFO.txt:120 | wr_Rig.tickPhysical |
| H15 | A gun hand moving toward the ring faster than Throw a Gun Back, in no card and aimed at none, swaps the gun for the fist; a double tap brings it back | Z:9442, Z:9444, Z:9486, Z:9485, CVARINFO.txt:121 | wr_Rig.tickPhysical; wr_Rig.fileAway |
| H16 | On the release, a different gun's card under the other hand goes to that hand | Z:1092, Z:1095, Z:1144 | wr_Rig.pressWheel; wr_Rig.secondPick |
| H17 | Off hand alt fire on a card picks it for the off hand and keeps the ring up | W:319, W:320, W:392, W:397, Z:10999 | wr_Rig.webInput; wr_Rig.webAlt; wr_Rig.commitAs |
| H18 | Main hand alt fire on a card without the Rig's service is a dull tick | W:368, W:370 | wr_Rig.webAlt |
| H19 | The fist card gives the picking hand its own fist, and gives the fist if the player had none | Z:10780, Z:10837, Z:5626 | wr_Rig.resolvePick; wr_Rig.commitAs; wr_Rig.ensureFistCards |
| H20 | A gun with nothing loaded, in reserve or for alt fire is not taken: dry click, ring closes | Z:10844, Z:10848, Z:1157 | wr_Rig.commitAs; wr_Rig.noAmmo |
| H21 | Picking the other hand's gun takes a free numbered copy, else swaps the two hands | Z:10868, Z:10870, Z:10882, Z:10890 | wr_Rig.commitAs |
| H22 | Fire or alt fire on the data sheet is consumed and sends a page event that does nothing with one page | Z:996, Z:998, Z:999, Z:753 | wr_Rig.InputProcess; wr_Rig.pageCount |
| H23 | With nothing lit the ring counts down from Folds After, fades and ticks once inside the warning time, then closes | Z:1298, Z:9026, Z:9030, Z:9033, Z:9035, Z:7368 | wr_Rig.openRig; wr_Rig.WorldTick; wr_Rig.layout |
| H24 | Turned more than Ring Follows Past from the ring, the ring swings round | Z:7139, Z:7144, CVARINFO.txt:86 | wr_Rig.layout |
| H25 | A key whose binding is exactly weapnext or weapprev (with " 1": off hand) steps that hand through its guns with ammo, in slot order | W:334, W:338, W:341, W:343, W:474, W:543, Z:948 | wr_Rig.webCycleKey; wr_Rig.webCycle; wr_Rig.webCycleTick; wr_Rig.InputProcess |
| H26 | Ring closed: a hand pointed at a floor weapon within Inspect Within for the rest time shows its sheet at that hand | Z:7887, Z:7923, Z:7927, Z:7942, Z:7982, Z:8042 | wr_Rig.tickInspect |
| H27 | Death and level exit close the ring at once | Z:3588, Z:3587, Z:8993 | wr_Rig.PlayerDied; wr_Rig.WorldUnloaded; wr_Rig.WorldTick |
| H28 | With fans on, 7 tics on a card, or Use at range, opens the slot's fan | Z:3848, Z:10342, Z:10349, Z:970, Z:974, Z:11011 | wr_Rig.gatherWeaponCards; wr_Rig.updateHover; wr_Rig.InputProcess |
| H29 | Fire held on a fan card drags it; moved onto another place the slot order is saved; not moved, it is a pick | Z:1013, Z:1015, Z:836, Z:4177, Z:4196, Z:854 | wr_Rig.InputProcess; wr_Rig.NetworkProcess; wr_Rig.tickDrag; wr_Rig.dragTo |
| H30 | With Off Hand Alt Picks off, off hand alt fire puts a gun out of or back into next / prev; a holstered gun gets a dull tick | W:404, W:406, W:411, W:222 | wr_Rig.webAlt; wr_Rig.webInRotation |
| H31 | Wrist card pose: hand 5 to 17 units from the eye, within 35 degrees of the view, pointing more than 55 degrees off it, held for the dwell, ring closed, Wrist Card on | zscript/wheel/wr_q_watch.zs:44, :47, :50, :66, :71, CVARINFO.txt:112 | wr_Watch.watching; wr_Watch.WorldTick |
| H32 | With Two Hands Compare on, the other hand's ray on a different gun's card swaps the sheet for the comparison | Z:9335, Z:9370, CVARINFO.txt:116 | wr_Rig.tickTwoHand |
| H33 | Wrist roll times Wrist Roll Spin is added to every card's bearing | Z:7200, Z:7398, CVARINFO.txt:231 | wr_Rig.layout |
| H34 | Opens On chooses the hand the ring opens on | Z:1190, Z:1072, CVARINFO.txt:259 | wr_Rig.opensOnHand; wr_Rig.pressWheel |
| H35 | With Either Hand off the hand does not switch and the gun goes to the ring's hand | Z:1185, Z:9103, Z:10647 | wr_Rig.eitherHand; wr_Rig.WorldTick; wr_Rig.commit |
| H36 | Time While Open on Slow asks RSQ SlowMo; with no SlowMo service the ring stops the world instead; on Normal nothing is done | Z:4767, Z:4793, Z:4799, Z:4804, Z:4819, Z:4820 | wr_Rig.bulletTime |
| H37 | Open at Level Start opens the ring on the first live tic of a map | Z:8932, Z:8938, CVARINFO.txt:228 | wr_Rig.WorldTick |
| H38 | The four toggle aliases have no key; each opens the ring or closes it | KEYCONF:36, KEYCONF:37, KEYCONF:38, KEYCONF:44, Z:808, Z:809, Z:810, Z:812, Z:1210 | KEYCONF aliases; wr_Rig.NetworkProcess; wr_Rig.toggle |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X1 | RSQ Accessibility is found by its class RSQA_Menu; Slower Taps scales hold and double tap | zscript/wheel/wr_a11y.zs:27, zscript/wheel/wr_a11y.zs:98, Z:1064, Z:1080 | wr_A11y.Cv; wr_A11y.Tap; wr_Rig.pressWheel |
| X1 | Rumble Strength and Rumble Backup | S:1208, S:1229, zscript/wheel/wr_a11y.zs:95 | wr_VR.VRHaptic; wr_A11y.Rumble |
| X1 | Steady Hands for pointing; Seated Play's eye | Z:8879, Z:8882, Z:8845, Z:8850 | wr_Rig.aimPos; wr_Rig.eyeZ |
| X1 | Colour blind: neutral cards; photosensitive: dimmed breathing and sweep | Z:5878, zscript/wheel/wr_q_gunlook.zs:38, :146, :226, :261 | wr_Rig.cardColorFor; wr_GunLook.CBMode; wr_Rig.glBegin; wr_Rig.glBreath; wr_Rig.glCard |
| X2 | RSQ SlowMo (RSQSM_Service): rsm_on on open, rsm_off on close, only with Time While Open on Slow; Close Ends Slow Time decides for slow time already running | Z:4793, Z:4799, Z:4804, Z:4809 | wr_Rig.bulletTime |
| X3 | RSQ Tactical Rig (RSQTR_RigService): HOLSTER row | Z:1799, Z:1802, Z:1803 | wr_Rig.seriesRows |
| X3 | Holster web: opens on main hand alt fire, assign and unassign events, Mirror view, draw wins over next / prev | W:382, W:437, W:446, W:711, W:887, W:527 | wr_Rig.webAlt; wr_Rig.webPick; wr_Rig.webOpenFor; wr_Rig.webLayout; wr_Rig.webCycleTick |
| X4 | Gun Bonsai rows from RSQGB_Service, else RSQ_MeleeUpgradeService | zscript/wheel/wr_q_bonsai.zs:50, :53, :60, :62, Z:1815, Z:1817, Z:1805 | WR_Bonsai.Entry; wr_Rig.bonsaiRows; wr_Rig.seriesRows |
| X5 | RSQ Gun Cards: card colour setting, weapon condition, watch card stands the Wheel's down | zscript/wheel/wr_q_gunlook.zs:48, Z:5897, zscript/wheel/wr_stats.zs:321, :326, Z:2681, Z:2685, zscript/wheel/wr_q_watch.zs:59, :60 | wr_GunLook.GunColour; wr_Rig.cardColorFor; wr_Stats.GunCardsCondition; wr_Rig.statRows; wr_Watch.WorldTick |
| X6 | RSQ Laser Sight (RSQLS_SightService): the hand points along its beam and the ring draws none there | S:1365, S:1328, Z:8877, Z:8878 | wr_VRState.laserBeamOn; wr_VRState.WorldTick; wr_Rig.aimPos |
| X7 | RSQ Grenade (RSQGN_Service, class RSQGN_Grenade): fan of kinds, kind set on pick, main hand home | Z:4414, Z:4491, Z:4526, Z:10825, Z:10717 | wr_Rig.GrenadeKinds; wr_Rig.expandSlot; wr_Rig.commitAs; wr_Rig.homeHandOf |
| X8 | RSQ ShieldSaw (class SSQ_ShieldSaw): off hand home, drawn through its ssq-draw event, icon and prop; it can ask when the Wheel last filled the off hand | Z:10714, Z:10994, Z:5522, Z:194 | wr_Rig.homeHandOf; wr_Rig.commitAs; wr_Rig.ownBases; wr_RigService.GetInt |
| X9 | RSQ Saber (UBQS_Saber, UBQS_SaberBase, UBQS_ForceHand): main hand home, icons, saber prop | Z:10715, Z:5520, Z:5525, Z:10094 | wr_Rig.homeHandOf; wr_Rig.ownBases; wr_Rig.spawnOwnProp |
| X10 | RSQ Whip (RSQWP_WhipWeapon): main hand home, icon | Z:10716, Z:5521 | wr_Rig.homeHandOf; wr_Rig.ownBases |
| X11 | RSQ Melee (RSQ_Glove, RSQ_GloveOff): gloves on the fist card, the hand's glove first, Melee's icon, glove or fist prop | Z:5509, Z:5591, Z:5592, Z:5573, Z:10098 | wr_Rig.isFistWith; wr_Rig.fistFor; wr_Rig.ownIconOf; wr_Rig.spawnOwnProp |
| X12 | RSQ FnF (RSQFF_Held, RSQFF_Torch): the Wheel's icons | Z:5523, Z:5524 | wr_Rig.ownBases |
| X13 | RSQ Score (RS_ScoreService): the web's ring numbers in its combo digits | W:710, W:741 | wr_Rig.webOpenFor; wr_Rig.webNumTex |
| X14 | BD22 VR Reloaded: RSQ_BD22OffhandService pairs a gun with its off hand version; one card; off hand gets the version | Z:10725, Z:10735, Z:4031, Z:10791, Z:10792 | wr_Rig.offSvc; wr_Rig.mainOfCopy; wr_Rig.slotWeapons; wr_Rig.resolvePick |
| X14 | RSQ_Hands is the off hand's fist; RSV_ MODELDEF blocks are read for voxel sizes | Z:5496, Z:9459, zscript/wheel/wr_q_vox.zs:77 | wr_Rig.isFistClass; wr_Rig.fileAway; wr_VoxSize.ReadAll |
| X15 | Brutal Doom: Melee_Attacks is a fist; its DRYFIRE lump gives the dry click; its head hits count | Z:5506, Z:1164, zscript/wheel/wr_stattracker.zs:478, :494, :799, Z:2577 | wr_Rig.isFistWith; wr_Rig.dryClick; wr_StatEvents.bdHeadshot; wr_StatTracker.HeadshotsOf; wr_Rig.buildSheetRows |
| X16 | RS_Headshots: HS_Marker spawns count as headshots | zscript/wheel/wr_stattracker.zs:639, :649 | wr_StatEvents.WorldThingSpawned |
| X17 | LegenDoom: rarity from owned token classes, colour on the card, rarity, name and effect rows | zscript/wheel/wr_compat_legendoom.zs:107, :125, :188, Z:5886, Z:1930, Z:1937, Z:2012 | wr_CompatLegenDoom.RarityOf; wr_CompatLegenDoom.EffectsOf; wr_Rig.cardColorFor; wr_Rig.buildSheetRows |
| X18 | LegenDoom x BD22 VR patch (RSLDP_Service): the token prefix for a stand-in gun | zscript/wheel/wr_compat_legendoom.zs:90, :94 | wr_CompatLegenDoom.PrefixOf |
| X19 | A service with GunModeService in its name: FIRE MODE row | zscript/wheel/wr_stats.zs:337, :341, Z:2691, Z:2692 | wr_Stats.FireMode; wr_Rig.statRows |
| X20 | ModelSwapper (RS_WeaponArchetypeService): MODEL row for a gun in a hand | zscript/wheel/wr_compat_modelswapper.zs:73, :84, Z:2541, Z:2545 | wr_CompatModelSwapper.msService; wr_CompatModelSwapper.StateOf; wr_Rig.buildSheetRows |
| X21 | RS_Main (RS_TierColorService): tier colour | Z:5920 | wr_Rig.rsTierLookup |
| X22 | Parked readers: Parked() is true unless wr_unpark_mods; each reader's gate | zscript/wheel/wr_modsupport.zs:12, zscript/wheel/wr_compat_drla.zs:73, zscript/wheel/wr_compat_doomablo.zs:66, zscript/wheel/wr_compat_pandemonia.zs:39, zscript/wheel/wr_compat_pandemonia_anarchy.zs:33, zscript/wheel/wr_compat_pandemonia_insurrection.zs:48, zscript/wheel/wr_compat_guncaster.zs:31, zscript/wheel/wr_compat_metadoom.zs:25, zscript/wheel/wr_compat_borderdoom.zs:91, zscript/wheel/wr_compat_doominfinite.zs:92, zscript/wheel/wr_compat_combinedarms.zs:59, zscript/wheel/wr_compat_finaldoomer.zs:41, zscript/wheel/wr_compat_lithium.zs:58, CVARINFO.txt:857 | wr_ModSupport.Parked; each wr_Compat reader's gate |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No opening while not alive, or with no cards | Z:1228, Z:1255 | wr_Rig.openRig |
| L2 | The engine's total freeze is set on the player while the ring is up | S:1260, Z:1307 | wr_VR.SuppressVRInput; wr_Rig.openRig |
| L3 | The buttons read: +attack, +oh_attack, +altattack, +oh_altatk, +use, and weapnext / weapprev by binding text; no grip | Z:953, Z:970, Z:984, Z:985, Z:987, W:334 | wr_Rig.InputProcess; wr_Rig.webCycleKey |
| L4 | Weapon Wheel off blocks the open events and the next / prev handling | Z:796, Z:817, Z:812, W:333 | wr_Rig.NetworkProcess; wr_Rig.webCycleKey |
| L5 | One page; the inventory page was removed | Z:751, Z:753 | wr_Rig.pageCount |
| L6 | A pickup with no voxel size keeps the flat icon; the series' hand weapons use their own prop | Z:10048, Z:10053, Z:10010 | wr_Rig.spawnCardModels |
| L7 | A shot is counted from an ammo drop; the KILLS row needs a counted shot | zscript/wheel/wr_stattracker.zs:380, :705, Z:2560 | wr_StatEvents.trackFire; wr_StatTracker.BasicsOf; wr_Rig.buildSheetRows |
| L8 | 28 row billboards; a row past the pool is dropped | Z:11259, Z:3037 | wr_Rig.sheetRow |
| L9 | The font set is fixed to Score | zscript/wheel/wr_q_look.zs:96 | wr_LookState.Refresh |
| L10 | The floor sheet needs the ring closed and the weapon within Inspect Within | Z:7887, Z:7942 | wr_Rig.tickInspect |
| L11 | Built on the console player; other players' events are dropped | Z:762, S:42 | wr_Rig.NetworkProcess |
| L12 | The room effects are empty functions | S:1417, S:1422, S:1433 | wr_FX |
