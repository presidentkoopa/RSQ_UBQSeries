# RSQ Distance Grab: where each README claim comes from

Commit read: 0252337bd (2026-11-27), then remapped the same day to the working tree after refused ammo said AMMO FULL
(flight.zs) and a thrown barrel was handed to RSQ Melee (hold.zs: one row added after H17, so the old H18 and later are
one higher; the new H18 rows, one H27 row and one W1 row were read from the changed code). Paths are inside `DistanceGrab/`; a file named without a folder (`grab.zs`,
`flight.zs`, `hold.zs`, `throw.zs`, `near.zs`, `door.zs`, `lockon.zs`, `reach.zs`, `aim.zs`, `cone.zs`, `policy.zs`,
`mass.zs`, `laser.zs`, `feel.zs`, `tell.zs`, `voxel.zs`) is in `zscript/rsqdg/`. A path starting
`../` is another mod's file, cited only where the README says that mod does something. Each line number is the line
that does the thing, not the start of its function. H rows follow the README's How to play table from the top. Remapped again 2026-11-27 after the Grab Keys were removed (owner: gesture only): the old H39 to H42, W11 and L18
rows went with them, the old H43 and later are four lower, the old W12 and later one lower, and L2 was re-read.

## How to play

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| H1 | Palm out: the absolute roll within Roll Tolerance (30) of Palm Roll (90), and the hand's pitch not under Min Hand Pitch (-30) | reach.zs:118, reach.zs:121, reach.zs:126, CVARINFO.txt:75, CVARINFO.txt:79, CVARINFO.txt:86 | RSQDG_Reach.PalmPose |
| H1 | The hand's pieces are drawn only while it has a lock or the palm gate passes; nothing with the mechanic off | laser.zs:460, laser.zs:461, laser.zs:366, CVARINFO.txt:17 | RSQDG_Laser.DrawHand; TickHands |
| H1 | Beam, dot and cone each have a switch; with Show When Idle the idle line is traced to the first surface, up to Reach | laser.zs:385, laser.zs:386, laser.zs:387, laser.zs:472, laser.zs:496, laser.zs:498, CVARINFO.txt:225, CVARINFO.txt:233, CVARINFO.txt:235, CVARINFO.txt:241 | RSQDG_Laser.TickHands; DrawHand |
| H1 | The cone drawn is one frame per degree of Aim Width, scaled by Reach; the test is Reach (512) and Aim Width (12) | laser.zs:605, laser.zs:609, cone.zs:34, cone.zs:35, cone.zs:107, cone.zs:110, CVARINFO.txt:18, CVARINFO.txt:19 | RSQDG_Laser.DrawCone; RSQDG_Cone.Best |
| H1 | With nothing found the pieces wear the idle translation, which is blue | laser.zs:351, TRNSLATE.txt:39 | RSQDG_Laser.Tint |
| H2 | An armed hand with no lock takes what the cone has; Lock Delay 0 locks the same tic | grab.zs:391, grab.zs:393, grab.zs:398, grab.zs:399, CVARINFO.txt:100 | RSQDG_Grab.WorldTick |
| H2 | The lock is stored and the hand is told: one tick | grab.zs:232, grab.zs:237, feel.zs:456 | RSQDG_Grab.TryLock; RSQDG_Feel.OnLock |
| H2 | While locked: a steady rumble (0.15 by default), the green "have" glow, the beam in its locked colour | feel.zs:552, feel.zs:554, CVARINFO.txt:262, tell.zs:52, tell.zs:106, laser.zs:455, laser.zs:349, TRNSLATE.txt:31 | RSQDG_Feel.Level0; RSQDG_Tell.UpdateGlow; GlowLook; RSQDG_Laser.DrawHand; Tint |
| H2 | Scored on angle, a quarter on distance, divided by the root of the kind's weight; sight is asked last | cone.zs:117, cone.zs:138, cone.zs:143, CVARINFO.txt:21 | RSQDG_Cone.Best |
| H2 | Weights: barrel 4; gun, key, flare 2; ammo, health, armour 0.6; +1 bonuses 0.3; any other pickup 1 | policy.zs:253, policy.zs:274, policy.zs:291, policy.zs:251, policy.zs:266, policy.zs:286, policy.zs:287, policy.zs:222, policy.zs:297 | RSQDG_Policy.Build |
| H3 | A lock ends when the hand is no longer armed, when the policy no longer allows the thing, or past 1.25 times Reach | grab.zs:418, grab.zs:425, grab.zs:430, grab.zs:434 | RSQDG_Grab.ValidateLock |
| H4 | The palm pose ending is the release: a carried thing is let go, else a lock is resolved | grab.zs:369, grab.zs:370, grab.zs:376 | RSQDG_Grab.WorldTick |
| H4 | The release launches when the fastest upward wrist tic of the last 7 is Flick Strength (5 degrees) or more | grab.zs:256, grab.zs:257, grab.zs:259, grab.zs:262, aim.zs:384, aim.zs:401, aim.zs:429, CVARINFO.txt:126 | RSQDG_Grab.Resolve; RSQDG_Aim.PeakPitchUp; SampleWrist |
| H4 | Flight Path 2 (Arc, the default) is the written path | flight.zs:230, flight.zs:232, flight.zs:271, CVARINFO.txt:142 | RSQDG_Flight.Launch |
| H4 | Its time is distance over Arc Speed (22 m/s), kept between 6 and 40 tics; the hump is 0.25 of the distance | flight.zs:1090, flight.zs:1091, flight.zs:1092, flight.zs:1093, flight.zs:1095, flight.zs:1143, CVARINFO.txt:289, CVARINFO.txt:290, CVARINFO.txt:291, CVARINFO.txt:293 | RSQDG_Flight.StartPath; StepPath |
| H4 | One end over end turn across the flight; a trail particle every other tic | flight.zs:1241, flight.zs:1284, CVARINFO.txt:299, flight.zs:949, flight.zs:950, CVARINFO.txt:184 | RSQDG_Flight.SaveTumble; StepTumble; WorldTick |
| H4 | A tick at launch, then a level that rises with the flight's progress | feel.zs:468, feel.zs:548 | RSQDG_Feel.OnLaunch; Level0 |
| H5 | No flick: the lock is ended with no launch | grab.zs:278, grab.zs:290 | RSQDG_Grab.Resolve; Unlock |
| H6 | "Held" is the hand armed, and the pose sets it each tic | grab.zs:114, grab.zs:360 | RSQDG_Grab.Held; WorldTick |
| H6 | On the way in and within Catch Distance (24), a held hand catches; so does one at the end of the path | flight.zs:974, flight.zs:976, flight.zs:981, flight.zs:983, flight.zs:1004, CVARINFO.txt:160 | RSQDG_Flight.WorldTick |
| H6 | The catch: one tick, two for a heft of 0.55 or more, the thud, the bloom at the palm | feel.zs:481, feel.zs:482, feel.zs:485, laser.zs:285, laser.zs:433, CVARINFO.txt:264, CVARINFO.txt:191 | RSQDG_Feel.OnCatch; RSQDG_Laser.Burst; DrawHand |
| H7 | Arrived and not caught: it waits Catch Window (4) tics, then the pull ends as missed and it falls | flight.zs:1007, flight.zs:1009, flight.zs:1029, CVARINFO.txt:161 | RSQDG_Flight.WorldTick |
| H8 | With Use On Catch on, a caught Inventory is picked up through the game's own pickup | flight.zs:369, flight.zs:384, flight.zs:389, flight.zs:646, CVARINFO.txt:171 | RSQDG_Flight.Catch; TakeInto |
| H9 | The gun the pickup gave goes to the catching hand: queued and raised in the off hand, or made the main hand's pending weapon | flight.zs:662, flight.zs:733, flight.zs:788, flight.zs:751, flight.zs:752 | RSQDG_Flight.TakeInto; HandKeep; TickOffHand |
| H9 | Not moved: melee, off-hand-only, NoHandSwitch, two-handed, UBQS_ / SSQ_ / RSQ_Hands / Fist; a gun already in the other hand | flight.zs:524, flight.zs:525, flight.zs:526, flight.zs:527, flight.zs:530, flight.zs:728, flight.zs:742 | RSQDG_Flight.HandNo; HandKeep |
| H10 | A bonus that would raise nothing is refused before the pickup; health or armour the game refuses is named after it | flight.zs:579, flight.zs:589, flight.zs:627, flight.zs:630, flight.zs:663, flight.zs:666 | RSQDG_Flight.FullWord; TakeInto |
| H10 | A gun the pickup refused that you own: refused as full; caught by the off hand, yours is raised there | flight.zs:671, flight.zs:675, flight.zs:678 | RSQDG_Flight.TakeInto |
| H10 | The refused catch ends the flight, puts the thing in front of your feet and says the word | flight.zs:408, flight.zs:412, flight.zs:413, flight.zs:415 | RSQDG_Flight.Catch |
| H10 | The word: VisualRewards' toast, else its word, else a centre print; a soft spike in the hand | flight.zs:549, flight.zs:552, flight.zs:554, flight.zs:557 | RSQDG_Flight.SayFull |
| H11 | A catch the pickup did not take goes to the hold; a held thing is weightless, pass-through and not collectable | flight.zs:422, hold.zs:190, hold.zs:191, hold.zs:192 | RSQDG_Flight.Catch; RSQDG_Hold.Take |
| H11 | Its place is Hold Distance (0.30 m) plus its half size ahead of the hand, lowered by the sag | hold.zs:550, hold.zs:556, hold.zs:557, CVARINFO.txt:209 | RSQDG_Hold.Target |
| H11 | A spring: the arm's motion times its share, plus the gap times k, capped; share, k and cap fall with weight | hold.zs:686, hold.zs:687, hold.zs:689, hold.zs:692, hold.zs:695 | RSQDG_Hold.WorldTick |
| H11 | Heavy things hang lower and dip in a swing; the roll follows the wrist's turn since the catch | hold.zs:574, hold.zs:281, CVARINFO.txt:305, CVARINFO.txt:306 | RSQDG_Hold.UpdateSag; Turn |
| H12 | Speed factor 1 / (1 + carried kg / 120), never under 0.2; the barrel is 60 kg | hold.zs:968, hold.zs:972, hold.zs:973, hold.zs:1019, MASSDEF.txt:78, CVARINFO.txt:215, CVARINFO.txt:216 | RSQDG_Hold.UpdateBurden; RSQDG_Burden.GetSpeedFactor |
| H13 | The palm's release of a carry the grip does not own; a hand under 0.5 m/s releases at once | grab.zs:375, hold.zs:498, hold.zs:488 | RSQDG_Grab.WorldTick; RSQDG_Hold.LetGoPalm |
| H13 | Under 0.5 m/s after weight and boost it is not a throw; it is given to the air and falls | hold.zs:366, hold.zs:411, hold.zs:418 | RSQDG_Hold.Release |
| H14 | A moving hand: the let-go waits until a forward stroke of 1 m/s or more falls under 70% of its fastest, at most 9 tics | hold.zs:499, hold.zs:508, hold.zs:512, hold.zs:634, hold.zs:485, hold.zs:486, hold.zs:487 | RSQDG_Hold.LetGoPalm; PalmDue; WorldTick |
| H14 | The throw is the fastest forward 2-tic window (within 60 degrees of your facing) times Throw Strength, times arm / (arm + kg), times Throw Boost | hold.zs:345, aim.zs:312, aim.zs:314, hold.zs:354, hold.zs:355, hold.zs:359, CVARINFO.txt:180, CVARINFO.txt:181, CVARINFO.txt:197 | RSQDG_Hold.Release; RSQDG_Aim.ThrowVelocity |
| H14 | A throw plays the whoosh | hold.zs:419 | RSQDG_Hold.Release |
| H15 | A thrown thing with no barrel lock is bent onto a monster within Throw Aim Assist (12) degrees, 32 to 1200 units, in sight, and its lob solved | hold.zs:409, hold.zs:853, hold.zs:866, hold.zs:868, hold.zs:875, hold.zs:879, CVARINFO.txt:186 | RSQDG_Hold.Release; Assist |
| H16 | Damage is half kg times speed squared over Impact Damage (15), at least 1 | throw.zs:477, throw.zs:478, throw.zs:482, CVARINFO.txt:201 | RSQDG_Throw.DamageFor |
| H16 | Nothing under Min Impact Speed (3 m/s); a pass-through thing overlapping a body strikes it; a stop that halves the speed is the impact | throw.zs:707, throw.zs:715, throw.zs:730, throw.zs:769, throw.zs:773, CVARINFO.txt:202 | RSQDG_Throw.WorldTick |
| H16 | The blow is dealt with the thrower as source; Stagger From (20) or more sets Pain and shoves | throw.zs:553, throw.zs:518, throw.zs:520, throw.zs:523, CVARINFO.txt:182 | RSQDG_Throw.Strike; Stagger |
| H17 | An "impact explode" thing thrown at Barrel Blast (4 m/s) or more is killed at its impact with the thrower as source | throw.zs:324, throw.zs:634, throw.zs:635, throw.zs:636, throw.zs:649, MASSDEF.txt:78, CVARINFO.txt:203 | RSQDG_Throw.Watch; Impact |
| H18 | A thrown thing (the arm's part over 0.5 m/s), shootable and alive, is offered to RSQML_Service "barrel.throw" with the hand and the throw's direction; a set-down never is | hold.zs:366, hold.zs:382, hold.zs:386, hold.zs:455, hold.zs:456, hold.zs:466 | RSQDG_Hold.Release; MeleeThrow |
| H18 | On 1 the hand lets go and nothing of our throw runs: the whoosh from you, the carry forgotten, "hold.throw" told with no thing | hold.zs:373, hold.zs:389, hold.zs:392, hold.zs:394, hold.zs:395, feel.zs:504, feel.zs:505 | RSQDG_Hold.Release; RSQDG_Feel.OnRelease |
| H18 | Melee launches it only with its Barrel Launch on and for a barrel by its own rule | ../Melee/zscript/rsqml/service.zs:141, ../Melee/zscript/rsqml/service.zs:148 | RSQML_Service.GetInt |
| H19 | The grip is a key code from the two lists (446; 443 436); the press is eaten and sent only when the hand is ready | near.zs:86, near.zs:87, near.zs:91, near.zs:98, near.zs:99, CVARINFO.txt:45, CVARINFO.txt:46 | RSQDG_Near.InputProcess |
| H19 | Ready: a thing the policy allows within Walk Up Reach (0.30 m) of the palm, the hand empty | near.zs:259, near.zs:159, near.zs:161, near.zs:190, near.zs:193, CVARINFO.txt:42, CVARINFO.txt:43 | RSQDG_Near.WorldTick; FindNearDist |
| H19 | The press: a pickup goes through the same pickup as a catch; anything else, or a pickup not taken, is carried and the grip owns it | near.zs:297, near.zs:301, near.zs:309, near.zs:311, near.zs:325, near.zs:327 | RSQDG_Near.NetworkProcess |
| H19 | A full gun, health or armour is left where it is with the word | near.zs:318, near.zs:320, near.zs:322 | RSQDG_Near.NetworkProcess |
| H20 | The grip let go: a carry the grip owns is released, by the same Release as the palm's | near.zs:105, near.zs:279, hold.zs:331 | RSQDG_Near.InputProcess; NetworkProcess; RSQDG_Hold.Release |
| H21 | A grip press on a full hand makes the grip the owner; a hand the grip owns is skipped by the palm's let-go | near.zs:288, near.zs:292, grab.zs:375 | RSQDG_Near.NetworkProcess; RSQDG_Grab.WorldTick |
| H21 | A grip already down at the catch owns it; a grip still held on a carry it does not own presses for it | flight.zs:427, near.zs:72, near.zs:73, near.zs:120, near.zs:123 | RSQDG_Flight.Catch; RSQDG_Near.TakeOnCatch; UiTick |
| H22 | The other hand not carrying, its palm within the thing's body plus 0.25 m: both hands, with a thud | hold.zs:657, hold.zs:658, hold.zs:837, hold.zs:839, hold.zs:842, hold.zs:843 | RSQDG_Hold.WorldTick; BothHands |
| H22 | It sits midway between the two targets and counts as its weight over Two Hand Lift (2) | hold.zs:664, hold.zs:824, hold.zs:831, CVARINFO.txt:192 | RSQDG_Hold.WorldTick; EffKg; TwoHandK |
| H23 | With Swing Hits on, the held thing's own travel at Swing Hits From (3 m/s) or more is swept against monsters | hold.zs:749, hold.zs:754, hold.zs:755, hold.zs:756, hold.zs:780, CVARINFO.txt:188, CVARINFO.txt:189 | RSQDG_Hold.SwingTick |
| H23 | Up to 4, each once per swing; the throw's damage rule; a thud and a tick | hold.zs:776, hold.zs:784, hold.zs:795, hold.zs:797, hold.zs:803, hold.zs:813, hold.zs:815, hold.zs:722 | RSQDG_Hold.SwingTick |
| H24 | A shield is a held thing that is no pickup, a corpse or no monster, 20 kg or more, with Body Shield on | hold.zs:888, hold.zs:917, CVARINFO.txt:193 | RSQDG_Hold.Shieldy; ShieldTick |
| H24 | A missile not yours whose next step crosses it is moved onto it and exploded there; a live held thing takes its damage | hold.zs:932, hold.zs:938, hold.zs:949, hold.zs:951, hold.zs:952 | RSQDG_Hold.ShieldTick |
| H25 | Held back more than Break Distance (1.5 m) for 18 tics: released with no throw | hold.zs:671, hold.zs:672, hold.zs:674, hold.zs:679, hold.zs:114, CVARINFO.txt:213 | RSQDG_Hold.WorldTick |
| H25 | The carry's rumble is the strain over the break distance, from 15% up | feel.zs:558, feel.zs:568, feel.zs:569, feel.zs:572, CVARINFO.txt:263 | RSQDG_Feel.Level0 |
| H26 | On with Distance Grab and Barrel Lock On; a palm the gate passes that carries and pulls nothing | lockon.zs:57, lockon.zs:216, lockon.zs:217, CVARINFO.txt:187 | RSQDG_LockOn.On; WorldTick |
| H26 | It prefers a monster while a barrel is within 64 units of your body or in the other hand | lockon.zs:218, lockon.zs:160, lockon.zs:28 | RSQDG_LockOn.WorldTick; NearBarrel |
| H26 | The monster nearest the palm's line inside Aim Width, in Reach, in sight, becomes the lock; that hand's item pick is taken away | lockon.zs:224, lockon.zs:119, lockon.zs:120, lockon.zs:231, lockon.zs:234 | RSQDG_LockOn.WorldTick; BestMonster |
| H26 | Kept while a palm is within twice Aim Width; with none, 105 tics, then cleared after 18 more | lockon.zs:221, lockon.zs:252, lockon.zs:255, lockon.zs:26, lockon.zs:27 | RSQDG_LockOn.WorldTick |
| H26 | The locked monster wears the "have" glow while the lock holds | lockon.zs:63, tell.zs:64 | RSQDG_LockOn.Shown; RSQDG_Tell.UpdateGlow |
| H27 | With a lock held for this barrel Melee is asked for a painted throw only; on 0 the lock takes it as before | hold.zs:461, hold.zs:466, ../Melee/zscript/rsqml/service.zs:144, hold.zs:407 | RSQDG_Hold.MeleeThrow; RSQML_Service.GetInt; RSQDG_Hold.Release |
| H27 | A thrown barrel is offered to the lock first; with a target its velocity is solved onto it | hold.zs:407, hold.zs:408, lockon.zs:265, lockon.zs:268, lockon.zs:269 | RSQDG_Hold.Release; RSQDG_LockOn.Send |
| H27 | Never slower than the 45 degree lob; re-solved every tic onto the monster; the blow lands when it meets it | lockon.zs:303, lockon.zs:357, lockon.zs:367, lockon.zs:375, throw.zs:664 | RSQDG_LockOn.Solve; TickSteer; RSQDG_Throw.ImpactNow |
| H27 | In the grace after the hold, the target is the monster or where it last was | lockon.zs:69, lockon.zs:70, lockon.zs:71 | RSQDG_LockOn.Target |
| H28 | A door: a line with a door special (11, 12, 13, 202), tag 0 and a back sector, within 7 units of the hand, the hand on its front | door.zs:32, door.zs:114, door.zs:143, door.zs:144, door.zs:151 | RSQDG_Door.FindDoor; IsDoorSpecial |
| H28 | Pressing: the grip (the hand armed, or its grip key down), Use, or the palm's roll turned out, each with its switch | door.zs:178, door.zs:182, door.zs:183, door.zs:184, door.zs:185, CVARINFO.txt:274, CVARINFO.txt:275, CVARINFO.txt:276, CVARINFO.txt:277 | RSQDG_Door.WorldTick |
| H28 | A fresh press at a door, or a palm out touching one, takes hold; the grip key is eaten for a hand on a door | door.zs:195, door.zs:197, door.zs:198, door.zs:206, near.zs:258, near.zs:296 | RSQDG_Door.WorldTick; RSQDG_Near.WorldTick; NetworkProcess |
| H28 | The target is the start height plus hand lift times the gain; the gain grows so Door Reach (0.22 m) reaches the commit point | door.zs:244, door.zs:274, door.zs:278, CVARINFO.txt:279, CVARINFO.txt:280 | RSQDG_Door.WorldTick; GainFor |
| H28 | Eased: a share of the gap a tic, capped at 4 times the door's speed scaled by its width | door.zs:468, door.zs:469, door.zs:396 | RSQDG_Door.ApplyAll; Grab |
| H28 | The door's opening sound loops, its pitch the rise against the door's speed; a tick every 6 tics, every 3 past half open | door.zs:486, door.zs:487, door.zs:498, door.zs:254 | RSQDG_Door.Voice; WorldTick |
| H29 | No longer pressing sends the release; at or past Door Commit Point (0.40) the line's own special is run, with a tick | door.zs:230, door.zs:234, door.zs:426, door.zs:428, door.zs:432, door.zs:433, CVARINFO.txt:278 | RSQDG_Door.WorldTick; Release |
| H30 | Under the commit point and open at all: Door_Close | door.zs:435, door.zs:438 | RSQDG_Door.Release |
| H31 | A rise of 1.2 m/s over 3 tics at the let-go lowers the commit point to 0.15 | door.zs:285, door.zs:286, door.zs:427, door.zs:43, door.zs:44, door.zs:45 | RSQDG_Door.Flicked; Release |
| H32 | A lock number without its key refuses the grab; CheckKeys is called not quiet | door.zs:385, door.zs:386 | RSQDG_Door.Grab |
| H33 | Palm out (roll only), no door held or touched, no holster, hand not carrying: the switch line under the palm, once until the palm leaves | door.zs:330, door.zs:332, door.zs:334, door.zs:336, door.zs:348, CVARINFO.txt:281 | RSQDG_Door.PalmSwitch; PalmOut |
| H33 | A switch: a line with a special a player can Use, not a manual door, front side, within 7 units, between floor and ceiling; activated as Use | door.zs:311, door.zs:312, door.zs:313, door.zs:320, door.zs:321, door.zs:366 | RSQDG_Door.FindSwitch; NetworkProcess |
| H34 | Two-handing: the engine's latch, BD22 VR's tokens, hands within 0.16 m, or the off hand 0.05 to 0.70 m ahead within Two Hand Reach (0.2 m) of the barrel | reach.zs:264, reach.zs:266, reach.zs:272, reach.zs:283, reach.zs:285, reach.zs:251, reach.zs:252, reach.zs:253, CVARINFO.txt:113 | RSQDG_Reach.TwoHandWhy |
| H34 | It lasts 18 tics after; a carrying hand is exempt; locks are let go, the beam hidden, the walk-up grip not ready | reach.zs:310, reach.zs:311, reach.zs:250, reach.zs:165, grab.zs:342, grab.zs:343, laser.zs:375, near.zs:253 | RSQDG_Reach.TwoHanding; BusyWhy; RSQDG_Grab.WorldTick; RSQDG_Laser.TickHands; RSQDG_Near.WorldTick |
| H35 | With Not With Melee on, a palm at 2 m/s (or Melee's Punch Min Speed) stands the hand down 26 tics; only an idle hand | reach.zs:172, reach.zs:177, reach.zs:346, reach.zs:347, reach.zs:350, reach.zs:354, reach.zs:328, reach.zs:362, CVARINFO.txt:106 | RSQDG_Reach.BusyWhy; Punching; MeleeHand |
| H36 | A melee weapon's hand is busy; "fist" and a melee weapon flagged not-a-weapon are not | reach.zs:210, reach.zs:215 | RSQDG_Reach.BusyWhy |
| H36 | A lasting reason held 18 tics with the palm out is printed, the same one not again within 350 tics | grab.zs:91, grab.zs:99, grab.zs:100, grab.zs:101, grab.zs:104, grab.zs:84, grab.zs:85, flight.zs:508 | RSQDG_Grab.SayBusy; RSQDG_Flight.Say |
| H37 | A path step that cannot move ends the pull as blocked; so does a pull past its limit | flight.zs:938, flight.zs:943, flight.zs:916, flight.zs:921 | RSQDG_Flight.WorldTick |
| H38 | Dead or switched off: locks are unlocked, pulls aborted, carried things dropped | grab.zs:308, grab.zs:315, flight.zs:849, flight.zs:851, hold.zs:587, hold.zs:589 | RSQDG_Grab.WorldTick; RSQDG_Flight.WorldTick; RSQDG_Hold.WorldTick |
| H39 | A dead monster is allowed only with Corpses on (default off), at weight 0.25 | policy.zs:418, policy.zs:419, policy.zs:430, policy.zs:316, CVARINFO.txt:27 | RSQDG_Policy.Decide; CategoryOn |
| H39 | A held corpse is made shootable while held and is a shield | hold.zs:186, hold.zs:888 | RSQDG_Hold.Take; Shieldy |
| H40 | With Use On Catch off the catch and the walk-up skip the pickup and go to the hold | flight.zs:369, flight.zs:422, near.zs:301, near.zs:325 | RSQDG_Flight.Catch; RSQDG_Near.NetworkProcess |
| H41 | The cone must hold the same target Lock Delay tics before the lock; meanwhile it is the "could" target, amber | grab.zs:393, grab.zs:396, grab.zs:397, grab.zs:398, tell.zs:53, tell.zs:107 | RSQDG_Grab.WorldTick; RSQDG_Tell.UpdateGlow; GlowLook |
| H42 | Flight Path 1 is the Lob: gravity on, the lob re-solved each tic, its time bounded by Lob Height (1 m) | flight.zs:231, flight.zs:235, flight.zs:1052, flight.zs:1053, flight.zs:1303, flight.zs:1304, MENUDEF.txt:35, CVARINFO.txt:143 | RSQDG_Flight.Launch; WorldTick; ArcTime |
| H42 | Flight Path 0 is Steer: cruise is Pull Speed (12 m/s) times the root of the pull share, steering by the share | flight.zs:173, flight.zs:174, flight.zs:175, flight.zs:1058, flight.zs:1063, MENUDEF.txt:34, CVARINFO.txt:131 | RSQDG_Flight.CruiseFor; WorldTick |
| H43 | A struck monster is frozen Hit Stop tics (0 off; 3, 4, 6 on the menu) | throw.zs:565, throw.zs:534, throw.zs:536, MENUDEF.txt:42, MENUDEF.txt:43, MENUDEF.txt:44, CVARINFO.txt:190 | RSQDG_Throw.Strike; HitStop |
| H44 | Sight is only asked when Line of Sight is on; the path moves with TryMove and a failed move ends the pull | cone.zs:72, cone.zs:143, flight.zs:1151, flight.zs:1168, flight.zs:943 | RSQDG_Cone.Best; RSQDG_Flight.StepPath; WorldTick |
| H45 | Walk Up Grab off finds nothing near; the grip is still ready for a carry it does not own and for a door | near.zs:159, near.zs:257, near.zs:258 | RSQDG_Near.FindNearDist; WorldTick |
| H48 | The cone and the beam still ask the real palm gate | cone.zs:32, laser.zs:460 | RSQDG_Cone.Best; RSQDG_Laser.DrawHand |

## Works with

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| W1 | A living monster is never allowed, nor taken by the walk-up grip | policy.zs:418, near.zs:192 | RSQDG_Policy.Decide; RSQDG_Near.FindNearDist |
| W1 | RSQML_Service is asked "headlock.claim" for the off hand; a claimed press is not ready | near.zs:222, near.zs:223, near.zs:225, near.zs:258 | RSQDG_Near.MeleeClaims; WorldTick |
| W1 | "near.dist" answers -2 for a hand already ours, else the nearest thing's distance | throw.zs:852, throw.zs:856, near.zs:208, near.zs:216 | RSQDG_ThrowService.GetInt; RSQDG_Near.NearDist |
| W1 | "headlock.throw": throw strength, arm over arm plus counted kg, boost, aim assist, the body's run, then watched | throw.zs:858, throw.zs:898, throw.zs:902, throw.zs:903, throw.zs:905, throw.zs:919 | RSQDG_ThrowService.HeadlockThrow |
| W1 | "lockon.kick" sends Melee's barrel to the lock and watches it as a throw | throw.zs:861, throw.zs:865, lockon.zs:419, lockon.zs:428 | RSQDG_ThrowService.GetInt; RSQDG_LockOn.Kick |
| W1 | A thrown carried barrel is offered to "barrel.throw"; Melee asks "hold.full" for a carrying hand | hold.zs:456, hold.zs:466, throw.zs:845, throw.zs:849, ../Melee/zscript/rsqml/gloves.zs:291 | RSQDG_Hold.MeleeThrow; RSQDG_ThrowService.GetInt; RSQML_Gloves.Carrying |
| W1 | A hand whose weapon class starts RSQ_Glove with rsqml_boxing or rsqml_slappers on; punch speed from rsqml_punch_min_speed | reach.zs:371, reach.zs:346 | RSQDG_Reach.MeleeHand; Punching |
| W2 | RSQTR_RigService "rig.busy" 1 stands the hand down; "rig.region" 0 or more stops the walk-up grip, a door hold's start and the palm switch | reach.zs:181, reach.zs:184, near.zs:145, near.zs:248, door.zs:189, door.zs:195, door.zs:332, door.zs:512 | RSQDG_Reach.BusyWhy; RSQDG_Near.RigBusy; WorldTick; RSQDG_Door.WorldTick; PalmSwitch; RigRegion |
| W2 | RSQDG_DoorService answers "door.holding" | door.zs:545, door.zs:547 | RSQDG_DoorService.GetInt |
| W4 | A weapon named ubqs_saber is not busy, lit or not; another ubqs_ or an ssq_ weapon is | reach.zs:196, reach.zs:201, reach.zs:205, reach.zs:216 | RSQDG_Reach.BusyWhy |
| W4 | A ubqs_ or ssq_ weapon is never moved between hands, and in the main hand it is not two-handing by position | flight.zs:530, reach.zs:271 | RSQDG_Flight.HandNo; RSQDG_Reach.TwoHandWhy |
| W5 | The ssq_ test sits behind Not With Melee | reach.zs:172, reach.zs:216 | RSQDG_Reach.BusyWhy |
| W6 | With Yield to Laser on (default off) and RSQLS_SightService answering "laser.beam" 1, the beam is not wanted on that hand | laser.zs:403, laser.zs:412, laser.zs:415, CVARINFO.txt:230 | RSQDG_Laser.TickHands; LaserOn |
| W7 | RSQVR_Service "toast", then "word", then A_Print | flight.zs:39, flight.zs:41, flight.zs:549, flight.zs:552, flight.zs:554 | RSQDG_Flight.Toast; SayFull |
| W7 | A class named RSQ_KR... is never allowed | policy.zs:330, policy.zs:405 | RSQDG_Policy.NotGrabbed; Decide |
| W8 | RS_ScoreService "touch" "grab.swing" before a swing's blow | hold.zs:802, hold.zs:803 | RSQDG_Hold.SwingTick |
| W8 | The throw ledger's answers, kept 350 tics | throw.zs:375, throw.zs:376, throw.zs:377, throw.zs:378, throw.zs:379, throw.zs:380, throw.zs:66, throw.zs:882 | RSQDG_Throw.Ask; RSQDG_ThrowService.GetInt |
| W9 | "lockon.met" is 1 for a barrel whose steering ended on its monster; SlowMo asks it | throw.zs:867, throw.zs:870, lockon.zs:374, lockon.zs:384, ../SlowMo/zscript/rsqsm/clock.zs:2139 | RSQDG_ThrowService.GetInt; RSQDG_LockOn.TickSteer; Met |
| W10 | RSQFF_Flare has a rule (Flares, weight 2, default on); a thrown one that strikes a monster left alive calls RSQFF_Service "flare.hit" | policy.zs:251, policy.zs:322, CVARINFO.txt:30, throw.zs:556, throw.zs:559, throw.zs:561 | RSQDG_Policy.Build; CategoryOn; RSQDG_Throw.Strike |
| W11 | No tree: the grab's file says so, and the menu has no gated row | reach.zs:542, MENUDEF.txt:4 | (comment); MENUDEF |
| W12 | Tokens RSQ_TwoHandRifle, RSVR_MeleeTwo, RSQ_TwoHandAimed counted in the inventory | grab.zs:68, grab.zs:71, reach.zs:266 | RSQDG_Grab.TwoHandToken; RSQDG_Reach.TwoHandWhy |
| W12 | brutalaxe and rsq_off_brutalaxe are not busy; rsq_hands is never moved between hands | reach.zs:214, flight.zs:530 | RSQDG_Reach.BusyWhy; RSQDG_Flight.HandNo |
| W13 | BDWeaponSpawner is a weapon rule; a class answers for what it replaces; a TNT1 sprite is never allowed | policy.zs:283, policy.zs:153, policy.zs:398 | RSQDG_Policy.Build; StandsFor; Decide |
| W13 | A melee weapon flagged not-a-weapon reaches; a shootable non-solid thing on a master is skipped; a thing with no plain Death state is blown as Explosive; BurningBarrel explodes on impact | reach.zs:210, throw.zs:495, throw.zs:646, MASSDEF.txt:87 | RSQDG_Reach.BusyWhy; RSQDG_Throw.Helper; Impact |
| W14 | Voxel-drawn: found from VOXELDEF and the voxels namespace; flash in place of the glow; model roll in flight; pitch and roll in the hand | voxel.zs:30, voxel.zs:64, voxel.zs:68, tell.zs:75, tell.zs:119, flight.zs:1252, flight.zs:1254, hold.zs:282, hold.zs:286 | RSQDG_Voxels.Drawn; Build; RSQDG_Tell.UpdateGlow; VoxelFlash; RSQDG_Flight.ArmTumble; RSQDG_Hold.Turn |
| W15 | Every MASSDEF lump is read, a later line replacing an earlier; RS_WeaponWeightService is asked for a gun's pounds | mass.zs:307, mass.zs:372, mass.zs:262, mass.zs:170, mass.zs:171 | RSQDG_MassTable.Load; ParseOne; GunService; RSQDG_Mass.GunPounds |
| W16 | Every service named ...GrabEventService gets "grab.event"; "pickup.first" before the pickup and "pickup.claim" after a refusal | feel.zs:704, feel.zs:707, feel.zs:716, feel.zs:720, flight.zs:609, flight.zs:610, flight.zs:616, flight.zs:656 | RSQDG_Events.Tell; Ask; RSQDG_Flight.TakeInto |
| W17 | RSLaserService answering "available" 1 draws the beam; else the model beam | laser.zs:152, laser.zs:155, laser.zs:182, laser.zs:518 | RSQDG_Laser.EngineLaser; EngineBeam; DrawHand |

## Services this mod answers

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| S1 | RSQDG_ThrowService: hold.full, near.dist, headlock.throw, lockon.on, lockon.kick, lockon.met, headlock.caught, then the ledger | throw.zs:841, throw.zs:845, throw.zs:852, throw.zs:858, throw.zs:859, throw.zs:861, throw.zs:867, throw.zs:872, throw.zs:882 | RSQDG_ThrowService.GetInt |
| S1 | The ledger: throw.by, throw.age, throw.cms, throw.kg, throw.blast, throw.juggle; -1 when not a recent throw | throw.zs:374, throw.zs:375, throw.zs:376, throw.zs:377, throw.zs:378, throw.zs:379, throw.zs:380 | RSQDG_Throw.Ask |
| S2 | RSQDG_MassService: mass.kg, mass.drag (GetDouble); mass.hello, mass.flags, mass.stated, mass.grams (GetInt); flags 1 flutter, 2 explode | mass.zs:394, mass.zs:400, mass.zs:401, mass.zs:407, mass.zs:410, mass.zs:411, mass.zs:412, mass.zs:59, mass.zs:60 | RSQDG_MassService.GetDouble; GetInt |
| S3 | RSQDG_GrabRuleService: grab.hello, grab.rule, grab.deny, grab.weight, grab.forget | policy.zs:494, policy.zs:561, policy.zs:562, policy.zs:563, policy.zs:565, policy.zs:579 | RSQDG_GrabRuleService.GetInt |
| S4 | RSQDG_DoorService: door.holding, 1 or -1 | door.zs:541, door.zs:545, door.zs:547 | RSQDG_DoorService.GetInt |

## Limits

| # | Claim (short) | File:line | Function |
|---|---|---|---|
| L1 | Every hand read is this machine's player's | aim.zs:55, grab.zs:300, hold.zs:579 | RSQDG_Aim.WorldTick; RSQDG_Grab.WorldTick; RSQDG_Hold.WorldTick |
| L2 | Inputs read: the grip key codes and the Use bit for doors. No fire, alt fire or stick read exists in zscript/rsqdg (searched for BT_, cmd. and GetBinding), and the mod has no KEYCONF: no key is bound or looked up by its bind outside the shared How To Play page | near.zs:91, door.zs:178 | RSQDG_Near.InputProcess; RSQDG_Door.WorldTick |
| L3 | Never: no interaction, a missile, a player, no size, invisible, TNT1, a shootable non-monster out of health, a living monster, an owned item | policy.zs:374, policy.zs:375, policy.zs:376, policy.zs:377, policy.zs:384, policy.zs:398, policy.zs:411, policy.zs:418, policy.zs:465 | RSQDG_Policy.Decide |
| L3 | The built-in rules name pickups, FnF's flare and the two barrels, nothing else; a class with no rule is refused | policy.zs:253, policy.zs:260, policy.zs:468 | RSQDG_Policy.Build; Decide |
| L4 | Corpses default off | CVARINFO.txt:27, policy.zs:419 | RSQDG_Policy.Decide |
| L5 | A hand holding or pulling is refused a lock; so is a thing the other hand has locked or holds; one flight and one held thing per hand | grab.zs:183, grab.zs:187, grab.zs:197, grab.zs:210, flight.zs:187, flight.zs:193, hold.zs:163, hold.zs:169 | RSQDG_Grab.TryLock; RSQDG_Flight.Launch; RSQDG_Hold.Take |
| L6 | A thing the throw watcher still watches is refused a lock | grab.zs:212 | RSQDG_Grab.TryLock |
| L7 | Nothing is drawn for a hand that is pulling or carrying | laser.zs:451 | RSQDG_Laser.DrawHand |
| L8 | The give-up limit is at least Give Up After (140 tics) | flight.zs:296, flight.zs:916, CVARINFO.txt:149 | RSQDG_Flight.Launch; WorldTick |
| L9 | A held thing is pass-through; a released one stays so until it fits, forced after 70 tics | hold.zs:191, throw.zs:221, throw.zs:260, throw.zs:82 | RSQDG_Hold.Take; RSQDG_Throw.Settle; TrySettle |
| L10 | A victim already struck is skipped; the first stop is the one impact and the throw is forgotten; at most 4 victims | throw.zs:722, throw.zs:773, throw.zs:774, throw.zs:594, throw.zs:41 | RSQDG_Throw.WorldTick; Impact |
| L11 | A collapsed or jumped pose is not trusted: zero samples, no new target; a held thing is frozen and its release throws nothing | aim.zs:129, aim.zs:181, aim.zs:182, aim.zs:187, aim.zs:211, hold.zs:616, hold.zs:620, hold.zs:344 | RSQDG_Aim.WorldTick; RSQDG_Hold.WorldTick; Release |
| L11 | An unfollowed turn of the pawn over 0.5 degrees in a tic silences the throw samples for 2 tics | aim.zs:152, aim.zs:224 | RSQDG_Aim.WorldTick |
| L12 | Tag 0 door specials from the front only; a moving door is refused unless its mover only just started; one door per player | door.zs:143, door.zs:144, door.zs:387, door.zs:412, door.zs:204 | RSQDG_Door.FindDoor; Grab; TakeOver; WorldTick |
| L13 | A hand in a rig region never starts a hold nor flips a switch | door.zs:195, door.zs:332 | RSQDG_Door.WorldTick; PalmSwitch |
| L14 | Use is read from the player's command, not eaten; a door the Use press just started is taken over | door.zs:178, door.zs:413 | RSQDG_Door.WorldTick; TakeOver |
| L15 | The door handler tests Lift Doors and Palm Flips Switches, never Distance Grab; the grip is not ready with Distance Grab off | door.zs:165, door.zs:171, door.zs:330, near.zs:241 | RSQDG_Door.WorldTick; PalmSwitch; RSQDG_Near.WorldTick |
| L16 | No monster pick without a barrel near or in the other hand; only "impact explode" shootable things are sent to the lock; the rest get the assist | lockon.zs:218, lockon.zs:222, lockon.zs:265, lockon.zs:77, hold.zs:409 | RSQDG_LockOn.WorldTick; Send; IsBarrel; RSQDG_Hold.Release |
| L17 | With cl_capfps on the rumble route is off and the pulse is used | feel.zs:311, feel.zs:312 | RSQDG_Feel.RumbleOn |
