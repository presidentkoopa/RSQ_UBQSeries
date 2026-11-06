# RSQ Gun Bonsai VR

Two hands, two guns, two careers: Gun Bonsai rebuilt so each hand earns its own XP and grows its own upgrades, with
more than 170 new upgrades built around what you do with your body.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

Gun Bonsai (by ToxicFrog) levels up your weapons as you use them. It was made for one gun at a time. In VR you hold two,
throw punches, swing sabers, throw grenades and grab monsters by the throat. This patch teaches Gun Bonsai all of that,
on stock QuestZDoom 17.3, in ZScript alone. No engine changes.

## Standout feature: XP follows the shot, not the hand

Hold a shotgun in your right hand and a pistol in your left. Fire both into the same crowd. Each gun gets paid for
exactly the damage it did, and only its own upgrades fire on its own rounds.

The patch tracks where every shot came from:

- A bullet is bracketed from trigger pull to impact, so the gun that fired it is known even when twenty pellets
  from one hand and a burst from the other land in the same tic.
- A rocket, its fragments, its explosion and anything those spawn all remember the gun that started the chain.
- A burn or poison keeps billing the gun that applied it, even after you drop that gun.
- When nothing else can tell, both hands are scored on position, aim direction, firing animation and trigger, and the
  hand with the strongest case wins.
- When two guns both hurt the same monster in one hit, the XP is split by share. Upgrade effects only come from the
  gun that did most of it.

Then it goes further. A Distance Grab throw and the grappling hook are not guns, so their XP goes to your player level
instead of to whatever you happen to be holding. A thrown gun pays itself. A lightsaber cut pays the saber that made
it. A ShieldSaw bash pays the shield. Brutal Doom VR Reloaded's travelling bullets pay the hand that fired them.

## Features

**Two hands, end to end**
- Every weapon in either hand has its own Gun Bonsai record: its own XP bar, level and upgrades.
- Two HUD gauges: main hand top right, off hand top left. With one weapon you see one gauge, on its own side.
- Upgrades on both guns run at once. Defensive upgrades on either hand fire when you are hurt.
- The level-up key spends the main hand's level first, then the off hand's, then the player's. With nothing to spend,
  each press shows the next hand.
- Turning an upgrade on or off, or tuning it, acts on the hand the status screen is showing.

**New upgrade trees** (offered only while the mod they belong to is loaded)
- **Fists**, per glove: Power, Elements, Combos, Counters, Grappler (off glove only), Berserk, Gun Hand.
- **Saber**: Focus, Blade, Stab, Deflect, Dual and the Force. The blade and the Force are one pool: a level-up on the
  main saber or on the Force hand offers nodes from both, kept on the main saber.
- **ShieldSaw**: Throw, Block, Bash and Grind.
- **Grenade**: Carry, Throw, Fuse, Blast, Style, a SlowMo link and eight grenade kinds.
- **Whip**: Crack, Reach, Wrap, Lasso and Rope.
- **Player trees**: Two Hands, Body, Guard, Critical Hits, Taunt, Grapple, Gunslinger, Laser Sight, SlowMo and Kill
  Rewards.
- **Any melee weapon**: Lunge, Executioner, Adrenaline (5 levels each).
- Nodes open in order: a child is offered only once its parent reaches the level it asks for.
- A node that unlocks a row on another mod's page (Grapple's Swing and Momentum, the Laser Sight's Target Lock, Melee's
  Guard and so on) greys that row until it is learned; learning it switches the row on, and the row can still turn it off.
  ShieldSaw's Hit-Stop Tics slider (it caps Strike True) is raised to 6 once when Strike True is learned, if it is lower.

**XP your way**
- **XP Source**: Damage (Gun Bonsai's own), Style (RSQ Score's style points become XP, split along the combo that
  set up the kill), or Both.
- **Force Learns From the Saber**: the Force hand keeps the XP of its own blows and also gets half of what the main
  saber earns, so it still levels when you play mostly with the saber.
- Score-to-XP, if you turn it on in Gun Bonsai, pays the gun that made each kill.

**A cleaner pool**
- **Silvergun** stock mode drops eight stock upgrades that clash with the series (Dark Harvest, the three Leeches,
  Intuition, Juggler, Player Damage, Thorns). **All** brings them back. Upgrades a save already holds keep working.
- No elemental damage and no rate-of-fire upgrades on the gloves, sabers, ShieldSaw or whip. In VR the rewards are for
  how you move.

**Screens built for the headset**
- GBOVR Menus and HUD (On by default): the redrawn status screen and level-up cards (the Mockup), the bottom row, and
  XP bars that breathe. Off, you get Gun Bonsai's own menus and plain gauges.
