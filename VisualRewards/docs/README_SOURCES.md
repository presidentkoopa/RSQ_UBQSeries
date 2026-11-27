# RSQ VisualRewards: where each README claim comes from

Commit read: a283738bb (2026-11-27). Line numbers moved to the working tree after the 2026-11-27 build of the owner's answers (F1, F2 to F6, F8, F10). Paths are inside `VisualRewards/pk3/` unless they start with another mod's folder.
`HD` is `zscript/rsqthp/handler.zs`, `BR` is `zscript/rsqthp/bar.zs`, `EV` is `zscript/rsqthp/damnums/events.zs`, `NU`
is `zscript/rsqthp/damnums/numbers.zs`, `A` is `zscript/rsqthp/a11y.zs`, `KR` is `zscript/rsqvr/killrewards.zs`, `BB` is
`zscript/rsqvr/batterybit.zs`, `SV` is `zscript/rsqvr/service.zs`, `DN` is `zscript/rsqvr/down.zs`, `BM` is
`zscript/rsqvr/beams.zs`, `WD` is `zscript/rsqvr/words.zs`, `WW` is `zscript/rsqvr/worldwords.zs`, `LD` is
`zscript/rsqvr/ldword.zs`, `SC` is `zscript/rsqvr/scenes.zs`, `BN` is `zscript/rsqvr/banners.zs`, `IB` is
`zscript/rsqvr/invbar.zs`, `HP` is `zscript/rsqvr/helpers.zs`, `CV` is `CVARINFO.txt`, `MD` is `MENUDEF.txt`.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| P1 | A damage event makes the bar; who may have one; the bar goes when its monster dies | HD:443, HD:447, HD:366, HD:373, BR:167 | RSQTHP_Handler.WorldThingDamaged; Eligible; RSQTHP_Bar.Tick |
| P1 | A player's hit flashes the bar white one tic; HP Bars on by default | HD:452, BR:265, BR:271, BR:272, CV:3 | WorldThingDamaged; RSQTHP_Bar.Update |
| P2 | One number per target per tic, never more than the health left | EV:146, EV:155, EV:163, EV:169 | RSQTHP_DamNumHandler.WorldThingDamaged |
| P2 | Stands where the shot struck, out in front of the monster | EV:180, EV:183, EV:196 | WorldThingDamaged |
| P2 | Pop on: a jet that spins, fading from tic 12, gone at 22 (0.63 s); Damage Numbers on by default | EV:623, EV:699, EV:711, EV:1078, CV:26, CV:35 | NewHit; PlaceJet; Advance |
| P3 | Within CHAIN_GAP (105 tics, 3 s) the second hit starts the total; the combo text from 2 hits | EV:65, EV:790, EV:793, NU:178 | ProcessPending; RSQTHP_DnNum.Layout |
| P3 | Default ramp White, Yellow, Orange, Red, stepped by hits; shake from x5; rows on by default | EV:432, NU:257, EV:1459, EV:1248, CV:38, CV:48, CV:53 | RampOf; ComboStep; Draw |
| P4 | Brutal Doom's head damage types and head hit boxes; x1.35, HEADSHOT, gold (3) | EV:138, EV:141, EV:614, EV:617, CV:58 | IsHead; NewHit |
| P4 | A headshot arcs out on alternating sides and jolts | EV:624, EV:649, EV:1209, EV:1212 | NewHit; PlaceArc; Draw |
| P5 | The killing hit or total punches, holds 14 tics, fades by 24; Kill Slam on | EV:1092, EV:808, EV:809, EV:1173, EV:1174, EV:1175, CV:39 | Advance; ProcessPending; Kill |
| P6 | On a monster's death (not a helper), spawn health / 10 rolls, x Boss Fountain (3) for a boss | KR:261, KR:265, KR:298, KR:121, KR:287, CV:70, CV:72, CV:74 | RSQ_KRHandler.WorldThingDied; HpRatio |
| P6 | Each roll 50% unless a boss; thrown 32 up, 1-6 out and up | KR:458, KR:475, CV:79 | Burst |
| P6b | One ammo roll in three is the teal bit while Ammo for Other Guns is on (default on) | KR:472, KR:507, KR:564, KR:567, CV:85, MD:362 | Burst; BurstCapped; OtherRoll |
| P7 | Bits drift to a player inside Bits Fly to Me (2 m), the row alone, and are touched near him | KR:769, KR:772, KR:779, KR:780, KR:109, CV:86 | RSQ_KRBit.BitTick; MagnetM |
| P7 | Health bit 25 (always picked up); armour bit 10 up to 250; ammo bit 5 rounds for each hand's gun; always these amounts (x worth over the cap) | KR:791, KR:793, KR:799, KR:813, KR:814, KR:819, KR:860, KR:862, KR:875 | RSQ_KRHealthBit; RSQ_KRArmorBit; RSQ_KRAmmoBit.TryPickup |
| P7b | Teal bit: 5 rounds (x worth) for each ammo type of the guns carried and in neither hand, once a type; none such: the ammo bit's rule; the teal sprite | KR:893, KR:905, KR:910, KR:912, KR:916 | RSQ_KROtherAmmoBit.TryPickup |
| P8 | Gold bits only with RSQ Score's bank and Gold Bits on; 5 gold banked by "gold.add" | KR:966, KR:951, KR:1025, CV:100, CV:103 | RSQ_KRGoldBit.Share; Value; TryPickup |
| P8 | Special Kills Only: a Big Boss, a Boss, a legendary champion | KR:229, KR:230, KR:231, KR:282, CV:101 | GoldKind; WorldThingDied |
| P8 | Any other kill rolls no gold: its rolls go on to steel and the mix | KR:282, KR:452, KR:465, KR:494, KR:502 | WorldThingDied; Burst; BurstCapped |
| P9 | Steel bits only while Gun Cards answers "cnd.on"; 1 condition through "cnd.repair" | KR:1070, KR:1072, KR:1057, KR:1082 | RSQ_KRSteelBit.Share; Value; TryPickup |
| P10 | Battery bits come only when RSQ FnF asks "kr.battery"; 15% through its torch service | SV:98, BB:10, BB:26, BB:39 | RSQVR_Service.GetInt; RSQ_KRBatteryBit |
| P11 | During a Miniboss fight, a kill within 256 units or 2 s adds 2 health and 2 armour bits, no chance roll | KR:359, KR:371, KR:376, KR:378, KR:381, KR:401, CV:93, CV:94, CV:95, CV:96, CV:97 | FightNow; FightBonus; FightBurst |
| P11b | RSQ Miniboss asks "burst.ammo" each time a Boss loses a life: 6 ammo bits, SoM's throw, every one dropping, one in three teal; Kill Rewards off: none | SV:99, KR:574, KR:576, KR:584, KR:591, Miniboss/zscript/rsqmb/boss.zs:328, Miniboss/zscript/rsqmb/boss.zs:308 | RSQVR_Service.GetInt; AmmoBurst; RSQMB_Boss.LoseLife |
| P12 | A DOWN killer within 3x his reach: bits fly to his plate; health and armour bank, ammo given | KR:307, KR:677, KR:697, KR:705 | WorldThingDied; BankTick; Arrive |
| P13 | A gain counts only when a pickup vanished within 160 units; health and armour to hand 1, ammo to its gun's hand | EV:208, EV:930, EV:940, EV:941, EV:961, EV:962, EV:963 | WorldThingDestroyed; TrackGains |
| P13 | It rises, then flies to the wrist; Gains on You on | EV:1115, EV:1117, EV:1268, EV:841, CV:44 | Advance; Draw; WristOf |
| P14 | Gun Bonsai's "bonsai-level-up": LEVEL UP! at that hand's muzzle; World skips the rest; rows on | EV:237, EV:245, EV:249, EV:250, EV:262, CV:59, CV:61, CV:119 | NetworkProcess; GunHand |
| P14 | World: the new sign queues a LEVEL UP! toast; the Toasts row hides it | WW:235, BN:295, BN:298, BN:300, BN:312, BN:233, BN:455, BN:950, CV:134 | WorldWord; RSQVR_Banners.RewardToast; Toast; ToastsOn |
| P15 | The bar shows while any PowerInvulnerable runs, draining over the time left; god face, else orb | IB:48, IB:149, IB:151, IB:161, IB:189, IB:196, CV:135 | InvLeft; DrawInvBar |
| P16 | "down.up": REVIVE! from the floor ahead, cyan | DN:44, DN:46, WW:168, WW:101 | RSQVR_RSQDownJoin.GetInt; WorldWord; FamilyRgb |
| P16 | World: SlowMo's REVIVE banner is not queued but its health, armour and invulnerable seconds are kept; the REVIVE! sign queues a toast with the non-zero ones | SlowMo/zscript/rsqsm/down.zs:1373, SlowMo/zscript/rsqsm/down.zs:1378, SlowMo/zscript/rsqsm/down.zs:1387, BN:116, BN:119, BN:286, BN:287, BN:288, WW:235, BN:308, BN:312 | Add; KeepRevive; RewardToast |
| P17 | "down.revenge": REVENGE! over the monster, else ahead, magenta | DN:36, DN:38, DN:39, WW:100 | RSQVR_RSQDownJoin.GetInt; FamilyRgb |
| P17 | World: the REVENGE! sign queues a REVENGE! toast | WW:235, BN:298, BN:301, BN:312 | WorldWord; RewardToast |
| P18 | RSQ Score's life: 1UP from the crate, else ahead, gold; World: a 1UP! toast | Score/zscript/rsscore/handler.zs:1118, Score/zscript/rsscore/handler.zs:1120, Score/zscript/rsscore/handler.zs:1122, WW:235, BN:298, BN:302, BN:312 | RS_ScoreHandler WorldWord; WorldWord; RewardToast |
| P19 | "down.time": the label pops at the monster in crimson (needs Damage Numbers) | DN:29, EV:872, EV:884, EV:866, EV:886 | DownTime |
| P20 | A LegenDoom drop's power name shows within 48 units, goes past 60; Drop Words on | LD:192, LD:211, LD:213, LD:216, LD:224, LD:225, CV:129 | RSQVR_LDWord.DropTick |
| P21 | Only Where I Aim: a trace from either hand's gun; the bar 18 tics after; made even at full health | HD:564, HD:573, HD:584, HD:119, BR:243, BR:173, CV:16 | TraceAims; Ensure; RSQTHP_Bar.Update |
| P22 | OVERKILL when the last hit passed zero by half the spawn health (at least 10); off by default | EV:615, EV:807, NU:168, CV:40 | NewHit; ProcessPending; Layout |
| P23 | Damage Chunk: lit 17 tics, drains 10; off by default | BR:77, BR:78, BR:299, BR:305, CV:19 | RSQTHP_Bar.Update |
| P24 | HUD or Both: LEVELUP banner (PLAYER LV, +1 UPGRADE), LEVELGUN (gun, LV n, NEW UPGRADE) by the gun | EV:251, EV:252, EV:270, EV:304, BN:184, BN:185, BN:982, BN:1112, BN:1121 | Banner; Tag; RSQVR_Banners.Add; DrawBanner; DrawLevelGun |
| P25 | Banners off: the band (player) or the tag, a half-size toast at the hand by default | EV:271, EV:272, EV:312, EV:313, EV:83, EV:1311, CV:62 | Banner; Tag; Toast; Draw |
| P26 | A token holder that turns: THREAT!, cleared after rsqvr_ldword_secs (3); row off by default | LD:43, LD:58, LD:62, LD:72, LD:82, LD:84, WD:553, CV:127, CV:128 | RSQVR_LDWord.WorldTick; ShownTick; RSQVR_FxHandler.DrawStep |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | RSQVR_Service's requests, play and UI | SV:94, SV:95, SV:96, SV:97, SV:98, SV:99, SV:100, SV:106, SV:107, SV:108, SV:109, SV:118, SV:124, SV:126, SV:134 | RSQVR_Service.GetInt; GetIntUI |
| W2 | RSQTHP_DnService "crit" marks hits; nothing is drawn for it | EV:1631, EV:219, NU:25 | RSQTHP_DnService.GetInt; MarkCrit |
| W3 | SlowMo's DOWN join: down.target keeps the bar, down.time, down.revenge, down.up | DN:19, DN:24, DN:29, DN:36, DN:44, BR:173, BR:243 | RSQVR_RSQDownJoin.GetInt |
| W4 | Score asks banner (LIFEUP), toast, worldword, invbar.bottom, banner.lives | Score/zscript/rsscore/handler.zs:1114, Score/zscript/rsscore/handler.zs:1147, Score/zscript/rsscore/handler.zs:1154, Score/zscript/rsscore/handler.zs:1161, Score/zscript/rsscore/hud.zs:189, Score/zscript/rsscore/hud.zs:349 | RS_Score Banner; Toast; WorldWord; hud |
| W4 | The new face held back while a +1UP flies; gold banks there; the bar sits under Score's | BN:399, BN:408, KR:966, IB:59 | LivesExchange; RSQ_KRGoldBit.Share; ScoreSpot |
| W4 | Reward Words World: its 1UP word also brings a 1UP! toast | Score/zscript/rsscore/handler.zs:1122, WW:235, BN:298, BN:302 | WorldWord; RewardToast |
| W5 | SlowMo asks banner, toast, scene.push / pop, word.hold / clear | SlowMo/zscript/rsqsm/down.zs:1432, SlowMo/zscript/rsqsm/down.zs:1446, SlowMo/zscript/rsqsm/down.zs:1504, SlowMo/zscript/rsqsm/down.zs:1505, SlowMo/zscript/rsqsm/plate.zs:98, SlowMo/zscript/rsqsm/plate.zs:104 | SlowMo down / plate |
| W5 | Numbers follow the world's speed; rsm_pulse sent by Level-Up Slow Motion | EV:390, EV:1015, EV:1145 | WorldSpeed; Step; Advance |
| W5 | Reward Words World: its REVIVE banner is not queued; its numbers go into the REVIVE! toast | SlowMo/zscript/rsqsm/down.zs:1378, BN:116, BN:119, BN:308 | Add; KeepRevive; RewardToast |
| W6 | Miniboss asks burst.ammo, beam, scene.push / pop, word / hold / clear, pop, worldword, banner, toast | Miniboss/zscript/rsqmb/boss.zs:328, Miniboss/zscript/rsqmb/bossfight.zs:1534, Miniboss/zscript/rsqmb/bossfight.zs:1420, Miniboss/zscript/rsqmb/fight.zs:49, Miniboss/zscript/rsqmb/fight.zs:50, Miniboss/zscript/rsqmb/fight.zs:51, Miniboss/zscript/rsqmb/telegraph.zs:450, Miniboss/zscript/rsqmb/telegraph.zs:507, Miniboss/zscript/rsqmb/tierup.zs:184, Miniboss/zscript/rsqmb/power.zs:72 | Miniboss callers |
| W6 | Crown with pips, chain link; boss for bits; thrall no health bits; siren; Boss Effects Light | HD:687, HD:688, HD:694, BN:227, KR:149, KR:461, BM:199, BM:388 | BossMarkOf; Siren; BossHere; Burst; RSQVR_Beam.Begin; Sparks |
| W7 | Gun Bonsai's level-up event; RSQGB_Service level and name; Kill Rewards asks it nothing (the nodes removed 2026-11-27) | EV:237, EV:259, EV:292, KR:9 | NetworkProcess; GunHand; Tag |
| W8 | Gun Cards: "levelcard" (banners path 62 tics, old toast path 45); its answer | EV:309, EV:326, GunCards/zscript/rsqgc/card.zs:1553 | Tag; RSQGC_Service.GetInt |
| W8 | Steel needs cnd.on; ammo gains land on its +N; it asks toast | KR:1072, EV:978, EV:856, EV:1131, GunCards/zscript/rsqgc/cnd.zs:206 | Share; WorldLoaded; Gain; Advance |
| W9 | Grapple: hooked (within 3 tics, or yanked), stunned; asks worldword | HD:627, HD:629, HD:630, Grapple/zscript/rsqgr/core.zs:842 | MarkersOf |
| W10 | ShieldSaw: locked | HD:634 | MarkersOf |
| W11 | Saber: gripped | HD:637 | MarkersOf |
| W12 | Any RSQTHP_Marker service is asked all five; the Whip and Gun Bonsai VR register one | HD:135, HD:640, HD:641, HD:642, Whip/zscript/rsqwp/whip.zs:1473, GunBonsaiOffhandVR/rsq/zscript/core.zs:748 | MarkersOf |
| W13 | Distance Grab asks toast and word | DistanceGrab/zscript/rsqdg/flight.zs:41, DistanceGrab/zscript/rsqdg/flight.zs:567 | flight |
| W14 | Frozen (count running down) or held (count still, flags borrowed), off the monster | BR:372, BR:376, BR:379 | RSQTHP_Bar.StatusOf |
| W15 | Monsters: tier 1..13 gem; tier names and colours | HD:169, HD:170, BR:345, BN:84, BN:90 | TierOf; Update; TierName; TierRgb |
| W16 | Grenade's fire field interval; it asks toast and worldword | HD:466, Grenade/zscript/rsqgn/hand.zs:211, Grenade/zscript/rsqgn/kinds.zs:82 | FireEvery |
| W17 | Melee, Tactical Rig, Graveyard, GNRC ask by name | Melee/zscript/rsqml/sparks.zs:284, TacticalRig/zscript/rsqtr/rig.zs:143, Graveyard/zscript/gy_Stone.zs:159, weaponsets/GNRC_Reloaded/zscript/rsqb/gn_hand.zs:150 | callers |
| W18 | FnF asks kr.battery and toast | FlashFlare/zscript/rsqff/battery.zs:210, FlashFlare/zscript/rsqff/handler.zs:102 | callers |
| W19 | Any "...MuzzleService" gives the muzzle, else 20 units ahead of the hand | WW:267, WW:271, WW:278, WW:81 | MuzzleAt |
| W20 | Accessibility: colour blind, photosensitive, text size, cue size, all behind RSQA_Menu | A:27, HD:252, HD:342, EV:372, EV:429, EV:887, WD:517, WD:747, A:34, BN:459, BR:457, BR:480 | RSQTHP_A11y.Cv; FindCVars; ReadSettings; RampOf; DownTime; DrawWord; SizeK; SyncSide; SyncParts |
| W21 | Champions: type and mutation icons beside the bar, its own icon hidden while the bar shows | HD:178, HD:186, HD:203, HD:204, BR:346, BR:347 | ChampFrame; MutFrame; ChampIconsTick |
| W22 | LegenDoom: gem from the turn; candidate drawn against its peak; drop words; fist model; economy off: no gold | HD:683, HD:225, LD:213, LD:180, KR:285, KR:286, KR:995 | BossMarkOf; FullOf; DropTick; FistLook; WorldThingDied; FountainCount |
| W23 | Brutal Doom: head hits, helpers and dying bodies, damage-type colours | EV:138, HP:31, HP:34, HP:35, EV:453 | IsHead; RSQVR_Helpers.IsHelper; TypeFam |
| W24 | coldcite's item taken off while ours are on; his menu opens ours | HD:483, MD:469, MD:472 | WorldTick; TopHPBars_Settings |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No input is read (no InputProcess, UiProcess, buttons or bindings in any file); one alias; test events need sv_cheats | KEYCONF.txt:1, BN:358, WW:352 | (search of zscript/); NetworkProcess |
| L2 | No bar until health differs from full, unless aimed | HD:447, HD:516, BR:172, BR:173 | WorldThingDamaged; WorldTick; RSQTHP_Bar.Tick |
| L3 | Own bar hidden in first person; numbers never on players | BR:239, BR:240, EV:129 | RSQTHP_Bar.Update; Eligible |
| L4 | Most Numbers 12; Nearest 24 and Distance Limit off by default | EV:348, EV:1597, CV:43, HD:114, BR:245, CV:21, CV:22 | ReadSettings; Cull; RSQTHP_Bar.Update |
| L5 | Bits live 7 s, gold 20 s, blink out; at most 100 bit actors a death, worth and size above | KR:759, KR:760, KR:718, CV:81, CV:107, KR:433, KR:552, KR:609 | BitTick; VanishTick; BurstCapped; SetWorth |
| L6 | Ammo bit with no hand gun that uses ammo gives nothing | KR:857, KR:860, KR:875 | RSQ_KRAmmoBit.TryPickup |
| L6b | The teal bit feeds only guns outside the hands; all in hand: an ordinary ammo bit | KR:905, KR:910 | RSQ_KROtherAmmoBit.TryPickup |
| L7 | A bit is taken only by touch or by drifting within the reach; reach 0 is off | KR:109, KR:770, KR:779 | MagnetM; BitTick |
| L8 | Gold rolled only on a death that may drop it; any other kill's rolls go on to steel and the mix | KR:282, KR:286, KR:452, KR:465, KR:494, KR:502, CV:101 | WorldThingDied; Burst; BurstCapped |
| L9 | Reward Words World: REVIVE, +1UP, LEVELUP and LEVELGUN banners not queued; one toast per sign instead (REVIVE! with its numbers; SlowMo toasts the mags); HUD or Both: no reward toast | BN:115, BN:116, BN:120, EV:250, DN:40, DN:47, WW:235, BN:298, BN:288, SlowMo/zscript/rsqsm/down.zs:1381 | RSQVR_Banners.Add; NetworkProcess; RSQVR_RSQDownJoin.GetInt; RewardToast |
| L10 | Slow-motion pulse, text colour, wrist toast, tag colour only in the old band and tag | EV:1142, EV:274, EV:316, EV:83, EV:270, EV:304 | Advance; Banner; Tag; Toast |
| L11 | One banner on screen per player, 5 waiting at most; 3 toasts | BN:422, BN:52, BN:204, BN:62, BN:259 | Current; Add; Toast |
| L12 | Drawn for the console player's view | EV:1022, WD:528, BN:937, BM:247 | Step; DrawStep; RenderOverlay; BeamStep |
| L13 | Scene stack and tracks cleared on a map change | SC:115, SC:116, SC:123 | WorldUnloaded; WorldLoaded |
| L14 | Outside VR the aim trace is the view's, main hand only | HD:577, HD:578 | TraceAims |
