# RSQ Miniboss: where each README claim comes from

Commit read: a283738bb (2026-11-27). Line numbers moved to the working tree after the 2026-11-27 build of the owner's
answers (F1 to F4, one weapon a kiosk, the ammo burst). Paths are inside `Miniboss/` unless they start with another mod's folder. `BF` is
`zscript/rsqmb/bossfight.zs`, `HN` `zscript/rsqmb/handler.zs`, `BO` `zscript/rsqmb/boss.zs`, `IT` `zscript/rsqmb/items.zs`,
`GC` `zscript/rsqmb/gestcopy.zs`, `A2` `zscript/rsqmb/arrival2.zs`, `TG` `zscript/rsqmb/telegraph.zs`, `TR`
`zscript/rsqmb/traits.zs`, `TU` `zscript/rsqmb/tierup.zs`, `KI` `zscript/rsqmb/kiosk.zs`, `BB` `zscript/rsqmb/bigboss.zs`,
`BA` `zscript/rsqmb/bigacts.zs`, `BX` `zscript/rsqmb/bigfix.zs`, `RK` `zscript/rsqmb/rank.zs`, `FN`
`zscript/rsqmb/finisher.zs`, `VF` `zscript/rsqmb/vrfinish.zs`, `PW` `zscript/rsqmb/power.zs`, `HU` `zscript/rsqmb/hud.zs`,
`SV` `zscript/rsqmb/service.zs`, `FT` `zscript/rsqmb/fight.zs`; other files are named in full. Each line number is the
line that does the thing, not the start of its function.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | A kill 10 + spawn health / 50 (at most 30); a chain step +6 (at most 30); kills within 105 tics chain | BF:289, BF:290, BF:103, BF:285 | RSQMB_Handler.BfKill |
| H1 | 2 points every 70 tics in which you moved 96 units; x Meter Speed; full at 1000 | BF:341, BF:345, BF:215, BF:218, CVARINFO.txt:2, CVARINFO.txt:3 | BfTick; Fill |
| H1 | The meter's row starts right of Score's bar | HU:73 | MeterRect |
| H2 | A kill counts 4 while Score fills it; Score style x0.25 (at most 120); Gun Bonsai XP x0.2 (at most 40) on the main hand's gun, every 8 tics | BF:289, BF:330, BF:338, BF:387, BF:394, CVARINFO.txt:16, CVARINFO.txt:17 | BfKill; BfTick; GbStep |
| H2 | Meter Fills From Both by default; an absent choice falls back to the other | BF:257, BF:259, BF:260, CVARINFO.txt:18 | FillSources |
| H3 | Full: gold colours; Glow In The Dark's tint and heartbeat | HU:219, BF:229, BF:356, BF:357, BF:1243 | RenderOverlay; Ready; BfTick; HeartBeat |
| H3 | A fight's own monsters never fill it; no fill while busy, in the director's relax (20 s after a fight) or after the map's Boss | BF:280, BF:329, BF:211, BF:214, RK:309, CVARINFO.txt:123 | BfKill; BfTick; Fill; RankTick |
| H4 | Comes by itself after Arrives By Itself (60 s); coasting (intensity under 0.15) counts twice | BF:373, BF:375, RK:64, RK:434, RK:435, CVARINFO.txt:5, CVARINFO.txt:121 | BfTick; DirWaited |
| H4 | Then the guardrails' reasons, the director's hold, the spot; the reason shown under the meter | BF:709, BF:719, BF:724, BF:731, BF:744, BF:746, BF:747, BF:748, BF:754, BF:759, BF:768, RK:425, HU:226 | TryArrive; Guard; DirHold; RenderOverlay |
| H5 | (row gone 2026-11-27) The watch check and Use call nothing: the call-in's input is gone; "callin" answers 0 | BF:359, BF:399, SV:138, CVARINFO.txt:4, MENUDEF.txt:72 | BfTick; GetIntData |
| H6 | The pulse check: Gun Cards' "pulse", else the own copy, else the rule directly; the inside: 60 / 75, gaze 50 / 65 | BF:494, BF:499, BF:501, GC:272, GC:273, GC:352 | PulseCheck; RSQMB_GCopy.PulseRule |
| H6 | Shown while the pulse check holds and the off hand does not steady the gun; stays 70 tics or Gun Cards' Stays After | BF:639, BF:643, BF:644, BF:514, BF:522 | WristCard; TwoHanding |
| H6 | Grey, gold (Call It In on, meter full, nothing called and forced), BIG BOSS! when a Big Boss is due | BF:636, BF:661, BF:672, zscript/rsqmb/wristcard_states.zs:2 | WristCard |
| H6 | Wrist Card row, default on | BF:637, CVARINFO.txt:76, MENUDEF.txt:75 | WristCard |
| H7 | Use on the gold card (shown, alpha 0.5+) sends the card call; it calls only with Call It In on; a chime | BF:676, BF:685, BF:697, BF:699, CVARINFO.txt:4 | WristCard; CallIn |
| H7 | The card call: meter full, not busy; every guardrail skipped but No Monsters; the director never holds it; No Room still stops it | BF:692, BF:693, BF:713, BF:716, RK:419, BF:724 | CallIn; TryArrive; DirHold |
| H8 | Around You by default; the stage turn 3 s at SlowMo's slowest, dark through it | A2:157, CVARINFO.txt:43, CVARINFO.txt:44, BF:1172, BF:1176, BF:1177, BF:1181 | AroundYouOn; StartArrival |
| H8 | Thralls at your sides and behind, 400-700 out, 60 degrees clear in front, 0.5-1 s apart | A2:195, A2:196, A2:207, A2:272, A2:273, A2:278, CVARINFO.txt:45, CVARINFO.txt:47 | RingPlan; ArrTimes |
| H8 | Each spot marked 0.75 s before with its crosshair and a sound; each thrall fights when it lands | A2:160, A2:295, A2:303, A2:304, A2:316, A2:317 | MarkStep; RevealLive |
| H8 | The Boss in front (within 55 degrees), last, 1.25x, invulnerable 1.5 s | BF:891, A2:280, BF:1118, A2:159, BF:1306 | PlanSpot; ArrTimes; ArrivalStep |
| H9 | Damage x (1 - 0.8 x living / total), 0.2 to 1.0; the ring lit while a thrall lives | IT:41, BO:236, BO:678 | RSQMB_Ward.ModifyDamage; ThrallFactor; FxStep |
| H9 | A thrall's death strips the power it gave | HN:391, FT:139, BO:342, BO:350 | Death; ThrallKilled; StripPowers |
| H9 | Thralls 3, up to Thralls + 3 by tier | A2:174, CVARINFO.txt:25 | ThrallWant |
| H10 | Lives 3 (+ inherited); a life lost at 1 hp: refill, invulnerable rsqmb_invuln (5 s) | HN:185, BO:280, BO:316, BO:317, BO:319, CVARINFO.txt:30, CVARINFO.txt:35 | Bind; Step; LoseLife |
| H10 | GUARD while invulnerable; X3 | zscript/rsqmb/bossbar.zs:416, zscript/rsqmb/bossbar.zs:450, zscript/rsqmb/bossbar.zs:467 | DrawBossBar |
| H10 | Each life about 20 s of your damage, never under the bound health | BX:138, BX:129, BX:130, BO:315, CVARINFO.txt:112, CVARINFO.txt:113 | BossBind; BossLifeHP; LoseLife |
| H10 | Steps up each life: bar colour one up, +15% speed, one fresh thrall | BA:210, BA:232, BA:235, BA:237, BA:243, BA:249, CVARINFO.txt:116, CVARINFO.txt:117, CVARINFO.txt:118 | ActChanged; BossActUp |
| H10b | The fresh thrall carries RSQMB_Called: its gun pickup is removed as every thrall's | BA:259, zscript/rsqmb/thralldrops.zs:50, zscript/rsqmb/thralldrops.zs:150 | BossActUp; RSQMB_ThrallDrops.KindOf; WorldTick |
| H10c | Each life a Boss (not a Big Boss) loses: 6 ammo bits at its feet, asked of VisualRewards ("burst.ammo"); Kill Rewards on; none without it | BO:308, BO:328, VisualRewards/pk3/zscript/rsqvr/service.zs:99, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:574, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:576 | LoseLife; RSQVR_Service.GetInt; RSQ_KRHandler.AmmoBurst |
| H11 | Every 20 s (Rank 0) to 10 s (Rank 100); only in sight within 3072 | TG:137, TG:138, TG:234, CVARINFO.txt:130, CVARINFO.txt:131 | RSQMB_Tele.Interval; Step |
| H11 | The roar, the red, 3 s; 2 points, 40 health each, WEAK! over each | TG:243, TG:245, TG:252, TG:257, TG:315, TG:293, TG:341, CVARINFO.txt:132, CVARINFO.txt:140 | WindStart; MakeWeakPoints; WpHealth |
| H11 | All broken: CRITICAL!, stagger 3 s at x2, thralls stagger as long | TG:440, TG:473, TG:474, TG:478, TG:481, TG:487, IT:41, CVARINFO.txt:143, CVARINFO.txt:144, CVARINFO.txt:147 | WindStep; DoBreak |
| H12 | Missed: the attack by kind (fan, ring, beam) | TG:441, TG:188, TG:189, TG:614, TG:620, TG:626 | WindStep; PickKind; Fire |
| H12 | The ring's two gaps (22 degrees half width); jumping over 20 units clears it | TG:1174, TG:1176, TG:1177, TG:1200, TG:1201 | RSQMB_Wave.Ring; Tick |
| H12 | The beam aimed where you stood (does not follow); the fan aimed at you | TG:663, TG:666, TG:650, TG:656 | Beam; Fan |
| H12 | 15 a hit at tier 1, +6% a tier, +25% an act; players only | TG:146, TG:147, TG:148, TG:1014 | Damage; RSQMB_BigShot.SpecialMissileHit |
| H13 | A melee strike (the groups) on a staggered thrall or the Boss in BREAK: +25 health, +15 armour, 250 Score, x2 the Boss; the thrall dies | FN:125, FN:127, FN:146, FN:149, FN:150, FN:151, FN:164, FN:53 | FinDamaged; FinTick; MeleeGroup |
| H13 | A thrall staggers 2 s, once, under 25% of its most health | TG:684, TG:686, CVARINFO.txt:215, CVARINFO.txt:216 | ThrallStep |
| H13 | The slow 1 s, Boss 2 s | VF:229, VF:232, CVARINFO.txt:199, CVARINFO.txt:200 | FinSlow |
| H14 | 8 s within 128 units in a fight sends the nearest living thrall; it shoots less | zscript/rsqmb/camp.zs:31, zscript/rsqmb/camp.zs:39, zscript/rsqmb/camp.zs:40, zscript/rsqmb/camp.zs:44, zscript/rsqmb/camp.zs:78, zscript/rsqmb/camp.zs:80, CVARINFO.txt:53, CVARINFO.txt:54, CVARINFO.txt:55 | CampTick; SendAt |
| H15 | One trait rolled per Boss | TR:93, TR:110 | RollTrait; TraitTick |
| H15 | SUMMONER: every 15 s a 1.5 s cast, 2-3 fodder, cap 6; each 10% of the life's health dealt takes a ring | TR:349, TR:396, TR:397, TR:424, TR:437, TR:469, TR:474, TR:492, CVARINFO.txt:159 | SumInterval; SumStart; SumCutHP; SumHurt; SumLand |
| H16 | CHARGER: two stamps, the line, the rush; wall or skid: stunned 2 s at x1.5; hit: 20 damage, knockback, sooner | TR:598, TR:601, TR:606, TR:607, TR:668, TR:674, TR:708, TR:1081, TR:721, TR:725, TR:728, TR:532 | ChgWindStep; ChgRushStep; ChgStun; TakeMult; ChgHit; ChgStep |
| H17 | SHIELDED: blows within 90 degrees of its front blocked; 3 rim points of 120; shattered for the life; BREAK opens it | TR:845, TR:856, TR:766, TR:769, TR:759, TR:877, TR:327, TR:836 | Blocks; MakeRim; ShdStep; Shatter; LifeLost |
| H18 | SPLITTER: SPLITTING! warning; two halves at 0.7 dealing x0.75, the health split; the life ends when both are down | TR:961, TR:971, TR:1017, TR:1050, TR:1054, TR:1061, TR:1095, TR:941, TR:947 | SplStep; Split; OutMult |
| H19 | Killed: BossDied: Score's "Miniboss Called" 1500; the words; the crate, kiosk, Big Boss bar; world tier +1; the thralls freed | HN:412, TU:70, TU:71, TU:73, TU:96, TU:131, BO:484 | BossDied; TierUpOnKill; TierUpNow; Finish |
| H20 | Score's life crate spawned at the death spot; touching it is +1 Score life (Score's code) | TU:146, TU:151, Score/zscript/rsscore/lifecrate.zs:100 | DropLifeCrate; RSQ_ScoreLifeCrate.TryPickup |
| H21 | A Score life spent in a fight, or leaving: they leave on beams, BOSS WINS!, tier -1; the Big Boss bar +25% | TU:235, TU:243, TU:290, TU:291, TU:320, TU:355, TU:369, TU:297 | LossTick; FightLost; TierDownNow; LossOnLeave |
| H22 | Opens within 3 m after 2 s still (moved under 16 units, speed under 2); shut in a fight | KI:1020, KI:1021, KI:1056, KI:1062, KI:1034, KI:1036, CVARINFO.txt:81, CVARINFO.txt:82 | RSQMB_Kiosk.Watch |
| H22 | Up to three offers on guns the buyer carries, priced in gold; needs BD22 VR's kiosk service and Score | KI:112, KI:291, KI:373, KI:261, TU:172 | Drop; OwnedRoll; DropKiosk |
| H23 | A hand's ray or the hand in a box picks the offer; the card; the dotted beam | KI:1154, KI:1157, KI:1165, KI:1186, KI:1206 | Interact |
| H23 | That hand's trigger is taken from the gun while it points | KI:1482, KI:1483, KI:1489, KI:1491 | RSQMB_KioskInput.InputProcess |
| H24 | Trigger buys if the bank holds the price; BD22 VR gives it; each once; prices | KI:1347, KI:1355, KI:1357, KI:1358, KI:247, KI:248, KI:249, KI:251, CVARINFO.txt:83, CVARINFO.txt:86 | Buy; PriceOf |
| H24b | One weapon a kiosk: after a purchase the other offers are shut (greyed: grey plate and price, no gun; the card and the counter say ONE WEAPON PER KIOSK); a trigger on one: the key-try sound and the toast | KI:153, KI:1359, KI:1363, KI:629, KI:646, KI:648, KI:706, KI:563, KI:1338, KI:1340, KI:1341 | OfferShut; Buy; BuildOffer; BuildCard; Note |
| H25 | Alt fire on an offer, or the LUCKY button then an offer: a Score life, +1 rarity; once; Boss kiosk stops at Rare | KI:1484, KI:1509, KI:1326, KI:1332, KI:1381, KI:1383, KI:1384, KI:1400 | InputProcess; NetworkProcess; Buy; Lucky |
| H25b | The card's LUCKY lines only under LUCKY's cap (Rare on a Boss kiosk, Epic elsewhere); none after a weapon is bought (no button, refused); its life costs no Rank (Score's "life.spend" sends no "rank.life") | KI:156, KI:704, KI:707, KI:711, KI:1129, KI:1325, KI:1380, Score/zscript/rsscore/gold.zs:67, RK:336 | LuckyTop; BuildCard; InBox; Buy; Lucky; RankTick |
| H26 | REPAIR: every gun back, 1 gold a missing point, at least 10 | KI:239, KI:1443, KI:1445, CVARINFO.txt:88, CVARINFO.txt:89 | RepairCost; Repair |
| H27 | Folds 24 units (0.75 m) past the range; stays until the map ends | KI:1043, KI:25 | Watch (header) |
| H28 | +250 a Boss won or lost; full: due; called as a Boss or by itself; never the map limit | BB:40, BB:61, BB:62, TU:297, BB:96, BB:98, BB:109, BF:687, BF:747 | ExStep; ExTick; ExCallIn; CallIn; Guard |
| H29 | The card before it lands; alone; each life about 60 s of your damage; 3 points of 60; drops per point and per CRITICAL!; x3 for 4 s | zscript/rsqmb/bigcard.zs:40, zscript/rsqmb/bigcard.zs:62, A2:172, BX:109, BX:100, TG:293, TG:455, TG:483, TG:473, TG:474, CVARINFO.txt:142, CVARINFO.txt:148, CVARINFO.txt:150 | CardPlan; ThrallWant; BigLifeHP; WeakBroken; DoBreak |
| H29 | Every Big Boss has a kit with three weak points | zscript/rsqmb/bk/bk_tyrant.zs:17, zscript/rsqmb/bigkit.zs:55 | RSQMB_BigKit.Lookup |
| H30 | GUARD: no damage while its summons live, 20 s at most; the lines | BA:303, BA:305, BA:306, BA:315, BA:316, BA:318, IT:36, CVARINFO.txt:184 | GuardStart; GuardStep; Tethers |
| H31 | A Big Boss's kiosk: five Epic offers, no LUCKY | KI:264, KI:291, KI:113, KI:580 | Drop; Note |
| H32 | REVENGE / REVIVE: x1.5 for 10 s, DAMAGE UP toast | PW:104, PW:105, PW:65, PW:72, CVARINFO.txt:105, CVARINFO.txt:106 | RSQMB_RSQDownJoin.GetInt; Comeback |
| H33 | +10% a world tier colour above Common, tier clamped at 10 (x1.9) | PW:36, PW:37, PW:52, PW:89, CVARINFO.txt:104 | ColourMult; ModifyDamage; RSQMB_PowerHandler |
| H34 | Rank: a map's kills share 2 points; calm combat; heavy damage -2, DOWN -3, death -6; Score's lives -8 (Rank Down per Life, once) / +4 | RK:261, RK:351, RK:291, RK:334, RK:268, RK:231, SV:155, CVARINFO.txt:109, CVARINFO.txt:110 | RankKill; RankTick; RankDamaged; RankPlayerDied; RankLife |
| H34 | Every 8 points a colour, written to the world tier; the map's window; RANK nn | RK:50, RK:113, RK:210, RK:375, HU:149, CVARINFO.txt:102, CVARINFO.txt:103, CVARINFO.txt:120 | TierOfRank; CeilTier; RankTick; RankLine |
| H35 | VR Finisher: a melee strike on a knocked-down (IsDown) or dazed (RSQ_Dazed) monster, not a boss, not over 1000, not a fight's: gibbed, bonus items, 100 Score, the slow | VF:98, VF:102, VF:103, VF:118, VF:120, VF:139, VF:205, VF:209, VF:213, CVARINFO.txt:195, CVARINFO.txt:197, CVARINFO.txt:198 | WorldThingDamaged; Staggered; WorldTick; Pay |
| H36 | BD22's scene tokens taken; the body put back and gibbed; paid | VF:250, VF:58, VF:181, VF:189, VF:192, CVARINFO.txt:196 | RSQMB_SceneGuard.HandlePickup; SceneToken; Restore |
| H37 | LegenDoom Lite: x3 health, at half it transforms: full health, stat boost, x2; loot by its health | zscript/rsqmb/ldlite.zs:104, zscript/rsqmb/ldlite.zs:118, zscript/rsqmb/ldlite.zs:121, zscript/rsqmb/ldlite.zs:123, zscript/rsqmb/ldlite.zs:135, CVARINFO.ldlite:5 | RSQMB_LDLMon.Start; DoEffect |
| H37 | Stands down while LegenDoom is loaded | zscript/rsqmb/ldlite.zs:35, zscript/rsqmb/ldlite.zs:211 | RSQMB_LDL.LegenDoomHere; RSQMB_LDLHandler.WorldLoaded |
| H38 | Champions: chance (4 + 10 x skill) x (skill + 1) of 256 at Difficulty Based; the bundle | zscript/champions/handler.txt:417, zscript/champions/handler.txt:419, zscript/champions/handler.txt:421, zscript/champions/baseclass.txt:283, CVARINFO.txt:239 | champion_Handler.WorldThingSpawned |
| H39 | Classic: Thralls to Thralls + 2 in front; all held and invulnerable to the 5 s count's end | A2:173, BF:127, BF:1309, BF:1310, BF:1620 | ThrallWant; ArrivalStep; Reveal |
| H40 | Call It In off: the card stays grey and its Use calls nothing | BF:636, BF:676, BF:685, CVARINFO.txt:4 | WristCard; CallIn |
| H41 | Ignore Spawn Restrictions: only the map limit and cooldown still hold; the loose spot | BF:745, BF:747, BF:748, BF:749, BF:957, BF:959, BF:1007, CVARINFO.txt:11 | Guard; PlanSpot |
| H42 | Graves Rise as it lands: one a stone or per thrall, map or radius | BF:1223, BF:1229, BF:1232, BF:1233, BF:1312, CVARINFO.txt:20, CVARINFO.txt:21 | Graves; ArrivalStep |
| H43 | Rank off: the world tier as set; wins and losses still step it | RK:314, RK:129, TU:128, TU:352 | RankTick; RankStepTier; TierUpNow; TierDownNow |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | Score: kill serial / style / victim, its bar's place, awards, lives, crate, gold, life spend; it sends "rank.life", asks "rank" and "meter.bottom" | BF:321, BF:327, BF:328, HU:102, HN:471, FN:151, TU:234, TU:146, KI:1355, KI:1400, Score/zscript/rsscore/handler.zs:251, Score/zscript/rsscore/handler.zs:775, Score/zscript/rsscore/hud.zs:186 | BfTick; ScoreSpot; Award; LossTick; Buy; Lucky |
| W2 | Gun Bonsai VR: "level", "xp", "xp.next"; RSQ_Dazed | BF:272, BF:387, VF:118 | GbSvc; GbStep; Staggered |
| W3 | SlowMo: start.bossfight, arrows, g2.slow, DOWN joins, "down"; the bar steps aside while DOWN; what it asks | BF:1177, FT:52, FT:53, VF:232, PW:104, RK:333, zscript/rsqmb/bossbar.zs:350, zscript/rsqmb/bossbar.zs:359, SlowMo/zscript/rsqsm/countdown.zs:103, SlowMo/zscript/rsqsm/countdown.zs:257, SlowMo/zscript/rsqsm/clock.zs:607, SlowMo/zscript/rsqsm/clock.zs:2218, SlowMo/zscript/rsqsm/clock.zs:2219, SlowMo/zscript/rsqsm/clock.zs:2251, SlowMo/zscript/rsqsm/down.zs:831, SlowMo/zscript/rsqsm/down.zs:845 | StartArrival; ArrowAdd; FinSlow; BBDown |
| W4 | VisualRewards: beams, words, pops, toasts, banners, scene music, the ammo burst; what it asks | BF:1534, FT:50, TG:341, TG:507, TU:184, BF:1420, KI:1458, BO:328, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:149, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:163, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:229, VisualRewards/pk3/zscript/rsqvr/killrewards.zs:359, VisualRewards/pk3/zscript/rsqthp/handler.zs:692, VisualRewards/pk3/zscript/rsqthp/handler.zs:687, VisualRewards/pk3/zscript/rsqvr/bossname.zs:92, VisualRewards/pk3/zscript/rsqvr/banners.zs:736, VisualRewards/pk3/zscript/rsqvr/invbar.zs:91 | BeamNow; Word; MakeWeakPoints; Say; Banner; SceneMusic; Toast |
| W5 | Glow In The Dark: tint, dark, wave, re-roll, the room glow; what it asks | BF:247, BF:1181, FT:54, FT:124, FT:329, GlowInTheDark/zscript/rsqgd/react.zs:96, GlowInTheDark/zscript/rsqgd/react.zs:98, GlowInTheDark/zscript/rsqgd/react.zs:99 | Glow; StartArrival; Wave; FightTick; RoomGlow |
| W6 | RSQ Monsters: the world tier, the roster, EX Big Bosses, the act token, tier changes held | TU:63, FT:421, FT:434, BB:156, BB:157, BA:204, FT:182 | TuWorld; ApplyFrom; ExPoolBuild; ActMark; HoldTier |
| W7 | Gun Cards: "pulse", Stays After, Watch Card, Weapon Condition; asks "fightcard.up" | BF:494, BF:643, BF:647, KI:236, KI:1445, GunCards/zscript/rsqgc/card.zs:766, SV:131 | PulseCheck; WristCard; RepairCost; Repair |
| W8 | BD22 VR Reloaded: the kiosk service, kiosk.take, the scene tokens, IsDown | KI:227, KI:303, KI:1357, VF:58, VF:118 | Legend; Drop; Buy; SceneToken; Staggered |
| W9 | LegenDoom: legendary thralls and Boss, best health, Lite stands down | HN:177, HN:288, HN:311, HN:334, zscript/rsqmb/ldlite.zs:211 | Bind; Inherit; LDBossHealth |
| W10 | Tactical Rig asks "callin" (always 0 now), "wasboss" | SV:138, SV:91, TacticalRig/zscript/rsqtr/rig.zs:2191, TacticalRig/zscript/rsqtr/cig.zs:394 | GetIntData |
| W11 | Melee, Grapple ask "bossfor" headlock / yank, Grapple "shielded" (always 0) and "invulnerable"; their damage types | SV:145, SV:146, Melee/zscript/rsqml/headlock.zs:168, Grapple/zscript/rsqgr/util.zs:182, Grapple/zscript/rsqgr/util.zs:191, FN:62 | GetIntData; MeleeGroup |
| W12 | ShieldSaw asks "bossfor" ldhealth; its grind and disc count | SV:147, ShieldSaw/zscript/ssq/disc.zs:666, FN:61 | GetIntData; MeleeGroup |
| W13 | Saber and Whip damage types count | FN:57, FN:58 | MeleeGroup |
| W14 | Graveyards: "bones.graves", "stones.pulse" | BF:1214, BF:1233, BF:1245 | GySvc; Graves; HeartBeat |
| W15 | Accessibility: Photosensitive, Text Size, colour-blind, Rumble Backup, Wrist Turn; off without it (the RSQA_Menu guard) | zscript/rsqmb/a11y.zs:27, zscript/rsqmb/a11y.zs:34, HU:108, TR:195, TR:578, TR:582, GC:340 | RSQMB_A11y.Cv; Photo; ScoreSpot; CBOn; Stamp; Way |
| W16 | RSQMB_Service's requests; the gone ones answered 0; RSQMB_GCopyService's | SV:82, SV:89, SV:91, SV:93, SV:94, SV:95, SV:96, SV:97, SV:98, SV:99, SV:100, SV:105, SV:109, SV:114, SV:123, SV:124, SV:125, SV:126, SV:131, SV:132, SV:141, SV:155, SV:160, SV:161, SV:187, SV:192, SV:197, SV:208, SV:209, GC:414, GC:418, GC:419, GC:420, GC:421, GC:427 | RSQMB_Service; RSQMB_GCopyService |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | No key: KEYCONF holds only a commented line | KEYCONF.txt:1, KEYCONF.txt:2 | KEYCONF |
| L2 | Use is read from the player's command, not taken; the only input handler takes fire keys at the kiosk | BF:674, KI:1482, KI:1485 | WristCard; RSQMB_KioskInput.InputProcess |
| L2b | Use while the gold card shows or lingers 2 s calls the fight | BF:643, BF:644, BF:676 | WristCard |
| L3 | The checks need hand poses (OverrideAttackPosDir); the timer does not | GC:281, BF:419, BF:375 | RawGood; InnerDot; BfTick |
| L4 | (row gone 2026-11-27: the watch check and Use call nothing; H5) | BF:359 | BfTick |
| L5 | Per Map Cap 1; no fill after; the Big Boss bar in its place | CVARINFO.txt:8, BF:207, BF:214, BF:747, HU:213 | MapBossDone; Fill; Guard; RenderOverlay |
| L6 | The kiosk needs BD22 VR's ready kiosk service and Score; only carried guns; none rolled: no kiosk; one weapon a kiosk, REPAIR not limited | KI:261, KI:266, KI:373, TU:176, KI:153, KI:1322 | Drop; OwnedRoll; DropKiosk; OfferShut; Buy |
| L7 | Tier changes turned back during a fight; Rank waits | FT:159, FT:182, RK:374 | HoldTiers; HoldTier; RankTick |
| L8 | A thrall's gun pickup is removed | zscript/rsqmb/thralldrops.zs:145, zscript/rsqmb/thralldrops.zs:150 | RSQMB_ThrallDrops.WorldTick |
| L9 | No BOSS flag: only FULLVOLSEE / FULLVOLDEATH / DONTMORPH are written; the "bossfor" switches | BO:424, BO:425, BO:431, SV:141 | RSQMB_Boss.Flags; GetIntData |
| L10 | A Big Boss alone; no EX pool: the map's strongest | A2:172, BF:866 | ThrallWant; PlanArrival |
| L11 | No beam: teleport fog and sound; no VisualRewards: a BIGFONT print, no ammo burst | BF:1539, BF:1540, TG:509, BO:328 | BeamNow; Say; LoseLife |