- The XP bars breathe slowly in their own colour, kick brighter when XP comes in, warm up and breathe faster as a level
  nears (with Colour Cycle off), and flare when a level is ready or taken. Photosensitive Mode keeps them steady; colour-blind modes change
  brightness only.
- Colour Cycle (On by default, each hand on its own): the gauge's frame, weapon XP bar and player XP bar cycle through
  the colours, the colour rippling from frame to bars. Speed, Spread and Intensity tune it per hand. Off, the gauge has
  Gun Bonsai's colours. A waiting level-up cycles whatever the switch. Photosensitive Mode: no cycling (the switch acts
  as off, and a level-up shows its colours held still). Any colour-blind mode turns the switch off for both hands (the
  colour-blind bar pair shows, as before); a level-up there still cycles and the whole HUD breathes in brightness.
- An optional bottom row with each hand's magazine and reserve, plus health, face and armour.
- A Berserk Meter gauge per glove that has learned it: fills dark crimson to hot orange-white, then burns while the
  Berserk it earned runs.
- An optional ShieldSaw gauge, top centre, while the shield rides on your shoulder.

## How To Play

1. Load Gun Bonsai 0.10.6, then this pack straight after it. Add any other RSQ mods you like.
2. Open Options → Customize Controls → Gun Bonsai and bind **Display Info** to a controller button.
3. Gun Bonsai's upgrade binding mode can stay as it is: in every mode each hand's gun keeps its own record.
4. Pick up a gun in each hand and fight. Watch both corner gauges fill.
5. When a gauge fills, press Display Info. Choose one of the cards with the thumbstick and confirm.
6. Every weapon level-up also counts toward your player level. Player levels offer the player trees: Two Hands, Body,
   Guard and the rest.

**Mastering it**
- Dual-wield on purpose. Akimbo pays when both guns fire together. Crossfire pays when each hand is on a different
  target. Alternator pays left, right, left.
- Give each glove its own job. Each fist is a separate record, so the left can take Frost Fist while the right takes
  Explosive Fist. Only the off glove can learn the Grappler branch.
- Move your head. Evasion cuts damage while your head is moving fast. Steady Aim pays for a still head. Lunge pays
  for stepping into a melee blow.
- Some moves become things you earn. With this patch loaded, the uppercut, the second saber, the saber's second blade,
  the Force, the lasso, the Human Shield hold and the grappling hook start locked, and each opens when you learn its
  node.

### The two-hand and off-hand trees

| Tree | Where it lives | What it rewards |
|---|---|---|
| Two Hands (player) | Akimbo, Crossfire, Alternator | Guns only. Akimbo: +6% a level (5 levels) while both hands fired in the last third of a second. Crossfire: +10% a level on a hit when your other hand hit a different, living target in the last second. Alternator: each hit with the other hand's gun inside two thirds of a second adds +4% a level, up to four in a row. |
| Southpaw (player) | Body | Whatever your off hand holds hits +6% harder a level. |
| One-Two, Three-Hit, Dempsey (each glove) | Fists: Combos | Alternate left and right to chain punches. A miss or a pause breaks it. |
| Ground Pound, Clear Out (each glove) | Fists: Power | Both fists swung down hard together, or both palms thrust forward. Needs RSQ Melee (it reads both hands, or RSQ Accessibility does). |
| Grappler (off glove only) | Fists: Grappler | Human Shield, Headlock Uppercut, Heavier Headlock, Slam, Throw Into, Chokehold. They grow RSQ Melee's off-hand Headlock. |
| Guard (player) | Guard, Parry, Reflect Guard, Absorb and Release | Both hands up at your face. Parry: drive both guarding hands into a blow just before it lands. |
| Two Sabers (main saber) | Saber: Dual | Unlocks the off-hand saber. Then Assault (alternating blades stack damage), Cross Guard (the crossed X turns shots) and Clash (blades together send out a shockwave). |
| Lasso (whip) | Whip: Lasso | Take the whip in your off hand to whirl it as a lasso. Bola takes several monsters at once. |
| Twin Lines, Double Hook (player) | Grapple | A rope from each hand at once; a monster on each hook slammed into each other. |

## Controls

The patch reads no buttons of its own. Every move belongs to the mod that owns it; this pack decides what each move
has learned and who gets paid for it.

