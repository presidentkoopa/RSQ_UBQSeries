# RSQ ShieldSaw

`pk3/RSQ_ShieldSaw.pk3`. Part of the Radiant Silvergun Quest series, for stock QuestZDoom 17.3.

## What it is

A shield that is also a throwable saw disc, in your off hand. It stops what crosses its face: fireballs are
turned before they reach you, bullets are stopped at the muzzle and sent back, claws and blasts are caught on
contact. Drive it forward to bash. Hold the off trigger and the blades come out and the saw revs. Let go while
your arm snaps forward and it flies, visits the targets you locked, and comes back. It is the shield saw from
*Doom: The Dark Ages*, brought to Doom VR first by Ermac in Rusted Legacy; this mod started from his version
and re-implements it as a standalone off-hand mod. No engine change, no player class replaced.

## Load order

doom2.wad -> brutal22test6.pk3 -> BD_VoxelPack.pk3 -> BD22_VR-Reloaded_2_0_3h.pk3 ->
BD22_VR-Reloaded_2.0.3ha_hotfix.pk3 -> `RSQ_ShieldSaw.pk3`

- **Needs no other RSQ pk3.**
- **Plain Doom 2 without Brutal Doom:** works. Brutal Doom's hands class is looked up by name at run time, never
  required; earlier rig rounds ran on freedoom2 (HANDOFF.md). "BD22 Monsters" (off) is only for Brutal Doom's
  tougher monsters.

## Setup

- **Menu:** Options -> Radiant Silvergun Options -> RSQ ShieldSaw. Front page, then "Shield Options",
  "Look and Sound", and "Tuning and Debug" (every number, debug switches, "Reset All").
- **You start with it** ("Start With Shield", on), on your back, not in hand ("Start in Hand", off).
- **Binds (optional):** Options -> Customize Controls -> section **RSQ ShieldSaw**:
  - **ShieldSaw: draw / put back / recall**: draw or put back from anywhere, or recall a thrown disc.
  - **ShieldSaw: throw along aim**: a backup throw.
  - **ShieldSaw: lock on (hold)**: only needed if "Lock On With" is set to "Lock Key".
  - Nothing else to bind: Use, the off trigger and the off alt are QuestZDoom's own.

## What to do in VR

- **Draw:** reach behind you to the small of your back (default "Take It From") and press Use. Press Use there
  again to put it back. ("Draw With Use", on.)
- **Block:** hold the shield's face toward what is coming.
- **Perfect block:** move the shield into the attack as it lands, instead of holding it still.
- **Bash:** shove the shield forward into a monster.
- **Wall slam:** bash a monster toward a wall.
- **Rev:** hold the off trigger. The blades come out; what touches them is ground.
- **Lock on:** hold Use with the shield away from the mount and sweep it over enemies. A ring goes on each, a
  buzz each.
- **Throw:** let go of the off trigger while your arm snaps forward. It flies to the rings in order, or where
  you point.
- **Recall:** press the off trigger while it flies. Catch it as it comes back, or it lands on the mount.
- **Saber over shield:** with RSQ Saber in your main hand, rest the lit blade across the shield's front.

## Features

"On" = on by default (CVARINFO). "Option" = off by default.

Front page:

| Menu row | Default | What it does |
|---|---|---|
| Start With Shield | On | Every player spawns with it. |
| Start in Hand | Off | Start with it drawn. |
| Draw With Use | On | Use at the mount draws and puts back. Off: only the Draw key. |
| Lock On With | Use | Use (away from the mount), Lock Key, or Throw Button (the old way). |
| Throw Button | Off Trigger | What throws on a flicked release: Off Alt, Either, Off Trigger. |
| Max Locks | 5 | Targets one throw visits. |
| Shield Size | Standard | Preset: Standard, Large, Largest. |
| Throw Feel | Standard | Preset: Easy, Standard, Deliberate. |
| Block Assist | Standard | Preset: Low, Standard, High. |
| Damage | Standard | Preset: Low, Standard, High. |
| Turned Shots Go | Off the Face and My Swing | Or To Shooter, Where I Look, Off the Face. |
| Blocked Melee | Stun and Shove | Or Stun, Nothing. |
| BD22 Monsters | Option | Brutal Doom's monsters: slices up to 250 health, grinds up to 1200. |

