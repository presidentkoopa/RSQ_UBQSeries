# 1.0 bug and feature list (owner, 2026-11-06 04:07)

Repos: RSQ_UBQSeries (most items) and RS_Brutal22WeaponsQ (items tagged **[BD22]**).
Attachments sent with this list: LegenDoom_3.0.pk3, LOB_v1.05.pk3 (Legion of Bones), LegenDoom_BD22VR_Patch.pk3.
**Not yet received:** the melee sprite sheet for item 40.

The owner's words are kept as written; numbers are added so later files can point at them. Status lives in
`BUGS_1.0_STATUS.md` once work starts. Nothing here is built yet.

| # | Area | Item (owner's words) |
|---|---|---|
| 1 | Wheel / ShieldSaw / Saber / Whip / Grenade | Cannot select shieldsaw from wheel, i need to select with either hand but have it live in offhand once selected. Same rule for saber and whip and grenade but they go in mainhand. |
| 2 | FnF | STILL CANNOT THROW FLARE. Please have it use the controls and mechanics of the grenade to throw. |
| 3 | Miniboss | I've asked several times to use the miniboss art from the OG mod, not the weak ass dotted tethers. Fix. |
| 4 | Distance Grab / FnF | Cannot target Flare with distance grab. Thrown flares need to do a little damage, at least, and light an enemy on fire if BD is detected, if enemy is below a certain tier (humanoids only?). |
| 5 | Rig / holsters **[BD22]** | When offhand takes a weapon, the offhand must always draw its offhand weapon regardless. Do we give all the offhand weapons at start but prevent them being selected via the wheel or any other means? Don't confuse ourselves or the player. Suggest. |
| 6 | **[BD22]** shotgun | We pump the shotgun after loading a full set of rounds, good, but the eject shell animation still plays, that's bad. |
| 7 | Graveyard | Get the options menu from Graveyards into the Radiant Silvergun options menu. |
| 8 | Glow In The Dark | GITD changed because the owner added MoreLights by SnakieJackie (abandoned). Check their repo for proof; credit. |
| 9 | FnF flashlight | Option to let DarkDoomZ's flashlight take over when DarkDoomZ is detected. Check DarkDoomZ credits; if we can rewrite/optimize that flashlight and have it come from our model with our tapered cone as an optional visual, happy. DarkDoomZ still loads: no conflicts. |
| 10 | SlowMo / GBOVR / Score / Graveyard | More SlowMo triggers: grenade blast, over-under rifle or machinegun secondary blast, reloading (always, or under low health), Low Health / Near Death. Lethal hit -> hold at 1 HP, max slow-mo for a few seconds, GITD deep blood red. A GBOVR upgrade: auto-reload, a few seconds of invulnerability; X kills earns the "Second Wind" (rename together): Level-Up-style graphic flies past, time normal, 50 HP, weapons reloaded, +1 cigarette, +1 grenade. Build it out: GBOVR and Score hooks, a repurposed BD voxel as a power-up/drop in this mode. What can Graveyard do now (we die a lot = many tombstones)? Put an agent on tombstone ideas across the mods. |
| 11 | FnF (PCVR flare setting) | Allow dropped or thrown flares to be shot out. |
| 12 | FnF flashlight | Battery system per Ermac's specs from his repo. Discuss: what can the flashlight show us that makes batteries a resource worth managing? |
| 13 | Melee / Whip | Punch, jab, hook, uppercut, whip, pistol whip, gun butt-shove all activate switches. Custom switch textures in WADs: same logic? |
| 14 | Wheel | Better spacing; some kerning is off. Can we use the nice font? |
| 15 | Wheel | One fist button, not two: gives the correct fist to the selecting hand. |
| 16 | **[BD22]** / Wheel / Distance Grab: Axe | Sometimes the axe moves to the offhand but isn't the Offhand Axe, so it can't melee there. Distance-grabbing the axe to the offhand must auto-equip every time. |
| 17 | ShieldSaw | Reachable by prev/next offhand weapon (optional), besides the other ways. Revving into monsters throws no blood. |
| 18 | Rig | Holster rules: rifle into right shoulder, then draw the hip pistol, and the rifle ends up on the hip instead of the shoulder. Suggestions wanted. |
| 19 | Gun Cards | More control over the small card's placement; an "always draw wrist cards" option if missing; a "no background" option?; emissive glow/light (Quest / PCVR setting). |
| 20 | Distance Grab | Throwing is still off: sometimes no follow-through, or it drops at the feet. (See melee trigger ideas, item 22.) |
| 21 | Grenade **[BD22]** | Option for our Grenade to replace the BD22 grenade when loaded together (today ours stands down; want the option for theirs to stand down). |
| 22 | Melee | Option: no barrel damage on uppercut, so it "kicks" barrels like Brutal Doom, lift in a forward arc. Hands must NOT animate a punch on trigger: we punch ourselves; triggers and secondaries stay free (lock on an enemy and uppercut a barrel into it). |
| 23 | Glow In The Dark | A truly random option: "Randomize Current Look". |
| 24 | Gun Cards | Cards on every weapon, at least the wrist card when on (saber has no ammo but still has the combined card and status card). |
| 25 | Wheel | Option for the wheel to freeze time. |
| 26 | SlowMo | The "slowmo remaining" bar is nice, but the bar showing how much SlowMo we've built up to toggle is gone. Suggest. |
| 27 | Grapple | Let go as soon as we arrive at the hook point (no bolting in place until fire). Faster, like its inspiration mod. |
| 28 | GBOVR / Score | Plan: go through each GBOVR upgrade tree one mod at a time (name + description, keep or change), then Score the same way. Melee may need more with the lock-on idea. Dedicated passes after the rest of this list. |
| 29 | FnF / Gun Cards | Another bar for the flashlight battery, maybe its own card. Speculate. |
| 30 | Whip | Snag range for doors and switches seems short: 3x for doors/switches only, or extend a little across the board? Is target range the same everywhere? |
| 31 | Miniboss | Tier choice: add options to use GBOVR player level or RS Score lives remaining, whichever is larger. Or propose better. |
| 32 | New mod / GBOVR / Graveyard / Miniboss | Considering https://forum.zdoom.org/viewtopic.php?t=65583 for the arcade design and GBOVR. New GBOVR ideas with it, Graveyard and the others. Maybe minibosses make every tombstone spawn a monster, with restrictions from Score/GBOVR/other. |
| 33 | Melee **[BD22]** | Gun butt-shove needs a larger range; hard to connect, needs an uncomfortably fast motion. The sound plays but the gesture shown is "two hand shove" (sentence cut off in the original). |
| 34 | Melee **[BD22]** | Weapons moved between hands: cannot pistol whip in the offhand. |
| 35 | Score / GBOVR | SCORE letters breathe independently (smooth sequence or random chaos). Life in the GBOVR XP bars (static light-blue outline today). |
| 36 | GBOVR | New player card "Chainsmoker": every 3 kills in cigarette slow-mo without missing extends it by 1 s; pellet weapons need one pellet to connect (guard against SSG / assault shotgun abuse). Builds emerging: Melee, Chainsmoker, Indiana Jones, Sword and Shield. Talk later. |
| 37 | VisualRewards bits | Nice fade-out: or flash fullbright a few tics, faster and faster, then blink out. |
| 38 | Laser Sight | Option: dot only on enemies. Grenade launcher laser is a straight line, not an arc. |
| 39 | Rig / Saber | Never seen the keyring (holster near left hip?). Offhand saber not shown with "start with it" checked: gated behind GBOVR? Prove the keyring exists with keys. Intended: grab with offhand, take to door, offhand fire = auto-unlock-and-open, or hold altfire and raise the hand to lift the door? |
| 40 | Melee | Plan to use the (not yet attached) sprites for melee attacks; contact sheet with sprites, colour choices, and which moveset each pairs with. Keep the bought ones; the community ones are great too. |
| 41 | **[BD22]** LegenDoom patch | Sitrep: hoped for a "LegenBrutalDoom", not getting there. |

| 42 | Laser Sight (added 11-06 06:20) | "Kickass lasers": an Unreal-1-style living, smoky/liquid shimmer on the laser beam, PCVR only. A Quest / PCVR setting; Quest keeps today's solid beam. |
| 43 | SlowMo (added 11-06 06:12) | Heavy Hit Slowdown (spec in BUGS_1.0_STATUS.md), grenade blast 3 s, Low Health trigger removed, a cause line under the automatic bar; Miniboss "Ignore Spawn Restrictions". |

**Testing:** if the test rig is reachable, plan one large confirmation test at the end, once the code is done.