| Action | How (VR) | Notes |
|---|---|---|
| Spend a level / open the status screen | Display Info, bound to a controller button | Keyboard I by default. Spends main hand, then off hand, then player levels. With nothing pending, each press shows the next hand. |
| Pick a level-up card | Thumbstick left/right or up/down, then confirm | Keyboard 1-9 picks directly. Back refuses the level, which costs that level's XP (Gun Bonsai's rule). |
| Browse the status screen | Thumbstick up/down | On an upgrade: left/right changes its level, confirm toggles it. On a gun: right or confirm steps into its upgrades, left into the player's. |
| Earn XP with one hand | Fire, swing or punch with that hand | Credited to that hand's weapon. |
| Ground Pound | Both fists swung down together at 3 m/s or more each | Glove node; needs RSQ Melee. |
| Clear Out | Both palms thrust forward together | Glove node; needs RSQ Melee. |
| Taunt | Throw both hands apart, empty or in fists | Player node; needs RSQ Melee. |
| Evasion / Steady Aim / Lunge | Head moving at 1.2 m/s or more / head under 0.2 m/s / head moving faster than 0.5 m/s | Read from your headset's movement. |
| Left-handed play | Set handedness in RSQ Accessibility, or QuestZDoom's Control Scheme | Gun Bonsai's own gauges swap sides so the main hand's is on the main hand's side. |

## Menu

Options → Radiant Silvergun Options → RSQ Gun Bonsai VR: one page, with Test and Debug and Reset All at its foot. The
same page is linked at the bottom of Gun Bonsai's own options.

