# Near-death mode: design for approval (2026-11-06)

From the owner's words in BUGS_1.0.md (SlowMo item) and the 11-06 talk. Every choice is filled in; the owner
approves or changes lines. Nothing built yet.

**Name (owner, 11-06 17:48):** the mode is **DOWN**; getting back up is **REVIVE**.

**Home:** RSQ SlowMo owns the mode (it owns time). Score, Gun Bonsai VR, Glow In The Dark, Tactical Rig, Grenade,
VisualRewards join by name when loaded. Works alone with SlowMo only.

1. **Trigger:** a hit that would kill you holds you at 1 HP instead (any source). Order: DOWN first; only if
   you fail it does a Score life get spent (owner, 11-06).
2. **While in DOWN:** the world drops to SlowMo's deepest speed for the window; you keep normal speed
   (you need to fight). Glow In The Dark turns the map deep blood red. A heartbeat (stock Doom sound). You can't
   be killed by a single hit during the first 1 s (so the trigger hit's splash can't finish you).
3. **Window:** 6 s. A bar under the SlowMo bars counts it down, cause line "LAST STAND".
4. **Getting up:** 3 kills inside the window = **REVIVE**: the word flies past like the level-up graphic
   (VisualRewards), time returns to normal, health set to 50, or kept if the power-ups already took you above 50, every weapon you carry reloaded, +1 cigarette,
   +1 grenade (each up to its normal carry cap).
5. **Failing:** the window ends without the kills: you die (or a Score life catches you, if you have one).
6. **Repeat:** DOWN can't trigger again for 60 s after it ends (pass or fail). Option "Repeat Without Limit" (off): no cooldown at all.
7. **Gun Bonsai VR upgrades** (in the GBOVR pass): Fewer Kills Needed (3 -> 2 -> 1), Longer Window (+2 s a level),
   Auto Reload on trigger, Iron Will (2 s invulnerability on trigger), Shorter Cooldown.
8. **Score:** "DOWN" bonus for each kill inside the window; "Revive" award for getting up; Swan Song
   (already exists) unchanged.
9. **Power-up drop:** during DOWN, the kills that count drop a BD voxel power-up (the Berserk pack voxel from
   BD_VoxelPack, recoloured to read as a medkit, white with a red cross, so it is never mistaken for a berserk) that refills 25 health when touched, so the getting-up can come from the floor too.
10. **Options (Radiant Silvergun Options -> RSQ SlowMo):** DOWN on/off (on), Kills Needed (3), Window (6 s),
    Cooldown (60 s), Repeat Without Limit (off), Red Map (on), Power-Up Drops (on).
11. **Netplay:** each player's own DOWN; the world slow-down follows SlowMo's existing netplay rule.

**Approved by the owner, 11-06 17:48** (with the changes above).

**Damage numbers (VisualRewards) during DOWN (owner, 11-06):** all three, with "some life to them, colours to let
the player know this is different, or important, or part of a sequence":
- a kill count "1/3", "2/3", "3/3" pops where each counted kill lands, colours escalating along the sequence;
- "+25" on the medkit pickup, shown like the numbers' gains going to the wrist;
- the REVIVE word in the damage numbers' font (JFO), with its own standout colour.