Shield Options page:

| Menu row | Default | What it does |
|---|---|---|
| Shield Blocks | On | The block at all. |
| Block While Holstered | Option | A shield on your back still blocks. |
| Double Block Radius | Option | The blocking plate is twice as wide (the shield you see is unchanged). |
| Blocked Projectiles | Returned | Or Cancelled. |
| Turn Shots Early | On | Shots about to cross the plate are turned, even ones that would miss. |
| Muzzle Block | On | A bullet whose line crosses the plate is stopped before it is fired. |
| Return Bullets | On | A stopped bullet goes back out. |
| Perfect Block | On | Plate moving into the attack: faster return, always staggers, rings bright, buzzes twice. |
| Shield Bash | On | Shove the shield: hit, shove, lift. |
| Bash Needs Sight | On | Bash and grind cannot reach through a wall or door. |
| Wall Slam | On | A bashed body that hits a wall takes extra damage and hangs stunned. |
| Hit-Stop | Option | A bash or a perfect block freezes the monster for a beat (4 tics). |
| Perfect Block Slow-Mo | Option | Half a second of slow motion on a perfect block. Needs RSQ SlowMo. |
| Saber Over Shield | On | RSQ Saber's lit blade across the shield widens the block (x1.3). |
| Hit Tiers | On | Thrown disc: weak monsters cut in two, mid-tier ground, heavies turn it away. |
| Catch on Return | On | The disc comes back to your hand. |
| On Manual Store | Fist | What the off hand holds after you put it away: Fist or Previously Held Weapon. |
| Off-Hand Switch | Keep Shield | Or Allow Switch (a weapon switch can take the off hand). |

Look and Sound page: Block Feedback (on), Positional Sound (on), Take It From (Small of the Back; or Over the
Off Shoulder, Behind the Neck, Small of Back or Neck), Show Mount (When Needed), Shield on Back (off), Others
See Shield (Netgame Only), Spin Direction (Normal).

Always on, no row: the bash's visible burst (a small flash and sparks at the body), and a bash never starts
Brutal Doom's stealth-kill cutscene.

## Test it

Load only the base order plus `RSQ_ShieldSaw.pk3`. Steps marked **(not yet headset-confirmed)** were only run
on the simulated rig (2026-10-31 onward).

1. Menu: Radiant Silvergun Options -> RSQ ShieldSaw. Pages and rows above are there.
2. Start a map. Reach to the small of your back and press Use: the shield is in your off hand. Press Use there
   again: it goes back.
3. Stand in front of an imp's fireballs with the shield up: they are turned before they reach you and fly where
   the plate sends them.
4. A zombie's bullets: stopped at the plate, sent back.
5. Let an imp claw at the shield: it is stunned and shoved back.
6. Perfect block: swing the shield into a fireball as it arrives. A higher ring, a double buzz, a white bloom.
7. Bash an imp: it is hit, shoved and lifted. A small flash and sparks at the body, at plate height, never on
   the floor. **(not yet headset-confirmed)**
8. Bash an imp that has not seen you yet: no Brutal Doom stealth-kill cutscene; the camera stays with you.
   **(not yet headset-confirmed)**
9. Wall slam: bash an imp into a wall. It hits the wall, takes extra damage and hangs in its pain frame a moment.
   **(not yet headset-confirmed)**
10. Hold the off trigger: blades out, saw revs. Push it into a monster: it grinds.
11. Hold Use with the shield away from your back and sweep over three monsters: a ring on each. Rev, then let go
    of the trigger while snapping your arm forward: it visits each ring, then comes back. Catch it.
12. Throw again; press the off trigger while it flies: it comes back.
13. Let go of the trigger with your arm still: nothing is thrown.
14. Options, one at a time, then back off:
    - Hit-Stop: a bashed monster freezes for a beat; so does one whose attack you perfectly blocked.
      **(not yet headset-confirmed)**
    - Perfect Block Slow-Mo: needs RSQ SlowMo loaded. A perfect block slows the world for half a second.
      **(not yet headset-confirmed)**
    - BD22 Monsters: a thrown disc cuts a Brutal Doom imp in two instead of grinding it.