| Row | Default | What it does |
|---|---|---|
| Stock Gun Bonsai Upgrades | Silvergun | Silvergun leaves eight clashing stock upgrades out of the pool. All offers every stock upgrade. |
| XP Source | Damage | Damage, Style (RSQ Score's style points) or Both. Style without RSQ Score acts as Damage. |
| Force Learns From Saber | On | The Force hand also gets a share of the main saber's XP. |
| Force XP Share | 50 | That share, in percent. |
| *HUD* | | |
| GBOVR Menus and HUD | On | On: the Mockup status screen and level-up cards, the bottom row, breathing XP bars. Off: Gun Bonsai's own menus and gauges. |
| Ammo and Health Row | On | A bottom row with each hand's ammo, plus health, face and armour. Greyed with GBOVR Menus and HUD off. |
| HUD Size | 1.50 | Size of the bottom row and the Berserk Meter gauges. |
| Dual HUD | On | A HUD for each hand (main top right, off top left; swapped for a left-hander). |
| Single HUD Follows | Main Hand | With Dual HUD off: the hand the one HUD shows (Main Hand, Off Hand, Last to Earn XP). It falls through to a hand that holds a gun, so it never goes blank. |
| ShieldSaw Gauge | Off | A third gauge, top centre, while the ShieldSaw rides on your shoulder. |
| Berserk Meter Gauge | On | A gauge for each glove that has learned Berserk Meter. |
| Gauge Animation | On | A band of light rises through the fill, its edge breathes, a full gauge glints. |
| *HUD Position* (with Dual HUD on) | | |
| Main HUD Across / Down | 0.99 / 0.02 | Where the main hand's HUD sits, as a share of the screen. |
| Main HUD Mirror | Both | None, Left-Right, Up-Down or Both (also picks the corner frame). |
| Off HUD Across / Down | 0.01 / 0.02 | Where the off hand's HUD sits. |
| Off HUD Mirror | Up-Down | As above; the defaults make the two HUDs mirror images. |
| *HUD Colour Cycle* | | |
| Main HUD Colour Cycle | On | The main hand's gauge frame and XP bars cycle through the colours. Off: Gun Bonsai's colours. Also colours the shield gauge and the single HUD. |
| Main HUD Cycle Speed | 1.0 | How fast it cycles (0 = still). Also the level-up cycle's speed. |
| Main HUD Cycle Spread | 1.0 | How far apart in the cycle the frame and the two bars are. |
| Main HUD Cycle Intensity | 1.0 | Brightness of the cycle. 1.0 / 1.0 / 1.0 is Gun Bonsai's own level-up cycle. |
| Off HUD Colour Cycle, Speed, Spread, Intensity | On, 1.0, 1.0, 1.0 | The same for the off hand's gauge. |
| Reset All | | Puts every row on this page and on Test and Debug back to its default. |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| Force Base Strength | 0.00 | How strong an unlearned Force power is, as a share of the saber's own. At 0 a power does nothing until learned. |
| Grapple XP | 1.0 | Multiplies the XP the grappling hook earns for your player level. |
| Style XP Scale | 1.0 | XP per style point, when XP Source is Style or Both. |
| Style Player Share | 10 | The extra share (percent) of style XP paid to your player level. |
| HUD Inset | 0.04 | How much of each screen edge the bottom row and the Berserk Meter gauges keep clear. |
| Debug Log | Off | One console line per Style XP payout (who got what for a kill). |
| Debug: Add All | | Gives every node of this patch at its cap, on the player and every weapon carried. For testing. |
| Debug: Add Incremental | | One level of every node offered right now. Press again to climb. For testing. |

Star Punch's two timing settings (`rsq_star_first`, `rsq_star_every`) have no rows: Star Punch is no longer offered.
Reset All still resets them.

## Works with

- **Gun Bonsai 0.10.6 is required**, loaded before this pack. This pack replaces some of its files by path, so the
  order matters. Gun Bonsai itself is not modified.
- **RSQ Melee**: the Fists tree, Lunge, Executioner and Adrenaline on the gloves, and the Guard and Taunt nodes. The
  Guard branch also opens if Melee's Start With Guard is on.
- **RSQ Accessibility (its gesture reader)**: Ground Pound, Clear Out, Taunt and Absorb and Release are done through its two-hand gestures.
- **RSQ QuestSaber**: the saber and Force trees. The second saber, the second blade and the Force become things you
  learn.
- **RSQ ShieldSaw**: its tree, and the optional shoulder gauge.
- **RSQ Grenade** and **RSQ Whip**: their trees. Thrown grenades are paid to the grenade.
- **RSQ Grapple**: its player tree. The hook starts locked and opens when you learn Grapple. Its XP goes to your
  player level.
- **RSQ Distance Grab**: throws, and the blasts they set off, pay your player level instead of a gun.
- **RSQ Tactical Rig**: the Gunslinger tree (Quick Draw, Pair Draw, Gun Toss, Boomerang Gun, Smoker, Chain Smoker; Gun Toss
  and Boomerang Gun are offered only while the Rig's Throw Guns is on).
  A thrown gun pays its own record. With **RSQ Laser Sight** too: Target Lock and Headshot Reaction.
- **RSQ SlowMo**: its tree, plus Showdown, Adrenaline, Finisher and the other slow-motion moments.
- **RSQ Score**: XP Source Style. Score draws its own score line.
- **RSQ VisualRewards**: the Kill Rewards tree (Gastropub, Rich Bits, Magnet, Lucky Kill), offered only while it is
  loaded. Its weapon level-up tag rises off the gun that levelled, in whichever hand.
- **RSQ Wheel**: shows each gun's level and progress.
- **RSQ Accessibility**: Photosensitive Mode dims the level-up flash. Its handedness setting moves the gauges.
- **Brutal Doom / BD22 VR Reloaded**: bullets that travel before they hit are still paid to the hand that fired them.
  With GBOVR Menus and HUD and Ammo and Health Row on, Brutal Doom's full-screen HUD is swapped for the bottom row. Turn
  GBOVR Menus and HUD off before removing this pack to restore it.
- **LegenDoom Lite, Champions, RSQ Miniboss**: Knockdown, Executioner and Finisher measure a monster against the
  boosted health it really started with.
- **SuperPunchOut**: its gloves count as melee weapons.

## Credits and licence

- **Gun Bonsai** © 2022 Rebecca "ToxicFrog" Kelly, MIT licence. The files under `ca.ancilla.bonsai/` are derived from
  Gun Bonsai 0.10.6; the gauges are Gun Bonsai's own frame art. The full licence is in `COPYING.md`.
- `sprites/ui/hud.xcf` © 2022 Sungraphica (sungraphica.itch.io), as noted in `COPYING.md`.
- **Sounds** from SuperPunchOut (presidentkoopa), which took them from Punch Out Doom (DerrickDavison) via Virtual Punch Out, and the
  Super Punch-Out!! announcer's count.
- **HUD Colour Cycle**: Gun Bonsai's own GetShinyColour level-up cycle (ToxicFrog, MIT), made an always-on option with
  per-hand speed, spread and intensity in presidentkoopa's fork of Gun Bonsai's HUD.
- **Berserk Meter gauge art**: coldcite's Top HP Bars bar, stood on end. His words: "Feel free to use this in your
  mods."
- **Kill Rewards tree**: the bits are SoM's Universal(ish?) Kill Rewards (now in RSQ VisualRewards).
- **Critical Hits**: the idea of Mikk's Critical Shots, as a concept only.
- Fonts are Doom's own.
- The patch's own code and upgrade trees: presidentkoopa, on the same MIT terms as Gun Bonsai.
- Built for stock QuestZDoom 17.3 by Emawind84 and Team Beef. No engine changes.
