# 1.0 list: status (2026-11-06, morning)

Everything below is **rig only, not headset-confirmed** unless it says otherwise. The rig is the Linux QuestZDoom 17.3
build (RSQ_WeaponDepot tools/rig) with Freedoom 2 standing in for doom2.wad.

**Final check (11-06):** Freedoom 2 -> brutal22test6 -> BD_VoxelPack -> BD22 VR 2.0.3y -> XMVE 04-07 -> all 19 RSQ
pk3s (Gun Bonsai VR left out: Gun Bonsai itself isn't here). MAP01 loaded and ran 680 tics with a Bossfight call-in,
quit cleanly. Script errors: only BD_VoxelPack's 4 voxeldef lines. Warnings from our packs: Miniboss's 2 old ones.

## Done

| Item | What was done | Commit |
|---|---|---|
| Wheel: ShieldSaw / Saber / Whip / Grenade picks | ShieldSaw always lands in the off hand (drawn through ShieldSaw itself: that was the bug), the others in the main hand, whichever hand picks | aa1beb39 |
| Flare throw | Grenade's control: trigger holds, let go mid-swing throws; trigger only (grip does nothing) | 31e0307a, be1539ad |
| Miniboss tethers | Original Minibosses! trail (30 plasma beads per thrall), then optimised: same look byte for byte, about half the cost | f03b469c, 76bed466 |
| Distance Grab on flares; flare damage and fire | Landed flares grabbable; 4 on hit, with BD humans + imps burn (90 over 5 s, kills BD's imp); boosted monsters below 25% | 31e0307a, be1539ad |
| Off-hand weapons (axe, offhand versions) | Pickup gives both versions (loaded); anything entering a hand becomes that hand's version; Wheel shows one card; Rig holsters them | 2.0.3y (BD22 71b8b3c), aa1beb39 |
| BD22 shotgun shell on full-load pump | No shell (shown on real BD22) | BD22 71b8b3c |
| Graveyards menu | Radiant Silvergun Options -> RSQ Graveyards, Graveyard's own row hidden | 24c58374 |
| More Lights credit | Credited (SnakieJakie, permission to use); your merge lives in Glow's GLDEFS | 4c14bd40 |
| DarkDoomZ flashlight | "Takes Over" option, and DarkDoomZ's flashlight rewritten into ours (zlib, credited); rows grey out by Light Style | 31e0307a, be1539ad, 734098c9 |
| More slow-mo triggers | Grenade Blast, Over-Under Blast, Low Health, Reload When (all off). The near-death "Second Wind" idea: not built (design talk) | 4c14bd40 |
| Shoot out flares | "Shoot Out Flares" row (off) | 31e0307a |
| Every blow works switches | Punches, Melee shove, whip crack/snag; BD22 pistol whip and butt strike; by line special, so custom switch textures work the same | 0ef1ee17, BD22 |
| Wheel spacing / font | JFO font, proportional spacing | aa1beb39 |
| Wheel: one fist | One fist card, the picking hand gets its own fist | aa1beb39 |
| ShieldSaw next/prev, blood | Option (off); revving throws the monster's own blood | 0ef1ee17 |
| Holsters | Holster lock: Wheel alt-fire locks a holstered gun; a locked gun always goes home (on). Replaced 11-07 by holster assignment and the Wheel's holster web (see below) | aa1beb39 |
| Gun Cards | Wider small-card sliders, No Background, Card Glow Off/Quest/PCVR, a card on every weapon (Always On already existed) | 4c14bd40 |
| Distance Grab throws | No drop at your feet while walking; no backwards throws | 31e0307a |
| Our grenade replaces BD22's | Option on both sides (off) | 0ef1ee17, BD22 |
| Uppercut kicks barrels; no automatic punches | Option (off); Melee's hands never auto-punch; BD22 "No Trigger Punch" (on) and no off-trigger jab | 0ef1ee17, BD22 |
| Glow: Randomize Current Look | Menu row | f03b469c |
| Wheel freeze time | "Freeze Time While Open" (off) | aa1beb39 |
| SlowMo stored bar | Stored bar (left) + auto countdown (right, only while running), centred, hourglass black/brown | 4c14bd40 |
| Grapple | Rope mode pulls at jp_grapple's speed and lets go on arrival; OG (jp's hookshot) stays the default | f03b469c |
| Whip reach | One reach, 20 m (slider); "Switches First" toggle (on) | 0ef1ee17, 24c58374 |
| Butt shove | BD22: reach 60 -> 90, swing needed 3.6 -> 2.4 m/s (slider), straight shoves count; label reads "gun-butt shove" | BD22, 0ef1ee17 |
| Off-hand pistol whip | Works (opened a door on real BD22; a monster hit not shown) | BD22 |
| SCORE letters | Uniform / Wave / Chaos | 4c14bd40 |
| Bits | Blink Out (default) / Fade Out | 4c14bd40 |
| Laser Sight | Dot Only on Enemies; launcher beam bends along the arc (Arc With Beam) | 4c14bd40 |
| Keyring | Exists, shows once you carry a key; off-hand trigger opens, alt-fire + raise lifts (Keys Open Doors, off) | aa1beb39 |
| Offhand saber at start | Not a bug: Gun Bonsai VR's Two Sabers upgrade gates it | (no change) |
| Melee sprites | CvS2 and Random Sprite Rips out; your kiddolink bursts + the shezzor sheet in KOF colours | 0ef1ee17 |
| Silvergun ammo (added 11-06) | Picked-up Silvergun arrives loaded; +18 pistol rounds at start | BD22 71b8b3c |

## Since this list (to 2026-11-07; rig only, not headset-confirmed unless it says otherwise)
- Holster Lock and New Guns to Holsters are gone: holsters are assigned (Tactical Rig), set from RSQ Wheel's holster web
  (Marine / Mirror view), with BD22 VR dual-wield rules (93aad009, 9ad66b96, 71299f7b, 62b48935).
- Near-death is built: RSQ SlowMo's DOWN v3 (off by default; design/NEAR_DEATH.md), with RSQ Score's life crate from
  Bossfights and Graves Rise with no cap (121e6a57, b7fb0732, 77318218, 81be3a21, 28e68a0f).
- Distance Grab: release to throw (Swing Lets Go removed) and Barrel Lock-On; Melee's uppercut barrel goes to the lock
  (dbdcd6bc, bb48e459). SlowMo barrel cues: Barrel Multi-Kill, Chain Reaction, Barrel Near You (df790f99); Locked Barrel
  built, loads clean, NOT shown on the rig (7f0e8c95).
- The flashlight battery and its meter are built (RSQ FnF, 11-06).
- BD22 VR is now 2.0.4c. Load-only boot (11-07) on the full order (doom2 -> brutal22test6 -> LOB 1.05 -> BD_VoxelPack ->
  BD22 VR 2.0.4c -> XMVE 04-07 -> Champions -> every RSQ pk3 but Gun Bonsai VR): no script error from an RSQ pk3
  (BD_VoxelPack's 4 voxeldef lines; Miniboss's 2 old warnings). The rig's doom2.wad is a Freedoom 2 copy.

## Held for a talk (not built)
(near-death and the battery have been built since: see above) Second Wind / near-death mode, Graveyard + tombstone ideas, Legion of Bones in GBOVR, flashlight batteries (Ermac's
iAmErmac/VR-Flashlight) and a battery bar, Miniboss tier from GBOVR level / Score lives, the GBOVR and Score tree
passes, the Chainsmoker card and builds, life in the GBOVR XP bars, LegenDoom x BD22 power hooks (on hold).

## Open questions left by the lanes
- Gun Cards: more small-card control beyond the wider sliders (forward/back needs re-baked voxels)?
- SlowMo: your own timed slow-mo (cigarette, shove, parry) shows no bar unless Adrenaline is on. Want that? (Answered
  11-06: with Adrenaline off it shows the countdown bar and its line.)
- Laser: should the bent beam (Arc With Beam) be on by default?
- Numbers the HUD lane picked: Blast slow-mo 1000 ms, Low Health slow-mo 2000 ms at 25 health. (Blast Time is 3000 ms
  since the owner's 11-06 call.)