15. With RSQ Saber loaded: lit saber in the main hand, rest it across the shield's front. Block a fireball at
    the plate's edge: blocks wider. Lift the blade off: back to normal. **(not yet headset-confirmed)**
16. "Reset All" (Tuning and Debug) puts everything back.

## Works with

- **RSQ Saber:** saber in the main hand, shield in the off. Saber Over Shield widens the block. Either load
  order, either absent.
- **RSQ SlowMo:** the Perfect Block Slow-Mo option.
- **RSQ Tactical Rig:** with the shield on your back (Take It From: back or neck) the rig keeps its off-shoulder
  holster. With "Draw With Use" off the shoulder is the rig's.
- **RSQ Score:** blocks, perfect blocks, turned shots and disc kills pay bonuses.
- **RSQ HP Bars:** a locked monster shows the "locked" marker; hit-stop shows the frozen marker.
- **Gun Bonsai with the RSQ Gun Bonsai VR patch:** the ShieldSaw levels up: Broadening, Lockstep, Bulwark,
  Rebound, Battering Ram, Ricochet, Meat Grinder, Hunter's Return. Without the patch nothing changes.
- **Brutal Doom VR (BD22Q):** its off-hand hands give way to the shield; flick reload with a gun in the main
  hand and the shield in the off follows BD22Q's flick setting.
- **RSQ Accessibility:** its comfort, colour-blind and gesture settings. Inert without it.

## Known limits / open issues

- Not felt in a headset: the flick throw on the trigger alone, Use as the lock button, rumble strengths, throw
  speed 60.
- The grind now runs every tic while revved: a real cost increase on Quest.
- The grind follows the plate's real path, so walking fast may read as the grind reaching backwards.
- A returned bullet is fired by a helper, so co-op friendly-fire rules do not apply to it, and Gun Bonsai cannot
  credit its damage.
- Planting the shield in the floor: not built (owner said no).
- RSQ Accessibility's Steady Hands is not read by this mod's code (the handoff lists ShieldSaw throw aim as
  still to wire).
- Where Ermac's first shield mesh came from, and where the hand and sounds came from before Rusted Legacy, is
  not recorded.

## Credits

From the old README, unchanged:

**Where it comes from.** The shield saw is id Software's: the weapon of *Doom: The Dark Ages*
(2025). Ermac brought it to Doom VR first, in his mod
[Rusted Legacy](https://github.com/iAmErmac/rusted-legacy), and this mod started from his version.
The meshes, in Ermac's own words (his conversation with the project owner, 2026-10-27): he worked
on two shield models. The first took him about three days to make work; the second was ripped from
the game, and he separated its parts in a day. This pack carries two shield meshes --
`shield.md3` (the held shield: holder, bolt, handle, back, rim) and `shieldsaw.md3` (the HD shield
front with its separate saw-blade parts) -- and which of his two each one is, and where the first
came from, is not recorded here. The ripped one is id Software's mesh, and the MIT licence of his
Rusted Legacy code (`models/hand/LICENSE_RustedLegacy_MIT.txt`) does not make it MIT. The hand
that holds it and the sounds come with Rusted Legacy's ShieldSaw; where they came from before that
is not recorded here either.

- Saw voice and block sparks come from RS_CombatFX (chainsaw archetype).
- **id Software** -- the shield saw itself, from *Doom: The Dark Ages*: its design, and the mesh
  Ermac ripped from the game.
- **Ermac** ([Rusted Legacy](https://github.com/iAmErmac/rusted-legacy), MIT code) -- brought the
  shield saw to Doom VR first; his two shield models (the first about three days' work to make
  work, the second a game rip whose parts he separated); the version this mod started from, with
  its hand model and sounds.
- **QuestZDoom** (Emawind, Team Beef) -- the engine and its off-hand weapon and attack-pose API.
- President_Koopa -- this standalone Quest version: its design, its testing on the headset, and
  the direction of every change.

SNDINFO: "RS_ShieldSawQ sounds. Lumps are Ermac's; the aliases are ours."
