# RSQ_Grapple (Radiant Silvergun Quest suite)

The owner's grappling hook for QuestZDoom 17.3 VR, on doom2 -> brutal22test6 -> BD_VoxelPack -> BD22Q r7 (and vanilla monsters, with or without Cheello's Voxel Doom II).

`jp_original/` is the source material: jp_grapple.pk3 (the hook from jpalomo's mod pack, parent missing), kept unmodified for its art (OCLW/CCLW claw, tenda0) and sounds (dschain, dsswish, dspulchn, dsmtalht, dsmeatht). The JP default look and sound come from here. It is not loaded as-is.

## Owner's brief (10-27)
- Fires from either hand: two binds, Fire Hook (Main) and Fire Hook (Off); bound to stick clicks by the owner. Own commands (netevent / KEYCONF aliases), never +user1-4 (BD22Q uses all four).
- Hook into a monster: by default it slides to you. Option: Yank, which throws it through the air in an arc like Distance Grab (RS WorldHands flight), with optional tumble.
- Geometry interaction (Distance Grab has none): Indiana Jones across gaps -- swing, reel, release.
- Hook / whip / rope combo if it can be done; otherwise a great hook. JP art and sound are the defaults; RS_CombatFX and RS_Ballistics give other options.
- Vanilla monsters and Cheello's voxels must work, not only Brutal Doom.
- Slow motion (RSQ_SlowMo) must not exaggerate the physics (ShieldSaw's bash flings monsters a mile in slow-mo).

## Split between the two builders
- core (branch agent-core): the mod skeleton, binds, firing from each hand, the hook projectile, rope drawing, geometry latch, swing/reel/release, monster default slide, JP defaults, menu.
- monster (branch agent-monster): zscript/rsqgr/monster.zs (Yank arc + tumble, vanilla/BD/voxel monsters), zscript/rsqgr/whip.zs (whip), zscript/rsqgr/looks.zs (JP / CombatFX / Ballistics look+sound sets).
- The seam, owned by core, stubbed until monster lands:
    class RSQGR_Monster  static void OnHooked(Actor victim, PlayerPawn pmo, int hand, Vector3 hookPos)  -- called once when the hook bites a monster
                         static bool  Tick(Actor victim, PlayerPawn pmo, int hand)                     -- each tic while hooked; false = let go
                         static void OnRelease(Actor victim, PlayerPawn pmo, int hand)
    class RSQGR_Looks    static String Sound(Name what) / static Name Sprite(Name what) / static void Spark(Vector3 at, Name what)

## The whip (PROJECT WHIP, 2026-10-30)
**Options → Radiant Silvergun Options → RSQ Grapple → Whip: On.** The two hook binds become a bullwhip, one per hand.

- **A real whip.** The thong is simulated (Eye of the Temple's method: links with mass that thin toward the tip), so it
  hangs, trails, loops and cracks from how you move your arm. A lazy swing never cracks; lift and snap the forearm, or
  throw it side-arm, and the loop runs down to the popper and cracks where it arrives.
- **Whip Style.** *Real*: hold the bind and the whip uncoils from that hand; let go and it rolls up. *Assist*: a press
  throws a lash for you at what you point at.
- **Whip Aim.** *Free*: the crack hits what it touches. *Assist* (default): what is nearest the tip. *Lock*: point the
  other hand and hold the whip hand's alt-fire (your gun's alt-fire is not used while a whip is out); a ring of sparks
  marks the lock; crack and the whip flies to it (~15 m). Keep the whip button held on a locked monster to leash it.
- **What a crack does.** Damage and a stun that breaks off the monster's attack; throws a switch it lands on; flicks a
  loose pickup to you.
- **Edges.** A lash that catches a beam, a doorway head or a ledge lip wraps round it and becomes the hook's rope: hold
  to reel, push the stick to pump, haul down on the whip in the air to pump, climb it hand over hand (Grab Rope), tap to
  let go and fly (your speed carries on landing). Reel up to a ledge lip -- or slap a free hand on it with Grab -- and
  you **mantle** up and over.
- Settings for all of it are on the RSQ Grapple page and in Tuning and Debug (Whip Length, Crack Speed, Aim Reach, Arm Pump).
