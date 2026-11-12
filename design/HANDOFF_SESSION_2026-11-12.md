# Session handoff, 2026-11-12 (night of 11-11)

Owner's notes of 11-11 23:56, worked in a cloud session with the QuestZDoom 17.3 rig from `RSQ_Meshturbator/rig/bin`
(prebuilt, qzd17.3 9afc750) on his full order (doom2, TUD No End In Sight, LegenDoom 3.0, brutal22test6, voxel pack,
BD22 VR 2.0.4i, XMVE, LOB, Champions, No More Hitscans, Universal Entropy, Spawn Adjuster, the Environmental set,
MK Crits, Regen Shield, Shotgun Spawner, Gun Bonsai 0.10.6, the 21 RSQ pk3s). Every item below loaded with no script
error from an RSQ pack. All of it is RIG ONLY, not headset-confirmed. The rig has no sound.

## Done
- Wheel: the BD pistol's card shows its voxel (BD22 VR lends it through MODELDEF, now measured too); Flat Ring Up To
  defaults to 99 (a saved 10 is moved once, cfg gen 31); Data Sheet Size goes to 4.0.
- Score: Down 10 -> 13 (saved 10 moved once, cfgver 2).
- Miniboss + SlowMo: the meter and the two bars draw as Meter Size + 0.3.
- Whip: a heavy crack is always an MK Crits critical hit (rsqwp_whip_hardcrit); on a rope, fire lets go and alt-fire
  reels (rsqwp_rope_fire). The owner has PARKED the whip's direction: do not redesign it without him.
- SlowMo DOWN: the bar is the DEATH IN clock (thirds of the Clock; no refill on a target kill; Bar Step row gone);
  the eye keeps its height in a liquid's foot clip (MTO Liquids); LiveReverb only while DOWN (rsqsm_down_reverb).
- VisualRewards: words and HP bar stay under the ceiling; a legendary fist drop wears a fist mesh (look not confirmed).

## Not reproduced / open
- Holsters while DOWN: on the rig the right hip hovers, holsters and draws the same standing and DOWN, both crouch
  modes. The hips are below the floor while DOWN. Ask the owner to try Lower View When Down off.
- "Sometimes we don't get up": not pinned. Needs his log with rsqsm_debug on.
- LegenDoom's Gun Smoke / Casings / Bullet Puffs / Recoil settings are never read by BD22 VR: nothing to change.

## Next (owner: "all at your discretion")
- GunCards: cards animated like the SlowMo bars (toggle, on); level-up cards out of the way; rogue voxels (his image).
- The legendary power on the Gun Bonsai VR card; legendary drops tied to minibosses; bits.
