# RSQ Wheel: where each README claim comes from

Commit read: 1a846b85c (2026-11-27). Paths are inside `Wheel/`. `Z` is `zscript/wheel/zscript.zs`, `W` is
`zscript/wheel/wr_web.zs`, `S` is `zscript/wheel/wr_q_shim.zs`; other files are named in full. Each line number is the
line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Open Wheel is the left stick click; pressing it opens the ring on the Opens On hand | KEYCONF:35, Z:817, Z:1078 | KEYCONF defaultbind; wr_Rig.NetworkProcess; wr_Rig.pressWheel |
| H1 | Letting go of the key takes nothing; the ring stays up | Z:1082, Z:1086 | wr_Rig.pressWheel |
| H2 | Taking a slot card opens the slot and the ring stays up; BACK returns | Z:10601, Z:3882, Z:10637 | wr_Rig.pressWheel; wr_Rig.navigate; wr_Rig.gatherWeaponCards; wr_Rig.commit |
| H4 | A press while the ring is up closes it; with a slot open it goes back to the slots | Z:1073, Z:1060, Z:1064 | wr_Rig.pressWheel |
| H5 | A second press within the double tap time closes the ring and gives the last picking hand its earlier gun | Z:1071, Z:1074, Z:1165, CVARINFO.txt:129 | wr_Rig.pressWheel; wr_Rig.swapToPrevious |
| H5b | With the ring up, Use and the grenade keys (+use, +user1, rsqgn_quickthrow) are taken and do nothing | Z:963, Z:965 | wr_Rig.InputProcess |
| H5c | The stick lights no card | Z:9132 | wr_Rig.WorldTick |
| H5d | The data sheet shows the gun for the pointing hand when either hand picks | Z:1484 | wr_Rig.refreshSheet |
| H5e | No reach in, no pull, no throw back: the touch radius is 0 and tickPhysical is not called | Z:9171, Z:9199 | wr_Rig.WorldTick |
| H6 | Opening stops the world while Time While Open is Frozen (the default); closing starts it again | Z:4757, Z:4758, Z:4760, Z:4769, CVARINFO.txt:102 | wr_Rig.bulletTime |
| H7 | The player is frozen while the ring is up | S:1260, Z:1294, Z:1392 | wr_VR.SuppressVRInput; wr_Rig.openRig; wr_Rig.holdStill |
| H8 | Either hand points: a ray from the hand finds the card; the other hand takes over when it is on a card and the first is not | Z:9116, Z:9093, Z:9095 | wr_Rig.WorldTick |
| H8 | The lit card grows, steps toward the eye and ticks in the pointing hand | Z:7377, Z:7405, Z:10391 | wr_Rig.layout; wr_Rig.updateHover |
| H9 | Fire of either hand on a lit card takes it into the pointing hand; the press is consumed | Z:990, Z:991, Z:1025, Z:866, Z:10994 | wr_Rig.InputProcess; wr_Rig.NetworkProcess; wr_Rig.commitAs |
| H17 | Off hand alt fire on a card picks it for the off hand and keeps the ring up | W:322, W:323, W:395, W:400, Z:10993 | wr_Rig.webInput; wr_Rig.webAlt; wr_Rig.commitAs |
| H18 | Main hand alt fire on a card without the Rig's service is a dull tick | W:371, W:373 | wr_Rig.webAlt |
| H19 | The fist card gives the picking hand its own fist, and gives the fist if the player had none | Z:10774, Z:10831, Z:5616 | wr_Rig.resolvePick; wr_Rig.commitAs; wr_Rig.ensureFistCards |
| H20 | A gun with nothing loaded, in reserve or for alt fire is not taken: dry click, ring closes | Z:10838, Z:10842, Z:1144 | wr_Rig.commitAs; wr_Rig.noAmmo |
| H21 | Picking the other hand's gun takes a free numbered copy, else swaps the two hands | Z:10862, Z:10864, Z:10876, Z:10884 | wr_Rig.commitAs |
| H22 | Fire or alt fire on the data sheet is consumed and sends a page event that does nothing with one page | Z:1002, Z:1004, Z:1005, Z:753 | wr_Rig.InputProcess; wr_Rig.pageCount |
| H23 | With nothing lit the ring counts down from Folds After, fades and ticks once inside the warning time, then closes | Z:1285, Z:9016, Z:9020, Z:9023, Z:9025, Z:7358 | wr_Rig.openRig; wr_Rig.WorldTick; wr_Rig.layout |
| H24 | Turned more than Ring Follows Past from the ring, the ring swings round | Z:7129, Z:7134, CVARINFO.txt:86 | wr_Rig.layout |
| H25 | A key whose binding is exactly weapnext or weapprev (with " 1": off hand) steps that hand through its guns with ammo, in slot order | W:337, W:341, W:344, W:346, W:489, W:558, Z:948 | wr_Rig.webCycleKey; wr_Rig.webCycle; wr_Rig.webCycleTick; wr_Rig.InputProcess |
| H25b | Skip Holstered Guns on: a gun with a holster is left out of next / prev, and the cards it reaches wear the gold light; off, no card wears it | W:227, W:240, W:241, CVARINFO.txt:111, MENUDEF.txt:143 | wr_Rig.webInRotation; wr_Rig.webState |
| H26 | Ring closed: a hand pointed at a floor weapon within Inspect Within for the rest time shows its sheet at that hand | Z:7877, Z:7913, Z:7917, Z:7932, Z:7972, Z:8032 | wr_Rig.tickInspect |
| H27 | Death and level exit close the ring at once | Z:3578, Z:3577, Z:8983 | wr_Rig.PlayerDied; wr_Rig.WorldUnloaded; wr_Rig.WorldTick |
| H28 | With fans on, 7 tics on a card, or Use at range, opens the slot's fan | Z:3838, Z:10336, Z:10343, Z:976, Z:980, Z:11005 | wr_Rig.gatherWeaponCards; wr_Rig.updateHover; wr_Rig.InputProcess |
| H29 | Fire held on a fan card drags it; moved onto another place the slot order is saved; not moved, it is a pick | Z:1019, Z:1021, Z:836, Z:4167, Z:4186, Z:854 | wr_Rig.InputProcess; wr_Rig.NetworkProcess; wr_Rig.tickDrag; wr_Rig.dragTo |
| H30 | With Off Hand Alt Picks off, off hand alt fire puts a gun out of or back into next / prev; a holstered gun gets a dull tick | W:407, W:409, W:414, W:229 | wr_Rig.webAlt; wr_Rig.webInRotation |
| H31 | Wrist card pose: hand 5 to 17 units from the eye, within 35 degrees of the view, pointing more than 55 degrees off it, held for the dwell, ring closed, Wrist Card on | zscript/wheel/wr_q_watch.zs:44, :47, :50, :66, :71, CVARINFO.txt:116 | wr_Watch.watching; wr_Watch.WorldTick |
| H32 | With Two Hands Compare on, the other hand's ray on a different gun's card swaps the sheet for the comparison | Z:9329, Z:9364, CVARINFO.txt:120 | wr_Rig.tickTwoHand |
| H33 | Wrist roll times Wrist Roll Spin is added to every card's bearing | Z:7190, Z:7388, CVARINFO.txt:235 | wr_Rig.layout |
| H34 | Opens On chooses the hand the ring opens on | Z:1177, Z:1078, CVARINFO.txt:263 | wr_Rig.opensOnHand; wr_Rig.pressWheel |
| H35 | With Either Hand off the hand does not switch and the gun goes to the ring's hand | Z:1172, Z:9093, Z:10641 | wr_Rig.eitherHand; wr_Rig.WorldTick; wr_Rig.commit |
| H36 | Time While Open on Slow asks RSQ SlowMo; with no SlowMo service the ring stops the world instead; on Normal nothing is done | Z:4757, Z:4783, Z:4789, Z:4794, Z:4809, Z:4810 | wr_Rig.bulletTime |
| H37 | Open at Level Start opens the ring on the first live tic of a map | Z:8922, Z:8928, CVARINFO.txt:232 | wr_Rig.WorldTick |
| H38 | The four toggle aliases have no key; each opens the ring or closes it | KEYCONF:38, KEYCONF:39, KEYCONF:40, KEYCONF:46, Z:808, Z:809, Z:810, Z:812, Z:1197 | KEYCONF aliases; wr_Rig.NetworkProcess; wr_Rig.toggle |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| X2 | RSQ SlowMo (RSQSM_Service): rsm_on on open, rsm_off on close, only with Time While Open on Slow; Close Ends Slow Time decides for slow time already running | Z:4783, Z:4789, Z:4794, Z:4799 | wr_Rig.bulletTime |
| X3 | RSQ Tactical Rig (RSQTR_RigService): HOLSTER row | Z:1789, Z:1792, Z:1793 | wr_Rig.seriesRows |
| X3 | Holster web: opens on main hand alt fire, assign and unassign events, Mirror view, draw wins over next / prev | W:385, W:452, W:461, W:726, W:902, W:542 | wr_Rig.webAlt; wr_Rig.webPick; wr_Rig.webOpenFor; wr_Rig.webLayout; wr_Rig.webCycleTick |
| X4 | Gun Bonsai rows from RSQGB_Service, else RSQ_MeleeUpgradeService | zscript/wheel/wr_q_bonsai.zs:50, :53, :60, :62, Z:1805, Z:1807, Z:1795 | WR_Bonsai.Entry; wr_Rig.bonsaiRows; wr_Rig.seriesRows |
| X5 | RSQ Gun Cards: card colour setting, weapon condition, watch card stands the Wheel's down | zscript/wheel/wr_q_gunlook.zs:48, Z:5887, zscript/wheel/wr_stats.zs:321, :326, Z:2671, Z:2675, zscript/wheel/wr_q_watch.zs:59, :60 | wr_GunLook.GunColour; wr_Rig.cardColorFor; wr_Stats.GunCardsCondition; wr_Rig.statRows; wr_Watch.WorldTick |
| X6 | RSQ Laser Sight (RSQLS_SightService): the hand points along its beam and the ring draws none there | S:1365, S:1328, Z:8867, Z:8868 | wr_VRState.laserBeamOn; wr_VRState.WorldTick; wr_Rig.aimPos |
| X7 | RSQ Grenade (RSQGN_Service, class RSQGN_Grenade): fan of kinds, kind set on pick, main hand home | Z:4404, Z:4481, Z:4516, Z:10819, Z:10711 | wr_Rig.GrenadeKinds; wr_Rig.expandSlot; wr_Rig.commitAs; wr_Rig.homeHandOf |
| X8 | RSQ ShieldSaw (class SSQ_ShieldSaw): off hand home, drawn through its ssq-draw event, icon and prop; it can ask when the Wheel last filled the off hand | Z:10708, Z:10988, Z:5512, Z:194 | wr_Rig.homeHandOf; wr_Rig.commitAs; wr_Rig.ownBases; wr_RigService.GetInt |
| X8 | On the holster assignment screen the ShieldSaw's card is sent only to the ring the Rig allows for it ("rig.lockable" asked for SSQ_ShieldSaw), by the same assign event; Clear sends the unassign event | W:433, W:436, W:452, W:461 | wr_Rig.webPick |
| X9 | RSQ Saber (UBQS_Saber, UBQS_SaberBase, UBQS_ForceHand): main hand home, icons, saber prop | Z:10709, Z:5510, Z:5515, Z:10088 | wr_Rig.homeHandOf; wr_Rig.ownBases; wr_Rig.spawnOwnProp |
| X10 | RSQ Whip (RSQWP_WhipWeapon): main hand home, icon | Z:10710, Z:5511 | wr_Rig.homeHandOf; wr_Rig.ownBases |
| X11 | RSQ Melee (RSQ_Glove, RSQ_GloveOff): gloves on the fist card, the hand's glove first, Melee's icon, glove or fist prop | Z:5499, Z:5581, Z:5582, Z:5563, Z:10092 | wr_Rig.isFistWith; wr_Rig.fistFor; wr_Rig.ownIconOf; wr_Rig.spawnOwnProp |
| X12 | RSQ FnF (RSQFF_Held, RSQFF_Torch): the Wheel's icons | Z:5513, Z:5514 | wr_Rig.ownBases |
| X13 | RSQ Score (RS_ScoreService): the web's ring numbers in its combo digits | W:725, W:756 | wr_Rig.webOpenFor; wr_Rig.webNumTex |
| X14 | BD22 VR Reloaded: RSQ_BD22OffhandService pairs a gun with its off hand version; one card; off hand gets the version | Z:10719, Z:10729, Z:4021, Z:10785, Z:10786 | wr_Rig.offSvc; wr_Rig.mainOfCopy; wr_Rig.slotWeapons; wr_Rig.resolvePick |
| X14 | RSQ_Hands is the off hand's fist; RSV_ MODELDEF blocks are read for voxel sizes | Z:5486, Z:9453, zscript/wheel/wr_q_vox.zs:77 | wr_Rig.isFistClass; wr_Rig.fileAway; wr_VoxSize.ReadAll |
| X15 | Brutal Doom: Melee_Attacks is a fist; its DRYFIRE lump gives the dry click; its head hits count | Z:5496, Z:1151, zscript/wheel/wr_stattracker.zs:478, :494, :799, Z:2567 | wr_Rig.isFistWith; wr_Rig.dryClick; wr_StatEvents.bdHeadshot; wr_StatTracker.HeadshotsOf; wr_Rig.buildSheetRows |
| X16 | RS_Headshots: HS_Marker spawns count as headshots | zscript/wheel/wr_stattracker.zs:639, :649 | wr_StatEvents.WorldThingSpawned |
| X17 | LegenDoom: rarity from owned token classes, colour on the card, rarity, name and effect rows | zscript/wheel/wr_compat_legendoom.zs:107, :125, :188, Z:5876, Z:1920, Z:1927, Z:2002 | wr_CompatLegenDoom.RarityOf; wr_CompatLegenDoom.EffectsOf; wr_Rig.cardColorFor; wr_Rig.buildSheetRows |
| X18 | LegenDoom x BD22 VR patch (RSLDP_Service): the token prefix for a stand-in gun | zscript/wheel/wr_compat_legendoom.zs:90, :94 | wr_CompatLegenDoom.PrefixOf |
| X19 | A service with GunModeService in its name: FIRE MODE row | zscript/wheel/wr_stats.zs:337, :341, Z:2681, Z:2682 | wr_Stats.FireMode; wr_Rig.statRows |
| X20 | ModelSwapper (RS_WeaponArchetypeService): MODEL row for a gun in a hand | zscript/wheel/wr_compat_modelswapper.zs:73, :84, Z:2531, Z:2535 | wr_CompatModelSwapper.msService; wr_CompatModelSwapper.StateOf; wr_Rig.buildSheetRows |
| X21 | RS_Main (RS_TierColorService): tier colour | Z:5910 | wr_Rig.rsTierLookup |
| X22 | Parked readers: Parked() is true unless wr_unpark_mods; each reader's gate | zscript/wheel/wr_modsupport.zs:12, zscript/wheel/wr_compat_drla.zs:73, zscript/wheel/wr_compat_doomablo.zs:66, zscript/wheel/wr_compat_pandemonia.zs:39, zscript/wheel/wr_compat_pandemonia_anarchy.zs:33, zscript/wheel/wr_compat_pandemonia_insurrection.zs:48, zscript/wheel/wr_compat_guncaster.zs:31, zscript/wheel/wr_compat_metadoom.zs:25, zscript/wheel/wr_compat_borderdoom.zs:91, zscript/wheel/wr_compat_doominfinite.zs:92, zscript/wheel/wr_compat_combinedarms.zs:59, zscript/wheel/wr_compat_finaldoomer.zs:41, zscript/wheel/wr_compat_lithium.zs:58, CVARINFO.txt:861 | wr_ModSupport.Parked; each wr_Compat reader's gate |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No opening while not alive, or with no cards | Z:1215, Z:1242 | wr_Rig.openRig |
| L2 | The engine's total freeze is set on the player while the ring is up | S:1260, Z:1294 | wr_VR.SuppressVRInput; wr_Rig.openRig |
| L3 | The buttons read: +attack, +oh_attack, +altattack, +oh_altatk, +use, and weapnext / weapprev by binding text; no grip | Z:953, Z:976, Z:990, Z:991, Z:993, W:337 | wr_Rig.InputProcess; wr_Rig.webCycleKey |
| L4 | Weapon Wheel off blocks the open events and the next / prev handling | Z:796, Z:817, Z:812, W:336 | wr_Rig.NetworkProcess; wr_Rig.webCycleKey |
| L5 | One page; the inventory page was removed | Z:751, Z:753 | wr_Rig.pageCount |
| L6 | A pickup with no voxel size keeps the flat icon; the series' hand weapons use their own prop | Z:10042, Z:10047, Z:10004 | wr_Rig.spawnCardModels |
| L7 | A shot is counted from an ammo drop; the KILLS row needs a counted shot | zscript/wheel/wr_stattracker.zs:380, :705, Z:2550 | wr_StatEvents.trackFire; wr_StatTracker.BasicsOf; wr_Rig.buildSheetRows |
| L8 | 28 row billboards; a row past the pool is dropped | Z:11253, Z:3027 | wr_Rig.sheetRow |
| L9 | The font set is fixed to Score | zscript/wheel/wr_q_look.zs:96 | wr_LookState.Refresh |
| L10 | The floor sheet needs the ring closed and the weapon within Inspect Within | Z:7877, Z:7932 | wr_Rig.tickInspect |
| L11 | Built on the console player; other players' events are dropped | Z:762, S:42 | wr_Rig.NetworkProcess |
| L12 | The room effects are empty functions | S:1417, S:1422, S:1433 | wr_FX |
